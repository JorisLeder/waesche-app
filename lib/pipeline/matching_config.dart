/// Schwellen und Gewichte der Zuordnung an einer Stelle.
///
/// Die Startwerte sind Schätzungen; sie werden mit den Messungen aus dem
/// Machbarkeits-Test kalibriert (der Debug-Bildschirm zeigt alle Werte an).
class MatchingConfig {
  const MatchingConfig({
    this.maxCandidates = 8,
    this.attributeWeight = 0.6,
    this.imageWeight = 0.4,
    this.imageSimFloor = 0.45,
    this.directMinScore = 0.82,
    this.directMinMargin = 0.25,
    this.directMinImageSim = 0.6,
    this.nnAcceptSim = 0.78,
    this.nnMinMargin = 0.06,
    this.maxQuestionRounds = 2,
    this.maxLlmRetries = 1,
    this.ownerContenderWindow = 0.15,
    this.ownerMinScore = 0.55,
  });

  /// Höchstzahl Kandidaten, die das LLM sieht (Kontext und Tempo).
  final int maxCandidates;

  /// Anteil von Attribut- und Bild-Ähnlichkeit am Gesamtscore.
  final double attributeWeight;
  final double imageWeight;

  /// Kosinus-Ähnlichkeit, ab der Bilder überhaupt als ähnlich zählen;
  /// darunter trägt das Bild 0 zum Score bei.
  final double imageSimFloor;

  /// Direkte Zuordnung ohne LLM: Mindestscore, Abstand zum Zweiten und
  /// Mindest-Bildähnlichkeit (falls Embeddings vorhanden sind).
  final double directMinScore;
  final double directMinMargin;
  final double directMinImageSim;

  /// NN-Stufe: Mindestähnlichkeit des besten Kandidaten und Abstand zum Zweiten.
  final double nnAcceptSim;
  final double nnMinMargin;

  final int maxQuestionRounds;
  final int maxLlmRetries;

  /// Besitzer-Abkürzung: Kandidaten innerhalb dieses Abstands zum Besten
  /// zählen als ernsthaft; gehören alle derselben Person, ist der Besitzer
  /// klar (sofern der Beste mindestens [ownerMinScore] erreicht).
  final double ownerContenderWindow;
  final double ownerMinScore;
}
