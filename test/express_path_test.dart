import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:waesche_app/core/models/catalog_item.dart';
import 'package:waesche_app/core/models/garment_attributes.dart';
import 'package:waesche_app/pipeline/decisions.dart';
import 'package:waesche_app/pipeline/identification_pipeline.dart';

import 'support/fakes.dart';

/// Teil mit mehreren Fotos (je ein Vektor) – wie nach bestätigten Scans.
CatalogItem multi(String id, String person, List<List<double>> photoVectors, {String kategorie = 'Socke'}) =>
    CatalogItem(
      id: id,
      personId: 'p-$person',
      personName: person,
      personColor: 0,
      name: id,
      attributes: GarmentAttributes(kategorie: kategorie, farben: const ['weiß']),
      photos: [
        for (var i = 0; i < photoVectors.length; i++)
          ReferencePhoto(id: '$id-$i', path: '/x/$id-$i.jpg', art: i == 0 ? 'vorne' : 'scan', embeddings: [
            Float32List.fromList(photoVectors[i]),
          ]),
      ],
    );

Uint8List photo(int key) => Uint8List.fromList([key]);

void main() {
  final scan = FakeEmbedder({
    1: [1, 0, 0],
  });

  test('eindeutiger Bildtreffer mit bestätigtem Scan: Express ohne VLM und LLM', () async {
    final describer = FakeDescriber(const GarmentAttributes(kategorie: 'Socke'));
    final matcher = ScriptedMatcher([]);
    final p = IdentificationPipeline(describer: describer, matcher: matcher, embedder: scan);
    final s = await p.start(photo(1), [
      multi('a', 'Anna', [
        [0.99, 0.1, 0],
        [0.98, 0.15, 0],
      ]),
      multi('b', 'Ben', [
        [0.2, 1, 0],
      ]),
    ]);
    expect(s, isA<PipelineProposal>());
    final prop = s as PipelineProposal;
    expect(prop.stage, Stage.express);
    expect(prop.item.id, 'a');
    expect(prop.ownerOnly, isFalse);
    expect(describer.calls, 0, reason: 'VLM übersprungen');
    expect(matcher.seenCandidates, isEmpty);
  });

  test('kein Express, wenn ein ähnliches Teil einer anderen Person nah liegt', () async {
    final describer = FakeDescriber(const GarmentAttributes(kategorie: 'Socke'));
    final p = IdentificationPipeline(
      describer: describer,
      matcher: ScriptedMatcher([(c) => UnclearDecision(c.map((x) => x.itemId).toList())]),
      embedder: scan,
    );
    final s = await p.start(photo(1), [
      multi('a', 'Anna', [
        [0.99, 0.1, 0],
        [0.98, 0.12, 0],
      ]),
      multi('b', 'Ben', [
        [0.97, 0.14, 0],
        [0.96, 0.2, 0],
      ]),
    ]);
    expect(describer.calls, 1, reason: 'normaler Ablauf mit VLM');
    expect(s, isNot(isA<PipelineProposal>().having((p) => p.stage, 'stage', Stage.express)));
  });

  test('kein Express mit nur einem Foto (noch kein bestätigter Scan)', () async {
    final describer = FakeDescriber(const GarmentAttributes(kategorie: 'Socke'));
    final p = IdentificationPipeline(describer: describer, matcher: ScriptedMatcher([]), embedder: scan);
    await p.start(photo(1), [
      multi('a', 'Anna', [
        [1, 0.01, 0],
      ]),
      multi('b', 'Ben', [
        [0, 1, 0],
      ]),
    ]);
    expect(describer.calls, 1);
  });

  test('kein Express ohne Embedding', () async {
    final describer = FakeDescriber(const GarmentAttributes(kategorie: 'Socke'));
    final p = IdentificationPipeline(describer: describer, matcher: ScriptedMatcher([]));
    await p.start(photo(1), [
      multi('a', 'Anna', [
        [1, 0, 0],
        [1, 0, 0],
      ]),
    ]);
    expect(describer.calls, 1);
  });

  test('Express mit ähnlichem Teil derselben Person: nur Besitzer sicher', () async {
    final p = IdentificationPipeline(
      describer: FakeDescriber(const GarmentAttributes()),
      matcher: ScriptedMatcher([]),
      embedder: scan,
    );
    final s = await p.start(photo(1), [
      multi('a1', 'Anna', [
        [0.99, 0.1, 0],
        [0.99, 0.1, 0],
      ]),
      multi('a2', 'Anna', [
        [0.98, 0.15, 0],
        [0.98, 0.15, 0],
      ]),
      multi('b', 'Ben', [
        [0, 1, 0],
      ]),
    ]);
    final prop = s as PipelineProposal;
    expect(prop.stage, Stage.express);
    expect(prop.ownerOnly, isTrue);
  });

  test('„Falsch“ nach Express: Fotovergleich über die Kategorie des Teils', () async {
    final p = IdentificationPipeline(
      describer: FakeDescriber(const GarmentAttributes()),
      matcher: ScriptedMatcher([]),
      embedder: scan,
    );
    final s = await p.start(photo(1), [
      multi('a', 'Anna', [
        [0.99, 0.1, 0],
        [0.98, 0.15, 0],
      ]),
      multi('b', 'Ben', [
        [0.2, 1, 0],
      ]),
      multi('shirt', 'Ben', [
        [0, 0, 1],
      ], kategorie: 'T-Shirt'),
    ]);
    final r = p.reject((s as PipelineProposal).item.id);
    expect(r, isA<PipelineManualChoice>());
    expect((r as PipelineManualChoice).candidates.map((c) => c.item.id), ['b']);
  });
}
