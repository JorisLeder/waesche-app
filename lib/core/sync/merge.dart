/// Zusammenführung von Datensätzen über UUIDs (Haushaltspaket, später Sync).
///
/// Regel: neue IDs werden eingefügt; bei bekannten IDs gewinnt der jüngere
/// `updatedAt`-Stand. Löschungen reisen als `deletedAt` mit und werden so
/// ebenfalls übernommen.
class MergePlan<T> {
  const MergePlan({required this.toInsert, required this.toUpdate, required this.unchanged});

  final List<T> toInsert;
  final List<T> toUpdate;
  final int unchanged;

  bool get isEmpty => toInsert.isEmpty && toUpdate.isEmpty;
}

MergePlan<T> planMerge<T>({
  required Map<String, DateTime> localUpdatedAt,
  required Iterable<T> incoming,
  required String Function(T) idOf,
  required DateTime Function(T) updatedAtOf,
}) {
  final insert = <T>[];
  final update = <T>[];
  var unchanged = 0;
  final seen = <String>{};
  for (final r in incoming) {
    final id = idOf(r);
    if (!seen.add(id)) continue; // doppelte Einträge im Paket ignorieren
    final local = localUpdatedAt[id];
    if (local == null) {
      insert.add(r);
    } else if (updatedAtOf(r).isAfter(local)) {
      update.add(r);
    } else {
      unchanged++;
    }
  }
  return MergePlan(toInsert: insert, toUpdate: update, unchanged: unchanged);
}
