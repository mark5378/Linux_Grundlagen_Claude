mkdir -p backup alt
printf 'pwd   – zeigt das aktuelle Verzeichnis\nls -l – Langform\ncd .. – eine Ebene hoch\n' > backup/notizen.txt
echo "Ich existiere" > alt/config.txt
ln -s alt/config.txt config_link
ln -s alt/geloescht.txt toter_link
ln -s ../gibtsnicht/datei alt/noch_ein_toter_link
