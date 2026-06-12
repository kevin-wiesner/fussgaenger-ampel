## Fußgänger-Bedarfsampel (SPS / Structured Text)

Beschreibung: „Bedarfsampel für einen Fußgängerüberweg. Autos haben normalerweise Grün; drückt ein Fußgänger den Anforderungstaster, läuft die Umschaltung ab und schaltet danach zurück."

Eine Ampelsteuerung , programmiert in Structured Text (IEC 61131-3) mit dem OpenPLC Editor.

Aktuelle Version: Kreuzung bestehend aus Fußgaenger und Auto Fahrer. 

## Funktion

| Schritt | Auto | Fußgänger | Dauer |
|--------:|------|-----------|-------|
| 0 | Rot-Gelb | Rot | 2 s |
| 1 | Grün | Rot | bis Taster gedrückt |
| 2 | Gelb | Rot | 3 s |
| 3 | Rot | Rot | 1 s |
| 4 | Rot | Grün | 6 s |
| 5 | Rot | Rot | 1 s |

## Technik

- Zustandsautomat über `CASE Schritt OF ... END_CASE`
- Sicherheitsverriegelung: falls je beide Richtungen grün wären, werden beide sofort abgeschaltet
- Grundstellung „alles Rot" je Zyklus, danach nur die Abweichungen setzen (sicherer Default)
- Ein einziger `TON`-Timer für alle Phasen, mit Selbstreset, bei jedem neuen Schritt wird Timer automatisch zurück gesetzt



