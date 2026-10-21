# WäscheWer

Erkennt beim Wäschemachen, **wem ein Kleidungsstück gehört** – komplett lokal auf dem Handy, ohne Cloud und ohne eigenes Modelltraining.

```
Scan → VLM beschreibt → Vorfilter → LLM ordnet zu
     → (mehrdeutig) Rückfrage → (mehrdeutig) Bildvergleich (NN) → (mehrdeutig) Fotovergleich durch dich
```

| Stufe | Technik |
|---|---|
| VLM + LLM | Gemma 4 E2B (`.litertlm`, ~2,6 GB) über `flutter_edge_ai` + `flutter_edge_ai_litertlm`, ein Modell für beide Rollen, Function Calling |
| Vorfilter | Kategorie hart, dann Score aus Attributen + Bildähnlichkeit (`lib/pipeline/candidate_filter.dart`) |
| Rückfrage | vom LLM formuliert; jede Antwort ist fest an Teile gebunden. Regelbasierte Ersatzfrage, wenn das LLM nichts Brauchbares liefert |
| NN | vortrainiertes Bild-Embedding (MediaPipe MobileNetV3-Large, im APK), Kosinus-Ähnlichkeit nur zwischen den verbliebenen Kandidaten |
| Fotovergleich | Scanfoto neben den Referenzfotos, du tippst das richtige an |

Abkürzung: Gehören alle passenden Teile **derselben Person**, ist der Besitzer klar. Dann gibt es keine Rückfrage.
Lernschleife: Jeder bestätigte Scan wird ein weiteres Referenzbild.

## Installation (Android)

1. Am Handy https://github.com/JorisLeder/waesche-app/releases/latest öffnen und `WaescheWer-x.y.z.apk` herunterladen.
2. Installieren („Unbekannte Apps installieren“ einmalig erlauben).
3. In der App: **KI-Modell → Modell herunterladen** (ca. 2,6 GB, WLAN).
4. **Personen** anlegen, dann im **Kleiderschrank** jedes Teil einmal mit Foto einpflegen.

Tipp: Die App [Obtainium](https://github.com/ImranR98/Obtainium) installiert neue Releases automatisch.

Voraussetzungen: Android 11+ (64-Bit/arm64), ≥ 6 GB RAM, ~3,5 GB freier Speicher.

## Releases und Secrets kurz erklärt

- **Release:** eine Download-Seite pro Version (z. B. `v0.1.0`) mit der fertigen APK. Am Handy öffnen, APK laden, installieren.
  Neue Versionen installieren sich über die alte, die Daten bleiben erhalten. Jedes Release verlinkt den [Testplan](TESTPLAN.md).
- **Secrets:** Android installiert ein Update nur, wenn es mit demselben Schlüssel signiert ist wie die installierte App.
  Dieser Schlüssel darf nicht in den Code, deshalb liegt er als verschlüsseltes GitHub-Secret vor
  (*Settings → Secrets and variables → Actions*). GitHub nutzt ihn nur beim Bauen; auslesen lässt er sich nicht.

## Erster Test: Machbarkeits-Test

Startbildschirm → **Machbarkeits-Test**:
1. *Modell laden*: misst Ladezeit, Backend (GPU/CPU) und Speicher.
2. *Foto beschreiben*: mit ~10 verschiedenen Teilen durchprobieren.
3. *Zuordnung testen*: prüft Function Calling am Beispiel „weiße Socken“.
4. *Bild-Embedding*: Tempo der NN-Stufe.
5. Danach auf **CPU** umschalten und wiederholen.
6. Oben rechts **Teilen**, die Ergebnisse gehen dann an die Entwicklung (Schwellen, Prompts und Modellwahl werden damit kalibriert).

## Haushaltspaket

Die Daten liegen lokal pro Handy. Unter **Haushaltspaket** lässt sich die Kleidertabelle als ZIP teilen (komplett oder nur Neues) und auf anderen Handys importieren. Dabei wird über UUIDs zusammengeführt, und der neuere Stand gewinnt. Ein automatischer Sync (Firebase) ist für Phase 2 geplant; das Datenmodell ist bereits darauf ausgelegt.

## Entwicklung

```bash
flutter pub get
dart run build_runner build   # drift-Code nach Schema-Änderungen
flutter analyze
flutter test
flutter build apk --release --target-platform android-arm64
```

Flutter 3.47.7 (siehe `.github/workflows/ci.yml`).

Struktur:
```
lib/
  ai/         Gemma-Dienst (Laden/Entladen, Beschreiben, Zuordnen), Prompts, Tool-Schemas, Parser, MobileNet-Embedder
  pipeline/   Kandidatenfilter, Rückfragen, Zustandsautomat, Verwechslungs-Check, Schwellen (matching_config.dart)
  core/       drift-Datenbank, Repository, Fotoablage, Vokabular, Gerät/Speicherwächter, Merge
  features/   Bildschirme (Scan, Kleiderschrank, Personen, Haushaltspaket, Setup, Machbarkeits-Test, Verlauf)
```

### CI / Releases

- Jeder Push: Analyse, Tests, APK als Artefakt (`.github/workflows/ci.yml`).
- Neue Version: `version:` in `pubspec.yaml` erhöhen (z. B. `0.1.1+1`) und auf `main` pushen. Gibt es den Tag `v0.1.1` noch nicht,
  baut `.github/workflows/release.yml` ein signiertes APK und legt Tag und Release selbst an. `TESTPLAN.md` → „Neu in dieser Version“ vorher ergänzen.

### Release-Schlüssel (einmalig)

Updates lassen sich nur über die installierte App installieren, wenn jede Version mit **demselben Schlüssel** signiert ist. Der Schlüssel liegt als GitHub-Secret vor, nicht im Repo:

| Secret | Inhalt |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Passwort des Keystores |
| `ANDROID_KEY_ALIAS` | Alias, z. B. `waeschewer` |
| `ANDROID_KEY_PASSWORD` | Passwort des Schlüssels |

Erzeugen: `keytool -genkeypair -v -keystore release.jks -alias waeschewer -keyalg RSA -keysize 4096 -validity 36500`.
Den Keystore sicher aufbewahren: Ohne ihn lässt sich kein Update mehr über die installierte App spielen.

## iOS (später)

Der Code ist plattformneutral. Für iPhone 16 / 17 Pro fehlen noch: Deployment-Target 16.0, Entitlements (Increased Memory Limit, Extended Virtual Addressing) und die Verteilung (TestFlight mit Apple Developer Program oder SideStore).
