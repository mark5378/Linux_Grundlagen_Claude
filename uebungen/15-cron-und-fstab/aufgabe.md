# Zeitsteuerung und dauerhaftes Einhängen

**Teil 1 – cron.** Schreibe in `crontab.txt` zwei Zeilen im Format einer **systemweiten** Cron-Datei (`/etc/cron.d/…`, also mit Benutzerfeld):

1. `/opt/skripte/backup.sh` täglich um **02:30 Uhr** als `root`, Ausgabe und Fehler an `/var/log/backup.log` **anhängen**.
2. `/opt/skripte/systemcheck.sh` **alle 15 Minuten** als `root`, Ausgabe und Fehler an `/var/log/systemcheck.log` anhängen.

Format: `Minute Stunde Tag Monat Wochentag Benutzer Befehl`

**Teil 2 – fstab.** Ein KI-Assistent hat für den neuen Backup-Datenträger diesen Eintrag vorgeschlagen:
```
/dev/sdb1 /mnt/backup ext4 defaults 0 2
```
Probleme: Gerätenamen wie `/dev/sdb1` können sich beim nächsten Start ändern, und fehlt die Platte, bleibt der Server beim Booten hängen.

Schreibe in `fstab_zeile.txt` einen verbesserten Eintrag. Verwende die UUID aus `blkid_ausgabe.txt` und die Option `nofail`, damit der Server auch ohne die Platte startet.

Nützliches: `*/15`, `>> datei 2>&1`, `grep -o 'UUID="[^"]*"'`, `man 5 crontab`, `man 5 fstab`

> In der Praxis danach: `sudo findmnt --verify`, `sudo mount -a` und `findmnt /mnt/backup` – **vor** dem Neustart!
