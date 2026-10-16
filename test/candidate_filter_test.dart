import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:waesche_app/core/models/garment_attributes.dart';
import 'package:waesche_app/pipeline/candidate_filter.dart';

import 'support/fakes.dart';

void main() {
  const filter = CandidateFilter();

  test('Kategorie ist ein harter Filter', () {
    final r = filter.rank(
      scan: const GarmentAttributes(kategorie: 'Socke', farben: ['weiß']),
      catalog: [item('socke'), item('shirt', kategorie: 'T-Shirt')],
    );
    expect(r.ranked.map((c) => c.item.id), ['socke']);
    expect(r.categoryFallback, isFalse);
  });

  test('ohne Teil der Kategorie: Rückfall auf alle Teile', () {
    final r = filter.rank(
      scan: const GarmentAttributes(kategorie: 'Hose'),
      catalog: [item('socke'), item('shirt', kategorie: 'T-Shirt')],
    );
    expect(r.ranked, hasLength(2));
    expect(r.categoryFallback, isTrue);
    expect(r.decisive, isFalse);
  });

  test('ein klar passendes Teil ist eindeutig (ohne LLM)', () {
    final r = filter.rank(
      scan: const GarmentAttributes(
        kategorie: 'Socke',
        farben: ['schwarz'],
        muster: 'geringelt',
        laengeSchnitt: 'Wadensocke',
        materialOptik: 'Baumwolle',
      ),
      catalog: [
        item('schwarz', farben: ['schwarz'], muster: 'geringelt', laenge: 'Wadensocke'),
        item('weiss', farben: ['weiß'], muster: 'gerippt', laenge: 'Knöchelsocke'),
      ],
    );
    expect(r.best!.item.id, 'schwarz');
    expect(r.decisive, isTrue);
  });

  test('zwei sehr ähnliche Teile sind nicht eindeutig', () {
    final r = filter.rank(
      scan: const GarmentAttributes(kategorie: 'Socke', farben: ['weiß'], muster: 'gerippt'),
      catalog: [item('a'), item('b', laenge: 'Wadensocke')],
    );
    expect(r.decisive, isFalse);
    expect(r.ranked, hasLength(2));
  });

  test('Bildähnlichkeit fließt in den Score ein', () {
    final r = filter.rank(
      scan: const GarmentAttributes(kategorie: 'Socke', farben: ['weiß'], muster: 'gerippt'),
      catalog: [
        item('fern', embeddings: [
          [0, 1, 0],
        ]),
        item('nah', embeddings: [
          [1, 0.05, 0],
        ]),
      ],
      scanEmbedding: Float32List.fromList([1, 0, 0]),
    );
    expect(r.best!.item.id, 'nah');
    expect(r.ranked.first.imageSim, greaterThan(0.99));
  });

  test('ähnliche Farben zählen teilweise', () {
    final gleich = CandidateFilter.attributeScore(
      const GarmentAttributes(farben: ['grau']),
      const GarmentAttributes(farben: ['grau']),
    );
    final familie = CandidateFilter.attributeScore(
      const GarmentAttributes(farben: ['grau']),
      const GarmentAttributes(farben: ['hellgrau']),
    );
    final anders = CandidateFilter.attributeScore(
      const GarmentAttributes(farben: ['grau']),
      const GarmentAttributes(farben: ['rot']),
    );
    expect(gleich, greaterThan(familie));
    expect(familie, greaterThan(anders));
  });

  test('höchstens maxCandidates Kandidaten', () {
    final r = filter.rank(
      scan: const GarmentAttributes(kategorie: 'Socke'),
      catalog: [for (var i = 0; i < 20; i++) item('s$i')],
    );
    expect(r.ranked, hasLength(8));
  });
}
