# Ein Backup-Skript mit Aufbewahrungsfrist

Schreibe das Skript `backup.sh` (im Übungsordner, ausführbar). Es sichert den Ordner `daten` nach `backups`.

**Anforderungen**

1. Aufruf: `./backup.sh [TAGE]` – `TAGE` ist die Aufbewahrungsdauer, Standard **14**.
2. Nur eine **positive ganze Zahl** ist erlaubt. Bei `0`, `-3`, `abc` o. Ä.: Fehlermeldung auf stderr, Exit-Code ungleich 0, **kein** Archiv erstellen.
3. Archiv: `backups/daten_JJJJ-MM-TT_HHMMSS.tar.gz` (z. B. mit `date +%F_%H%M%S`), komprimiert mit `tar -czf`.
4. Das neue Archiv mit `tar -tzf` auf Lesbarkeit prüfen.
5. Alte Archive löschen: nur Dateien `daten_*.tar.gz` **in** `backups`, die älter als `TAGE` Tage sind. Andere Dateien in `backups` bleiben unangetastet!
6. Keine zwei Läufe gleichzeitig: Sperre mit `flock -n` auf die Datei `backup.lock` im Übungsordner. Ist die Sperre belegt → Meldung, Exit-Code ungleich 0.
7. Jeden Lauf mit Datum und Uhrzeit in `backup.log` protokollieren (anhängen).

Empfohlen: `set -euo pipefail` am Anfang.

Ungefährlich testen, ob alte Archive erkannt werden – erst nur anzeigen, dann löschen:
```
touch -d "20 days ago" backups/daten_2026-01-01_000000.tar.gz
find backups -name 'daten_*.tar.gz' -mtime +14          # nur anzeigen
```

Nützliches: `[[ $1 =~ ^[1-9][0-9]*$ ]]`, `${1:-14}`, `exec 9>backup.lock; flock -n 9 || exit 1`, `find ... -mtime +N -delete`, `>> backup.log`, `>&2`
