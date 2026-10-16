import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:waesche_app/ai/mobilenet_embedder.dart';
import 'package:waesche_app/ai/vector_math.dart';

void main() {
  Uint8List jpeg(int w, int h) {
    final im = img.Image(width: w, height: h);
    img.fill(im, color: img.ColorRgb8(200, 100, 50));
    return img.encodeJpg(im);
  }

  test('Vorverarbeitung liefert 224x224x3 Werte in 0..1', () {
    final t = MobileNetEmbedder.preprocess(jpeg(640, 480));
    expect(t, hasLength(1));
    expect(t.first.length, 224 * 224 * 3);
    expect(t.first.every((v) => v >= 0 && v <= 1), isTrue);
    expect(t.first[0], closeTo(200 / 255, 0.05));
  });

  test('Augmentierung erzeugt fünf Varianten', () {
    expect(MobileNetEmbedder.preprocess(jpeg(300, 500), augment: true), hasLength(5));
  });

  test('Vektor-Hilfen', () {
    final v = l2Normalize([3, 4]);
    expect(v[0], closeTo(0.6, 1e-6));
    expect(cosineSimilarity([1, 0], [0, 1]), 0);
    expect(bytesToVector(vectorToBytes(Float32List.fromList([1.5, -2]))), [1.5, -2]);
    expect(maxSimilarity([1, 0], []), isNull);
  });
}
