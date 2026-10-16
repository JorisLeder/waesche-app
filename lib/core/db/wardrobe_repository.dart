import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../ai/engines.dart';
import '../../ai/vector_math.dart';
import '../models/catalog_item.dart';
import '../models/garment_attributes.dart';
import 'database.dart';
import 'photo_store.dart';

const _uuid = Uuid();

String newId() => _uuid.v4();

/// Ein Teil mit Person und Fotos für Listen und Formulare.
class ItemView {
  const ItemView({required this.item, required this.person, required this.photos});

  final ItemRow item;
  final PersonRow person;
  final List<PhotoRow> photos;

  GarmentAttributes get attributes => attributesOf(item);
}

GarmentAttributes attributesOf(ItemRow r) => GarmentAttributes(
  kategorie: r.kategorie,
  farben: (jsonDecode(r.farben) as List).cast<String>(),
  muster: r.muster,
  materialOptik: r.materialOptik,
  laengeSchnitt: r.laengeSchnitt,
  logoMarke: r.logoMarke,
  aufdruckText: r.aufdruckText,
  besondereMerkmale: r.besondereMerkmale,
);

/// Neues Foto zum Speichern (bereits zugeschnitten).
class NewPhoto {
  const NewPhoto(this.bytes, this.art);

  final Uint8List bytes;
  final String art;
}

class SimilarItem {
  const SimilarItem(this.view, this.imageSim, this.reason);

  final ItemView view;
  final double? imageSim;
  final String reason;
}

class WardrobeRepository {
  WardrobeRepository(this.db, this.photos, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final AppDatabase db;
  final PhotoStore photos;
  final DateTime Function() _now;

  // ---------------------------------------------------------------- Personen

  Stream<List<PersonRow>> watchPersons() =>
      (db.select(db.persons)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .watch();

  Future<List<PersonRow>> persons() =>
      (db.select(db.persons)..where((t) => t.deletedAt.isNull())).get();

  Future<String> addPerson(String name, int color) async {
    final id = newId();
    final now = _now();
    await db.into(db.persons).insert(PersonsCompanion.insert(
      id: id,
      name: name.trim(),
      color: color,
      createdAt: now,
      updatedAt: now,
    ));
    return id;
  }

  Future<void> updatePerson(String id, {String? name, int? color}) =>
      (db.update(db.persons)..where((t) => t.id.equals(id))).write(PersonsCompanion(
        name: name == null ? const Value.absent() : Value(name.trim()),
        color: color == null ? const Value.absent() : Value(color),
        updatedAt: Value(_now()),
      ));

  /// Löscht die Person und ihre Teile (als Markierung).
  Future<void> deletePerson(String id) => db.transaction(() async {
    final now = _now();
    await (db.update(db.persons)..where((t) => t.id.equals(id)))
        .write(PersonsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
    await (db.update(db.items)..where((t) => t.personId.equals(id) & t.deletedAt.isNull()))
        .write(ItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  });

  // ------------------------------------------------------------------- Teile

  Stream<List<ItemView>> watchItems() {
    final q = db.select(db.items).join([innerJoin(db.persons, db.persons.id.equalsExp(db.items.personId))])
      ..where(db.items.deletedAt.isNull() & db.persons.deletedAt.isNull())
      ..orderBy([OrderingTerm(expression: db.persons.name), OrderingTerm(expression: db.items.kategorie)]);
    return q.watch().asyncMap((rows) async {
      final ids = rows.map((r) => r.readTable(db.items).id).toList();
      final photosByItem = await _photosFor(ids);
      return [
        for (final r in rows)
          ItemView(
            item: r.readTable(db.items),
            person: r.readTable(db.persons),
            photos: photosByItem[r.readTable(db.items).id] ?? const [],
          ),
      ];
    });
  }

  Future<ItemView?> item(String id) async {
    final q = db.select(db.items).join([innerJoin(db.persons, db.persons.id.equalsExp(db.items.personId))])
      ..where(db.items.id.equals(id));
    final r = await q.getSingleOrNull();
    if (r == null) return null;
    final ph = await _photosFor([id]);
    return ItemView(item: r.readTable(db.items), person: r.readTable(db.persons), photos: ph[id] ?? const []);
  }

  Future<Map<String, List<PhotoRow>>> _photosFor(List<String> itemIds) async {
    if (itemIds.isEmpty) return {};
    final rows = await (db.select(db.itemPhotos)
          ..where((t) => t.itemId.isIn(itemIds) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
    final out = <String, List<PhotoRow>>{};
    for (final r in rows) {
      out.putIfAbsent(r.itemId, () => []).add(r);
    }
    return out;
  }

  ItemsCompanion _attrCompanion(GarmentAttributes a) => ItemsCompanion(
    kategorie: Value(a.kategorie),
    farben: Value(jsonEncode(a.farben)),
    muster: Value(a.muster),
    materialOptik: Value(a.materialOptik),
    laengeSchnitt: Value(a.laengeSchnitt),
    logoMarke: Value(a.logoMarke),
    aufdruckText: Value(a.aufdruckText),
    besondereMerkmale: Value(a.besondereMerkmale),
  );

  Future<String> addItem({
    required String personId,
    required GarmentAttributes attributes,
    String name = '',
    String markierung = '',
    String vlmRaw = '',
    List<NewPhoto> newPhotos = const [],
    EmbeddingEngine? embedder,
  }) async {
    final id = newId();
    final now = _now();
    await db.into(db.items).insert(_attrCompanion(attributes).copyWith(
      id: Value(id),
      personId: Value(personId),
      name: Value(name.trim()),
      markierung: Value(markierung.trim()),
      vlmRaw: Value(vlmRaw),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    for (final ph in newPhotos) {
      await addPhoto(id, ph, embedder: embedder, augment: true);
    }
    return id;
  }

  Future<void> updateItem(
    String id, {
    String? personId,
    GarmentAttributes? attributes,
    String? name,
    String? markierung,
  }) {
    var c = attributes == null ? const ItemsCompanion() : _attrCompanion(attributes);
    c = c.copyWith(
      personId: personId == null ? const Value.absent() : Value(personId),
      name: name == null ? const Value.absent() : Value(name.trim()),
      markierung: markierung == null ? const Value.absent() : Value(markierung.trim()),
      updatedAt: Value(_now()),
    );
    return (db.update(db.items)..where((t) => t.id.equals(id))).write(c);
  }

  Future<void> deleteItem(String id) {
    final now = _now();
    return (db.update(db.items)..where((t) => t.id.equals(id)))
        .write(ItemsCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  /// Speichert ein Foto und (falls ein Embedder da ist) seine Embeddings.
  /// Wird auch von der Lernschleife genutzt (art = 'scan').
  Future<String> addPhoto(String itemId, NewPhoto photo, {EmbeddingEngine? embedder, bool augment = false}) async {
    final id = newId();
    final fileName = '$id.jpg';
    await photos.write(fileName, photo.bytes);
    final now = _now();
    await db.into(db.itemPhotos).insert(ItemPhotosCompanion.insert(
      id: id,
      itemId: itemId,
      fileName: fileName,
      art: photo.art,
      createdAt: now,
      updatedAt: now,
    ));
    await (db.update(db.items)..where((t) => t.id.equals(itemId))).write(ItemsCompanion(updatedAt: Value(now)));
    if (embedder != null) {
      final vectors = await embedder.embed(photo.bytes, augment: augment);
      await _storeEmbeddings(id, embedder.modelId, vectors);
    }
    return id;
  }

  Future<void> deletePhoto(String photoId) {
    final now = _now();
    return (db.update(db.itemPhotos)..where((t) => t.id.equals(photoId)))
        .write(ItemPhotosCompanion(deletedAt: Value(now), updatedAt: Value(now)));
  }

  Future<void> _storeEmbeddings(String photoId, String modelId, List<Float32List> vectors) async {
    await db.batch((b) {
      for (var i = 0; i < vectors.length; i++) {
        b.insert(
          db.photoEmbeddings,
          PhotoEmbeddingsCompanion.insert(photoId: photoId, modelId: modelId, variant: i, vector: vectorToBytes(vectors[i])),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Berechnet fehlende Embeddings (z. B. nach einem Import). Liefert die Anzahl.
  Future<int> ensureEmbeddings(EmbeddingEngine embedder, {void Function(int done, int total)? onProgress}) async {
    final all = await (db.select(db.itemPhotos)..where((t) => t.deletedAt.isNull())).get();
    final have = await (db.selectOnly(db.photoEmbeddings, distinct: true)
          ..addColumns([db.photoEmbeddings.photoId])
          ..where(db.photoEmbeddings.modelId.equals(embedder.modelId)))
        .map((r) => r.read(db.photoEmbeddings.photoId)!)
        .get();
    final haveSet = have.toSet();
    final missing = all.where((p) => !haveSet.contains(p.id)).toList();
    var done = 0;
    for (final ph in missing) {
      final bytes = await photos.read(ph.fileName);
      if (bytes != null) {
        final vectors = await embedder.embed(bytes, augment: ph.art != 'scan');
        await _storeEmbeddings(ph.id, embedder.modelId, vectors);
      }
      done++;
      onProgress?.call(done, missing.length);
    }
    return missing.length;
  }

  /// Katalog für die Pipeline: alle aktiven Teile mit Fotos und Embeddings.
  Future<List<CatalogItem>> loadCatalog(String? embeddingModelId) async {
    final q = db.select(db.items).join([innerJoin(db.persons, db.persons.id.equalsExp(db.items.personId))])
      ..where(db.items.deletedAt.isNull() & db.persons.deletedAt.isNull());
    final rows = await q.get();
    final ids = rows.map((r) => r.readTable(db.items).id).toList();
    final photosByItem = await _photosFor(ids);
    final allPhotoIds = photosByItem.values.expand((l) => l).map((p) => p.id).toList();
    final embByPhoto = <String, List<Float32List>>{};
    if (embeddingModelId != null && allPhotoIds.isNotEmpty) {
      final embs = await (db.select(db.photoEmbeddings)
            ..where((t) => t.modelId.equals(embeddingModelId) & t.photoId.isIn(allPhotoIds)))
          .get();
      for (final e in embs) {
        embByPhoto.putIfAbsent(e.photoId, () => []).add(bytesToVector(e.vector));
      }
    }
    return [
      for (final r in rows)
        () {
          final it = r.readTable(db.items);
          final pe = r.readTable(db.persons);
          return CatalogItem(
            id: it.id,
            personId: pe.id,
            personName: pe.name,
            personColor: pe.color,
            name: it.name,
            attributes: attributesOf(it),
            markierung: it.markierung,
            photos: [
              for (final ph in photosByItem[it.id] ?? const <PhotoRow>[])
                ReferencePhoto(
                  id: ph.id,
                  path: photos.pathOf(ph.fileName),
                  art: ph.art,
                  embeddings: embByPhoto[ph.id] ?? const [],
                ),
            ],
          );
        }(),
    ];
  }

  // -------------------------------------------------------------- Scan-Log

  Future<void> logScan({
    required String? itemId,
    required String stage,
    required int rounds,
    required int durationMs,
    required bool confirmed,
    String device = '',
    String backend = '',
    String detail = '',
  }) => db.into(db.scanLogs).insert(ScanLogsCompanion.insert(
    time: _now(),
    itemId: Value(itemId),
    stage: stage,
    rounds: Value(rounds),
    durationMs: durationMs,
    confirmed: Value(confirmed),
    device: Value(device),
    backend: Value(backend),
    detail: Value(detail),
  ));

  Future<List<ScanLogRow>> recentScans({int limit = 50}) =>
      (db.select(db.scanLogs)
            ..orderBy([(t) => OrderingTerm(expression: t.time, mode: OrderingMode.desc)])
            ..limit(limit))
          .get();
}
