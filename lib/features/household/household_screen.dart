import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/widgets.dart';

/// Haushaltspaket: Kleidertabelle als ZIP teilen und auf anderen Handys
/// einspielen (bis zum automatischen Sync in Phase 2).
class HouseholdScreen extends ConsumerStatefulWidget {
  const HouseholdScreen({super.key});

  @override
  ConsumerState<HouseholdScreen> createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends ConsumerState<HouseholdScreen> {
  DateTime? _lastExport;
  bool _busy = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    ref.read(householdProvider).lastExportAt().then((d) => mounted ? setState(() => _lastExport = d) : null);
  }

  Future<void> _export({required bool deltaOnly}) async {
    setState(() {
      _busy = true;
      _status = 'Paket wird erstellt …';
    });
    try {
      final pkg = ref.read(householdProvider);
      final dir = await getTemporaryDirectory();
      final file = await pkg.exportToFile(dir, since: deltaOnly ? _lastExport : null);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/zip')],
        text: 'WäscheWer-Haushaltspaket – in der App unter „Haushaltspaket → Importieren“ öffnen.',
      ));
      final last = await pkg.lastExportAt();
      setState(() {
        _lastExport = last;
        _status = 'Paket erstellt (${(file.lengthSync() / 1e6).toStringAsFixed(1)} MB).';
      });
    } catch (e) {
      setState(() => _status = 'Export fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final f = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['zip']);
    if (f == null) return;
    setState(() {
      _busy = true;
      _status = 'Paket wird eingelesen …';
    });
    try {
      final bytes = await f.xFile.readAsBytes();
      final report = await ref.read(householdProvider).import(bytes);
      setState(() => _status = 'Importiert:\n${report.describe()}\n\nBildmerkmale werden berechnet …');
      final n = await ref.read(repositoryProvider).ensureEmbeddings(
        ref.read(embedderProvider),
        onProgress: (done, total) {
          if (mounted) setState(() => _status = 'Importiert:\n${report.describe()}\n\nBildmerkmale: $done / $total');
        },
      );
      setState(() => _status = 'Importiert:\n${report.describe()}\n\nBildmerkmale für $n Fotos berechnet.');
    } catch (e) {
      setState(() => _status = 'Import fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Haushaltspaket')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Die Kleidertabelle liegt auf jedem Handy lokal. Mit dem Haushaltspaket gibst du sie an die '
          'anderen weiter, z. B. per Messenger. Beim Import wird zusammengeführt: Neues kommt dazu, '
          'bei Änderungen gewinnt der neuere Stand.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy ? null : () => _export(deltaOnly: false),
          icon: const Icon(Icons.ios_share),
          label: const Text('Komplettes Paket teilen'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy || _lastExport == null ? null : () => _export(deltaOnly: true),
          icon: const Icon(Icons.update),
          label: Text(_lastExport == null ? 'Nur Neues teilen (nach erstem Export)' : 'Nur Neues seit ${_fmt(_lastExport!)} teilen'),
        ),
        const Divider(height: 32),
        FilledButton.tonalIcon(
          onPressed: _busy ? null : _import,
          icon: const Icon(Icons.download),
          label: const Text('Paket importieren'),
        ),
        const SizedBox(height: 16),
        if (_busy) const LinearProgressIndicator(),
        if (_status != null)
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(_status!))),
        const SizedBox(height: 16),
        Text(
          'Tipp: Wer neue Kleidung einpflegt, teilt danach „Nur Neues“. So bleibt das Paket klein.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (_status != null && _status!.contains('fehlgeschlagen'))
          TextButton(onPressed: () => showSnack(context, _status!), child: const Text('Fehler anzeigen')),
      ],
    ),
  );

  static String _fmt(DateTime d) {
    final l = d.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(l.day)}.${two(l.month)}. ${two(l.hour)}:${two(l.minute)}';
  }
}
