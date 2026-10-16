import 'dart:convert';

import '../core/models/garment_attributes.dart';
import '../pipeline/decisions.dart';
import 'prompts.dart';
import 'tool_schemas.dart';

/// Wandelt Modellantworten (Werkzeugaufruf oder Text mit JSON) in geprüfte
/// Ergebnisse um. Alles hier ist rein und testbar.
class ResponseParser {
  const ResponseParser();

  /// Sucht das erste vollständige JSON-Objekt in [text] (auch in ```json-Blöcken).
  static Map<String, dynamic>? extractJsonObject(String text) {
    final start = text.indexOf('{');
    if (start < 0) return null;
    var depth = 0;
    var inString = false;
    var escaped = false;
    for (var i = start; i < text.length; i++) {
      final ch = text[i];
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (ch == r'\') {
          escaped = true;
        } else if (ch == '"') {
          inString = false;
        }
        continue;
      }
      if (ch == '"') {
        inString = true;
      } else if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) {
          try {
            final decoded = jsonDecode(text.substring(start, i + 1));
            return decoded is Map<String, dynamic> ? decoded : null;
          } on FormatException {
            return null;
          }
        }
      }
    }
    return null;
  }

  GarmentAttributes? parseDescription({String? toolName, Map<String, dynamic>? args, String? text}) {
    Map<String, dynamic>? data;
    if (toolName == ToolSchemas.describeName && args != null) {
      data = args;
    } else if (text != null) {
      data = extractJsonObject(text);
    }
    if (data == null) return null;
    return GarmentAttributes.fromLooseJson(data);
  }

  /// Prüft eine Zuordnungsantwort gegen die Kandidaten. Unbekannte Labels,
  /// leere Optionen oder fehlende Felder ergeben [InvalidDecision].
  MatchDecision parseMatch({
    required List<LabeledCandidate> candidates,
    String? toolName,
    Map<String, dynamic>? args,
    String? text,
  }) {
    var name = toolName;
    var data = args;
    if ((name == null || data == null) && text != null) {
      final json = extractJsonObject(text);
      if (json == null) return InvalidDecision('Kein JSON in der Antwort', raw: text);
      name = '${json['aktion'] ?? json['action'] ?? ''}'.toLowerCase();
      data = json;
    }
    if (name == null || data == null) return const InvalidDecision('Leere Antwort');

    final byLabel = {for (final c in candidates) c.label: c.itemId};
    String? labelToId(Object? l) {
      if (l == null) return null;
      final s = '$l'.trim().toUpperCase();
      final direct = byLabel[s];
      if (direct != null) return direct;
      // "Teil A", "(B)", "Label: C" -> einzelner Buchstabe als eigenes Wort
      final m = RegExp(r'(?:^|[^A-Z])([A-Z])(?:[^A-Z]|$)').firstMatch(s);
      return m == null ? null : byLabel[m.group(1)];
    }

    List<String>? labelsToIds(Object? v) {
      if (v is! List) return null;
      final ids = <String>[];
      for (final l in v) {
        final id = labelToId(l);
        if (id == null) return null; // erfundenes Label -> ungültig
        if (!ids.contains(id)) ids.add(id);
      }
      return ids;
    }

    switch (name) {
      case ToolSchemas.assignName:
        final id = labelToId(data['label']);
        if (id == null) return InvalidDecision('Unbekanntes Label: ${data['label']}', raw: '$data');
        final conf = _toDouble(data['sicherheit'] ?? data['confidence']) ?? 0.5;
        return AssignDecision(
          itemId: id,
          confidence: conf.clamp(0.0, 1.0),
          reason: '${data['begruendung'] ?? ''}',
        );
      case ToolSchemas.askName:
        final frage = '${data['frage'] ?? ''}'.trim();
        final rawOptions = data['optionen'];
        if (frage.isEmpty || rawOptions is! List) {
          return InvalidDecision('Rückfrage ohne Frage oder Optionen', raw: '$data');
        }
        final options = <AnswerOption>[];
        for (final o in rawOptions) {
          if (o is! Map) return InvalidDecision('Option ist kein Objekt', raw: '$data');
          final text = '${o['text'] ?? ''}'.trim();
          final ids = labelsToIds(o['labels']);
          if (text.isEmpty || ids == null || ids.isEmpty) {
            return InvalidDecision('Option ohne Text oder gültige Labels', raw: '$data');
          }
          options.add(AnswerOption(text: text, itemIds: ids));
        }
        if (options.length < 2) return InvalidDecision('Weniger als zwei Optionen', raw: '$data');
        // Eine Frage, deren Optionen alle dieselben Teile meinen, hilft nicht.
        final distinct = options.map((o) => (o.itemIds.toList()..sort()).join(',')).toSet();
        if (distinct.length < 2) return InvalidDecision('Optionen unterscheiden nichts', raw: '$data');
        return AskDecision(Question(text: frage, options: options, source: 'llm'));
      case ToolSchemas.unclearName:
        final ids = labelsToIds(data['labels']);
        if (ids == null) return InvalidDecision('Unklar mit ungültigen Labels', raw: '$data');
        return UnclearDecision(ids.isEmpty ? candidates.map((c) => c.itemId).toList() : ids);
      default:
        return InvalidDecision('Unbekannte Aktion: $name', raw: '$data');
    }
  }

  static double? _toDouble(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) {
      final lower = v.toLowerCase();
      if (lower == 'hoch') return 0.9;
      if (lower == 'mittel') return 0.6;
      if (lower == 'niedrig') return 0.3;
      return double.tryParse(v.replaceAll(',', '.'));
    }
    return null;
  }
}
