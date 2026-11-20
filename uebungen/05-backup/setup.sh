mkdir -p daten/web daten/datenbank/alt daten/mail daten/fotos
echo "port=80"       > daten/web/server.conf
echo "port=5432"     > daten/datenbank/db.conf
echo "port=5431"     > daten/datenbank/alt/db-alt.conf
echo "smtp=on"       > daten/mail/mail.conf
for i in 1 2 3 4; do head -c 2048 /dev/urandom > "daten/fotos/bild$i.jpg"; done
echo "Notizen"       > daten/notizen.txt
echo "Nicht gemeint" > daten/web/server.conf.bak
