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

---

✅ **Teste dich:** `./quiz.sh -t 05`
