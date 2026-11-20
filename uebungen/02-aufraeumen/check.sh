source "$UEBUNGEN_LIB"
pruefe "Ordner projekt/docs existiert" test -d projekt/docs
pruefe "Ordner projekt/skripte existiert" test -d projekt/skripte
for n in readme anleitung notizen changelog; do
  pruefe "$n.md liegt in projekt/docs" test -f "projekt/docs/$n.md"
done
for n in backup start aufraeumen; do
  pruefe "$n.sh liegt in projekt/skripte" test -f "projekt/skripte/$n.sh"
done
if [[ -z $(find . -name '*.tmp' -not -path './.uebung/*') ]]; then ok "Keine .tmp-Dateien mehr vorhanden"; else falsch "Es gibt noch .tmp-Dateien"; fi
pruefe "Der Ordner chaos ist gelöscht" test ! -e chaos
ergebnis
