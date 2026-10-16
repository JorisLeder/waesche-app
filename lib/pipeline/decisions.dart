/// Antwortoption einer Rückfrage. Jede Option ist an eine Teilmenge der
/// Kandidaten gebunden; die Eingrenzung ist dadurch deterministisch.
class AnswerOption {
  const AnswerOption({required this.text, required this.itemIds});

  final String text;
  final List<String> itemIds;
}

class Question {
  const Question({required this.text, required this.options, required this.source});

  final String text;
  final List<AnswerOption> options;

  /// 'llm' oder 'regel' (regelbasierte Ersatzfrage).
  final String source;
}

/// Ergebnis eines Zuordnungs-Aufrufs ans LLM (bereits auf Item-IDs abgebildet
/// und validiert).
sealed class MatchDecision {
  const MatchDecision();
}

class AssignDecision extends MatchDecision {
  const AssignDecision({required this.itemId, required this.confidence, this.reason = ''});

  final String itemId;

  /// 0..1
  final double confidence;
  final String reason;
}

class AskDecision extends MatchDecision {
  const AskDecision(this.question);

  final Question question;
}

class UnclearDecision extends MatchDecision {
  const UnclearDecision(this.itemIds);

  final List<String> itemIds;
}

class InvalidDecision extends MatchDecision {
  const InvalidDecision(this.reason, {this.raw = ''});

  final String reason;
  final String raw;
}
