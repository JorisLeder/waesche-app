import 'package:flutter_test/flutter_test.dart';
import 'package:waesche_app/pipeline/confusion_check.dart';

import 'support/fakes.dart';

void main() {
  test('findet Lookalikes anderer Personen, nicht der eigenen', () {
    final neu = item('neu', person: 'Anna');
    final res = findLookalikes(neu, [
      neu,
      item('eigene', person: 'Anna'),
      item('fremde', person: 'Ben'),
      item('anders', person: 'Ben', farben: ['schwarz'], muster: 'geringelt', laenge: 'Wadensocke'),
      item('shirt', person: 'Ben', kategorie: 'T-Shirt'),
    ]);
    expect(res.map((l) => l.item.id), ['fremde']);
  });

  test('hohe Bildähnlichkeit reicht auch bei abweichender Beschreibung', () {
    final neu = item('neu', person: 'Anna', embeddings: [
      [1, 0, 0],
    ]);
    final res = findLookalikes(neu, [
      item('x', person: 'Ben', farben: ['schwarz'], muster: 'uni', laenge: 'Wadensocke', embeddings: [
        [0.99, 0.05, 0],
      ]),
    ]);
    expect(res, hasLength(1));
    expect(res.single.imageSim, greaterThan(0.95));
  });
}
