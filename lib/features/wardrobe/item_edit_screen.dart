import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/gemma_service.dart';
import '../../app/providers.dart';
import '../../app/widgets.dart';
import '../../core/db/database.dart';
import '../../core/db/wardrobe_repository.dart';
import '../../core/models/garment_attributes.dart';
import '../../core/models/vocabulary.dart';
import '../../core/utils/image_prep.dart';
import '../../pipeline/confusion_check.dart';
import '../capture/capture_screen.dart';

const photoArten = {'vorne': 'Vorderseite', 'hinten': 'Rückseite', 'detail': 'Detail', 'etikett': 'Etikett', 'scan': 'Scan'};

/// Einpflegen (itemId == null) oder Bearbeiten eines Teils.
class ItemEditScreen extends ConsumerStatefulWidget {
  const ItemEditScreen({super.key, this.itemId, this.personId, this.initialPhoto});

  final String? itemId;
  final String? personId;
  final Uint8List? initialPhoto;

  static Future<void> open(BuildContext context, {String? itemId, String? personId, Uint8List? initialPhoto}) =>
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ItemEditScreen(itemId: itemId, personId: personId, initialPhoto: initialPhoto),
      ));

  @override
  ConsumerState<ItemEditScreen> createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends ConsumerState<ItemEditScreen> {
  final _name = TextEditingController();
  final _logo = TextEditingController();
  final _aufdruck = TextEditingController();
  final _merkmale = TextEditingController();
  final _markierung = TextEditingController();

  String? _itemId;
  String? _personId;
  String _kategorie = Vocabulary.unbekannt;
  List<String> _farben = [];
  String _muster = Vocabulary.unbekannt;
  String _material = Vocabulary.unbekannt;
  String _laenge = Vocabulary.unbekannt;
  String _vlmRaw = '';

  List<PhotoRow> _existingPhotos = [];
  final List<NewPhoto> _newPhotos = [];
  List<Lookalike> _lookalikes = [];

  bool _loading = true;
  bool _aiBusy = false;
  bool _saving = false;
  String? _aiInfo;

  bool get _isNew => _itemId == null;

  // In initState gelesen: ref ist in dispose() nicht mehr nutzbar.
  late final GemmaService _gemma;

  @override
  void initState() {
    super.initState();
    _gemma = ref.read(gemmaServiceProvider);
    _itemId = widget.itemId;
    _personId = widget.personId;
    // Neues Teil: Die KI wird gleich gebraucht, also schon laden.
    if (widget.itemId == null) _gemma.prewarm();
    _load();
  }

  Future<void> _load() async {
    if (_itemId != null) {
      final v = await ref.read(repositoryProvider).item(_itemId!);
      if (v != null) _apply(v);
      await _refreshLookalikes();
    } else if (widget.initialPhoto != null) {
      _newPhotos.add(NewPhoto(widget.initialPhoto!, 'vorne'));
      _runAi(widget.initialPhoto!);
    }
    if (_personId == null) {
      final persons = await ref.read(repositoryProvider).persons();
      if (persons.length == 1) _personId = persons.first.id;
    }
    if (mounted) setState(() => _loading = false);
  }

  void _apply(ItemView v) {
    final a = v.attributes;
    _personId = v.person.id;
    _name.text = v.item.name;
    _markierung.text = v.item.markierung;
    _vlmRaw = v.item.vlmRaw;
    _existingPhotos = v.photos;
    _setAttributes(a);
  }

  void _setAttributes(GarmentAttributes a) {
    _kategorie = a.kategorie;
    _farben = List.of(a.farben);
    _muster = a.muster;
    _material = a.materialOptik;
    _laenge = a.laengeSchnitt;
    _logo.text = a.logoMarke;
    _aufdruck.text = a.aufdruckText;
    _merkmale.text = a.besondereMerkmale;
  }

  GarmentAttributes get _attributes => GarmentAttributes(
    kategorie: _kategorie,
    farben: _farben,
    muster: _muster,
    materialOptik: _material,
    laengeSchnitt: _laenge,
    logoMarke: _logo.text.trim(),
    aufdruckText: _aufdruck.text.trim(),
    besondereMerkmale: _merkmale.text.trim(),
  );

  Future<void> _runAi(Uint8List photo) async {
    final gemma = ref.read(gemmaServiceProvider);
    if (!await gemma.refreshInstalled()) {
      setState(() => _aiInfo = 'KI-Modell nicht installiert – bitte die Felder selbst ausfüllen (oder Modell auf dem Startbildschirm laden).');
      return;
    }
    setState(() {
      _aiBusy = true;
      _aiInfo = 'KI beschreibt das Teil … (beim ersten Mal lädt das Modell)';
    });
    try {
      final small = await ImagePrep.resize(photo, size: ImagePrep.vlmSize);
      final d = await ref.read(describerProvider).describe(small);
      if (!mounted) return;
      setState(() {
        _setAttributes(d.attributes);
        _vlmRaw = d.raw;
        _aiInfo = 'KI-Vorschlag übernommen (${(d.elapsed.inMilliseconds / 1000).toStringAsFixed(1)} s). Bitte prüfen und korrigieren.';
      });
    } catch (e) {
      if (mounted) setState(() => _aiInfo = 'KI-Vorschlag fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _aiBusy = false);
    }
  }

  Future<void> _addPhoto() async {
    final art = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in photoArten.entries.where((e) => e.key != 'scan'))
              ListTile(title: Text(e.value), onTap: () => Navigator.pop(c, e.key)),
          ],
        ),
      ),
    );
    if (art == null || !mounted) return;
    final bytes = await CaptureScreen.open(context, title: photoArten[art]!);
    if (bytes == null || !mounted) return;
    final firstPhoto = _existingPhotos.isEmpty && _newPhotos.isEmpty;
    setState(() => _newPhotos.add(NewPhoto(bytes, art)));
    if (_isNew && firstPhoto) _runAi(bytes);
  }

  Future<void> _save() async {
    if (_personId == null) {
      showSnack(context, 'Bitte eine Person wählen.');
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(repositoryProvider);
    final embedder = ref.read(embedderProvider);
    try {
      if (_isNew) {
        _itemId = await repo.addItem(
          personId: _personId!,
          attributes: _attributes,
          name: _name.text,
          markierung: _markierung.text,
          vlmRaw: _vlmRaw,
          newPhotos: _newPhotos,
          embedder: embedder,
        );
      } else {
        await repo.updateItem(_itemId!, personId: _personId, attributes: _attributes, name: _name.text, markierung: _markierung.text);
        for (final ph in _newPhotos) {
          await repo.addPhoto(_itemId!, ph, embedder: embedder, augment: true);
        }
      }
      final wasNew = _newPhotos.isNotEmpty || widget.itemId == null;
      _newPhotos.clear();
      final v = await repo.item(_itemId!);
      if (v != null) _existingPhotos = v.photos;
      await _refreshLookalikes();
      if (!mounted) return;
      if (_lookalikes.isEmpty) {
        Navigator.of(context).pop();
      } else {
        setState(() {});
        if (wasNew) await _showLookalikeHint();
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Speichern fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _refreshLookalikes() async {
    if (_itemId == null) return;
    final catalog = await ref.read(repositoryProvider).loadCatalog(ref.read(embedderProvider).modelId);
    final me = catalog.where((c) => c.id == _itemId).firstOrNull;
    _lookalikes = me == null ? [] : findLookalikes(me, catalog);
  }

  Future<void> _showLookalikeHint() => showDialog(
    context: context,
    builder: (c) => AlertDialog(
      icon: const Icon(Icons.compare),
      title: const Text('Verwechslungsgefahr'),
      content: Text(
        'Dieses Teil sieht aus wie ${_lookalikes.map((l) => '„${l.item.displayName}“ von ${l.item.personName}').join(', ')}.\n\n'
        '• Bitte 2–3 Detailfotos ergänzen (Bündchen, Ferse, Etikett).\n'
        '• Ein Unterscheidungsmerkmal unter „Besondere Merkmale“ eintragen.\n'
        '• Sind die Teile wirklich identisch: mit Textilstift markieren (z. B. ein Punkt am Bündchen) '
        'und unter „Markierung“ eintragen.',
      ),
      actions: [FilledButton(onPressed: () => Navigator.pop(c), child: const Text('Verstanden'))],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final persons = ref.watch(personsProvider).value ?? const [];
    final store = ref.watch(photoStoreProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Teil einpflegen' : 'Teil bearbeiten'),
        actions: [
          if (!_isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await confirmDialog(context, 'Teil löschen?', 'Das Teil wird aus dem Kleiderschrank entfernt.')) {
                  await ref.read(repositoryProvider).deleteItem(_itemId!);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _saving || _aiBusy ? null : _save,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: Text(_saving ? 'Speichern … (Bildmerkmale werden berechnet)' : 'Speichern'),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _personId,
                  decoration: const InputDecoration(labelText: 'Gehört', border: OutlineInputBorder()),
                  items: [
                    for (final p in persons)
                      DropdownMenuItem(
                        value: p.id,
                        child: Row(children: [PersonDot(color: p.color), const SizedBox(width: 8), Text(p.name)]),
                      ),
                  ],
                  onChanged: (v) => setState(() => _personId = v),
                ),
                const SizedBox(height: 16),
                Text('Fotos', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SizedBox(
                  height: 96,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final p in _existingPhotos)
                        _PhotoTile(
                          label: photoArten[p.art] ?? p.art,
                          child: PhotoThumb(path: store.pathOf(p.fileName), size: 80),
                          onDelete: () async {
                            await ref.read(repositoryProvider).deletePhoto(p.id);
                            setState(() => _existingPhotos = _existingPhotos.where((x) => x.id != p.id).toList());
                          },
                        ),
                      for (final p in _newPhotos)
                        _PhotoTile(
                          label: '${photoArten[p.art] ?? p.art} (neu)',
                          child: PhotoThumb(bytes: p.bytes, size: 80),
                          onDelete: () => setState(() => _newPhotos.remove(p)),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(fixedSize: const Size(80, 80), padding: EdgeInsets.zero),
                          onPressed: _addPhoto,
                          child: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_aiInfo != null || _aiBusy)
                  Card(
                    child: ListTile(
                      leading: _aiBusy
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.auto_awesome),
                      title: Text(_aiInfo ?? ''),
                      trailing: !_aiBusy && (_newPhotos.isNotEmpty || _existingPhotos.isNotEmpty)
                          ? IconButton(
                              tooltip: 'KI erneut fragen',
                              icon: const Icon(Icons.refresh),
                              onPressed: () async {
                                final bytes = _newPhotos.isNotEmpty
                                    ? _newPhotos.first.bytes
                                    : await store.read(_existingPhotos.first.fileName);
                                if (bytes != null) _runAi(bytes);
                              },
                            )
                          : null,
                    ),
                  ),
                if (_lookalikes.isNotEmpty)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      leading: const Icon(Icons.compare),
                      title: const Text('Verwechslungsgefahr'),
                      subtitle: Text(
                        'Ähnlich wie ${_lookalikes.map((l) => '„${l.item.displayName}“ (${l.item.personName})').join(', ')}. '
                        'Detailfotos, Unterscheidungsmerkmal oder Markierung ergänzen.',
                      ),
                      onTap: _showLookalikeHint,
                    ),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name (optional, z. B. „Laufsocke grau“)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                _dropdown('Kategorie', _kategorie, Vocabulary.kategorien, (v) => setState(() => _kategorie = v)),
                const SizedBox(height: 12),
                Text('Farben (max. 3)', style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final f in Vocabulary.farben)
                      FilterChip(
                        label: Text(f),
                        selected: _farben.contains(f),
                        onSelected: (sel) => setState(() {
                          if (sel && _farben.length < 3) {
                            _farben.add(f);
                          } else {
                            _farben.remove(f);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _dropdown('Muster', _muster, Vocabulary.muster, (v) => setState(() => _muster = v)),
                const SizedBox(height: 12),
                _dropdown('Länge / Schnitt', _laenge, Vocabulary.laengeSchnitt, (v) => setState(() => _laenge = v)),
                const SizedBox(height: 12),
                _dropdown('Material (Optik)', _material, Vocabulary.materialOptik, (v) => setState(() => _material = v)),
                const SizedBox(height: 12),
                TextField(controller: _logo, decoration: const InputDecoration(labelText: 'Logo / Marke', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _aufdruck, decoration: const InputDecoration(labelText: 'Aufdruck (Text)', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(
                  controller: _merkmale,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Besondere Merkmale',
                    hintText: 'z. B. Rippung nur ab Knöchel, graue Ferse, kleines Loch am Zeh',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _markierung,
                  decoration: const InputDecoration(
                    labelText: 'Markierung (optional)',
                    hintText: 'z. B. roter Punkt am Bündchen',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_vlmRaw.isNotEmpty)
                  ExpansionTile(
                    title: const Text('KI-Rohausgabe'),
                    children: [SelectableText(_vlmRaw, style: Theme.of(context).textTheme.bodySmall)],
                  ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _dropdown(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    final all = [Vocabulary.unbekannt, ...options];
    return DropdownButtonFormField<String>(
      initialValue: all.contains(value) ? value : Vocabulary.unbekannt,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: [for (final o in all) DropdownMenuItem(value: o, child: Text(o))],
      onChanged: (v) => onChanged(v ?? Vocabulary.unbekannt),
    );
  }

  @override
  void dispose() {
    for (final c in [_name, _logo, _aufdruck, _merkmale, _markierung]) {
      c.dispose();
    }
    _gemma.unload();
    super.dispose();
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.label, required this.child, required this.onDelete});

  final String label;
  final Widget child;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Column(
      children: [
        Stack(
          children: [
            child,
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: onDelete,
                child: const CircleAvatar(radius: 11, child: Icon(Icons.close, size: 14)),
              ),
            ),
          ],
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    ),
  );
}
