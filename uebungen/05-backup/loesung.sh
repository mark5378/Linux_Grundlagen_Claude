find daten -name "*.conf" > conf_liste.txt
tar -czf backup.tar.gz daten
mkdir -p wiederhergestellt
tar -xzf backup.tar.gz -C wiederhergestellt
