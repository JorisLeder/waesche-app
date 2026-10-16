import '../core/models/vocabulary.dart';

/// JSON-Schemata der Werkzeuge (Function Calling). Als reine Maps, damit sie
/// ohne die KI-Laufzeit testbar sind; gemma_service.dart macht daraus Tools.
class ToolSchemas {
  ToolSchemas._();

  static const describeName = 'beschreibe_kleidung';
  static const assignName = 'zuordnen';
  static const askName = 'rueckfrage';
  static const unclearName = 'unklar';

  static Map<String, dynamic> describe() => {
    'name': describeName,
    'description': 'Gibt die strukturierte Beschreibung des Kleidungsstücks auf dem Foto zurück.',
    'parameters': {
      'type': 'object',
      'properties': {
        'kategorie': {'type': 'string', 'description': 'Art des Teils', 'enum': Vocabulary.kategorien},
        'farben': {
          'type': 'array',
          'description': '1 bis 3 Hauptfarben, wichtigste zuerst',
          'items': {'type': 'string', 'enum': Vocabulary.farben},
        },
        'muster': {'type': 'string', 'enum': [...Vocabulary.muster, Vocabulary.unbekannt]},
        'material_optik': {'type': 'string', 'enum': [...Vocabulary.materialOptik, Vocabulary.unbekannt]},
        'laenge_schnitt': {'type': 'string', 'enum': [...Vocabulary.laengeSchnitt, Vocabulary.unbekannt]},
        'logo_marke': {'type': 'string', 'description': 'Sichtbares Logo oder Marke, sonst leer'},
        'aufdruck_text': {'type': 'string', 'description': 'Lesbarer Aufdruck, sonst leer'},
        'besondere_merkmale': {
          'type': 'string',
          'description': 'Unterscheidende Details in höchstens 15 Wörtern',
        },
      },
      'required': ['kategorie', 'farben', 'muster', 'laenge_schnitt', 'besondere_merkmale'],
    },
  };

  static Map<String, dynamic> assign(List<String> labels) => {
    'name': assignName,
    'description': 'Ordnet das gescannte Teil genau einem bekannten Teil zu.',
    'parameters': {
      'type': 'object',
      'properties': {
        'label': {'type': 'string', 'enum': labels, 'description': 'Label des passenden Teils'},
        'sicherheit': {'type': 'number', 'description': 'Sicherheit von 0 bis 1'},
        'begruendung': {'type': 'string', 'description': 'Kurze Begründung'},
      },
      'required': ['label', 'sicherheit'],
    },
  };

  static Map<String, dynamic> ask(List<String> labels) => {
    'name': askName,
    'description': 'Stellt dem Nutzer eine Rückfrage zu einem sichtbaren Merkmal, um zwischen Teilen zu unterscheiden.',
    'parameters': {
      'type': 'object',
      'properties': {
        'frage': {'type': 'string', 'description': 'Kurze Frage zu einem sichtbaren Merkmal'},
        'optionen': {
          'type': 'array',
          'description': '2 bis 4 Antwortmöglichkeiten',
          'items': {
            'type': 'object',
            'properties': {
              'text': {'type': 'string'},
              'labels': {
                'type': 'array',
                'items': {'type': 'string', 'enum': labels},
              },
            },
            'required': ['text', 'labels'],
          },
        },
      },
      'required': ['frage', 'optionen'],
    },
  };

  static Map<String, dynamic> unclear(List<String> labels) => {
    'name': unclearName,
    'description': 'Meldet, dass sich die Teile anhand der Beschreibung nicht unterscheiden lassen.',
    'parameters': {
      'type': 'object',
      'properties': {
        'labels': {
          'type': 'array',
          'items': {'type': 'string', 'enum': labels},
          'description': 'Labels der Teile, die in Frage kommen',
        },
      },
      'required': ['labels'],
    },
  };
}
