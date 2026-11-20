# Fehler und Angriffe in Logdateien finden

Im Ordner `logs` liegen zwei Protokolle:

- `portal.log` – Meldungen eines Webportals im Format `ZEIT STUFE MODUL Text`
- `auth.log` – SSH-Anmeldeversuche

Erzeuge die folgenden Dateien im Ordner `berichte` (lege ihn an). Nutze Pipes, nicht abzählen!

| Datei | Inhalt |
|---|---|
| `stufen.txt` | Wie oft kommt jede Meldungsstufe (INFO, WARN, ERROR, CRITICAL) vor? Absteigend sortiert, im Format von `uniq -c` (Anzahl, dann Stufe) |
| `fehler_module.txt` | Nur ERROR-Meldungen: Anzahl pro Modul (Format wie `uniq -c`) |
| `sendungen.txt` | Alle Sendungsnummern mit Häufigkeit. Eine gültige Nummer ist `WK-` gefolgt von **genau sechs** Ziffern (Format wie `uniq -c`) |
| `ssh_fehlversuche.txt` | Nur die Anzahl der fehlgeschlagenen Passwort-Anmeldungen (`Failed password`) |
| `ssh_ips.txt` | Von welchen IP-Adressen kamen die Fehlversuche, wie oft? (Format wie `uniq -c`) |

Zum Schluss Datenströme trennen: Führe `ls logs/portal.log logs/gibtsnicht.log` aus und leite dabei die normale Ausgabe nach `berichte/gefunden.txt` und die Fehlermeldung nach `berichte/fehler.txt` um.

Nützliche Befehle: `grep`, `grep -oE`, `grep -E 'A|B'`, `awk '{print $2}'`, `cut`, `sort`, `uniq -c`, `sort -rn`, `wc -l`, `>`, `2>`, `tee`

> `\b` im regulären Ausdruck markiert eine Wortgrenze – damit trifft `WK-[0-9]{6}\b` keine siebenstelligen Nummern.
