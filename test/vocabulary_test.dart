import 'package:flutter_test/flutter_test.dart';
import 'package:waesche_app/core/models/garment_attributes.dart';
import 'package:waesche_app/core/models/vocabulary.dart';

void main() {
  group('Vocabulary.normalize', () {
    test('exakt und Groß-/Kleinschreibung', () {
      expect(Vocabulary.normalize('socke', Vocabulary.kategorien), 'Socke');
      expect(Vocabulary.normalize(' T-SHIRT ', Vocabulary.kategorien), 'T-Shirt');
    });

    test('Synonyme und Umlaut-Schreibweisen', () {
      expect(Vocabulary.normalize('weiss', Vocabulary.farben), 'weiß');
      expect(Vocabulary.normalize('gruen', Vocabulary.farben), 'grün');
      expect(Vocabulary.normalize('navy', Vocabulary.farben), 'dunkelblau');
      expect(Vocabulary.normalize('geriffelt', Vocabulary.muster), 'gerippt');
      expect(Vocabulary.normalize('Sneakersocken', Vocabulary.laengeSchnitt), 'Sneakersocke');
      expect(Vocabulary.normalize('blue', Vocabulary.farben), 'blau');
    });

    test('längster Teiltreffer gewinnt', () {
      expect(Vocabulary.normalize('dunkelblaue', Vocabulary.farben), 'dunkelblau');
      expect(Vocabulary.normalize('weiße Socke mit Logo', Vocabulary.kategorien), 'Socke');
    });

    test('Unbekanntes wird "unbekannt"', () {
      expect(Vocabulary.normalize('Raumschiff', Vocabulary.kategorien), Vocabulary.unbekannt);
      expect(Vocabulary.normalize(null, Vocabulary.kategorien), Vocabulary.unbekannt);
      expect(Vocabulary.normalize('', Vocabulary.kategorien), Vocabulary.unbekannt);
    });
  });

  group('GarmentAttributes.fromLooseJson', () {
    test('liest saubere Werkzeug-Argumente', () {
      final a = GarmentAttributes.fromLooseJson({
        'kategorie': 'Socke',
        'farben': ['weiß', 'grau'],
        'muster': 'gerippt',
        'material_optik': 'Baumwolle',
        'laenge_schnitt': 'Knöchelsocke',
        'logo_marke': '',
        'aufdruck_text': 'null',
        'besondere_merkmale': 'graue Ferse',
      });
      expect(a.kategorie, 'Socke');
      expect(a.farben, ['weiß', 'grau']);
      expect(a.aufdruckText, '');
      expect(a.besondereMerkmale, 'graue Ferse');
    });

    test('toleriert Strings statt Listen und andere Schlüssel', () {
      final a = GarmentAttributes.fromLooseJson({
        'category': 'socken',
        'farbe': 'weiss und hellgrau',
        'pattern': 'Rippen',
        'laenge': 'knöchelhoch',
      });
      expect(a.kategorie, 'Socke');
      expect(a.farben, ['weiß', 'hellgrau']);
      expect(a.muster, 'gerippt');
      expect(a.laengeSchnitt, 'Knöchelsocke');
    });

    test('Rundreise über JSON', () {
      const a = GarmentAttributes(kategorie: 'Hose', farben: ['blau'], muster: 'uni');
      final b = GarmentAttributes.fromLooseJson(a.toJson());
      expect(b.kategorie, 'Hose');
      expect(b.farben, ['blau']);
      expect(b.muster, 'uni');
    });
  });
}
