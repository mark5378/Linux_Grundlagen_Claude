# Installationsmedien prüfen

Bevor man ein Betriebssystem installiert, prüft man, ob die heruntergeladene Datei unbeschädigt ist. Im Ordner `downloads` liegen drei Abbilddateien und die offizielle Prüfsummendatei `SHA256SUMS`.

1. Prüfe alle Dateien gegen `SHA256SUMS`.
2. Schreibe den Namen jeder **beschädigten** Datei in `defekt.txt` (ein Name pro Zeile, nur der Dateiname).
3. Lösche die beschädigten Dateien aus `downloads` – von einem kaputten Medium installiert man nicht.
4. Erzeuge für die Datei `meine_daten.tar` eine eigene Prüfsummendatei `meine_daten.sha256`, die sich mit `sha256sum -c meine_daten.sha256` prüfen lässt.

Nützliche Befehle: `cd`, `sha256sum`, `sha256sum -c`, `rm`, `>`

> Merke: Die Prüfsumme sichert die **Integrität** (Datei unverändert/vollständig). Ob die Prüfsummendatei wirklich vom Herausgeber stammt (**Echtheit**), prüft man zusätzlich mit einer GPG-Signatur.
