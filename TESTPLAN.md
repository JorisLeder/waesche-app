# Testplan WäscheWer

Diese Liste gehört zu jedem Release. Oben steht, was in der aktuellen Version neu ist und deshalb besonders geprüft
werden sollte. Darunter folgt die vollständige Liste für einen Komplett-Test.

**Testgeräte:** Samsung Galaxy A37, Redmi Note 10 Pro (beide Android).

**Bei Fehlern bitte schicken:** Gerät, Schritt, was passiert ist (Screenshot), und den Text aus „Details“ im Scan bzw.
aus dem Teilen-Knopf im Machbarkeits-Test.

---

## Neu in dieser Version

### v0.1.0: erste Testversion
Alles ist neu, also bitte einmal die komplette Liste durchgehen. Am wichtigsten sind Abschnitt 1 (Modell-Download)
und Abschnitt 2 (Machbarkeits-Test) auf **beiden** Geräten: Davon hängt ab, ob das Redmi eine schnellere
Sonderlösung braucht und wie die Schwellen eingestellt werden.

---

## Komplett-Test

### 1. Installation & KI-Modell
- [ ] APK installiert sich, App „WäscheWer“ startet ohne Absturz.
- [ ] Startbildschirm zeigt den Hinweis zum KI-Modell.
- [ ] *KI-Modell → Modell herunterladen* (ca. 2,6 GB, WLAN): Fortschritt sichtbar, Benachrichtigung erscheint.
- [ ] Download läuft weiter bei ausgeschaltetem Bildschirm bzw. wenn die App im Hintergrund ist.
- [ ] App während des Downloads ganz schließen und wieder öffnen: Lädt sie weiter oder fängt sie neu an? (Notieren.)
- [ ] Nach dem Download steht dort „bereit“.
- [ ] Bei einer Fehlermeldung (z. B. Hugging Face, Speicherplatz): den genauen Text notieren.

### 2. Machbarkeits-Test (auf jedem Gerät)
Startbildschirm → *Machbarkeits-Test*
- [ ] *1. Modell laden* (GPU): Ladezeit, Backend (gpu/cpu) und Speicherwerte notieren.
- [ ] *2. Foto beschreiben* mit ca. 10 verschiedenen Teilen (Socken, Shirts, Hosen …): Stimmt die Beschreibung? Wie lange dauert es?
- [ ] *3. Zuordnung testen*: Kommt eine sinnvolle Rückfrage oder Zuordnung, oder „ungültig“?
- [ ] *4. Bild-Embedding*: Zeit notieren.
- [ ] Auf **CPU** umschalten, *1* und *2* wiederholen.
- [ ] Oben rechts **Teilen** und die Ergebnisse schicken.

### 3. Personen
- [ ] 2–3 Personen anlegen (Name, Farbe).
- [ ] Person bearbeiten (Name/Farbe ändern).
- [ ] Person löschen: Ihre Teile verschwinden mit.

### 4. Kleiderschrank / Einpflegen
- [ ] Teil per Kamera einpflegen: Passt der weiße Rahmen zum gespeicherten Bildausschnitt?
- [ ] KI-Vorschlag erscheint (beim ersten Mal mit Ladezeit). Wie gut sind Kategorie, Farbe, Muster und Länge?
- [ ] Teil per Galerie-Foto einpflegen.
- [ ] Detailfoto ergänzen, ein Foto wieder löschen.
- [ ] Speichern: Wie lange dauert es (Bildmerkmale werden berechnet)?
- [ ] Zwei ähnliche Teile für **verschiedene** Personen anlegen (z. B. weiße Socken): Erscheint „Verwechslungsgefahr“?
- [ ] Teil bearbeiten, Besitzer ändern, Teil löschen.
- [ ] Filter nach Person in der Liste.

### 5. Scannen
Vorher: mindestens 2 Personen und ca. 10 Teile einpflegen, darunter bewusst ähnliche Paare.
- [ ] Eindeutiges Teil scannen: direktes Ergebnis mit großer Personenanzeige? Gesamtzeit unter „Details“ notieren.
- [ ] Eine der ähnlichen Socken scannen: Kommt eine Rückfrage? Ist sie verständlich, und führt die Antwort zur richtigen Person?
- [ ] *Weiß nicht* bei einer Rückfrage führt zum Fotovergleich.
- [ ] Fotovergleich: richtiges Teil antippen, die Person wird angezeigt.
- [ ] *Falsch* bei einem Vorschlag führt zum Fotovergleich ohne das falsche Teil.
- [ ] *Keins davon* bietet *Als neues Teil einpflegen* an (mit dem Scanfoto).
- [ ] *Stimmt – nächstes Teil* öffnet direkt die Kamera für das nächste Teil.
- [ ] Dasselbe Teil 3–4 Mal scannen: Wird die Zuordnung sicherer oder schneller (Lernschleife)?
- [ ] Falsche Zuordnungen **ohne** Rückfrage bitte immer melden (das ist der wichtigste Fehler).
- [ ] *Scan-Verlauf*: Statistik zeigt, welche Stufe entschieden hat.

### 6. Stabilität & Speicher
- [ ] Während eines Scans die App wechseln und zurückkommen: kein Absturz?
- [ ] Viele andere Apps offen: Kommt ein Speicherhinweis statt eines Absturzes?
- [ ] Nach ca. 2 Minuten ohne Nutzung zeigt der Machbarkeits-Test „nicht im Speicher“.
- [ ] Wird das Handy bei 10 Scans hintereinander spürbar warm, oder sinkt der Akku auffällig?
- [ ] Kamera-Berechtigung einmal verweigern: Gibt es eine verständliche Meldung?

### 7. Haushaltspaket (zwei Handys)
- [ ] *Komplettes Paket teilen* (z. B. per WhatsApp an dich selbst).
- [ ] Auf dem zweiten Handy *Paket importieren*: Personen, Teile und Fotos sind da, die Bildmerkmale werden berechnet.
- [ ] Teil auf Handy A ändern, *Nur Neues teilen*, auf Handy B importieren: Die Änderung ist angekommen.
- [ ] Dasselbe Paket zweimal importieren: keine doppelten Einträge.
