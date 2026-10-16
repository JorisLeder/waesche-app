import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Farbpalette für Personen (gut unterscheidbar, auch auf dem Wäscheständer).
const personPalette = <int>[
  0xFFE53935, // rot
  0xFF1E88E5, // blau
  0xFF43A047, // grün
  0xFFFDD835, // gelb
  0xFF8E24AA, // lila
  0xFFFB8C00, // orange
  0xFF00ACC1, // türkis
  0xFFD81B60, // pink
  0xFF6D4C41, // braun
  0xFF546E7A, // blaugrau
];

class PersonDot extends StatelessWidget {
  const PersonDot({super.key, required this.color, this.size = 16});

  final int color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Color(color),
      shape: BoxShape.circle,
      border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
    ),
  );
}

class PersonChip extends StatelessWidget {
  const PersonChip({super.key, required this.name, required this.color});

  final String name;
  final int color;

  @override
  Widget build(BuildContext context) => Chip(
    avatar: PersonDot(color: color),
    label: Text(name),
    visualDensity: VisualDensity.compact,
  );
}

/// Vorschaubild aus einer Datei oder aus Bytes.
class PhotoThumb extends StatelessWidget {
  const PhotoThumb({super.key, this.path, this.bytes, this.size = 64, this.radius = 8});

  final String? path;
  final Uint8List? bytes;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cache = (size * MediaQuery.devicePixelRatioOf(context)).round();
    Widget placeholder() => Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(Icons.checkroom, size: size * 0.5),
    );
    Widget img;
    if (bytes != null) {
      img = Image.memory(bytes!, width: size, height: size, fit: BoxFit.cover, cacheWidth: cache);
    } else if (path != null) {
      img = Image.file(
        File(path!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: cache,
        errorBuilder: (_, _, _) => placeholder(),
      );
    } else {
      img = placeholder();
    }
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: img);
  }
}

Future<bool> confirmDialog(BuildContext context, String title, String message, {String ok = 'Löschen'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Abbrechen')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(ok)),
      ],
    ),
  );
  return r ?? false;
}

void showSnack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
