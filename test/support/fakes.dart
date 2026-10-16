import 'dart:typed_data';

import 'package:waesche_app/ai/engines.dart';
import 'package:waesche_app/ai/prompts.dart';
import 'package:waesche_app/core/models/catalog_item.dart';
import 'package:waesche_app/core/models/garment_attributes.dart';
import 'package:waesche_app/pipeline/decisions.dart';

class FakeDescriber implements DescriberEngine {
  FakeDescriber(this.result, {this.fail = false});

  GarmentAttributes result;
  bool fail;
  int calls = 0;

  @override
  Future<Description> describe(Uint8List jpeg) async {
    calls++;
    if (fail) throw StateError('VLM nicht verfügbar');
    return Description(attributes: result, raw: result.toJsonString(), elapsed: Duration.zero);
  }
}

/// Matcher, der der Reihe nach vorbereitete Antworten liefert. Eine Antwort
/// ist eine Funktion der Kandidaten, damit Tests Labels auflösen können.
class ScriptedMatcher implements MatcherEngine {
  ScriptedMatcher(this.script);

  final List<MatchDecision Function(List<LabeledCandidate>)> script;
  final List<List<LabeledCandidate>> seenCandidates = [];
  final List<List<String>> seenAnswers = [];
  bool throwError = false;

  @override
  Future<MatchDecision> decide({
    required GarmentAttributes scan,
    required List<LabeledCandidate> candidates,
    List<String> previousAnswers = const [],
  }) async {
    seenCandidates.add(candidates);
    seenAnswers.add(List.of(previousAnswers));
    if (throwError) throw StateError('LLM abgestürzt');
    if (script.isEmpty) return const InvalidDecision('Skript leer');
    return script.removeAt(0)(candidates);
  }
}

/// Embedder, der pro Bild-Bytes einen festen Vektor liefert (erstes Byte = Schlüssel).
class FakeEmbedder implements EmbeddingEngine {
  FakeEmbedder(this.vectors);

  final Map<int, List<double>> vectors;

  @override
  String get modelId => 'fake';

  @override
  Future<List<Float32List>> embed(Uint8List imageBytes, {bool augment = false}) async =>
      [Float32List.fromList(vectors[imageBytes.first]!)];
}

CatalogItem item(
  String id, {
  String person = 'Anna',
  String kategorie = 'Socke',
  List<String> farben = const ['weiß'],
  String muster = 'gerippt',
  String laenge = 'Knöchelsocke',
  String merkmale = '',
  String logo = '',
  String markierung = '',
  List<List<double>> embeddings = const [],
}) => CatalogItem(
  id: id,
  personId: 'p-$person',
  personName: person,
  personColor: 0xFF000000,
  name: id,
  attributes: GarmentAttributes(
    kategorie: kategorie,
    farben: farben,
    muster: muster,
    laengeSchnitt: laenge,
    logoMarke: logo,
    besondereMerkmale: merkmale,
  ),
  markierung: markierung,
  photos: [
    ReferencePhoto(id: 'ph-$id', path: '/x/$id.jpg', art: 'vorne', embeddings: [
      for (final e in embeddings) Float32List.fromList(e),
    ]),
  ],
);

/// Label zur Item-ID in einer Kandidatenliste.
String labelOf(List<LabeledCandidate> c, String itemId) => c.firstWhere((x) => x.itemId == itemId).label;
