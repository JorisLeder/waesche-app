import 'dart:typed_data';

import '../ai/engines.dart';
import '../ai/prompts.dart';
import '../ai/vector_math.dart';
import '../core/models/catalog_item.dart';
import '../core/models/garment_attributes.dart';
import 'candidate_filter.dart';
import 'decisions.dart';
import 'matching_config.dart';
import 'rule_based_questions.dart';

/// Welche Stufe die Zuordnung entschieden hat.
enum Stage {
  filter('Vorfilter'),
  llm('LLM'),
  rueckfrage('Rückfrage'),
  nn('Bildvergleich (NN)'),
  manuell('Fotovergleich');

  const Stage(this.label);

  final String label;
}

class StageLog {
  const StageLog(this.step, this.elapsed, [this.detail = '']);

  final String step;
  final Duration elapsed;
  final String detail;

  @override
  String toString() => '$step: ${elapsed.inMilliseconds} ms${detail.isEmpty ? '' : ' – $detail'}';
}

class ManualCandidate {
  const ManualCandidate(this.item, this.imageSim);

  final CatalogItem item;
  final double? imageSim;
}

sealed class PipelineState {
  const PipelineState();
}

class PipelineWorking extends PipelineState {
  const PipelineWorking(this.message);

  final String message;
}

class PipelineQuestion extends PipelineState {
  const PipelineQuestion(this.question, this.round);

  final Question question;
  final int round;
}

class PipelineProposal extends PipelineState {
  const PipelineProposal({
    required this.item,
    required this.stage,
    required this.reason,
    this.userChosen = false,
    this.ownerOnly = false,
  });

  final CatalogItem item;
  final Stage stage;
  final String reason;

  /// true, wenn der Nutzer das Teil selbst im Fotovergleich gewählt hat.
  final bool userChosen;

  /// true, wenn nur der Besitzer sicher ist: Alle passenden Teile gehören
  /// derselben Person, welches genau es ist, bleibt offen. Für die Wäsche
  /// reicht das; die Lernschleife überspringt solche Ergebnisse.
  final bool ownerOnly;
}

class PipelineManualChoice extends PipelineState {
  const PipelineManualChoice(this.candidates, {this.reason = ''});

  final List<ManualCandidate> candidates;
  final String reason;
}

class PipelineNoMatch extends PipelineState {
  const PipelineNoMatch(this.reason);

  final String reason;
}

/// Zustandsautomat der 4-stufigen Zuordnung:
/// Beschreiben -> Vorfilter -> LLM (-> Rückfrage) -> NN -> Fotovergleich.
///
/// Rein in Dart, ohne Flutter: Engines und Katalog werden hineingereicht.
class IdentificationPipeline {
  IdentificationPipeline({
    required this.describer,
    required this.matcher,
    this.embedder,
    this.config = const MatchingConfig(),
    this.onProgress,
  }) : _filter = CandidateFilter(config);

  final DescriberEngine describer;
  final MatcherEngine matcher;
  final EmbeddingEngine? embedder;
  final MatchingConfig config;
  final void Function(String message)? onProgress;

  final CandidateFilter _filter;
  final _rules = const RuleBasedQuestions();

  // Sitzungszustand eines Scans
  final List<StageLog> log = [];
  final Stopwatch _total = Stopwatch();
  List<CatalogItem> _catalog = const [];
  GarmentAttributes scanAttributes = GarmentAttributes.empty;
  String scanRaw = '';
  Float32List? scanEmbedding;
  CandidateRanking? ranking;
  List<CatalogItem> _remaining = const [];
  final List<String> _answers = [];
  final Set<String> _askedRuleDims = {};
  int _round = 0;
  Question? _currentQuestion;

  int get questionRounds => _round;
  Duration get totalElapsed => _total.elapsed;
  List<CatalogItem> get remaining => List.unmodifiable(_remaining);

  void _progress(String m) => onProgress?.call(m);

  Future<T> _timed<T>(String step, Future<T> Function() f, [String Function(T)? detail]) async {
    final sw = Stopwatch()..start();
    final r = await f();
    log.add(StageLog(step, sw.elapsed, detail?.call(r) ?? ''));
    return r;
  }

  Future<PipelineState> start(Uint8List photo, List<CatalogItem> catalog) async {
    log.clear();
    _answers.clear();
    _askedRuleDims.clear();
    _round = 0;
    _currentQuestion = null;
    _catalog = catalog;
    _total
      ..reset()
      ..start();

    if (embedder != null) {
      _progress('Bildmerkmale berechnen …');
      try {
        final vs = await _timed('Embedding', () => embedder!.embed(photo), (v) => '${v.first.length} Dimensionen');
        scanEmbedding = vs.first;
      } catch (e) {
        log.add(StageLog('Embedding', Duration.zero, 'Fehler: $e'));
        scanEmbedding = null;
      }
    }

    _progress('Kleidungsstück wird beschrieben …');
    try {
      final d = await _timed('VLM-Beschreibung', () => describer.describe(photo), (d) => d.attributes.summary());
      scanAttributes = d.attributes;
      scanRaw = d.raw;
    } catch (e) {
      log.add(StageLog('VLM-Beschreibung', Duration.zero, 'Fehler: $e'));
      scanAttributes = GarmentAttributes.empty;
    }

    if (catalog.isEmpty) {
      return _finish(const PipelineNoMatch('Es sind noch keine Kleidungsstücke eingepflegt.'));
    }

    final r = _filter.rank(scan: scanAttributes, catalog: catalog, scanEmbedding: scanEmbedding);
    ranking = r;
    log.add(StageLog(
      'Vorfilter',
      Duration.zero,
      r.ranked
          .take(4)
          .map((c) => '${c.item.displayName}: ${c.total.toStringAsFixed(2)}'
              ' (Attr ${c.attributeScore.toStringAsFixed(2)}, Bild ${c.imageSim?.toStringAsFixed(2) ?? '–'})')
          .join(' | '),
    ));
    _remaining = r.ranked.map((c) => c.item).toList();

    if (r.decisive) {
      return _finish(PipelineProposal(
        item: r.best!.item,
        stage: Stage.filter,
        reason: 'Eindeutig nach Beschreibung und Bild (Score ${r.best!.total.toStringAsFixed(2)}).',
      ));
    }
    if (!r.categoryFallback && r.ranked.length > 1) {
      final best = r.best!;
      final contenders =
          r.ranked.where((c) => c.total >= best.total - config.ownerContenderWindow).map((c) => c.item).toList();
      if (contenders.length > 1 && best.total >= config.ownerMinScore && _singleOwner(contenders)) {
        return _finish(_ownerProposal(best.item, Stage.filter, contenders.length));
      }
    }
    if (r.categoryFallback || _remaining.length == 1) {
      // Nichts zu unterscheiden (ein Kandidat) oder Kategorie unsicher:
      // direkt der Bildvergleich entscheidet.
      return _finish(_neuralStage(_remaining));
    }
    return _llmStage();
  }

  Future<PipelineState> _llmStage() async {
    if (_remaining.length > 1 && _singleOwner(_remaining)) {
      return _finish(_ownerProposal(_remaining.first, _round > 0 ? Stage.rueckfrage : Stage.filter, _remaining.length));
    }
    final labeled = <LabeledCandidate>[
      for (var i = 0; i < _remaining.length && i < candidateLabels.length; i++)
        LabeledCandidate(
          label: candidateLabels[i],
          itemId: _remaining[i].id,
          attributes: _remaining[i].attributes,
          markierung: _remaining[i].markierung,
        ),
    ];

    MatchDecision decision = const InvalidDecision('nicht ausgeführt');
    for (var attempt = 0; attempt <= config.maxLlmRetries; attempt++) {
      _progress(attempt == 0 ? 'Zuordnung wird geprüft …' : 'Zuordnung, zweiter Versuch …');
      try {
        decision = await _timed(
          'LLM-Zuordnung${attempt > 0 ? ' (Wdh.)' : ''}',
          () => matcher.decide(scan: scanAttributes, candidates: labeled, previousAnswers: _answers),
          _describeDecision,
        );
      } catch (e) {
        decision = InvalidDecision('Fehler: $e');
        log.add(StageLog('LLM-Zuordnung', Duration.zero, 'Fehler: $e'));
        break; // Ein Absturz der Laufzeit wird nicht wiederholt.
      }
      if (decision is! InvalidDecision) break;
    }

    final remainingIds = _remaining.map((i) => i.id).toSet();
    switch (decision) {
      case AssignDecision(:final itemId, :final confidence, :final reason) when confidence >= 0.6:
        return _finish(PipelineProposal(
          item: _byId(itemId),
          stage: _round > 0 ? Stage.rueckfrage : Stage.llm,
          reason: reason.isNotEmpty ? reason : 'Vom LLM zugeordnet (Sicherheit ${(confidence * 100).round()} %).',
        ));
      case AssignDecision():
        // Zu unsicher: Bildvergleich mit allen verbleibenden Kandidaten.
        return _finish(_neuralStage(_remaining));
      case AskDecision(:final question) when _round < config.maxQuestionRounds:
        final cleaned = _restrictQuestion(question, remainingIds);
        if (cleaned != null) return _ask(cleaned);
        return _ruleQuestionOrNeural();
      case AskDecision():
        return _finish(_neuralStage(_remaining));
      case UnclearDecision(:final itemIds):
        final subset = _remaining.where((i) => itemIds.contains(i.id)).toList();
        if (subset.length == 1) {
          return _finish(PipelineProposal(item: subset.first, stage: Stage.llm, reason: 'Nur ein Teil passt.'));
        }
        return _finish(_neuralStage(subset.isEmpty ? _remaining : subset));
      case InvalidDecision():
        return _ruleQuestionOrNeural();
    }
  }

  Future<PipelineState> _ruleQuestionOrNeural() async {
    if (_round < config.maxQuestionRounds) {
      final q = _rules.build(_remaining, alreadyAsked: _askedRuleDims);
      if (q != null) {
        _askedRuleDims.add(q.source.replaceFirst('regel:', ''));
        log.add(StageLog('Regel-Rückfrage', Duration.zero, q.text));
        return _ask(q);
      }
    }
    return _finish(_neuralStage(_remaining));
  }

  PipelineState _ask(Question q) {
    _currentQuestion = q;
    return PipelineQuestion(q, _round + 1);
  }

  /// Entfernt Teile aus den Optionen, die nicht mehr im Rennen sind, und
  /// verwirft Fragen, die danach nichts mehr unterscheiden.
  Question? _restrictQuestion(Question q, Set<String> remainingIds) {
    final opts = <AnswerOption>[];
    for (final o in q.options) {
      final ids = o.itemIds.where(remainingIds.contains).toList();
      if (ids.isNotEmpty) opts.add(AnswerOption(text: o.text, itemIds: ids));
    }
    final distinct = opts.map((o) => (o.itemIds.toList()..sort()).join(',')).toSet();
    if (opts.length < 2 || distinct.length < 2) return null;
    return Question(text: q.text, options: opts, source: q.source);
  }

  Future<PipelineState> answer(AnswerOption option) async {
    final q = _currentQuestion;
    _round++;
    _answers.add('${q?.text ?? 'Frage'} -> ${option.text}');
    log.add(StageLog('Antwort', Duration.zero, option.text));
    final subset = _remaining.where((i) => option.itemIds.contains(i.id)).toList();
    if (subset.isNotEmpty) _remaining = subset;

    if (_remaining.length == 1) {
      return _finish(PipelineProposal(
        item: _remaining.first,
        stage: Stage.rueckfrage,
        reason: 'Durch die Antwort „${option.text}“ eindeutig.',
      ));
    }
    if (_round >= config.maxQuestionRounds) return _finish(_neuralStage(_remaining));
    if (q != null && q.source.startsWith('regel')) return _ruleQuestionOrNeural();
    return _llmStage();
  }

  /// „Weiß nicht“: direkt zum Bildvergleich.
  Future<PipelineState> answerUnknown() async {
    _round++;
    log.add(const StageLog('Antwort', Duration.zero, 'weiß nicht'));
    return _finish(_neuralStage(_remaining));
  }

  PipelineState _neuralStage(List<CatalogItem> pool) {
    final sw = Stopwatch()..start();
    final emb = scanEmbedding;
    final scored = <ManualCandidate>[
      for (final i in pool) ManualCandidate(i, emb == null ? null : maxSimilarity(emb, i.allEmbeddings)),
    ];
    scored.sort((a, b) => (b.imageSim ?? -1).compareTo(a.imageSim ?? -1));
    log.add(StageLog(
      'NN-Bildvergleich',
      sw.elapsed,
      scored.take(4).map((c) => '${c.item.displayName}: ${c.imageSim?.toStringAsFixed(3) ?? '–'}').join(' | '),
    ));

    if (scored.isNotEmpty && scored.first.imageSim != null) {
      final top = scored.first.imageSim!;
      final second = scored.length > 1 ? (scored[1].imageSim ?? 0) : 0.0;
      if (top >= config.nnAcceptSim && (scored.length == 1 || top - second >= config.nnMinMargin)) {
        return PipelineProposal(
          item: scored.first.item,
          stage: Stage.nn,
          reason: 'Bildvergleich: Ähnlichkeit ${top.toStringAsFixed(2)}'
              '${scored.length > 1 ? ', Abstand zum nächsten ${(top - second).toStringAsFixed(2)}' : ''}.',
        );
      }
    }
    if (scored.length > 1 && _singleOwner(scored.map((c) => c.item))) {
      return _ownerProposal(scored.first.item, Stage.nn, scored.length);
    }
    return PipelineManualChoice(
      scored,
      reason: emb == null
          ? 'Kein Bildvergleich möglich – bitte selbst abgleichen.'
          : 'Die Bilder sind sich zu ähnlich – bitte selbst abgleichen.',
    );
  }

  /// „Falsch“ beim Vorschlag: Fotovergleich mit allen übrigen Kandidaten
  /// derselben Kategorie (nach Bildähnlichkeit sortiert).
  PipelineState reject(String itemId) {
    log.add(StageLog('Vorschlag abgelehnt', Duration.zero, itemId));
    final ranked = ranking?.ranked.map((c) => c.item).toList() ?? <CatalogItem>[];
    final sameCategory = _catalog.where((i) => i.attributes.kategorie == scanAttributes.kategorie);
    final pool = <CatalogItem>[
      ...ranked,
      for (final i in sameCategory)
        if (!ranked.any((r) => r.id == i.id)) i,
    ].where((i) => i.id != itemId).take(12).toList();
    if (pool.isEmpty) return const PipelineNoMatch('Kein anderes passendes Teil gefunden.');
    final state = _neuralStage(pool);
    // Nach einer Ablehnung entscheidet der Nutzer selbst.
    if (state is PipelineProposal) {
      return PipelineManualChoice([
        for (final i in pool) ManualCandidate(i, scanEmbedding == null ? null : maxSimilarity(scanEmbedding!, i.allEmbeddings)),
      ]..sort((a, b) => (b.imageSim ?? -1).compareTo(a.imageSim ?? -1)));
    }
    return state;
  }

  PipelineProposal chooseManually(String itemId) {
    log.add(StageLog('Manuell gewählt', Duration.zero, itemId));
    return _finish(PipelineProposal(
      item: _byId(itemId),
      stage: Stage.manuell,
      reason: 'Im Fotovergleich ausgewählt.',
      userChosen: true,
    )) as PipelineProposal;
  }

  PipelineState noneMatches() =>
      _finish(const PipelineNoMatch('Kein eingepflegtes Teil passt – das Teil ist vermutlich neu.'));

  static bool _singleOwner(Iterable<CatalogItem> items) => items.map((i) => i.personId).toSet().length == 1;

  PipelineProposal _ownerProposal(CatalogItem representative, Stage stage, int count) => PipelineProposal(
    item: representative,
    stage: stage,
    reason: 'Alle $count passenden Teile gehören ${representative.personName}.',
    ownerOnly: true,
  );

  CatalogItem _byId(String id) => _catalog.firstWhere((i) => i.id == id);

  PipelineState _finish(PipelineState s) {
    if (s is PipelineProposal || s is PipelineNoMatch) _total.stop();
    return s;
  }

  static String _describeDecision(MatchDecision d) => switch (d) {
    AssignDecision(:final itemId, :final confidence) => 'zuordnen $itemId (${confidence.toStringAsFixed(2)})',
    AskDecision(:final question) => 'rückfrage: ${question.text}',
    UnclearDecision(:final itemIds) => 'unklar: ${itemIds.length} Teile',
    InvalidDecision(:final reason) => 'ungültig: $reason',
  };
}
