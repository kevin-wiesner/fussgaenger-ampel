# Fussgänger-Bedarfsampel (SPS / Structured Text)

Bedarfsampel für einen Fussgängerüberweg, programmiert in **Structured Text nach IEC 61131-3** mit dem OpenPLC Editor.

Autos haben im Normalfall Grün. Drückt ein Fussgänger den Anforderungstaster, läuft die Umschaltung ab und der Automat kehrt danach in die Autofreigabe zurück.

**Dieses Programm habe ich eigenständig nach Spezifikation entworfen und implementiert** — Anforderungen und Variablenliste waren vorgegeben, Logik und Umsetzung stammen von mir.

---

## Funktion

| Schritt | Auto | Fussgänger | Dauer | Übergang |
|--------:|------|------------|:-----:|---|
| 0 | Rot-Gelb | Rot | 2 s | Zeit |
| 1 | Grün | Rot | unbegrenzt | **Taster** |
| 2 | Gelb | Rot | 3 s | Zeit |
| 3 | Rot | Rot | 1 s | Zeit |
| 4 | Rot | **Grün** | 6 s | Zeit |
| 5 | Rot | Rot | 1 s | Zeit |

Nach Schritt 5 beginnt der Zyklus wieder bei 0.

---

## Zustandsdiagramm

```mermaid
stateDiagram-v2
    direction LR
    [*] --> S0
    S0: 0 · Auto Rot-Gelb
    S1: 1 · Auto Grün — wartet
    S2: 2 · Auto Gelb
    S3: 3 · Alles Rot
    S4: 4 · FG Grün
    S5: 5 · Alles Rot

    S0 --> S1: nach 2 s
    S1 --> S2: Taster_FG
    S2 --> S3: nach 3 s
    S3 --> S4: nach 1 s
    S4 --> S5: nach 6 s
    S5 --> S0: nach 1 s
```

**Der Unterschied zur reinen Zeitampel liegt in Schritt 1.** Alle anderen Übergänge sind zeitgesteuert; dieser eine wartet auf ein Ereignis. Der Automat bleibt beliebig lange in Schritt 1 stehen, solange niemand drückt.

---

## Signalliste

Das Projekt läuft im **OpenPLC-Simulator**, ein Pin-Mapping auf physische Hardware ist nicht hinterlegt.

| Variable | Typ | Richtung | Bedeutung |
|---|---|---|---|
| `Taster_FG` | `BOOL` | **Eingang** | Anforderungstaster Fussgänger |
| `Auto_Rot` | `BOOL` | Ausgang | Rot Fahrbahn |
| `Auto_Gelb` | `BOOL` | Ausgang | Gelb Fahrbahn |
| `Auto_Gruen` | `BOOL` | Ausgang | Grün Fahrbahn |
| `FG_Rot` | `BOOL` | Ausgang | Rot Fussgänger |
| `FG_Gruen` | `BOOL` | Ausgang | Grün Fussgänger |
| `Schritt` | `INT` | intern | aktuelle Phase 0–5 |
| `Schritt_alt` | `INT` | intern | Schritt des vorherigen Zyklus, für den Timer-Reset |
| `T_Zeit` | `TIME` | intern | Dauer der aktuellen Phase |
| `T1` | `TON` | intern | Phasentimer |

**Bei Zuordnung auf echte Hardware:** `Taster_FG` auf einen digitalen Eingang (`%IX0.0`), die fünf Lampen auf digitale Ausgänge (`%QX0.0` bis `%QX0.4`).

---

## Technik

- **Zustandsautomat** über `CASE Schritt OF ... END_CASE`
- **Grundstellung auf sicheren Zustand:** Zu Beginn jedes Zyklus stehen alle Lampen auf Rot, danach setzt die aktive Phase nur ihre Abweichungen.
- **Sicherheitsverriegelung:** Wären je beide Richtungen gleichzeitig grün, werden beide sofort abgeschaltet.

### Timer-Reset über den Schrittwechsel

```pascal
T1(IN := (Schritt = Schritt_alt), PT := T_Zeit);
Schritt_alt := Schritt;
```

Der Timer läuft nur, solange der Schritt unverändert bleibt. Sobald der Automat weiterschaltet, ist `Schritt <> Schritt_alt` — `IN` wird für einen Zyklus `FALSE` und der Timer startet in der neuen Phase sauber bei null.

Das löst ein Problem, das bei einem Timer mit Selbstreset (`IN := NOT T1.Q`) nicht so klar zu sehen ist: Der Reset hängt hier am Zustandswechsel selbst, nicht am Ablaufen der Zeit. Genau deshalb funktioniert Schritt 1, der gar keine Zeitbedingung hat, sondern auf den Taster wartet.

---

## Bekannte Vereinfachungen

Bewusst nicht umgesetzt, für eine reale Anlage aber nötig:

- **Keine Mindestgrünzeit für Fahrzeuge.** Wird der Taster sofort nach Beginn von Schritt 1 gedrückt, schaltet die Ampel unmittelbar weiter. Eine echte Bedarfsampel hält eine Mindestfreigabezeit ein, bevor sie auf Anforderung reagiert.
- **Keine gespeicherte Anforderung.** Ein Tastendruck während der Schritte 2 bis 5 verfällt. In der Praxis wird die Anforderung gespeichert und im nächsten Grünabschnitt bedient.
- **Keine Flankenauswertung des Tasters.** In dieser Logik unkritisch, weil in Schritt 1 nur der Pegel abgefragt wird. Bei einer gespeicherten Anforderung wäre `R_TRIG` nötig.

---

## Ausführen

1. Projekt im OpenPLC Editor öffnen
2. Kompilieren und Simulation starten
3. Variablen `Schritt`, `Auto_*`, `FG_*` und `Taster_FG` in den Debugger holen
4. In Schritt 1 `Taster_FG` auf `TRUE` setzen, um die Anforderung auszulösen

**Beim Testen beachten:** Gedrückt halten ist ein Dauersignal, einmal drücken ein Impuls. Für diesen Automaten reicht der Pegel — bei einer gespeicherten Anforderung wäre der Unterschied entscheidend.

---

## Hintergrund

Übungsprojekt im Rahmen meiner Vorbereitung auf die Industrieautomation. Erstes vollständig eigenständig entworfenes Programm nach vorgegebener Spezifikation.

Verwandtes Projekt: [ampelsteuerung](https://github.com/kevin-wiesner/ampelsteuerung) — Kreuzung mit zwei verriegelten Fahrtrichtungen, rein zeitgesteuert.
