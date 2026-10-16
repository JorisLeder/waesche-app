import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waesche_app/core/db/database.dart';
import 'package:waesche_app/core/db/photo_store.dart';
import 'package:waesche_app/core/db/wardrobe_repository.dart';
import 'package:waesche_app/core/models/garment_attributes.dart';

import 'support/fakes.dart';

void main() {
  late AppDatabase db;
  late WardrobeRepository repo;
  late Directory tmp;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tmp = await Directory.systemTemp.createTemp('waesche_test');
    repo = WardrobeRepository(db, PhotoStore(tmp));
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  test('Teil mit Foto anlegen und als Katalog mit Embeddings laden', () async {
    final anna = await repo.addPerson('Anna', 0xFFE91E63);
    final embedder = FakeEmbedder({
      7: [1, 0, 0],
    });
    final id = await repo.addItem(
      personId: anna,
      attributes: const GarmentAttributes(kategorie: 'Socke', farben: ['weiß'], muster: 'gerippt'),
      name: 'Laufsocke',
      newPhotos: [NewPhoto(Uint8List.fromList([7, 1, 2]), 'vorne')],
      embedder: embedder,
    );
    final catalog = await repo.loadCatalog(embedder.modelId);
    expect(catalog, hasLength(1));
    final c = catalog.single;
    expect(c.id, id);
    expect(c.personName, 'Anna');
    expect(c.attributes.farben, ['weiß']);
    expect(c.photos.single.embeddings.single, [1, 0, 0]);
    expect(File(c.photos.single.path).existsSync(), isTrue);
  });

  test('Löschen markiert nur und blendet aus', () async {
    final anna = await repo.addPerson('Anna', 1);
    final id = await repo.addItem(personId: anna, attributes: const GarmentAttributes(kategorie: 'Hose'));
    await repo.deleteItem(id);
    expect(await repo.loadCatalog(null), isEmpty);
    final row = await (db.select(db.items)..where((t) => t.id.equals(id))).getSingle();
    expect(row.deletedAt, isNotNull);
  });

  test('Person löschen entfernt auch ihre Teile aus dem Katalog', () async {
    final anna = await repo.addPerson('Anna', 1);
    final ben = await repo.addPerson('Ben', 2);
    await repo.addItem(personId: anna, attributes: const GarmentAttributes(kategorie: 'Hose'));
    await repo.addItem(personId: ben, attributes: const GarmentAttributes(kategorie: 'Hose'));
    await repo.deletePerson(anna);
    final catalog = await repo.loadCatalog(null);
    expect(catalog.map((c) => c.personName), ['Ben']);
  });

  test('fehlende Embeddings werden nachberechnet', () async {
    final anna = await repo.addPerson('Anna', 1);
    await repo.addItem(
      personId: anna,
      attributes: const GarmentAttributes(kategorie: 'Socke'),
      newPhotos: [NewPhoto(Uint8List.fromList([7]), 'vorne')],
    );
    final embedder = FakeEmbedder({
      7: [0, 1, 0],
    });
    expect(await repo.ensureEmbeddings(embedder), 1);
    expect(await repo.ensureEmbeddings(embedder), 0);
    final c = (await repo.loadCatalog(embedder.modelId)).single;
    expect(c.photos.single.embeddings, isNotEmpty);
  });

  test('Einstellungen speichern', () async {
    expect(await db.getSetting('x'), isNull);
    await db.setSetting('x', '1');
    await db.setSetting('x', '2');
    expect(await db.getSetting('x'), '2');
  });
}
