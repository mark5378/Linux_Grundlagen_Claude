# Rechte richtig setzen

In deinem Übungsordner liegen drei Dateien. Setze ihre Rechte wie folgt:

| Datei          | Besitzer             | Gruppe            | Andere  |
|----------------|----------------------|-------------------|---------|
| `deploy.sh`    | lesen, schreiben, ausführen | lesen, ausführen | nichts |
| `geheim.key`   | lesen, schreiben     | nichts            | nichts  |
| `info.txt`     | lesen, schreiben     | lesen             | lesen   |

Außerdem: Starte danach `./deploy.sh` – das Skript legt eine Datei an, die ebenfalls geprüft wird.

Nützliche Befehle: `ls -l`, `chmod`, `stat -c %a DATEI`
