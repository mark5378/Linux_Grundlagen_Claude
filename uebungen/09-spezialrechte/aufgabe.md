# Gemeinsame Ablage mit Spezialrechten

Baue im Übungsordner eine kleine Dateiablage für ein Team. Gruppe ist jeweils deine eigene Gruppe (die musst du nicht ändern).

| Verzeichnis | Rechte | Warum? |
|---|---|---|
| `ablage` | `750` | Nur Besitzer und Gruppe kommen hinein |
| `ablage/team` | `2770` | SetGID: neue Dateien erben die Gruppe des Ordners |
| `ablage/austausch` | `1770` | Sticky Bit: jeder darf nur eigene Dateien löschen |

1. Lege die drei Verzeichnisse an und setze die Rechte.
2. Lege in `ablage/team` die Datei `plan.txt` an, die Besitzer und Gruppe lesen und schreiben dürfen, alle anderen gar nichts.
3. Schreibe in `umrechnung.txt` die Oktalwerte zu diesen Rechten – eine Zahl pro Zeile, in dieser Reihenfolge:

```
-rwxr-x--x
drwxrws---
drwxrwxrwt
-rwsr-xr-x
```

Nützliche Befehle: `mkdir -p`, `chmod`, `touch`, `ls -ld`, `stat -c '%a %A' DATEI`

> Spezialbits als vorangestellte Ziffer: **4** = SetUID, **2** = SetGID, **1** = Sticky. Ein großes `S` oder `T` in `ls -l` bedeutet: Spezialbit gesetzt, aber das `x` darunter fehlt.
