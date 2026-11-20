grep -c ERROR server.log > fehler_anzahl.txt
cut -d' ' -f4 server.log | sort -u > ips.txt
grep WARN server.log > warnungen.txt
