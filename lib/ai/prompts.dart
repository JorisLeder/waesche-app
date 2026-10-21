import '../core/models/garment_attributes.dart';
import '../core/models/vocabulary.dart';

/// Ein Kandidat, wie ihn das LLM sieht. Kurze Buchstaben-Labels statt UUIDs:
/// Gemma 4 kann auf der GPU lange Ziffernfolgen falsch abschreiben.
class LabeledCandidate {
  const LabeledCandidate({required this.label, required this.itemId, required this.attributes, this.markierung = ''});

  final String label;
  final String itemId;
  final GarmentAttributes attributes;
  final String markierung;
}

const candidateLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

class Prompts {
  Prompts._();

  static String _list(List<String> v) => v.join(', ');

  static const describeSystem =
      'Du bist ein präziser Assistent, der Kleidungsstücke für die Wäschesortierung beschreibt. '
      'Du antwortest ausschließlich über das Werkzeug beschreibe_kleidung.';

  /// Kurz gehalten: Die erlaubten Begriffe stehen bereits als Enums im
  /// Werkzeug-Schema, jede Zeile hier kostet auf Mittelklasse-Handys Zeit.
  static String describeUser() =>
      'Beschreibe das Kleidungsstück auf dem Foto so, dass man es von ähnlichen Teilen unterscheiden kann. '
      'Achte auf Details: Rippung (ganz oder nur am Bündchen), andersfarbige Ferse/Spitze/Bündchen, '
      'Logos, Aufdrucke, Löcher, Flecken. Nur erlaubte Begriffe aus dem Werkzeug verwenden, sonst "unbekannt". '
      'besondere_merkmale: höchstens 15 Wörter.';

  /// Mit vollständiger Begriffsliste für den JSON-Rückfall ohne Werkzeug-Schema.
  static String _describeUserWithVocabulary() =>
      'Beschreibe das Kleidungsstück auf dem Foto so, dass man es von ähnlichen Teilen unterscheiden kann. '
      'Achte besonders auf Details: Rippung (ganz oder nur am Bündchen), andersfarbige Ferse/Spitze/Bündchen, '
      'Logos, Aufdrucke, Nähte, Löcher, Flecken.\n'
      'Verwende NUR diese Begriffe:\n'
      'kategorie: ${_list(Vocabulary.kategorien)}\n'
      'farben (1-3): ${_list(Vocabulary.farben)}\n'
      'muster: ${_list(Vocabulary.muster)}\n'
      'material_optik: ${_list(Vocabulary.materialOptik)}\n'
      'laenge_schnitt: ${_list(Vocabulary.laengeSchnitt)}\n'
      'Unsicher: "unbekannt". logo_marke und aufdruck_text: leer lassen, wenn nichts zu sehen ist. '
      'besondere_merkmale: höchstens 15 Wörter.';

  /// JSON-Fallback, falls das Modell nicht über das Werkzeug antwortet.
  static String describeUserJsonFallback() =>
      '${_describeUserWithVocabulary()}\nAntworte nur mit einem JSON-Objekt mit den Schlüsseln '
      'kategorie, farben, muster, material_optik, laenge_schnitt, logo_marke, aufdruck_text, besondere_merkmale.';

  static const matchSystem =
      'Du ordnest ein gescanntes Kleidungsstück einem von mehreren bekannten Teilen zu. '
      'Du antwortest ausschließlich über genau eines der Werkzeuge zuordnen, rueckfrage oder unklar.';

  static String matchUser({
    required GarmentAttributes scan,
    required List<LabeledCandidate> candidates,
    List<String> previousAnswers = const [],
  }) {
    final b = StringBuffer()
      ..writeln('Gescanntes Teil: ${scan.summary()}')
      ..writeln()
      ..writeln('Bekannte Teile:');
    for (final c in candidates) {
      b.write('${c.label}: ${c.attributes.summary()}');
      if (c.markierung.isNotEmpty) b.write(', Markierung: ${c.markierung}');
      b.writeln();
    }
    if (previousAnswers.isNotEmpty) {
      b
        ..writeln()
        ..writeln('Bisherige Antworten des Nutzers:');
      for (final a in previousAnswers) {
        b.writeln('- $a');
      }
    }
    b
      ..writeln()
      ..writeln('Regeln:')
      ..writeln('- Passt genau ein Teil eindeutig: zuordnen(label, sicherheit).')
      ..writeln('- Passen mehrere: rueckfrage mit einer kurzen Frage zu einem Merkmal, das man am Teil SEHEN kann '
          '(z. B. "Ist die Rippung über den ganzen Socken oder erst ab dem Knöchel?"). '
          'Jede Option nennt die Labels der Teile, zu denen sie passt.')
      ..writeln('- Wenn eine Frage nicht weiterhilft: unklar(labels) mit den Labels der passenden Teile.')
      ..writeln('- Verwende nur diese Labels: ${candidates.map((c) => c.label).join(', ')}.');
    return b.toString();
  }

  static String matchUserJsonFallback({
    required GarmentAttributes scan,
    required List<LabeledCandidate> candidates,
    List<String> previousAnswers = const [],
  }) =>
      '${matchUser(scan: scan, candidates: candidates, previousAnswers: previousAnswers)}\n'
      'Antworte nur mit JSON, eines von:\n'
      '{"aktion":"zuordnen","label":"A","sicherheit":0.9}\n'
      '{"aktion":"rueckfrage","frage":"...","optionen":[{"text":"...","labels":["A"]},{"text":"...","labels":["B"]}]}\n'
      '{"aktion":"unklar","labels":["A","B"]}';
}
