/// Kontrolliertes Vokabular für Kleidungs-Attribute.
///
/// VLM-Ausgabe, Datenbank und Formulare benutzen dieselben Begriffe, damit
/// Scan und Tabelle vergleichbar sind. [normalize] fängt Schreibvarianten
/// und Synonyme des Modells ab.
library;

class Vocabulary {
  Vocabulary._();

  static const unbekannt = 'unbekannt';

  static const kategorien = <String>[
    'Socke',
    'Unterhose',
    'BH',
    'Unterhemd',
    'T-Shirt',
    'Top',
    'Hemd',
    'Bluse',
    'Pullover',
    'Sweatjacke',
    'Hoodie',
    'Jacke',
    'Hose',
    'Jeans',
    'Shorts',
    'Leggings',
    'Rock',
    'Kleid',
    'Schlafanzug',
    'Sportshirt',
    'Sporthose',
    'Badebekleidung',
    'Mütze',
    'Schal',
    'Handschuh',
    'Handtuch',
    'Sonstiges',
  ];

  static const farben = <String>[
    'weiß',
    'schwarz',
    'grau',
    'hellgrau',
    'dunkelgrau',
    'beige',
    'braun',
    'rot',
    'dunkelrot',
    'rosa',
    'pink',
    'orange',
    'gelb',
    'grün',
    'dunkelgrün',
    'olivgrün',
    'türkis',
    'hellblau',
    'blau',
    'dunkelblau',
    'lila',
    'bunt',
  ];

  static const muster = <String>[
    'uni',
    'gestreift',
    'geringelt',
    'gerippt',
    'kariert',
    'gepunktet',
    'meliert',
    'Print',
    'Logo',
    'Muster',
  ];

  static const materialOptik = <String>[
    'Baumwolle',
    'Strick',
    'Frottee',
    'Jersey',
    'Denim',
    'Funktionsstoff',
    'Fleece',
    'Spitze',
    'Wolle',
    'Synthetik',
  ];

  static const laengeSchnitt = <String>[
    'Füßling',
    'Sneakersocke',
    'Knöchelsocke',
    'Wadensocke',
    'Kniestrumpf',
    'kurzarm',
    'langarm',
    'ärmellos',
    'kurz',
    'dreiviertel',
    'lang',
    'Slip',
    'Boxershorts',
    'Panty',
    'mit Kapuze',
    'ohne Kapuze',
  ];

  static const _synonyme = <String, String>{
    // Farben
    'weiss': 'weiß',
    'white': 'weiß',
    'cremeweiß': 'weiß',
    'creme': 'beige',
    'black': 'schwarz',
    'gray': 'grau',
    'grey': 'grau',
    'anthrazit': 'dunkelgrau',
    'silber': 'hellgrau',
    'navy': 'dunkelblau',
    'marine': 'dunkelblau',
    'marineblau': 'dunkelblau',
    'blue': 'blau',
    'red': 'rot',
    'bordeaux': 'dunkelrot',
    'weinrot': 'dunkelrot',
    'green': 'grün',
    'oliv': 'olivgrün',
    'khaki': 'olivgrün',
    'mint': 'türkis',
    'petrol': 'türkis',
    'violett': 'lila',
    'purple': 'lila',
    'flieder': 'lila',
    'magenta': 'pink',
    'mehrfarbig': 'bunt',
    'yellow': 'gelb',
    'senf': 'gelb',
    'camel': 'braun',
    'taupe': 'beige',
    // Muster
    'einfarbig': 'uni',
    'unifarben': 'uni',
    'glatt': 'uni',
    'streifen': 'gestreift',
    'längsstreifen': 'gestreift',
    'ringel': 'geringelt',
    'quergestreift': 'geringelt',
    'rippe': 'gerippt',
    'rippen': 'gerippt',
    'geriffelt': 'gerippt',
    'ripp': 'gerippt',
    'karo': 'kariert',
    'punkte': 'gepunktet',
    'aufdruck': 'Print',
    'bedruckt': 'Print',
    'motiv': 'Print',
    'gemustert': 'Muster',
    // Länge / Schnitt
    'sneaker': 'Sneakersocke',
    'sneakersocken': 'Sneakersocke',
    'knöchel': 'Knöchelsocke',
    'knöchelhoch': 'Knöchelsocke',
    'quarter': 'Knöchelsocke',
    'wade': 'Wadensocke',
    'wadenhoch': 'Wadensocke',
    'crew': 'Wadensocke',
    'kniestrümpfe': 'Kniestrumpf',
    'kniehoch': 'Kniestrumpf',
    'kurzärmlig': 'kurzarm',
    'kurzärmelig': 'kurzarm',
    'langärmlig': 'langarm',
    'langärmelig': 'langarm',
    'boxer': 'Boxershorts',
    'boxershort': 'Boxershorts',
    'hipster': 'Panty',
    // Kategorien
    'socken': 'Socke',
    'strumpf': 'Socke',
    'strümpfe': 'Socke',
    'sock': 'Socke',
    'unterwäsche': 'Unterhose',
    'slip': 'Unterhose',
    'tshirt': 'T-Shirt',
    't shirt': 'T-Shirt',
    'shirt': 'T-Shirt',
    'pulli': 'Pullover',
    'sweatshirt': 'Pullover',
    'strickpullover': 'Pullover',
    'kapuzenpullover': 'Hoodie',
    'hosen': 'Hose',
    'jogginghose': 'Sporthose',
    'kurze hose': 'Shorts',
    'pyjama': 'Schlafanzug',
    'badehose': 'Badebekleidung',
    'badeanzug': 'Badebekleidung',
    'bikini': 'Badebekleidung',
  };

  /// Bildet [value] auf einen Begriff aus [allowed] ab. Unbekanntes wird
  /// [unbekannt]. Groß-/Kleinschreibung, Umlaut-Schreibweisen und Synonyme
  /// werden toleriert.
  static String normalize(String? value, List<String> allowed) {
    if (value == null) return unbekannt;
    final plain = _clean(value);
    if (plain.isEmpty) return unbekannt;
    // Zusätzlich die Umlaut-Umschrift prüfen ("gruen" -> "grün"), aber nur
    // als zweite Variante, damit "dunkelblaue" nicht zu "dunkelblaü" wird.
    final variants = {plain, _transliterate(plain)};
    for (final v in variants) {
      for (final a in allowed) {
        if (_clean(a) == v) return a;
      }
      final syn = _cleanedSynonyme[v];
      if (syn != null && allowed.contains(syn)) return syn;
    }
    // Teilwort-Treffer, z. B. "weiße socke" -> "Socke". Der längste Treffer
    // gewinnt, damit "dunkelblaue" zu "dunkelblau" wird und nicht zu "blau".
    String? best;
    var bestLen = 0;
    for (final v in variants) {
      for (final a in allowed) {
        final ca = _clean(a);
        if (ca.length >= 3 && ca.length > bestLen && v.contains(ca)) {
          best = a;
          bestLen = ca.length;
        }
      }
      for (final entry in _cleanedSynonyme.entries) {
        if (entry.key.length >= 4 &&
            entry.key.length > bestLen &&
            v.contains(entry.key) &&
            allowed.contains(entry.value)) {
          best = entry.value;
          bestLen = entry.key.length;
        }
      }
    }
    return best ?? unbekannt;
  }

  static final Map<String, String> _cleanedSynonyme = {
    for (final e in _synonyme.entries) _clean(e.key): e.value,
  };

  static String _transliterate(String s) =>
      s.replaceAll('ae', 'ä').replaceAll('oe', 'ö').replaceAll('ue', 'ü');

  static List<String> normalizeList(Iterable<String> values, List<String> allowed) {
    final out = <String>[];
    for (final v in values) {
      final n = normalize(v, allowed);
      if (n != unbekannt && !out.contains(n)) out.add(n);
    }
    return out;
  }

  static String _clean(String s) =>
      s.toLowerCase().trim().replaceAll('-', '').replaceAll(RegExp(r'\s+'), ' ');

  /// Ähnliche Farben zählen beim Vergleich teilweise (z. B. grau ~ hellgrau).
  static const _farbFamilien = <String, String>{
    'weiß': 'hell',
    'beige': 'hell',
    'hellgrau': 'grau',
    'grau': 'grau',
    'dunkelgrau': 'grau',
    'schwarz': 'dunkel',
    'dunkelblau': 'blau',
    'blau': 'blau',
    'hellblau': 'blau',
    'türkis': 'blau',
    'rot': 'rot',
    'dunkelrot': 'rot',
    'rosa': 'rosa',
    'pink': 'rosa',
    'grün': 'grün',
    'dunkelgrün': 'grün',
    'olivgrün': 'grün',
  };

  static String? farbFamilie(String farbe) => _farbFamilien[farbe];
}
