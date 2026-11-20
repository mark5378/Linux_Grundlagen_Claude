source "$UEBUNGEN_LIB"
inode() { stat -c %i "$1" 2>/dev/null; }
if [[ -f backup/notizen_hard.txt && ! -L backup/notizen_hard.txt && $(inode backup/notizen_hard.txt) == "$(inode backup/notizen.txt)" ]]; then
  ok "notizen_hard.txt ist ein Hardlink (gleiche Inode)"
else
  falsch "backup/notizen_hard.txt ist kein Hardlink auf backup/notizen.txt"
fi
if [[ -L notizen_link.txt && $(stat -L -c %i notizen_link.txt 2>/dev/null) == "$(inode backup/notizen.txt)" ]]; then
  ok "notizen_link.txt ist ein funktionierender Symlink"
else
  falsch "notizen_link.txt ist kein Symlink auf backup/notizen.txt"
fi
if [[ -z $(find . -path ./.uebung -prune -o -xtype l -print) ]]; then ok "Keine kaputten Links mehr"; else falsch "Es gibt noch kaputte Links"; fi
pruefe "Der funktionierende Link config_link wurde nicht gelöscht" test -L config_link
if [[ -f antwort.txt ]] && grep -qix '[[:space:]]*hardlink[[:space:]]*' antwort.txt; then ok "antwort.txt ist richtig"; else falsch "antwort.txt fehlt oder ist falsch"; fi
ergebnis
