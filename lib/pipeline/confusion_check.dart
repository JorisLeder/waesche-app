import '../ai/vector_math.dart';
import '../core/models/catalog_item.dart';
import 'candidate_filter.dart';

class Lookalike {
  const Lookalike(this.item, this.attributeScore, this.imageSim);

  final CatalogItem item;
  final double attributeScore;
  final double? imageSim;
}

/// Verwechslungs-Check beim Einpflegen: sucht Teile ANDERER Personen, die dem
/// neuen Teil sehr ähneln. Ähnliche Teile derselben Person sind für die
/// Zuordnung egal – der Besitzer stimmt in jedem Fall.
List<Lookalike> findLookalikes(
  CatalogItem target,
  List<CatalogItem> catalog, {
  double attributeThreshold = 0.75,
  double imageThreshold = 0.85,
}) {
  final out = <Lookalike>[];
  final targetVectors = target.allEmbeddings.toList();
  for (final other in catalog) {
    if (other.id == target.id || other.personId == target.personId) continue;
    if (other.attributes.kategorie != target.attributes.kategorie) continue;
    final attr = CandidateFilter.attributeScore(target.attributes, other.attributes);
    double? sim;
    for (final v in targetVectors) {
      final s = maxSimilarity(v, other.allEmbeddings);
      if (s != null && (sim == null || s > sim)) sim = s;
    }
    if (attr >= attributeThreshold || (sim != null && sim >= imageThreshold)) {
      out.add(Lookalike(other, attr, sim));
    }
  }
  out.sort((a, b) => (b.imageSim ?? b.attributeScore).compareTo(a.imageSim ?? a.attributeScore));
  return out;
}
