# 05 – Prozesse & Systeminformationen

## Was ist ein Prozess?

Jedes laufende Programm ist ein **Prozess** mit einer eindeutigen Nummer, der **PID**.

## Prozesse anzeigen

```bash
ps                # Prozesse in diesem Terminal
ps aux            # alle Prozesse aller Benutzer
ps aux | grep ssh # gezielt suchen
pgrep -a ssh      # kürzer: PID und Name
top               # Live-Ansicht (q beendet)
htop              # komfortabler, ggf. erst installieren
```

## Prozesse beenden

```bash
kill 1234         # höflich bitten (SIGTERM, Signal 15)
kill -9 1234      # erzwingen (SIGKILL) – nur wenn nötig
pkill firefox     # nach Namen
```

| Signal | Nr. | Bedeutung |
|---|---|---|
| SIGTERM | 15 | Bitte sauber beenden (Standard) |
| SIGKILL | 9 | Sofort abschießen, kein Aufräumen |
| SIGINT | 2 | Unterbrechen – das, was **Strg+C** sendet |
| SIGHUP | 1 | Terminal geschlossen / Konfiguration neu laden |

## Vordergrund & Hintergrund

```bash
sleep 100 &       # direkt im Hintergrund starten
jobs              # Hintergrund-Jobs dieses Terminals
fg %1             # Job 1 in den Vordergrund holen
# Strg+Z          # laufenden Prozess pausieren
bg                # pausierten Prozess im Hintergrund weiterlaufen lassen
```

## Systeminformationen

```bash
uname -a          # Kernel und System
uname -r          # nur Kernel-Version
hostname          # Rechnername
uptime            # Laufzeit und Last
free -h           # Arbeitsspeicher
df -h             # freier Platz auf Datenträgern
du -sh ordner/    # Größe eines Ordners
lsblk             # Datenträger und Partitionen
cat /etc/os-release   # welche Distribution?
```

## Dienste mit systemd

Hintergrunddienste (Webserver, SSH, …) werden über `systemctl` gesteuert:

```bash
systemctl status ssh
sudo systemctl start ssh
sudo systemctl stop ssh
sudo systemctl restart ssh
sudo systemctl enable ssh      # beim Booten starten
journalctl -u ssh -f           # Logs des Dienstes live verfolgen
```


## Prozesse genauer verstehen

- **PID**: Nummer des Prozesses, **PPID**: Nummer des Elternprozesses (`ps -ef --forest`, `pstree`)
- **Zustände**: `R` läuft, `S` schläft/wartet, `D` wartet auf Ein-/Ausgabe, `T` gestoppt, `Z` Zombie (beendet, Elternprozess hat den Status noch nicht abgeholt)

```bash
pgrep -af import_test      # PID und vollständige Befehlszeile
ps -o pid,ppid,stat,%cpu,%mem,cmd -p 4711
kill 4711                  # SIGTERM – sauber beenden
ps -p 4711                 # Kontrolle: noch da?
kill -9 4711               # SIGKILL – nur wenn SIGTERM nicht hilft
```

## Prioritäten: nice und renice

Nice-Werte reichen von **-20** (höchste Priorität) bis **19** (niedrigste). Negative Werte darf nur root setzen.

```bash
nice -n 19 ./import.sh &       # mit niedrigster Priorität starten
sudo renice -n 10 -p 4711      # laufenden Prozess herabstufen
```

## Systemlast richtig lesen

| Messwert | Befehl | kritisch, wenn … |
|---|---|---|
| Load Average | `uptime` | dauerhaft über der Anzahl der Kerne (`nproc`) |
| Arbeitsspeicher | `free -h` | „available“ sehr klein |
| Swap | `free -h`, `swapon --show` | stark und dauerhaft genutzt |
| Speicherplatz | `df -h` | über ca. 90 % belegt |

**Speicherfresser finden:**

```bash
sudo du -h --max-depth=1 / | sort -hr | head
du -ah ~/pilot | sort -h | tail
```

Erst den **schreibenden Prozess beenden**, dann die Datei leeren (`truncate -s 0 datei.log`) oder löschen. Eine gelöschte, aber noch geöffnete Datei belegt weiter Platz. Danach `df -h` prüfen.

## Weitere Diagnosebefehle

| Ziel | Befehl |
|---|---|
| CPU-Eigenschaften | `lscpu` |
| Datenträger und Einhängepunkte | `lsblk`, `findmnt`, `df -h` |
| geladene Kernelmodule | `lsmod` |
| Meldungen seit dem letzten Start | `journalctl -b`, `dmesg` |

🛠️ **Übung:** `./uebung.sh start 10` – einen außer Kontrolle geratenen Prozess finden und stoppen

---

✅ **Teste dich:** `./quiz.sh -t 05` &nbsp;·&nbsp; 🛠️ **Übung:** `./uebung.sh start 10`
