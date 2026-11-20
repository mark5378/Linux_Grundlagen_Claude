# Ein Systemcheck-Skript schreiben

Schreibe das Skript `systemcheck.sh`, das Speicherplatz und Dienste bewertet. Damit du es ohne echten Server testen kannst, liest es die Messwerte aus zwei Dateien im **aktuellen Verzeichnis** (Beispiele liegen im Ordner `beispiel`):

`belegung.txt` – Einhängepunkt und Belegung in Prozent:
```
/ 84
/mnt/backup 92
```
`dienste.txt` – Dienst und Status:
```
nginx active
cron inactive
```

**Regeln**

| Prüfung | OK | WARNUNG | KRITISCH |
|---|---|---|---|
| Speicherplatz | unter 80 % | ab 80 % | ab 90 % |
| Dienst | `active` | – | alles andere |

**Ausgabe:** eine Zeile pro Prüfobjekt, die mit dem Status beginnt, z. B.
```
OK: nginx läuft
WARNUNG: / ist zu 84 % belegt
KRITISCH: cron ist inactive
```

**Exit-Code:** `0` = alles OK, `1` = mindestens eine Warnung, aber nichts Kritisches, `2` = mindestens ein kritischer Zustand.

**Anforderungen:** Shebang `#!/usr/bin/env bash` in der ersten Zeile, ausführbar, mindestens **zwei Funktionen** (z. B. `pruefe_platz` und `pruefe_dienst`). Ein kritischer Befund darf das Skript nicht vorzeitig abbrechen – alle Zeilen werden geprüft.

Testen: `cd beispiel && ../systemcheck.sh; echo "Exit-Code: $?"`

Nützliches: `while read -r name wert; do … done < datei`, `if (( wert >= 90 ))`, `local`, `return`, `exit`, `bash -n`, `bash -x`, `shellcheck`
