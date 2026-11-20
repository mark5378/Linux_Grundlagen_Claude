mkdir -p berichte
awk '{print $2}' logs/portal.log | sort | uniq -c | sort -rn > berichte/stufen.txt
grep ' ERROR ' logs/portal.log | awk '{print $3}' | sort | uniq -c | sort -rn > berichte/fehler_module.txt
grep -oE '\bWK-[0-9]{6}\b' logs/portal.log | sort | uniq -c | sort -rn > berichte/sendungen.txt
grep -c 'Failed password' logs/auth.log > berichte/ssh_fehlversuche.txt
grep 'Failed password' logs/auth.log | grep -oE 'from [0-9.]+' | cut -d' ' -f2 | sort | uniq -c | sort -rn > berichte/ssh_ips.txt
ls logs/portal.log logs/gibtsnicht.log > berichte/gefunden.txt 2> berichte/fehler.txt
