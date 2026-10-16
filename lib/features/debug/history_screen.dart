import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../core/db/database.dart';
import '../../pipeline/identification_pipeline.dart';

/// Scan-Verlauf mit Statistik: welche Stufe wie oft entschieden hat.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Scan-Verlauf')),
    body: FutureBuilder<List<ScanLogRow>>(
      future: ref.read(repositoryProvider).recentScans(limit: 200),
      builder: (context, snap) {
        final rows = snap.data;
        if (rows == null) return const Center(child: CircularProgressIndicator());
        if (rows.isEmpty) return const Center(child: Text('Noch keine Scans.'));
        final byStage = <String, int>{};
        for (final r in rows) {
          byStage[r.stage] = (byStage[r.stage] ?? 0) + 1;
        }
        final confirmed = rows.where((r) => r.confirmed).toList();
        final avgMs = confirmed.isEmpty
            ? 0
            : confirmed.map((r) => r.durationMs).reduce((a, b) => a + b) ~/ confirmed.length;
        String stageLabel(String s) => Stage.values.where((v) => v.name == s).firstOrNull?.label ?? s;
        final summary = [
          '${rows.length} Scans, ${confirmed.length} bestätigt, Ø ${(avgMs / 1000).toStringAsFixed(1)} s',
          for (final e in byStage.entries) '${stageLabel(e.key)}: ${e.value}',
        ].join('\n');
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: ListTile(
                title: const Text('Statistik'),
                subtitle: Text(summary),
                trailing: IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => SharePlus.instance.share(ShareParams(
                    text: '$summary\n\n${rows.map((r) => '${r.time.toIso8601String()} ${r.stage} ${r.durationMs} ms '
                        '${r.confirmed ? '✓' : '✗'} ${r.backend}\n${r.detail}').join('\n\n')}',
                  )),
                ),
              ),
            ),
            for (final r in rows)
              ExpansionTile(
                leading: Icon(r.confirmed ? Icons.check_circle_outline : Icons.help_outline),
                title: Text('${stageLabel(r.stage)} · ${(r.durationMs / 1000).toStringAsFixed(1)} s'),
                subtitle: Text(r.time.toLocal().toString().substring(0, 16)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SelectableText(r.detail, style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
          ],
        );
      },
    ),
  );
}
