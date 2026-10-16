import '../core/models/catalog_item.dart';
import '../core/models/vocabulary.dart';
import 'decisions.dart';

/// Regelbasierte Ersatzfrage: sucht das Attribut, das die Kandidaten am
/// besten trennt, und baut daraus eine Frage mit Antwort-Buttons.
///
/// Teile mit unbekanntem Wert für das Attribut landen in jeder Option –
/// sie dürfen durch die Antwort nicht fälschlich ausgeschlossen werden.
class RuleBasedQuestions {
  const RuleBasedQuestions();

  static const _maxOptions = 5;

  Question? build(List<CatalogItem> candidates, {Set<String> alreadyAsked = const {}}) {
    if (candidates.length < 2) return null;

    final dims = <_Dimension>[
      _Dimension('laenge', 'Welche Länge bzw. welchen Schnitt hat das Teil?',
          (i) => _known(i.attributes.laengeSchnitt)),
      _Dimension('muster', 'Welches Muster hat das Teil?', (i) => _known(i.attributes.muster)),
      _Dimension('farben', 'Welche Farbe(n) hat das Teil?',
          (i) => i.attributes.farben.isEmpty ? null : i.attributes.farben.join(' / ')),
      _Dimension('markierung', 'Hat das Teil eine Markierung?',
          (i) => i.markierung.trim().isEmpty ? 'keine Markierung' : i.markierung.trim()),
      _Dimension('logo', 'Welches Logo / welche Marke ist zu sehen?',
          (i) => i.attributes.logoMarke.trim().isEmpty ? 'kein Logo' : i.attributes.logoMarke.trim()),
      _Dimension('aufdruck', 'Welcher Aufdruck ist zu sehen?',
          (i) => i.attributes.aufdruckText.trim().isEmpty ? 'kein Aufdruck' : i.attributes.aufdruckText.trim()),
      _Dimension('material', 'Wie sieht das Material aus?', (i) => _known(i.attributes.materialOptik)),
      _Dimension('merkmale', 'Welches dieser Merkmale passt zum Teil?',
          (i) => i.attributes.besondereMerkmale.trim().isEmpty ? null : i.attributes.besondereMerkmale.trim()),
    ];

    _Scored? best;
    for (var d = 0; d < dims.length; d++) {
      final dim = dims[d];
      if (alreadyAsked.contains(dim.key)) continue;
      final groups = <String, List<String>>{};
      final unknown = <String>[];
      for (final c in candidates) {
        final v = dim.valueOf(c);
        if (v == null) {
          unknown.add(c.id);
        } else {
          groups.putIfAbsent(v, () => []).add(c.id);
        }
      }
      if (groups.length < 2 || groups.length > _maxOptions) continue;
      // Erwarteter Anteil, der nach der Antwort ausscheidet. Teile mit
      // unbekanntem Wert bleiben in jeder Option, schwächen die Frage also.
      final n = candidates.length;
      final known = n - unknown.length;
      var expectedRemaining = 0.0;
      for (final g in groups.values) {
        final p = g.length / known;
        expectedRemaining += p * (g.length + unknown.length) / n;
      }
      // Frühere Dimensionen gewinnen bei Gleichstand.
      final score = 1 - expectedRemaining - d * 0.001;
      if (best == null || score > best.score) {
        best = _Scored(dim, groups, unknown, score);
      }
    }
    if (best == null || best.score <= 0) return null;

    final options = best.groups.entries
        .map((e) => AnswerOption(text: e.key, itemIds: [...e.value, ...best!.unknown]))
        .toList();
    return Question(text: best.dim.text, options: options, source: 'regel:${best.dim.key}');
  }

  static String? _known(String v) => v == Vocabulary.unbekannt ? null : v;
}

class _Dimension {
  const _Dimension(this.key, this.text, this.valueOf);

  final String key;
  final String text;
  final String? Function(CatalogItem) valueOf;
}

class _Scored {
  const _Scored(this.dim, this.groups, this.unknown, this.score);

  final _Dimension dim;
  final Map<String, List<String>> groups;
  final List<String> unknown;
  final double score;
}
