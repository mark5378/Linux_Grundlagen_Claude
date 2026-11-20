source "$UEBUNGEN_LIB"
uuid=$(cat .uebung/uuid)
zeilen() { grep -vE '^[[:space:]]*(#|$)' "$1" 2>/dev/null | sed 's/[[:space:]]\{1,\}/ /g; s/^ //; s/ $//'; }
if zeilen crontab.txt | grep -qE '^30 0?2 \* \* \* root /opt/skripte/backup\.sh >> ?/var/log/backup\.log 2>&1$'; then
  ok "Backup-Zeile: täglich 02:30 als root, Ausgabe angehängt"
else
  falsch "Keine korrekte Backup-Zeile (30 2 * * * root /opt/skripte/backup.sh >> /var/log/backup.log 2>&1)"
fi
if zeilen crontab.txt | grep -qE '^(\*/15|0,15,30,45) \* \* \* \* root /opt/skripte/systemcheck\.sh >> ?/var/log/systemcheck\.log 2>&1$'; then
  ok "Systemcheck-Zeile: alle 15 Minuten als root"
else
  falsch "Keine korrekte Systemcheck-Zeile (alle 15 Minuten, Benutzer root, Ausgabe anhängen)"
fi
fz=$(zeilen fstab_zeile.txt | head -n1)
read -r geraet ziel typ optionen dump pass <<<"$fz"
[[ $geraet == "UUID=$uuid" || $geraet == "UUID=\"$uuid\"" ]] && ok "Gerät per UUID angegeben" || falsch "Erstes Feld muss UUID=$uuid sein (nicht /dev/sdb1)"
[[ $ziel == /mnt/backup && $typ == ext4 ]] && ok "Einhängepunkt /mnt/backup und Typ ext4" || falsch "Einhängepunkt oder Dateisystemtyp stimmt nicht"
[[ ,$optionen, == *,nofail,* ]] && ok "Option nofail gesetzt" || falsch "Option nofail fehlt"
[[ $dump == 0 && $pass == 2 ]] && ok "dump 0, Prüfreihenfolge 2" || falsch "Die letzten beiden Felder sollten 0 2 sein"
ergebnis
