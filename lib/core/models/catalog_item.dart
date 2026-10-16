import 'dart:typed_data';

import 'garment_attributes.dart';

/// Ein Referenzfoto eines Teils mit seinen (lokal berechneten) Embeddings.
/// Augmentierte Varianten liefern mehrere Vektoren pro Foto.
class ReferencePhoto {
  const ReferencePhoto({
    required this.id,
    required this.path,
    required this.art,
    this.embeddings = const [],
  });

  final String id;
  final String path;
  final String art;
  final List<Float32List> embeddings;
}

/// Lesesicht auf ein Kleidungsstück für die Zuordnungs-Pipeline.
/// Bewusst unabhängig von den Datenbank-Klassen, damit die Pipeline ohne
/// Flutter und ohne Datenbank testbar bleibt.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.personId,
    required this.personName,
    required this.personColor,
    required this.name,
    required this.attributes,
    this.markierung = '',
    this.photos = const [],
  });

  final String id;
  final String personId;
  final String personName;
  final int personColor;
  final String name;
  final GarmentAttributes attributes;
  final String markierung;
  final List<ReferencePhoto> photos;

  Iterable<Float32List> get allEmbeddings => photos.expand((p) => p.embeddings);

  String get displayName => name.isNotEmpty ? name : attributes.summary();
}
