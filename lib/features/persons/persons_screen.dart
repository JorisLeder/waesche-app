import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/widgets.dart';
import '../../core/db/database.dart';

class PersonsScreen extends ConsumerWidget {
  const PersonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persons = ref.watch(personsProvider);
    final items = ref.watch(itemsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Personen')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => editPersonDialog(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('Person'),
      ),
      body: persons.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Noch niemand angelegt.\nLege zuerst alle Personen im Haushalt an.', textAlign: TextAlign.center),
                ),
              )
            : ListView(
                children: [
                  for (final p in list)
                    ListTile(
                      leading: PersonDot(color: p.color, size: 28),
                      title: Text(p.name),
                      subtitle: Text('${items.where((i) => i.person.id == p.id).length} Teile'),
                      onTap: () => editPersonDialog(context, ref, person: p),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          if (await confirmDialog(
                            context,
                            '${p.name} löschen?',
                            'Die Person und alle ihre Teile werden entfernt.',
                          )) {
                            await ref.read(repositoryProvider).deletePerson(p.id);
                          }
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

Future<void> editPersonDialog(BuildContext context, WidgetRef ref, {PersonRow? person}) async {
  final name = TextEditingController(text: person?.name ?? '');
  var color = person?.color ?? personPalette.first;
  final used = (ref.read(personsProvider).value ?? const []).map((p) => p.color).toSet();
  if (person == null) {
    color = personPalette.firstWhere((c) => !used.contains(c), orElse: () => personPalette.first);
  }
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => AlertDialog(
        title: Text(person == null ? 'Neue Person' : 'Person bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final pc in personPalette)
                  GestureDetector(
                    onTap: () => setState(() => color = pc),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(pc),
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: pc == color ? 4 : 1,
                          color: pc == color ? Theme.of(c).colorScheme.onSurface : Theme.of(c).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Speichern')),
        ],
      ),
    ),
  );
  if (ok != true || name.text.trim().isEmpty) return;
  final repo = ref.read(repositoryProvider);
  if (person == null) {
    await repo.addPerson(name.text, color);
  } else {
    await repo.updatePerson(person.id, name: name.text, color: color);
  }
}
