import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/engines.dart';
import '../../ai/gemma_service.dart';
import '../../app/providers.dart';
import '../../app/widgets.dart';
import '../../core/db/wardrobe_repository.dart';
import '../../core/device/device_info.dart';
import '../../core/utils/image_prep.dart';
import '../../pipeline/decisions.dart';
import '../../pipeline/identification_pipeline.dart';
import '../../pipeline/matching_config.dart';
import '../capture/capture_screen.dart';
import '../wardrobe/item_edit_screen.dart';

/// Verkleinert das Bild vor dem VLM (weniger Bild-Tokens, schneller).
class _VlmSizedDescriber implements DescriberEngine {
  _VlmSizedDescriber(this.inner);

  final DescriberEngine inner;

  @override
  Future<Description> describe(Uint8List jpeg) async =>
      inner.describe(await ImagePrep.resize(jpeg, size: ImagePrep.vlmSize));
}

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  IdentificationPipeline? _pipeline;
  PipelineState? _state;
  Uint8List? _photo;
  String _progress = '';
  bool _logged = false;
  String _device = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scan());
    DeviceInfo.snapshot().then((s) => _device = s.model ?? '');
  }

  Future<void> _scan() async {
    final bytes = await CaptureScreen.open(context, title: 'Teil scannen');
    if (!mounted) return;
    if (bytes == null) {
      if (_photo == null) Navigator.of(context).pop();
      return;
    }
    final p = IdentificationPipeline(
      describer: _VlmSizedDescriber(ref.read(describerProvider)),
      matcher: ref.read(matcherProvider),
      embedder: ref.read(embedderProvider),
      // Der Gemma-Matcher hat einen eigenen JSON-Rückfall; eine weitere
      // Wiederholung würde auf langsamen Geräten nur Zeit kosten.
      config: const MatchingConfig(maxLlmRetries: 0),
      onProgress: (m) {
        if (mounted) setState(() => _progress = m);
      },
    );
    setState(() {
      _pipeline = p;
      _photo = bytes;
      _state = const PipelineWorking('Start …');
      _progress = 'Katalog wird geladen …';
      _logged = false;
    });
    try {
      final catalog = await ref.read(repositoryProvider).loadCatalog(ref.read(embedderProvider).modelId);
      final s = await p.start(bytes, catalog);
      if (mounted) setState(() => _state = s);
    } catch (e) {
      if (mounted) setState(() => _state = PipelineNoMatch('Fehler: $e'));
    }
  }

  Future<void> _step(Future<PipelineState> Function(IdentificationPipeline p) f) async {
    final p = _pipeline;
    if (p == null) return;
    setState(() => _state = const PipelineWorking('…'));
    try {
      final s = await f(p);
      if (mounted) setState(() => _state = s);
    } catch (e) {
      if (mounted) setState(() => _state = PipelineNoMatch('Fehler: $e'));
    }
  }

  Future<void> _confirm(PipelineProposal prop) async {
    final p = _pipeline!;
    final repo = ref.read(repositoryProvider);
    if (!_logged) {
      _logged = true;
      await repo.logScan(
        itemId: prop.item.id,
        stage: prop.stage.name,
        rounds: p.questionRounds,
        durationMs: p.totalElapsed.inMilliseconds,
        confirmed: true,
        device: _device,
        backend: ref.read(gemmaServiceProvider).status.value.backend?.name ?? '',
        detail: p.log.join('\n'),
      );
      // Lernschleife: bestätigter Scan wird weiteres Referenzbild.
      if (!prop.ownerOnly && _photo != null) {
        await repo.addPhoto(prop.item.id, NewPhoto(_photo!, 'scan'), embedder: ref.read(embedderProvider));
      }
    }
    if (mounted) _scan();
  }

  Future<void> _logUnconfirmed(String stage) async {
    final p = _pipeline;
    if (p == null || _logged) return;
    _logged = true;
    await ref.read(repositoryProvider).logScan(
      itemId: null,
      stage: stage,
      rounds: p.questionRounds,
      durationMs: p.totalElapsed.inMilliseconds,
      confirmed: false,
      device: _device,
      detail: p.log.join('\n'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _state;
    return Scaffold(
      appBar: AppBar(title: const Text('Scannen')),
      body: _photo == null || s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(child: PhotoThumb(bytes: _photo, size: 160, radius: 12)),
                const SizedBox(height: 8),
                ValueListenableBuilder<ModelStatus>(
                  valueListenable: ref.watch(gemmaServiceProvider).status,
                  builder: (context, st, _) => st.phase == ModelPhase.error || st.phase == ModelPhase.notInstalled
                      ? Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: ListTile(
                            leading: const Icon(Icons.warning_amber),
                            title: Text(st.phase == ModelPhase.notInstalled
                                ? 'KI-Modell nicht installiert – es entscheidet nur der Bildvergleich.'
                                : 'KI-Modell nicht verfügbar – es entscheidet nur der Bildvergleich.'),
                            subtitle: st.message.isEmpty ? null : Text(st.message),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 8),
                switch (s) {
                  PipelineWorking() => _Working(text: _progress),
                  PipelineQuestion(:final question, :final round) => _QuestionView(
                    question: question,
                    round: round,
                    onAnswer: (o) => _step((p) => p.answer(o)),
                    onUnknown: () => _step((p) => p.answerUnknown()),
                  ),
                  PipelineManualChoice(:final candidates, :final reason) => _ManualView(
                    candidates: candidates,
                    reason: reason,
                    onChoose: (id) => setState(() => _state = _pipeline!.chooseManually(id)),
                    onNone: () {
                      _logUnconfirmed('keins');
                      setState(() => _state = _pipeline!.noneMatches());
                    },
                  ),
                  PipelineProposal() => _ProposalView(
                    proposal: s,
                    onConfirm: () => _confirm(s),
                    onReject: () => setState(() => _state = _pipeline!.reject(s.item.id)),
                  ),
                  PipelineNoMatch(:final reason) => _NoMatchView(
                    reason: reason,
                    onNewItem: () {
                      _logUnconfirmed('neu');
                      ItemEditScreen.open(context, initialPhoto: _photo);
                    },
                    onRetry: _scan,
                  ),
                },
                const SizedBox(height: 16),
                if (_pipeline != null && s is! PipelineWorking) _DebugLog(pipeline: _pipeline!),
              ],
            ),
    );
  }
}

class _Working extends StatelessWidget {
  const _Working({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const SizedBox(height: 24),
      const CircularProgressIndicator(),
      const SizedBox(height: 16),
      Text(text, textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(
        'Auf diesem Gerät kann das einige Sekunden dauern.',
        style: Theme.of(context).textTheme.bodySmall,
        textAlign: TextAlign.center,
      ),
    ],
  );
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.question, required this.round, required this.onAnswer, required this.onUnknown});

  final Question question;
  final int round;
  final ValueChanged<AnswerOption> onAnswer;
  final VoidCallback onUnknown;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Rückfrage $round', style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      Text(question.text, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      for (final o in question.options)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: () => onAnswer(o),
            child: Text(o.text, textAlign: TextAlign.center),
          ),
        ),
      OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        onPressed: onUnknown,
        child: const Text('Weiß nicht'),
      ),
    ],
  );
}

class _ManualView extends StatelessWidget {
  const _ManualView({required this.candidates, required this.reason, required this.onChoose, required this.onNone});

  final List<ManualCandidate> candidates;
  final String reason;
  final ValueChanged<String> onChoose;
  final VoidCallback onNone;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Selbst abgleichen', style: Theme.of(context).textTheme.titleLarge),
      Text(reason),
      const SizedBox(height: 12),
      for (final c in candidates) _CandidateCard(candidate: c, onTap: () => onChoose(c.item.id)),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: onNone, icon: const Icon(Icons.help_outline), label: const Text('Keins davon')),
    ],
  );
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.candidate, required this.onTap});

  final ManualCandidate candidate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final it = candidate.item;
    final refs = it.photos.where((p) => p.art != 'scan').toList();
    final shown = (refs.isEmpty ? it.photos : refs).take(3).toList();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PersonDot(color: it.personColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${it.personName} – ${it.displayName}', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  if (candidate.imageSim != null)
                    Text('${(candidate.imageSim! * 100).round()} %', style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final p in shown)
                    Padding(padding: const EdgeInsets.only(right: 6), child: PhotoThumb(path: p.path, size: 96)),
                ],
              ),
              if (it.attributes.besondereMerkmale.isNotEmpty || it.markierung.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    [it.attributes.besondereMerkmale, if (it.markierung.isNotEmpty) 'Markierung: ${it.markierung}']
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProposalView extends StatelessWidget {
  const _ProposalView({required this.proposal, required this.onConfirm, required this.onReject});

  final PipelineProposal proposal;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final it = proposal.item;
    final color = Color(it.personColor);
    final onColor = ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? Colors.white : Colors.black;
    final refPhoto = it.photos.where((p) => p.art != 'scan').firstOrNull ?? it.photos.firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text('Gehört', style: TextStyle(color: onColor.withValues(alpha: 0.8), fontSize: 16)),
              Text(it.personName, style: TextStyle(color: onColor, fontSize: 40, fontWeight: FontWeight.bold)),
              if (!proposal.ownerOnly) Text(it.displayName, style: TextStyle(color: onColor), textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (refPhoto != null && !proposal.ownerOnly)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Referenz: '),
              PhotoThumb(path: refPhoto.path, size: 72),
            ],
          ),
        const SizedBox(height: 8),
        Text('${proposal.stage.label}: ${proposal.reason}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        Row(
          children: [
            if (!proposal.userChosen)
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: onReject,
                  icon: const Icon(Icons.close),
                  label: const Text('Falsch'),
                ),
              ),
            if (!proposal.userChosen) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: onConfirm,
                icon: const Icon(Icons.check),
                label: const Text('Stimmt – nächstes Teil'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NoMatchView extends StatelessWidget {
  const _NoMatchView({required this.reason, required this.onNewItem, required this.onRetry});

  final String reason;
  final VoidCallback onNewItem;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(Icons.search_off, size: 48),
      const SizedBox(height: 8),
      Text(reason, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 16),
      FilledButton.icon(onPressed: onNewItem, icon: const Icon(Icons.add), label: const Text('Als neues Teil einpflegen')),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.camera_alt), label: const Text('Nochmal scannen')),
    ],
  );
}

class _DebugLog extends StatelessWidget {
  const _DebugLog({required this.pipeline});

  final IdentificationPipeline pipeline;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text('Details (${(pipeline.totalElapsed.inMilliseconds / 1000).toStringAsFixed(1)} s)'),
    children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: SelectableText(
          [
            'Beschreibung: ${pipeline.scanAttributes.summary()}',
            ...pipeline.log.map((l) => l.toString()),
          ].join('\n'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ],
  );
}
