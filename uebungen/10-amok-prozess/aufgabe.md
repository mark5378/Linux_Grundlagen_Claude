# Ein Prozess läuft aus dem Ruder

Beim Start dieser Übung wurde im Hintergrund das Skript `import_test.sh` gestartet. Es schreibt ununterbrochen in `logs/import_test.log` – die Datei ist schon mehrere Megabyte groß und wächst weiter.

1. Finde die **PID** des Prozesses und schreibe sie in `pid.txt`.
2. Beende den Prozess **sauber** mit SIGTERM (nicht gleich `kill -9`!) und kontrolliere, dass er weg ist.
3. Finde heraus, welche Datei im Übungsordner so groß ist (`du`), und **leere** sie, ohne sie zu löschen.
4. Schreibe in `freier_platz.txt` die Ausgabe von `df -h .` (zur Kontrolle des Speicherplatzes).

Nützliche Befehle: `pgrep -af`, `ps aux | grep`, `kill`, `ps -p PID`, `du -sh *`, `du -ah | sort -h`, `truncate -s 0`, `> datei`, `df -h`

> Erst den schreibenden Prozess beenden, dann aufräumen! Löscht man eine Datei, die ein Prozess noch offen hat, wird der Platz erst frei, wenn der Prozess endet.
