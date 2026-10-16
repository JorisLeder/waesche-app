import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_litert/flutter_litert.dart';
import 'package:image/image.dart' as img;

import 'engines.dart';
import 'vector_math.dart';

/// Vortrainiertes Bild-Embedding (MediaPipe MobileNetV3-Large, 1280-d).
///
/// Eingabe 224×224 RGB mit Werten 0..1 (laut Modell-Metadaten). Kein
/// Training: Die Vektoren werden nur verglichen (Kosinus-Ähnlichkeit).
class MobileNetEmbedder implements EmbeddingEngine {
  MobileNetEmbedder({this.assetPath = 'assets/models/mobilenet_v3_large.tflite', this.threads = 4});

  static const inputSize = 224;
  static const outputDim = 1280;

  final String assetPath;
  final int threads;
  Interpreter? _interpreter;

  /// Dauer der letzten Inferenz eines Bildes (für den Machbarkeits-Test).
  Duration lastInference = Duration.zero;

  @override
  String get modelId => 'mobilenet_v3_large_f32_v1';

  Future<Interpreter> _load() async {
    final existing = _interpreter;
    if (existing != null) return existing;
    final options = InterpreterOptions()..threads = threads;
    final i = await Interpreter.fromAsset(assetPath, options: options);
    _interpreter = i;
    return i;
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }

  @override
  Future<List<Float32List>> embed(Uint8List imageBytes, {bool augment = false}) async {
    final inputs = await Isolate.run(() => preprocess(imageBytes, augment: augment));
    final interpreter = await _load();
    final out = <Float32List>[];
    for (final input in inputs) {
      final sw = Stopwatch()..start();
      interpreter.getInputTensor(0).setTo(input.buffer.asUint8List(input.offsetInBytes, input.lengthInBytes));
      interpreter.invoke();
      final result = Float32List(outputDim);
      interpreter.getOutputTensor(0).copyTo(result);
      lastInference = sw.elapsed;
      out.add(l2Normalize(result));
    }
    return out;
  }

  /// Dekodiert, schneidet quadratisch zu und erzeugt Eingabetensoren.
  /// Mit [augment]: Original, gespiegelt, enger Zuschnitt, heller, dunkler.
  static List<Float32List> preprocess(Uint8List bytes, {bool augment = false}) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const FormatException('Bild konnte nicht gelesen werden');
    final oriented = img.bakeOrientation(decoded);
    final square = _centerCrop(oriented, 1.0);
    final variants = <img.Image>[square];
    if (augment) {
      variants
        ..add(img.flipHorizontal(img.Image.from(square)))
        ..add(_centerCrop(square, 0.85))
        ..add(img.adjustColor(img.Image.from(square), brightness: 1.15))
        ..add(img.adjustColor(img.Image.from(square), brightness: 0.85));
    }
    return [for (final v in variants) _toTensor(v)];
  }

  static img.Image _centerCrop(img.Image src, double fraction) {
    final side = (src.width < src.height ? src.width : src.height) * fraction;
    final s = side.round();
    return img.copyCrop(src, x: (src.width - s) ~/ 2, y: (src.height - s) ~/ 2, width: s, height: s);
  }

  static Float32List _toTensor(img.Image square) {
    final resized = img.copyResize(
      square,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );
    final rgb = resized.getBytes(order: img.ChannelOrder.rgb);
    final t = Float32List(inputSize * inputSize * 3);
    for (var i = 0; i < t.length && i < rgb.length; i++) {
      t[i] = rgb[i] / 255.0;
    }
    return t;
  }
}
