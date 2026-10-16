import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/widgets.dart';
import '../../core/db/wardrobe_repository.dart';
import 'item_edit_screen.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen> {
  String? _personFilter;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsProvider);
    final persons = ref.watch(personsProvider).value ?? const [];
    final photos = ref.watch(photoStoreProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kleiderschrank')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: persons.isEmpty
            ? () => showSnack(context, 'Bitte zuerst eine Person anlegen.')
            : () => ItemEditScreen.open(context, personId: _personFilter),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Teil einpflegen'),
      ),
      body: Column(
        children: [
          if (persons.length > 1)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Alle'),
                    selected: _personFilter == null,
                    onSelected: (_) => setState(() => _personFilter = null),
                  ),
                  for (final p in persons)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        avatar: PersonDot(color: p.color),
                        label: Text(p.name),
                        selected: _personFilter == p.id,
                        onSelected: (_) => setState(() => _personFilter = p.id),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: items.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Fehler: $e')),
              data: (all) {
                final list = _personFilter == null ? all : all.where((i) => i.person.id == _personFilter).toList();
                if (list.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Noch keine Teile.\nJedes Kleidungsstück einmal mit Foto einpflegen – '
                        'die KI füllt die Beschreibung vor.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _ItemTile(view: list[i], photoPath: _firstPhoto(list[i], photos.pathOf)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _firstPhoto(ItemView v, String Function(String) pathOf) {
    final p = v.photos.where((p) => p.art != 'scan').firstOrNull ?? v.photos.firstOrNull;
    return p == null ? null : pathOf(p.fileName);
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.view, required this.photoPath});

  final ItemView view;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    final a = view.attributes;
    return ListTile(
      leading: PhotoThumb(path: photoPath, size: 56),
      title: Text(view.item.name.isNotEmpty ? view.item.name : a.kategorie),
      subtitle: Text(a.summary(), maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          PersonDot(color: view.person.color),
          const SizedBox(height: 4),
          Text(view.person.name, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
      onTap: () => ItemEditScreen.open(context, itemId: view.item.id),
    );
  }
}
