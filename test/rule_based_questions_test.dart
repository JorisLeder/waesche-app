import 'package:flutter_test/flutter_test.dart';
import 'package:waesche_app/pipeline/rule_based_questions.dart';

import 'support/fakes.dart';

void main() {
  const rules = RuleBasedQuestions();

  test('wählt das Attribut, das die Kandidaten trennt', () {
    final q = rules.build([
      item('a', laenge: 'Knöchelsocke'),
      item('b', laenge: 'Wadensocke'),
    ]);
    expect(q, isNotNull);
    expect(q!.source, 'regel:laenge');
    expect(q.options.map((o) => o.text).toSet(), {'Knöchelsocke', 'Wadensocke'});
    expect(q.options.firstWhere((o) => o.text == 'Wadensocke').itemIds, ['b']);
  });

  test('unbekannte Werte landen in jeder Option', () {
    final q = rules.build([
      item('a', muster: 'gerippt', laenge: 'unbekannt'),
      item('b', muster: 'uni', laenge: 'unbekannt'),
      item('c', muster: 'unbekannt', laenge: 'unbekannt'),
    ]);
    expect(q!.source, 'regel:muster');
    for (final o in q.options) {
      expect(o.itemIds, contains('c'));
    }
  });

  test('bereits gefragte Dimensionen werden übersprungen', () {
    final q = rules.build(
      [
        item('a', laenge: 'Knöchelsocke', markierung: 'Punkt'),
        item('b', laenge: 'Wadensocke'),
      ],
      alreadyAsked: {'laenge'},
    );
    expect(q!.source, 'regel:markierung');
  });

  test('null, wenn sich nichts unterscheidet', () {
    expect(rules.build([item('a'), item('b')]), isNull);
    expect(rules.build([item('a')]), isNull);
  });
}
