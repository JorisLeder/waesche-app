import 'dart:math' as math;
import 'dart:typed_data';

/// L2-normalisiert einen Vektor (in einer Kopie).
Float32List l2Normalize(List<double> v) {
  var sum = 0.0;
  for (final x in v) {
    sum += x * x;
  }
  final norm = math.sqrt(sum);
  final out = Float32List(v.length);
  if (norm == 0) return out;
  for (var i = 0; i < v.length; i++) {
    out[i] = v[i] / norm;
  }
  return out;
}

/// Kosinus-Ähnlichkeit zweier Vektoren gleicher Länge.
double cosineSimilarity(List<double> a, List<double> b) {
  if (a.length != b.length || a.isEmpty) return 0;
  var dot = 0.0, na = 0.0, nb = 0.0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  if (na == 0 || nb == 0) return 0;
  return dot / (math.sqrt(na) * math.sqrt(nb));
}

/// Höchste Ähnlichkeit von [query] zu einem der [references]; null, wenn
/// keine Referenz vorhanden ist.
double? maxSimilarity(List<double> query, Iterable<List<double>> references) {
  double? best;
  for (final r in references) {
    if (r.length != query.length) continue;
    final s = cosineSimilarity(query, r);
    if (best == null || s > best) best = s;
  }
  return best;
}

/// Vektor <-> Bytes für die Speicherung als BLOB.
Uint8List vectorToBytes(Float32List v) => v.buffer.asUint8List(v.offsetInBytes, v.lengthInBytes);

Float32List bytesToVector(Uint8List bytes) {
  final copy = Uint8List.fromList(bytes);
  return copy.buffer.asFloat32List(0, copy.lengthInBytes ~/ 4);
}
