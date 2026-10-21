import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../ai/gemma_service.dart';
import '../../ai/prompts.dart';
import '../../app/providers.dart';
import '../../core/device/device_info.dart';
import '../../core/models/garment_attributes.dart';
import '../../core/utils/image_prep.dart';
import '../../pipeline/decisions.dart';
import '../capture/capture_screen.dart';
import '../setup/setup_screen.dart';

/// Tastet den Speicher während einer Aufgabe ab (höchstens 1×/s, siehe
/// flutter_edge_ai_diagnostics) und merkt sich die Spitze.
class _MemorySampler {
  Timer? _t;
  int peakAnon = 0;
  int peakFile = 0;
  int minAvail = 1 << 62;

  void start() {
    _t = Timer.periodic(const Duration(seconds: 1), (_) async {
      final s = await DeviceInfo.snapshot();
      if ((s.appAnonymousBytes ?? 0) > peakAnon) peakAnon = s.appAnonymousBytes!;
      if ((s.appFileBackedBytes ?? 0) > peakFile) peakFile = s.appFileBackedBytes!;
      if (s.availRamBytes != null && s.availRamBytes! < minAvail) minAvail = s.availRamBytes!;
    });
  }

  String stop() {
    _t?.cancel();
    return 'Spitze (Abtastung 1/s): ${DeviceSnapshot.gb(peakAnon)} anonym + ${DeviceSnapshot.gb(peakFile)} dateibasiert, '
        'min. frei ${minAvail == 1 << 62 ? '–' : DeviceSnapshot.gb(minAvail)}';
  }
}

/// Machbarkeits-Test: misst Laden, Beschreiben, Zuordnen und Embedding auf
/// dem echten Gerät. Die Ergebnisse lassen sich als Text teilen.
class FeasibilityScreen extends ConsumerStatefulWidget {
  const FeasibilityScreen({super.key});

  @override
  ConsumerState<FeasibilityScreen> createState() => _FeasibilityScreenState();
}

class _FeasibilityScreenState extends ConsumerState<FeasibilityScreen> {
  DeviceSnapshot? _device;
  final List<String> _results = [];
  bool _busy = false;
  String _busyText = '';

  @override
  void initState() {
    super.initState();
    _refreshDevice();
  }

  Future<void> _refreshDevice() async {
    final d = await DeviceInfo.snapshot();
    if (mounted) setState(() => _device = d);
  }

  void _add(String title, String body) {
    final now = DateTime.now();
    final stamp = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    setState(() => _results.insert(0, '[$stamp] $title\n$body'));
  }

  Future<void> _guarded(String label, Future<void> Function() f) async {
    setState(() {
      _busy = true;
      _busyText = label;
    });
    final sampler = _MemorySampler()..start();
    try {
      await f();
    } catch (e) {
      _add('$label – FEHLER', '$e');
    } finally {
      final mem = sampler.stop();
      if (_results.isNotEmpty) _results[0] = '${_results[0]}\n$mem';
      await _refreshDevice();
      if (mounted) setState(() => _busy = false);
    }
  }

  GemmaService get _gemma => ref.read(gemmaServiceProvider);

  Future<void> _load() => _guarded('Modell laden', () async {
    await _gemma.unload();
    await _gemma.run((m) async {});
    _add('Modell laden', _gemma.lastLoad?.describe() ?? '–');
  });

  Future<void> _describe() async {
    final photo = await CaptureScreen.open(context, title: 'Testfoto');
    if (photo == null) return;
    await _guarded('Foto beschreiben', () async {
      final small = await ImagePrep.resize(photo, size: ImagePrep.vlmSize);
      final wasLoaded = _gemma.isLoaded;
      final sw = Stopwatch()..start();
      final d = await ref.read(describerProvider).describe(small);
      sw.stop();
      _add(
        'Foto beschreiben',
        'Gesamt: ${sw.elapsedMilliseconds} ms${wasLoaded ? '' : ' (inkl. Laden ${_gemma.lastLoad?.elapsed.inMilliseconds ?? '?'} ms)'}\n'
            'Text: ${_gemma.status.value.backend?.name ?? '–'}, Bild-Encoder: ${_gemma.visionBackend.name}'
            '${_gemma.visionFallbackReason != null ? ' (GPU fehlgeschlagen)' : ''}, '
            'über Werkzeug: ${d.viaTool ? 'ja' : 'nein (JSON-Rückfall)'}\n'
            'Ergebnis: ${d.attributes.summary()}\n'
            'Roh: ${d.raw}',
      );
    });
  }

  Future<void> _match() => _guarded('Zuordnung (Text)', () async {
    const candidates = [
      LabeledCandidate(
        label: 'A',
        itemId: 'a',
        attributes: GarmentAttributes(
          kategorie: 'Socke',
          farben: ['weiß'],
          muster: 'gerippt',
          laengeSchnitt: 'Knöchelsocke',
          besondereMerkmale: 'Rippung über den ganzen Socken',
        ),
      ),
      LabeledCandidate(
        label: 'B',
        itemId: 'b',
        attributes: GarmentAttributes(
          kategorie: 'Socke',
          farben: ['weiß'],
          muster: 'gerippt',
          laengeSchnitt: 'Knöchelsocke',
          besondereMerkmale: 'Rippung erst ab dem Knöchel, Fuß glatt',
        ),
      ),
    ];
    const scan = GarmentAttributes(kategorie: 'Socke', farben: ['weiß'], muster: 'gerippt');
    final sw = Stopwatch()..start();
    final matcher = ref.read(matcherProvider);
    final d = await matcher.decide(scan: scan, candidates: candidates);
    sw.stop();
    final text = switch (d) {
      AssignDecision(:final itemId, :final confidence) => 'zuordnen $itemId (${confidence.toStringAsFixed(2)})',
      AskDecision(:final question) =>
        'Rückfrage: ${question.text}\n${question.options.map((o) => '  • ${o.text} → ${o.itemIds.join(',')}').join('\n')}',
      UnclearDecision(:final itemIds) => 'unklar: ${itemIds.join(', ')}',
      InvalidDecision(:final reason) => 'ungültig: $reason',
    };
    _add('Zuordnung (Text, Beispiel weiße Socken)', '${sw.elapsedMilliseconds} ms\n$text\nRoh: ${matcher.lastRaw}');
  });

  Future<void> _embed() async {
    final photo = await CaptureScreen.open(context, title: 'Testfoto Embedding');
    if (photo == null) return;
    await _guarded('Bild-Embedding', () async {
      final e = ref.read(embedderProvider);
      final sw = Stopwatch()..start();
      final v = await e.embed(photo, augment: true);
      sw.stop();
      _add(
        'Bild-Embedding (MobileNetV3, 5 Varianten)',
        'Gesamt: ${sw.elapsedMilliseconds} ms (inkl. Vorverarbeitung), letzte Inferenz: ${e.lastInference.inMilliseconds} ms, '
            '${v.length} × ${v.first.length} Dimensionen',
      );
    });
  }

  Future<void> _unload() => _guarded('Entladen', () async {
    final before = await DeviceInfo.snapshot();
    await _gemma.unload();
    await Future<void>.delayed(const Duration(seconds: 1));
    final after = await DeviceInfo.snapshot();
    _add('Modell entladen', 'Vorher: ${before.describe()}\nNachher: ${after.describe()}');
  });

  void _share() {
    final header = [
      'WäscheWer Machbarkeits-Test',
      _device?.describe() ?? '',
      'Einstellungen: Text ${_gemma.preferredBackend.name}, Bild-Encoder ${_gemma.visionBackend.name}, '
          'Kontext ${_gemma.maxTokens}, Sparmodus ${_gemma.unloadAfterUse ? 'an' : 'aus'}',
    ].join('\n');
    SharePlus.instance.share(ShareParams(text: '$header\n\n${_results.reversed.join('\n\n')}'));
  }

  @override
  Widget build(BuildContext context) {
    final gemma = ref.watch(gemmaServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machbarkeits-Test'),
        actions: [IconButton(onPressed: _results.isEmpty ? null : _share, icon: const Icon(Icons.share))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_device?.describe() ?? 'Gerätedaten …'),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<ModelStatus>(
                    valueListenable: gemma.status,
                    builder: (_, st, _) => Text(
                      '${modelPhaseText(st.phase)}${st.backend != null ? ' – läuft auf ${st.backend!.name}' : ''}'
                      '${st.message.isNotEmpty ? '\n${st.message}' : ''}',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Backend: '),
              SegmentedButton<PreferredBackend>(
                segments: const [
                  ButtonSegment(value: PreferredBackend.gpu, label: Text('GPU')),
                  ButtonSegment(value: PreferredBackend.cpu, label: Text('CPU')),
                ],
                selected: {gemma.preferredBackend},
                onSelectionChanged: _busy
                    ? null
                    : (s) async {
                        await gemma.configure(backend: s.first);
                        setState(() {});
                      },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Bild-Encoder: '),
              SegmentedButton<PreferredBackend>(
                segments: const [
                  ButtonSegment(value: PreferredBackend.gpu, label: Text('GPU')),
                  ButtonSegment(value: PreferredBackend.cpu, label: Text('CPU')),
                ],
                selected: {gemma.visionBackend},
                onSelectionChanged: _busy
                    ? null
                    : (s) async {
                        await gemma.configure(vision: s.first);
                        setState(() {});
                      },
              ),
            ],
          ),
          if (gemma.visionFallbackReason != null)
            Text(
              'GPU-Bild-Encoder ist fehlgeschlagen, es läuft CPU: ${gemma.visionFallbackReason}',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Kontext: '),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1024, label: Text('1024')),
                  ButtonSegment(value: 2048, label: Text('2048')),
                  ButtonSegment(value: 4096, label: Text('4096')),
                ],
                selected: {gemma.maxTokens},
                onSelectionChanged: _busy
                    ? null
                    : (s) async {
                        await gemma.configure(maxTokens: s.first);
                        setState(() {});
                      },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: _busy ? null : _load, child: const Text('1. Modell laden')),
              FilledButton(onPressed: _busy ? null : _describe, child: const Text('2. Foto beschreiben')),
              FilledButton(onPressed: _busy ? null : _match, child: const Text('3. Zuordnung testen')),
              FilledButton(onPressed: _busy ? null : _embed, child: const Text('4. Bild-Embedding')),
              OutlinedButton(onPressed: _busy ? null : _unload, child: const Text('Entladen')),
            ],
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
            Text(_busyText),
          ],
          const SizedBox(height: 12),
          if (_results.isEmpty)
            const Text(
              'Ablauf: 1 → 2 (mit ~10 verschiedenen Teilen) → 3 → 4, dann mit „CPU“ wiederholen. '
              'Oben rechts die Ergebnisse teilen und mir schicken.',
            ),
          for (final r in _results)
            Card(child: Padding(padding: const EdgeInsets.all(12), child: SelectableText(r))),
        ],
      ),
    );
  }
}
