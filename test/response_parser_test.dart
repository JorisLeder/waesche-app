import 'package:flutter_test/flutter_test.dart';
import 'package:waesche_app/ai/prompts.dart';
import 'package:waesche_app/ai/response_parser.dart';
import 'package:waesche_app/core/models/garment_attributes.dart';
import 'package:waesche_app/pipeline/decisions.dart';

void main() {
  const parser = ResponseParser();
  const candidates = [
    LabeledCandidate(label: 'A', itemId: 'id-a', attributes: GarmentAttributes()),
    LabeledCandidate(label: 'B', itemId: 'id-b', attributes: GarmentAttributes()),
  ];

  group('extractJsonObject', () {
    test('findet JSON in Markdown-Block mit Text drumherum', () {
      final j = ResponseParser.extractJsonObject('Hier:\n```json\n{"a": {"b": "x}y"}, "c": 1}\n```\nfertig');
      expect(j, {'a': {'b': 'x}y'}, 'c': 1});
    });

    test('liefert null bei kaputtem JSON', () {
      expect(ResponseParser.extractJsonObject('{"a": '), isNull);
      expect(ResponseParser.extractJsonObject('kein json'), isNull);
    });
  });

  group('parseDescription', () {
    test('aus Werkzeugaufruf', () {
      final a = parser.parseDescription(toolName: 'beschreibe_kleidung', args: {'kategorie': 'Socke', 'farben': ['weiß']});
      expect(a!.kategorie, 'Socke');
    });

    test('aus Text-JSON', () {
      final a = parser.parseDescription(text: 'Antwort: {"kategorie":"Hose","farben":["blau"]}');
      expect(a!.kategorie, 'Hose');
    });

    test('null ohne verwertbare Antwort', () {
      expect(parser.parseDescription(text: 'Ich sehe eine Socke.'), isNull);
    });
  });

  group('parseMatch', () {
    test('zuordnen mit gültigem Label', () {
      final d = parser.parseMatch(candidates: candidates, toolName: 'zuordnen', args: {'label': 'B', 'sicherheit': 0.8});
      expect(d, isA<AssignDecision>());
      expect((d as AssignDecision).itemId, 'id-b');
      expect(d.confidence, 0.8);
    });

    test('Label-Varianten wie "Teil A" werden erkannt', () {
      final d = parser.parseMatch(candidates: candidates, toolName: 'zuordnen', args: {'label': 'Teil a', 'sicherheit': 'hoch'});
      expect((d as AssignDecision).itemId, 'id-a');
      expect(d.confidence, 0.9);
    });

    test('erfundenes Label ist ungültig', () {
      final d = parser.parseMatch(candidates: candidates, toolName: 'zuordnen', args: {'label': 'Z', 'sicherheit': 1});
      expect(d, isA<InvalidDecision>());
    });

    test('rückfrage mit Optionen', () {
      final d = parser.parseMatch(candidates: candidates, toolName: 'rueckfrage', args: {
        'frage': 'Gerippt ganz oder ab Knöchel?',
        'optionen': [
          {'text': 'ganz', 'labels': ['A']},
          {'text': 'ab Knöchel', 'labels': ['B']},
        ],
      });
      expect(d, isA<AskDecision>());
      final q = (d as AskDecision).question;
      expect(q.options.map((o) => o.itemIds), [
        ['id-a'],
        ['id-b'],
      ]);
    });

    test('rückfrage, die nichts unterscheidet, ist ungültig', () {
      final d = parser.parseMatch(candidates: candidates, toolName: 'rueckfrage', args: {
        'frage': 'Ist es eine Socke?',
        'optionen': [
          {'text': 'ja', 'labels': ['A', 'B']},
          {'text': 'eher ja', 'labels': ['B', 'A']},
        ],
      });
      expect(d, isA<InvalidDecision>());
    });

    test('rückfrage mit erfundenem Label ist ungültig', () {
      final d = parser.parseMatch(candidates: candidates, toolName: 'rueckfrage', args: {
        'frage': 'Welche?',
        'optionen': [
          {'text': 'x', 'labels': ['A']},
          {'text': 'y', 'labels': ['Q']},
        ],
      });
      expect(d, isA<InvalidDecision>());
    });

    test('unklar', () {
      final d = parser.parseMatch(candidates: candidates, toolName: 'unklar', args: {'labels': ['A', 'B']});
      expect((d as UnclearDecision).itemIds, ['id-a', 'id-b']);
    });

    test('Text-JSON-Rückfall mit "aktion"', () {
      final d = parser.parseMatch(candidates: candidates, text: '{"aktion":"zuordnen","label":"A","sicherheit":0.95}');
      expect((d as AssignDecision).itemId, 'id-a');
    });

    test('Prosa ohne JSON ist ungültig', () {
      final d = parser.parseMatch(candidates: candidates, text: 'Ich denke, es ist Teil A.');
      expect(d, isA<InvalidDecision>());
    });
  });
}
