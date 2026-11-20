source "$UEBUNGEN_LIB"
kaputt=$(cat .uebung/erwartet)
if [[ -f defekt.txt ]] && [[ $(sed 's|.*/||; /^[[:space:]]*$/d' defekt.txt | tr -d '[:space:]') == "$kaputt" ]]; then
  ok "defekt.txt nennt die beschädigte Datei"
else
  falsch "defekt.txt fehlt oder nennt nicht (nur) die beschädigte Datei"
fi
pruefe "Die beschädigte Datei wurde gelöscht" test ! -e "downloads/$kaputt"
intakt=0
for f in downloads/*.iso; do [[ -f $f && $(basename "$f") != "$kaputt" ]] && intakt=$((intakt + 1)); done
[[ $intakt -eq 2 ]] && ok "Die beiden intakten Dateien sind noch da" || falsch "Es fehlen intakte Dateien – die hätten bleiben sollen"
pruefe "meine_daten.sha256 lässt sich erfolgreich prüfen" sha256sum -c meine_daten.sha256
ergebnis
