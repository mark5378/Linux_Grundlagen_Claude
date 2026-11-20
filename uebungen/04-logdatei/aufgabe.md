# Detektivarbeit in einer Logdatei

Die Datei `server.log` enthält die Zugriffe eines Webservers. Jede Zeile sieht so aus:

    2026-11-20 08:15:02 INFO 192.168.1.23 GET /index.html

Beantworte die folgenden Fragen, indem du **Befehle und Pipes** nutzt (nicht abzählen!):

1. Schreibe die **Anzahl** der Zeilen mit `ERROR` in die Datei `fehler_anzahl.txt` (nur die Zahl).
2. Schreibe alle **unterschiedlichen IP-Adressen** (4. Spalte) **sortiert**, eine pro Zeile, in `ips.txt`.
3. Schreibe alle Zeilen mit `WARN` in die Datei `warnungen.txt`.

Nützliche Befehle: `grep`, `grep -c`, `cut -d' ' -f4`, `sort`, `uniq`, `wc -l`, `>`
