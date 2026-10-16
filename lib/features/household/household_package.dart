import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/db/photo_store.dart';
import '../../core/sync/merge.dart';

class ImportReport {
  const ImportReport({
    required this.personsNew,
    required this.personsUpdated,
    required this.itemsNew,
    required this.itemsUpdated,
    required this.photosNew,
    required this.photosUpdated,
  });

  final int personsNew, personsUpdated, itemsNew, itemsUpdated, photosNew, photosUpdated;

  String describe() =>
      'Personen: $personsNew neu, $personsUpdated aktualisiert\n'
      'Teile: $itemsNew neu, $itemsUpdated aktualisiert\n'
      'Fotos: $photosNew neu, $photosUpdated aktualisiert';
}

/// Haushaltspaket: ZIP mit manifest.json (Personen, Teile, Fotos) und den
/// Fotodateien. Embeddings reisen nicht mit, sie werden lokal neu berechnet.
class HouseholdPackage {
  HouseholdPackage(this.db, this.photos, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final AppDatabase db;
  final PhotoStore photos;
  final DateTime Function() _now;

  static const format = 'waeschewer-paket';
  static const version = 1;
  static const lastExportKey = 'lastExportAt';

  Future<DateTime?> lastExportAt() async {
    final v = await db.getSetting(lastExportKey);
    return v == null ? null : DateTime.tryParse(v);
  }

  /// Baut das Paket. Mit [since] nur Änderungen danach (plus alle Personen
  /// und die Teile, auf die geänderte Fotos verweisen, damit der Import
  /// keine Bezüge verliert).
  Future<Uint8List> export({DateTime? since}) async {
    final persons = await db.select(db.persons).get();
    var items = await db.select(db.items).get();
    var photoRows = await db.select(db.itemPhotos).get();
    if (since != null) {
      photoRows = photoRows.where((p) => p.updatedAt.isAfter(since)).toList();
      final needed = photoRows.map((p) => p.itemId).toSet();
      items = items.where((i) => i.updatedAt.isAfter(since) || needed.contains(i.id)).toList();
    }
    final archive = Archive();
    final manifest = {
      'format': format,
      'version': version,
      'exportedAt': _now().toUtc().toIso8601String(),
      'since': since?.toUtc().toIso8601String(),
      'persons': persons.map((r) => r.toJson()).toList(),
      'items': items.map((r) => r.toJson()).toList(),
      'photos': photoRows.map((r) => r.toJson()).toList(),
    };
    archive.addFile(ArchiveFile.string('manifest.json', jsonEncode(manifest)));
    for (final p in photoRows) {
      if (p.deletedAt != null) continue;
      final bytes = await photos.read(p.fileName);
      if (bytes != null) archive.addFile(ArchiveFile.noCompress('photos/${p.fileName}', bytes.length, bytes));
    }
    await db.setSetting(lastExportKey, _now().toUtc().toIso8601String());
    return ZipEncoder().encodeBytes(archive);
  }

  Future<ImportReport> import(Uint8List zipBytes) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) throw const FormatException('Kein Haushaltspaket (manifest.json fehlt).');
    final manifest = jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>;
    if (manifest['format'] != format) throw const FormatException('Unbekanntes Paketformat.');
    if ((manifest['version'] as int? ?? 0) > version) {
      throw const FormatException('Das Paket stammt aus einer neueren App-Version. Bitte die App aktualisieren.');
    }

    List<T> rows<T>(String key, T Function(Map<String, dynamic>) f) =>
        (manifest[key] as List? ?? const []).map((e) => f(e as Map<String, dynamic>)).toList();

    final inPersons = rows('persons', PersonRow.fromJson);
    final inItems = rows('items', ItemRow.fromJson);
    final inPhotos = rows('photos', PhotoRow.fromJson);

    Future<Map<String, DateTime>> localStamps<T extends Table, D>(
      TableInfo<T, D> table,
      GeneratedColumn<String> id,
      GeneratedColumn<DateTime> updatedAt,
    ) async {
      final q = db.selectOnly(table)..addColumns([id, updatedAt]);
      final r = await q.get();
      return {for (final row in r) row.read(id)!: row.read(updatedAt)!};
    }

    final pPlan = planMerge<PersonRow>(
      localUpdatedAt: await localStamps(db.persons, db.persons.id, db.persons.updatedAt),
      incoming: inPersons,
      idOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    final iPlan = planMerge<ItemRow>(
      localUpdatedAt: await localStamps(db.items, db.items.id, db.items.updatedAt),
      incoming: inItems,
      idOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );
    final phPlan = planMerge<PhotoRow>(
      localUpdatedAt: await localStamps(db.itemPhotos, db.itemPhotos.id, db.itemPhotos.updatedAt),
      incoming: inPhotos,
      idOf: (r) => r.id,
      updatedAtOf: (r) => r.updatedAt,
    );

    // Fotodateien zuerst schreiben, dann die Zeilen (Fremdschlüssel-Reihenfolge).
    for (final p in [...phPlan.toInsert, ...phPlan.toUpdate]) {
      final f = archive.findFile('photos/${p.fileName}');
      if (f != null && !await photos.exists(p.fileName)) {
        await photos.write(p.fileName, f.content);
      }
    }
    await db.transaction(() async {
      for (final r in [...pPlan.toInsert, ...pPlan.toUpdate]) {
        await db.into(db.persons).insertOnConflictUpdate(r);
      }
      for (final r in [...iPlan.toInsert, ...iPlan.toUpdate]) {
        await db.into(db.items).insertOnConflictUpdate(r);
      }
      for (final r in [...phPlan.toInsert, ...phPlan.toUpdate]) {
        await db.into(db.itemPhotos).insertOnConflictUpdate(r);
      }
    });

    return ImportReport(
      personsNew: pPlan.toInsert.length,
      personsUpdated: pPlan.toUpdate.length,
      itemsNew: iPlan.toInsert.length,
      itemsUpdated: iPlan.toUpdate.length,
      photosNew: phPlan.toInsert.length,
      photosUpdated: phPlan.toUpdate.length,
    );
  }

  /// Schreibt das Paket als Datei (zum Teilen).
  Future<File> exportToFile(Directory dir, {DateTime? since}) async {
    final bytes = await export(since: since);
    final stamp = _now().toIso8601String().substring(0, 16).replaceAll(':', '-');
    final f = File('${dir.path}/Haushaltspaket_$stamp.zip');
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }
}
