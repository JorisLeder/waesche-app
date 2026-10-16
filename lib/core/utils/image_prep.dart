import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Bildaufbereitung nach der Aufnahme: Ausrichtung übernehmen, auf den
/// quadratischen Zielrahmen zuschneiden, verkleinern, als JPEG speichern.
class ImagePrep {
  ImagePrep._();

  /// Anteil der kürzeren Bildseite, den der Zielrahmen im Sucher abdeckt.
  static const frameFraction = 0.9;

  /// Speichergröße der Fotos (Referenz und Scan).
  static const storeSize = 1024;

  /// Größe des Bildes, das das VLM bekommt (Bild-Tokens und Tempo).
  static const vlmSize = 768;

  static Future<Uint8List> cropToFrame(Uint8List jpeg, {int size = storeSize, int quality = 88}) =>
      Isolate.run(() => _cropToFrame(jpeg, size, quality));

  static Future<Uint8List> resize(Uint8List jpeg, {required int size, int quality = 85}) =>
      Isolate.run(() => _resize(jpeg, size, quality));

  static Uint8List _cropToFrame(Uint8List jpeg, int size, int quality) {
    final decoded = img.decodeImage(jpeg);
    if (decoded == null) throw const FormatException('Bild konnte nicht gelesen werden');
    final o = img.bakeOrientation(decoded);
    final side = ((o.width < o.height ? o.width : o.height) * frameFraction).round();
    final crop = img.copyCrop(o, x: (o.width - side) ~/ 2, y: (o.height - side) ~/ 2, width: side, height: side);
    final out = side > size ? img.copyResize(crop, width: size, height: size, interpolation: img.Interpolation.average) : crop;
    return img.encodeJpg(out, quality: quality);
  }

  static Uint8List _resize(Uint8List jpeg, int size, int quality) {
    final decoded = img.decodeImage(jpeg);
    if (decoded == null) throw const FormatException('Bild konnte nicht gelesen werden');
    if (decoded.width <= size && decoded.height <= size) return jpeg;
    final scale = size / (decoded.width > decoded.height ? decoded.width : decoded.height);
    final out = img.copyResize(
      decoded,
      width: (decoded.width * scale).round(),
      height: (decoded.height * scale).round(),
      interpolation: img.Interpolation.average,
    );
    return img.encodeJpg(out, quality: quality);
  }
}
