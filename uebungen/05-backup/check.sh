source "$UEBUNGEN_LIB"
if [[ -f conf_liste.txt ]] && diff -q <(find daten -name '*.conf' | sed 's|^\./||' | sort) \
     <(sed 's|^\./||; /^$/d' conf_liste.txt | sort) >/dev/null; then
  ok "conf_liste.txt enthält genau die .conf-Dateien"
else
  falsch "conf_liste.txt fehlt oder ist unvollständig (Tipp: .conf.bak gehört nicht dazu)"
fi
pruefe "backup.tar.gz ist ein gültiges gzip-Archiv" tar -tzf backup.tar.gz
pruefe "Das Archiv enthält daten/mail/mail.conf" bash -c "tar -tzf backup.tar.gz | sed 's|^\./||' | grep -qx 'daten/mail/mail.conf'"
pruefe "Das Archiv enthält die Fotos" bash -c "tar -tzf backup.tar.gz | grep -q 'daten/fotos/bild4.jpg'"
pruefe "wiederhergestellt/daten stimmt mit dem Original überein" diff -r daten wiederhergestellt/daten
ergebnis
