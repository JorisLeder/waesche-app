import 'dart:convert';

import 'vocabulary.dart';

/// Strukturierte Beschreibung eines Kleidungsstücks.
///
/// Gleiches Schema für VLM-Ausgabe (Scan) und Datenbank (Einpflegen).
class GarmentAttributes {
  const GarmentAttributes({
    this.kategorie = Vocabulary.unbekannt,
    this.farben = const [],
    this.muster = Vocabulary.unbekannt,
    this.materialOptik = Vocabulary.unbekannt,
    this.laengeSchnitt = Vocabulary.unbekannt,
    this.logoMarke = '',
    this.aufdruckText = '',
    this.besondereMerkmale = '',
  });

  final String kategorie;
  final List<String> farben;
  final String muster;
  final String materialOptik;
  final String laengeSchnitt;
  final String logoMarke;
  final String aufdruckText;
  final String besondereMerkmale;

  static const empty = GarmentAttributes();

  /// Liest eine (möglicherweise unsaubere) Modellausgabe und normalisiert
  /// sie auf das Vokabular. Fehlende Felder werden [Vocabulary.unbekannt].
  factory GarmentAttributes.fromLooseJson(Map<String, dynamic> json) {
    List<String> asList(Object? v) {
      if (v == null) return const [];
      if (v is List) return v.map((e) => '$e').toList();
      return '$v'.split(RegExp(r'[,/;]| und ')).map((e) => e.trim()).toList();
    }

    String asText(Object? v) {
      if (v == null) return '';
      final s = '$v'.trim();
      final lower = s.toLowerCase();
      if (lower == 'null' ||
          lower == 'keine' ||
          lower == 'kein' ||
          lower == 'keins' ||
          lower == 'none' ||
          lower == '-' ||
          lower == Vocabulary.unbekannt) {
        return '';
      }
      return s;
    }

    Object? pick(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k)) return json[k];
      }
      return null;
    }

    return GarmentAttributes(
      kategorie: Vocabulary.normalize(
        pick(['kategorie', 'category', 'art'])?.toString(),
        Vocabulary.kategorien,
      ),
      farben: Vocabulary.normalizeList(
        asList(pick(['farben', 'farbe', 'colors', 'color'])),
        Vocabulary.farben,
      ),
      muster: Vocabulary.normalize(
        pick(['muster', 'pattern'])?.toString(),
        Vocabulary.muster,
      ),
      materialOptik: Vocabulary.normalize(
        pick(['material_optik', 'material', 'materialOptik'])?.toString(),
        Vocabulary.materialOptik,
      ),
      laengeSchnitt: Vocabulary.normalize(
        pick(['laenge_schnitt', 'länge_schnitt', 'laenge', 'schnitt', 'laengeSchnitt'])
            ?.toString(),
        Vocabulary.laengeSchnitt,
      ),
      logoMarke: asText(pick(['logo_marke', 'logo', 'marke', 'logoMarke'])),
      aufdruckText: asText(pick(['aufdruck_text', 'aufdruck', 'text', 'aufdruckText'])),
      besondereMerkmale: asText(
        pick(['besondere_merkmale', 'merkmale', 'besonderheiten', 'besondereMerkmale']),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'kategorie': kategorie,
    'farben': farben,
    'muster': muster,
    'material_optik': materialOptik,
    'laenge_schnitt': laengeSchnitt,
    'logo_marke': logoMarke,
    'aufdruck_text': aufdruckText,
    'besondere_merkmale': besondereMerkmale,
  };

  String toJsonString() => jsonEncode(toJson());

  GarmentAttributes copyWith({
    String? kategorie,
    List<String>? farben,
    String? muster,
    String? materialOptik,
    String? laengeSchnitt,
    String? logoMarke,
    String? aufdruckText,
    String? besondereMerkmale,
  }) => GarmentAttributes(
    kategorie: kategorie ?? this.kategorie,
    farben: farben ?? this.farben,
    muster: muster ?? this.muster,
    materialOptik: materialOptik ?? this.materialOptik,
    laengeSchnitt: laengeSchnitt ?? this.laengeSchnitt,
    logoMarke: logoMarke ?? this.logoMarke,
    aufdruckText: aufdruckText ?? this.aufdruckText,
    besondereMerkmale: besondereMerkmale ?? this.besondereMerkmale,
  );

  /// Kurze, menschenlesbare Zusammenfassung, z. B. für Listen und Prompts.
  String summary() {
    final parts = <String>[
      if (kategorie != Vocabulary.unbekannt) kategorie,
      if (farben.isNotEmpty) farben.join('/'),
      if (muster != Vocabulary.unbekannt) muster,
      if (laengeSchnitt != Vocabulary.unbekannt) laengeSchnitt,
      if (materialOptik != Vocabulary.unbekannt) materialOptik,
      if (logoMarke.isNotEmpty) 'Logo: $logoMarke',
      if (aufdruckText.isNotEmpty) 'Aufdruck: "$aufdruckText"',
      if (besondereMerkmale.isNotEmpty) besondereMerkmale,
    ];
    return parts.isEmpty ? 'keine Angaben' : parts.join(', ');
  }

  @override
  String toString() => 'GarmentAttributes(${summary()})';
}
