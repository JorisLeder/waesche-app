import 'dart:typed_data';

import '../core/models/garment_attributes.dart';
import '../pipeline/decisions.dart';
import 'prompts.dart';

/// Ergebnis der VLM-Beschreibung.
class Description {
  const Description({required this.attributes, required this.raw, required this.elapsed, this.viaTool = true});

  final GarmentAttributes attributes;
  final String raw;
  final Duration elapsed;

  /// true: über Function Calling, false: aus JSON-Text gelesen.
  final bool viaTool;
}

/// Stufe 1: Bild -> strukturierte Attribute.
abstract interface class DescriberEngine {
  Future<Description> describe(Uint8List jpeg);
}

/// Stufe 2: Beschreibung + Kandidaten -> Entscheidung.
abstract interface class MatcherEngine {
  Future<MatchDecision> decide({
    required GarmentAttributes scan,
    required List<LabeledCandidate> candidates,
    List<String> previousAnswers = const [],
  });
}

/// Stufe 3: vortrainiertes Bild-Embedding.
abstract interface class EmbeddingEngine {
  String get modelId;

  /// Ein Vektor für das Bild; mit [augment] zusätzlich Vektoren leicht
  /// veränderter Kopien (Spiegelung, Zuschnitt, Helligkeit).
  Future<List<Float32List>> embed(Uint8List imageBytes, {bool augment = false});
}
