import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/gemma_service.dart';
import '../../app/providers.dart';
import '../../core/device/device_info.dart';

String modelPhaseText(ModelPhase p) => switch (p) {
  ModelPhase.unknown => 'Status wird geprüft …',
  ModelPhase.notInstalled => 'KI-Modell nicht installiert',
  ModelPhase.downloading => 'KI-Modell wird heruntergeladen …',
  ModelPhase.installed => 'KI-Modell bereit (wird bei Bedarf geladen)',
  ModelPhase.loading => 'KI-Modell wird in den Speicher geladen …',
  ModelPhase.ready => 'KI-Modell aktiv',
  ModelPhase.error => 'KI-Modell: Fehler',
};

/// Einmaliger Download von Gemma 4 E2B (~2,6 GB).
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  DeviceSnapshot? _device;

  @override
  void initState() {
    super.initState();
    DeviceInfo.snapshot().then((d) => mounted ? setState(() => _device = d) : null);
    ref.read(gemmaServiceProvider).refreshInstalled();
  }

  Future<void> _download() async {
    final free = _device?.freeDiskBytes;
    if (free != null && free < GemmaModelSpec.approxBytes + 500 * 1000 * 1000) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Wenig Speicherplatz'),
          content: Text('Frei: ${DeviceSnapshot.gb(free)}. Das Modell braucht etwa 2,6 GB plus Puffer. Trotzdem versuchen?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Abbrechen')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Trotzdem')),
          ],
        ),
      );
      if (ok != true) return;
    }
    try {
      await ref.read(gemmaServiceProvider).install();
    } catch (_) {
      // Fehler steht im Status.
    }
  }

  @override
  Widget build(BuildContext context) {
    final gemma = ref.watch(gemmaServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('KI-Modell einrichten')),
      body: ValueListenableBuilder<ModelStatus>(
        valueListenable: gemma.status,
        builder: (context, st, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Die Erkennung läuft komplett auf dem Handy. Dafür wird einmalig das Modell '
              '${GemmaModelSpec.displayName} heruntergeladen (ca. 2,6 GB). Bitte WLAN verwenden.',
            ),
            const SizedBox(height: 16),
            if (_device != null)
              Card(
                child: Padding(padding: const EdgeInsets.all(12), child: Text(_device!.describe())),
              ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(switch (st.phase) {
                ModelPhase.installed || ModelPhase.ready => Icons.check_circle,
                ModelPhase.error => Icons.error,
                _ => Icons.download,
              }),
              title: Text(modelPhaseText(st.phase)),
              subtitle: st.message.isEmpty ? null : Text(st.message),
            ),
            if (st.phase == ModelPhase.downloading) ...[
              LinearProgressIndicator(value: st.progress / 100),
              const SizedBox(height: 8),
              Text('${st.progress} %', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'Der Download läuft im Hintergrund weiter (Benachrichtigung). Die App bitte nicht beenden.',
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            if (st.phase == ModelPhase.notInstalled || st.phase == ModelPhase.error || st.phase == ModelPhase.unknown)
              FilledButton.icon(onPressed: _download, icon: const Icon(Icons.download), label: const Text('Modell herunterladen')),
            if (st.phase == ModelPhase.installed || st.phase == ModelPhase.ready)
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fertig')),
            const Divider(height: 32),
            SwitchListTile(
              title: const Text('Speicher sparen'),
              subtitle: const Text(
                'Gibt den Arbeitsspeicher wenige Sekunden nach jedem Scan wieder frei. '
                'Jeder Scan dauert dann etwas länger, weil die KI neu lädt.',
              ),
              value: gemma.unloadAfterUse,
              onChanged: (v) async {
                gemma.unloadAfterUse = v;
                await ref.read(databaseProvider).setSetting(memorySaverKey, v ? '1' : '0');
                if (v) await gemma.unload();
                setState(() {});
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hinweis: Android zeigt auch Zwischenspeicher als „belegt“ an. Den gibt das System sofort frei, '
                'wenn eine andere App Platz braucht. Echte Belegung durch WäscheWer siehst du im Machbarkeits-Test.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
