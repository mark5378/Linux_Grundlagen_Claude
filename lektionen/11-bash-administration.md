# 11 – Bash-Skripte, Automatisierung & Datenträger

## Ein erstes Skript

```bash
#!/usr/bin/env bash
# bericht.sh – erstellt einen kurzen Systembericht
set -euo pipefail

rechner=$(hostname)                         # Befehlsausgabe in Variable
bericht="$HOME/bericht_$(date +%F).txt"     # KEINE Leerzeichen um das =

echo "Bericht für $rechner" > "$bericht"    # neu anlegen
df -h / >> "$bericht"                       # anhängen
echo "Gespeichert unter: $bericht"
```

```bash
chmod +x bericht.sh
./bericht.sh      # ./ nötig: das aktuelle Verzeichnis steht nicht in $PATH
```

**Variablen immer in Anführungszeichen** (`"$datei"`). Sonst zerfallen Namen mit Leerzeichen in mehrere Wörter.

### Typische Anfängerfehler

| Beobachtung | Ursache | Lösung |
|---|---|---|
| „Keine Berechtigung“ beim Start | nicht ausführbar | `chmod +x skript.sh` |
| `bericht = "…"`: „Befehl nicht gefunden“ | Leerzeichen um `=` | `bericht="…"` |
| Skript verhält sich seltsam, obwohl Rechte stimmen | falsche/fehlende Shebang-Zeile oder Windows-Zeilenenden (CRLF) | erste Zeile prüfen, `file skript.sh`, `sed -i 's/\r$//' skript.sh` |

## Bedingungen

```bash
if [[ -f /etc/hostname ]]; then echo "Datei existiert"; fi
if (( belegung >= 90 )); then echo "KRITISCH"; elif (( belegung >= 80 )); then echo "WARNUNG"; else echo "OK"; fi
if systemctl is-active --quiet nginx; then echo "läuft"; fi
if mountpoint -q /mnt/backup; then echo "eingehängt"; fi
[[ $1 =~ ^[1-9][0-9]*$ ]] || { echo "Bitte positive Zahl" >&2; exit 1; }
```

| Test | Bedeutung |
|---|---|
| `-f` / `-d` / `-e` | Datei / Verzeichnis / existiert |
| `-x` / `-r` / `-w` | ausführbar / lesbar / schreibbar |
| `-z "$s"` / `-n "$s"` | Zeichenkette leer / nicht leer |
| `==`, `!=`, `=~` | gleich, ungleich, passt auf regulären Ausdruck |
| `(( a > b ))` | Rechnen und Vergleichen mit ganzen Zahlen |

## Schleifen

```bash
# for: feste Liste abarbeiten
for dienst in nginx ssh cron; do systemctl is-active "$dienst"; done

# while: solange etwas gilt, z. B. eine Datei zeilenweise lesen
while read -r ort prozent; do echo "$ort: $prozent %"; done < belegung.txt

# until: bis etwas eintritt, z. B. warten, bis ein Dienst erreichbar ist
until ping -c1 -W1 10.40.10.1 >/dev/null; do sleep 2; done
```

## Arrays, Funktionen, lokale Variablen

```bash
dienste=(nginx ssh cron fail2ban)
for d in "${dienste[@]}"; do echo "$d"; done
echo "Anzahl: ${#dienste[@]}"

pruefe_dienst() {
  local name=$1                    # local: gilt nur in der Funktion
  if systemctl is-active --quiet "$name"; then
    echo "OK: $name läuft"
  else
    echo "KRITISCH: $name läuft nicht"
    return 2
  fi
}
pruefe_dienst nginx || status=2
```

## Exit-Codes und Befehlsverkettung

- `0` = Erfolg, alles andere = Fehler. `$?` enthält den Code des letzten Befehls.
- Eigene Codes mit `exit 2` (Skript) bzw. `return 2` (Funktion).

```bash
cd /opt/skripte && ./bericht.sh      # nur wenn cd klappt
mkdir test || echo "Ging nicht"      # nur bei Fehler
befehl1 ; befehl2                    # immer beide
```

## Robuste Skripte: `set -euo pipefail`

| Option | Wirkung |
|---|---|
| `-e` | Abbruch, sobald ein Befehl fehlschlägt |
| `-u` | Abbruch bei nicht gesetzten Variablen (Tippfehler!) |
| `-o pipefail` | eine Pipeline gilt als fehlgeschlagen, wenn **ein** Teil fehlschlägt |

In **Prüfskripten** darf ein ausgefallener Dienst das Skript nicht abbrechen. Erwartete Fehlschläge fängst du deshalb mit `if …` oder `|| …` ab.

## Skripte prüfen

| Werkzeug | Was es tut |
|---|---|
| `bash -n skript.sh` | nur **Syntax** prüfen, ohne Ausführung |
| `bash -x skript.sh` | ausführen und **jede Zeile** vor der Ausführung anzeigen |
| `shellcheck skript.sh` | **statische Analyse**: findet fehlende Anführungszeichen, Tippfehler und typische Fallen |

## Aliase

```bash
alias portalfehler='grep ERROR ~/pilot/logs/portal.log | tail -n 5'
alias portalfehler          # Definition anzeigen
echo "alias portalfehler='grep ERROR ~/pilot/logs/portal.log | tail -n 5'" >> ~/.bashrc
source ~/.bashrc            # dauerhaft und sofort aktiv
```

Aliase gelten nur in **interaktiven** Shells. Skripte laden die `.bashrc` nicht und werten Aliase standardmäßig nicht aus. Nimm dort Funktionen.

🛠️ **Übung:** `./uebung.sh start 13` – ein Systemcheck mit Schwellenwerten und Exit-Codes

## Datensicherung

**3-2-1-Regel:** **3** Kopien der Daten, auf **2** verschiedenen Medien, **1** davon außer Haus bzw. offline.

Was ein gutes Backup-Skript vorher prüft:

| Prüfung | Warum |
|---|---|
| Root-Rechte (`[[ $EUID -eq 0 ]]`) | sonst fehlen Lesezugriffe und das Backup bleibt unvollständig |
| `mountpoint -q /mnt/backup` | Ist die Platte nicht eingehängt, landet das Backup unbemerkt auf der Systemplatte |
| Aufbewahrungsdauer validieren | `-mtime +abc` oder `+0` würde falsch oder zu viel löschen |
| `flock -n` | zwei gleichzeitige Läufe überschreiben sich oder füllen die Platte |
| `tar -tzf archiv` | Ist das Archiv lesbar? |
| Löschauswahl erst anzeigen (`find … -mtime +14` ohne `-delete`) | nur alte Sicherungen im Backup-Ordner löschen, nichts anderes |

```bash
exec 9>/run/backup.lock; flock -n 9 || { echo "läuft bereits" >&2; exit 1; }
archiv="/mnt/backup/daten/daten_$(date +%F_%H%M%S).tar.gz"
tar -czf "$archiv" -C /srv daten && tar -tzf "$archiv" >/dev/null
find /mnt/backup/daten -maxdepth 1 -name 'daten_*.tar.gz' -mtime +14 -delete
```

**Ein Backup ist erst gut, wenn die Wiederherstellung klappt:** Lies das Archiv in ein Testverzeichnis zurück (`tar -xzf … -C /tmp/restore`) und vergleiche (`diff -r`). Dass ein Cronjob *gestartet* wurde, beweist noch nicht, dass ein brauchbares Backup entstanden ist.

🛠️ **Übung:** `./uebung.sh start 14` – Backup-Skript mit Aufbewahrungsfrist und flock

## Zeitsteuerung mit cron

```
┌──────── Minute (0–59)
│ ┌────── Stunde (0–23)
│ │ ┌──── Tag des Monats (1–31)
│ │ │ ┌── Monat (1–12)
│ │ │ │ ┌ Wochentag (0–7, 0 und 7 = Sonntag)
│ │ │ │ │
30 2 * * *  root  /opt/skripte/backup.sh >> /var/log/backup.log 2>&1
*/15 * * * * root /opt/skripte/systemcheck.sh >> /var/log/systemcheck.log 2>&1
```

- `crontab -e`: persönliche Crontab, **ohne** Benutzerfeld
- `/etc/cron.d/datei`: systemweit, **mit** Benutzerfeld, da sonst unklar wäre, als wer der Befehl läuft
- Cron hat einen sehr kurzen `PATH`. Deshalb **immer absolute Pfade** angeben. Sonst kommt `backup.sh: not found`.

| cron | systemd-Timer |
|---|---|
| eine Zeile, einfach | zwei Dateien (`.service` + `.timer`) |
| verpasste Läufe (Rechner aus) entfallen | `Persistent=true` holt sie nach |
| Ausgabe muss man selbst umleiten | Ausgabe automatisch im Journal (`journalctl -u name`) |
| | Übersicht: `systemctl list-timers` |

Funktioniert die Automatisierung? Prüfe `systemctl status cron`, `journalctl -u cron`, die Logdateien und die neu erzeugten Archive, und mach einen Test der Wiederherstellung.

## Datenträger einrichten

```bash
lsblk            # Baum aller Datenträger und Partitionen
sudo blkid       # UUIDs, Labels, Dateisystemtypen
sudo fdisk -l    # Partitionstabellen
df -hT           # eingehängte Dateisysteme, Belegung, Typ
```

**Block- und Zeichengeräte:** Blockgeräte wie Festplatten (`/dev/sda`) arbeiten mit Datenblöcken und wahlfreiem Zugriff. Zeichengeräte wie Terminals (`/dev/tty`) arbeiten mit einem Strom aus Zeichen.

| MBR | GPT |
|---|---|
| max. 2 TiB | praktisch unbegrenzt |
| 4 primäre Partitionen | standardmäßig 128 Partitionen |
| eine Partitionstabelle | Sicherungskopie am Plattenende + Prüfsummen |
| BIOS | UEFI-Standard |

**Neue Platte als Backup-Ziel**: Die Schritte 2 und 3 **löschen alles** auf dem Gerät. Prüfe deshalb vorher genau, ob es die richtige Platte ist (`lsblk`: Größe, keine Einhängepunkte).

```bash
lsblk                                         # 1. neue Platte identifizieren, z. B. sdb (50G, ohne Partitionen)
sudo parted /dev/sdb --script mklabel gpt mkpart backup ext4 0% 100%   # 2. GPT + Partition
sudo mkfs.ext4 -L backup /dev/sdb1            # 3. formatieren mit Label
sudo mkdir -p /mnt/backup                     # 4. Einhängepunkt
sudo blkid /dev/sdb1                          # 5. UUID ermitteln
```

**Eintrag in `/etc/fstab`:**

```
# schlecht (Vorschlag einer KI):
/dev/sdb1 /mnt/backup ext4 defaults 0 2
# besser:
UUID=5b2e8c41-...  /mnt/backup  ext4  defaults,nofail  0  2
```

- `/dev/sdb1` kann beim nächsten Start ein anderes Gerät sein. Die **UUID** bleibt gleich.
- Ohne `nofail` bleibt der Start hängen (Notfallmodus), wenn die Platte fehlt.

**Vor dem Neustart testen:**

```bash
sudo cp /etc/fstab /etc/fstab.bak
sudo findmnt --verify      # fstab auf Fehler prüfen
sudo mount -a              # alles einhängen, was in fstab steht
findmnt /mnt/backup        # eingehängt?
```

**Swap** ist Auslagerungsspeicher auf dem Datenträger, falls der RAM knapp wird. Prüfen kannst du ihn mit `swapon --show` oder `free -h`.

🛠️ **Übung:** `./uebung.sh start 15` – cron-Zeilen und fstab-Eintrag

## KI in der Systemadministration

**Guter Prompt:** Rolle, Kontext, Aufgabe, Ausgabeformat und Einschränkungen.

```
Rolle: Du bist erfahrener Linux-Administrator.
Kontext: Ubuntu Server 24.04, neue leere 50-GiB-Platte /dev/sdb (laut lsblk), Systemplatte ist sda mit LVM.
Aufgabe: Erkläre Schritt für Schritt, wie ich sdb als Backup-Ziel unter /mnt/backup einrichte (GPT, ext4).
Format: nummerierte Schritte, jeder Befehl mit kurzer Erklärung und Prüfbefehl.
Einschränkungen: Markiere jeden Schritt, der Daten löschen kann. Verwende UUIDs in fstab, der Server muss
auch ohne die Platte starten. Keine Befehle, die sda betreffen.
```

- **Keine Zugangsdaten oder personenbezogenen Daten** in Prompts. Sie verlassen das Unternehmen.
- KI-Befehle **vor** dem Ausführen verstehen und prüfen (`man`, offizielle Dokumentation, Test-VM). KIs schlagen auch plausible, aber falsche oder gefährliche Befehle vor.
- Die **Verantwortung** für Änderungen am System bleibt beim Administrator.

---

✅ **Teste dich:** `./quiz.sh -t 11` &nbsp;·&nbsp; 🛠️ **Übungen:** `./uebung.sh start 13`, `14`, `15`
