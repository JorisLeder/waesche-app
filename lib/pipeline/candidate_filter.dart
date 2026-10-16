import 'dart:typed_data';

import '../ai/vector_math.dart';
import '../core/models/catalog_item.dart';
import '../core/models/garment_attributes.dart';
import '../core/models/vocabulary.dart';
import 'matching_config.dart';

class ScoredCandidate {
  const ScoredCandidate({
    required this.item,
    required this.attributeScore,
    required this.imageSim,
    required this.total,
  });

  final CatalogItem item;

  /// 0..1, Übereinstimmung der beschriebenen Attribute.
  final double attributeScore;

  /// Höchste Kosinus-Ähnlichkeit zu einem Referenzbild; null ohne Embeddings.
  final double? imageSim;

  /// Kombinierter Score 0..1.
  final double total;
}

class CandidateRanking {
  const CandidateRanking({required this.ranked, required this.decisive, required this.categoryFallback});

  /// Absteigend nach [ScoredCandidate.total], höchstens maxCandidates.
  final List<ScoredCandidate> ranked;

  /// true, wenn der Beste so klar vorne liegt, dass kein LLM nötig ist.
  final bool decisive;

  /// true, wenn kein Teil der erkannten Kategorie existiert und deshalb
  /// über alle Kategorien nach Bildähnlichkeit sortiert wurde.
  final bool categoryFallback;

  ScoredCandidate? get best => ranked.isEmpty ? null : ranked.first;
}

/// Deterministischer Vorfilter: Kategorie hart, dann Score aus Attributen
/// und Bildähnlichkeit. Liefert die Top-K für das LLM.
class CandidateFilter {
  const CandidateFilter([this.config = const MatchingConfig()]);

  final MatchingConfig config;

  CandidateRanking rank({
    required GarmentAttributes scan,
    required List<CatalogItem> catalog,
    Float32List? scanEmbedding,
  }) {
    final scanKnown = scan.kategorie != Vocabulary.unbekannt;
    var pool = catalog.where((i) {
      if (!scanKnown) return true;
      final k = i.attributes.kategorie;
      return k == scan.kategorie || k == Vocabulary.unbekannt;
    }).toList();

    var categoryFallback = false;
    if (pool.isEmpty) {
      pool = List.of(catalog);
      categoryFallback = true;
    }

    final scored = <ScoredCandidate>[];
    for (final item in pool) {
      final attr = attributeScore(scan, item.attributes);
      final sim = scanEmbedding == null ? null : maxSimilarity(scanEmbedding, item.allEmbeddings);
      final total = combine(attr, sim, categoryFallback: categoryFallback);
      scored.add(ScoredCandidate(item: item, attributeScore: attr, imageSim: sim, total: total));
    }
    scored.sort((a, b) => b.total.compareTo(a.total));
    final top = scored.take(config.maxCandidates).toList();

    var decisive = false;
    if (top.isNotEmpty && !categoryFallback) {
      final best = top.first;
      final second = top.length > 1 ? top[1].total : 0.0;
      final imageOk = best.imageSim == null || best.imageSim! >= config.directMinImageSim;
      decisive =
          best.total >= config.directMinScore && best.total - second >= config.directMinMargin && imageOk;
    }
    return CandidateRanking(ranked: top, decisive: decisive, categoryFallback: categoryFallback);
  }

  double combine(double attr, double? sim, {bool categoryFallback = false}) {
    if (sim == null) return categoryFallback ? attr * 0.5 : attr;
    final img = ((sim - config.imageSimFloor) / (1 - config.imageSimFloor)).clamp(0.0, 1.0);
    final total = config.attributeWeight * attr + config.imageWeight * img;
    // Ohne passende Kategorie zählt fast nur das Bild.
    return categoryFallback ? 0.2 * attr + 0.8 * img : total;
  }

  /// Ähnlichkeit zweier Beschreibungen, 0..1. Unbekannte Werte sind neutral (0.5).
  static double attributeScore(GarmentAttributes scan, GarmentAttributes item) {
    var sum = 0.0;
    var weights = 0.0;
    void add(double w, double s) {
      sum += w * s;
      weights += w;
    }

    add(0.35, _colorScore(scan.farben, item.farben));
    add(0.2, _exactScore(scan.muster, item.muster, mismatch: 0.0));
    add(0.2, _lengthScore(scan.laengeSchnitt, item.laengeSchnitt));
    add(0.1, _exactScore(scan.materialOptik, item.materialOptik, mismatch: 0.2));
    add(0.15, _textScore('${scan.logoMarke} ${scan.aufdruckText}', '${item.logoMarke} ${item.aufdruckText}'));
    return weights == 0 ? 0 : sum / weights;
  }

  static double _exactScore(String a, String b, {required double mismatch}) {
    if (a == Vocabulary.unbekannt || b == Vocabulary.unbekannt) return 0.5;
    return a == b ? 1.0 : mismatch;
  }

  static const _sockLengths = ['Füßling', 'Sneakersocke', 'Knöchelsocke', 'Wadensocke', 'Kniestrumpf'];
  static const _sleeveLengths = ['ärmellos', 'kurzarm', 'dreiviertel', 'langarm'];
  static const _legLengths = ['kurz', 'dreiviertel', 'lang'];

  static double _lengthScore(String a, String b) {
    if (a == Vocabulary.unbekannt || b == Vocabulary.unbekannt) return 0.5;
    if (a == b) return 1.0;
    for (final scale in [_sockLengths, _sleeveLengths, _legLengths]) {
      final ia = scale.indexOf(a), ib = scale.indexOf(b);
      if (ia >= 0 && ib >= 0) return (ia - ib).abs() == 1 ? 0.4 : 0.0;
    }
    return 0.0;
  }

  static double _colorScore(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.5;
    double best(String c, List<String> others) {
      var m = 0.0;
      for (final o in others) {
        if (o == c) return 1.0;
        final fc = Vocabulary.farbFamilie(c), fo = Vocabulary.farbFamilie(o);
        if (fc != null && fc == fo) m = m < 0.5 ? 0.5 : m;
      }
      return m;
    }

    var s = 0.0;
    for (final c in a) {
      s += best(c, b);
    }
    for (final c in b) {
      s += best(c, a);
    }
    return s / (a.length + b.length);
  }

  static double _textScore(String a, String b) {
    final ta = _tokens(a), tb = _tokens(b);
    if (ta.isEmpty && tb.isEmpty) return 0.6;
    if (ta.isEmpty || tb.isEmpty) return 0.3;
    final inter = ta.intersection(tb).length;
    final union = ta.union(tb).length;
    return 0.3 + 0.7 * inter / union;
  }

  static Set<String> _tokens(String s) => s
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9äöüß]+'))
      .where((t) => t.length >= 2)
      .toSet();
}
