import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Ablage der Fotos als Dateien im App-Verzeichnis. In der Datenbank steht
/// nur der Dateiname, weil sich der absolute App-Pfad ändern kann.
class PhotoStore {
  PhotoStore(this.directory);

  final Directory directory;

  static Future<PhotoStore> open() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'photos'));
    await dir.create(recursive: true);
    return PhotoStore(dir);
  }

  String pathOf(String fileName) => p.join(directory.path, fileName);

  File fileOf(String fileName) => File(pathOf(fileName));

  Future<void> write(String fileName, Uint8List bytes) => fileOf(fileName).writeAsBytes(bytes, flush: true);

  Future<Uint8List?> read(String fileName) async {
    final f = fileOf(fileName);
    return await f.exists() ? f.readAsBytes() : null;
  }

  Future<bool> exists(String fileName) => fileOf(fileName).exists();

  Future<void> delete(String fileName) async {
    final f = fileOf(fileName);
    if (await f.exists()) await f.delete();
  }
}
