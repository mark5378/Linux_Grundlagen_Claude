cat > crontab.txt <<'CRON'
# Minute Stunde Tag Monat Wochentag Benutzer Befehl
30 2 * * * root /opt/skripte/backup.sh >> /var/log/backup.log 2>&1
*/15 * * * * root /opt/skripte/systemcheck.sh >> /var/log/systemcheck.log 2>&1
CRON
uuid=$(grep sdb1 blkid_ausgabe.txt | grep -o ' UUID="[^"]*"' | cut -d'"' -f2)
echo "UUID=$uuid /mnt/backup ext4 defaults,nofail 0 2" > fstab_zeile.txt
