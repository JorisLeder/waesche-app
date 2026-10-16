import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Gemeinsame Spalten für sync-fähige Tabellen: UUID, Zeitstempel und
/// Lösch-Markierung (gelöscht wird nie physisch, damit Löschungen per
/// Haushaltspaket/Sync weitergegeben werden können).
mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PersonRow')
class Persons extends Table with SyncColumns {
  TextColumn get name => text()();
  IntColumn get color => integer()();
}

@DataClassName('ItemRow')
class Items extends Table with SyncColumns {
  TextColumn get personId => text().references(Persons, #id)();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get kategorie => text()();
  TextColumn get farben => text().withDefault(const Constant('[]'))(); // JSON-Liste
  TextColumn get muster => text()();
  TextColumn get materialOptik => text()();
  TextColumn get laengeSchnitt => text()();
  TextColumn get logoMarke => text().withDefault(const Constant(''))();
  TextColumn get aufdruckText => text().withDefault(const Constant(''))();
  TextColumn get besondereMerkmale => text().withDefault(const Constant(''))();
  TextColumn get markierung => text().withDefault(const Constant(''))();
  TextColumn get vlmRaw => text().withDefault(const Constant(''))();
}

@DataClassName('PhotoRow')
class ItemPhotos extends Table with SyncColumns {
  TextColumn get itemId => text().references(Items, #id)();

  /// Dateiname im Foto-Verzeichnis (relativ, da sich der App-Pfad ändern kann).
  TextColumn get fileName => text()();

  /// vorne / hinten / detail / etikett / scan
  TextColumn get art => text()();
}

/// Lokaler Cache, wird weder exportiert noch synchronisiert.
@DataClassName('EmbeddingRow')
class PhotoEmbeddings extends Table {
  TextColumn get photoId => text().references(ItemPhotos, #id)();
  TextColumn get modelId => text()();
  IntColumn get variant => integer()(); // 0 = Original, >0 = Augmentierung
  BlobColumn get vector => blob()();

  @override
  Set<Column<Object>> get primaryKey => {photoId, modelId, variant};
}

@DataClassName('ScanLogRow')
class ScanLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get time => dateTime()();
  TextColumn get itemId => text().nullable()();
  TextColumn get stage => text()();
  IntColumn get rounds => integer().withDefault(const Constant(0))();
  IntColumn get durationMs => integer()();
  BoolColumn get confirmed => boolean().withDefault(const Constant(false))();
  TextColumn get device => text().withDefault(const Constant(''))();
  TextColumn get backend => text().withDefault(const Constant(''))();
  TextColumn get detail => text().withDefault(const Constant(''))();
}

@DataClassName('SettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [Persons, Items, ItemPhotos, PhotoEmbeddings, ScanLogs, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'waeschewer'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<String?> getSetting(String key) async =>
      (await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setSetting(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));
}
