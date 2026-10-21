import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ai/gemma_service.dart';
import '../../app/providers.dart';
import '../../app/widgets.dart';
import '../setup/setup_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(gemmaServiceProvider).refreshInstalled();
  }

  @override
  Widget build(BuildContext context) {
    final gemma = ref.watch(gemmaServiceProvider);
    final persons = ref.watch(personsProvider).value ?? const [];
    final items = ref.watch(itemsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('WäscheWer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ValueListenableBuilder<ModelStatus>(
            valueListenable: gemma.status,
            builder: (context, st, _) {
              if (st.phase == ModelPhase.ready || st.phase == ModelPhase.loading) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.memory),
                    title: Text(st.phase == ModelPhase.loading ? 'KI wird geladen …' : 'KI belegt Arbeitsspeicher'),
                    subtitle: Text(gemma.unloadAfterUse
                        ? 'Sparmodus: wird nach dem Scan sofort freigegeben.'
                        : 'Wird nach 1 Minute ohne Nutzung automatisch freigegeben.'),
                    trailing: st.phase == ModelPhase.ready
                        ? TextButton(onPressed: gemma.unload, child: const Text('Freigeben'))
                        : null,
                  ),
                );
              }
              if (st.phase == ModelPhase.installed) return const SizedBox.shrink();
              return Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(modelPhaseText(st.phase)),
                  subtitle: Text(
                    st.phase == ModelPhase.downloading
                        ? '${st.progress} %'
                        : 'Einmalig ca. 2,6 GB laden, damit die Erkennung offline läuft.',
                  ),
                  onTap: () => context.push('/setup'),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: FilledButton(
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () {
                if (items.isEmpty) {
                  showSnack(context, 'Zuerst Personen anlegen und Teile einpflegen.');
                  return;
                }
                context.push('/scan');
              },
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.document_scanner, size: 48),
                  SizedBox(height: 8),
                  Text('Teil scannen', style: TextStyle(fontSize: 22)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Tile(
            icon: Icons.checkroom,
            title: 'Kleiderschrank',
            subtitle: '${items.length} Teile',
            onTap: () => context.push('/wardrobe'),
          ),
          _Tile(
            icon: Icons.people,
            title: 'Personen',
            subtitle: persons.isEmpty ? 'Noch niemand angelegt' : persons.map((p) => p.name).join(', '),
            onTap: () => context.push('/persons'),
          ),
          _Tile(
            icon: Icons.family_restroom,
            title: 'Haushaltspaket',
            subtitle: 'Kleidertabelle mit den anderen Handys teilen',
            onTap: () => context.push('/household'),
          ),
          const Divider(height: 32),
          _Tile(
            icon: Icons.speed,
            title: 'Machbarkeits-Test',
            subtitle: 'Tempo und Speicher der KI auf diesem Gerät messen',
            onTap: () => context.push('/test'),
          ),
          _Tile(icon: Icons.history, title: 'Scan-Verlauf', subtitle: 'Welche Stufe hat entschieden?', onTap: () => context.push('/history')),
          _Tile(icon: Icons.memory, title: 'KI-Modell', subtitle: 'Download und Status', onTap: () => context.push('/setup')),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
