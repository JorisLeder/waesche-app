import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waesche_app/core/db/database.dart';
import 'package:waesche_app/core/db/photo_store.dart';
import 'package:waesche_app/core/db/wardrobe_repository.dart';
import 'package:waesche_app/core/models/garment_attributes.dart';
import 'package:waesche_app/features/household/household_package.dart';

class Device {
  Device(this.db, this.dir, DateTime Function() clock)
    : repo = WardrobeRepository(db, PhotoStore(dir), clock: clock),
      pkg = HouseholdPackage(db, PhotoStore(dir), clock: clock);

  final AppDatabase db;
  final Directory dir;
  final WardrobeRepository repo;
  final HouseholdPackage pkg;
}

void main() {
  var now = DateTime.utc(2026, 10, 1, 12);
  DateTime clock() => now;
  late Device a, b;

  Future<Device> device() async =>
      Device(AppDatabase(NativeDatabase.memory()), await Directory.systemTemp.createTemp('pkg'), clock);

  setUp(() async {
    now = DateTime.utc(2026, 10, 1, 12);
    a = await device();
    b = await device();
  });

  tearDown(() async {
    for (final d in [a, b]) {
      await d.db.close();
      await d.dir.delete(recursive: true);
    }
  });

  test('Export von A, Import auf B überträgt Personen, Teile und Fotos', () async {
    final anna = await a.repo.addPerson('Anna', 1);
    await a.repo.addItem(
      personId: anna,
      attributes: const GarmentAttributes(kategorie: 'Socke', farben: ['weiß']),
      newPhotos: [NewPhoto(Uint8List.fromList([1, 2, 3]), 'vorne')],
    );
    final zip = await a.pkg.export();
    final report = await b.pkg.import(zip);
    expect(report.personsNew, 1);
    expect(report.itemsNew, 1);
    expect(report.photosNew, 1);
    final catalog = await b.repo.loadCatalog(null);
    expect(catalog.single.personName, 'Anna');
    expect(File(catalog.single.photos.single.path).readAsBytesSync(), [1, 2, 3]);
  });

  test('erneuter Import ändert nichts', () async {
    final anna = await a.repo.addPerson('Anna', 1);
    await a.repo.addItem(personId: anna, attributes: const GarmentAttributes(kategorie: 'Hose'));
    final zip = await a.pkg.export();
    await b.pkg.import(zip);
    final again = await b.pkg.import(zip);
    expect(again.personsNew + again.personsUpdated + again.itemsNew + again.itemsUpdated, 0);
  });

  test('Änderungen und Löschungen reisen mit, neuerer Stand gewinnt', () async {
    final anna = await a.repo.addPerson('Anna', 1);
    final id = await a.repo.addItem(personId: anna, attributes: const GarmentAttributes(kategorie: 'Hose'));
    await b.pkg.import(await a.pkg.export());

    now = now.add(const Duration(hours: 1));
    await a.repo.updateItem(id, name: 'Lieblingsjeans');
    final since = DateTime.utc(2026, 10, 1, 12, 30);
    final delta = await a.pkg.export(since: since);
    final r = await b.pkg.import(delta);
    expect(r.itemsUpdated, 1);
    expect((await b.repo.loadCatalog(null)).single.name, 'Lieblingsjeans');

    now = now.add(const Duration(hours: 1));
    await a.repo.deleteItem(id);
    await b.pkg.import(await a.pkg.export(since: since));
    expect(await b.repo.loadCatalog(null), isEmpty);
  });

  test('fremde Datei wird abgelehnt', () async {
    expect(() => b.pkg.import(Uint8List.fromList([1, 2, 3])), throwsA(anything));
  });
}
