source "$UEBUNGEN_LIB"
pruefe "backup.sh existiert und ist ausführbar" test -x backup.sh
[[ -x backup.sh ]] || ergebnis
pruefe "Syntax ist fehlerfrei (bash -n)" bash -n backup.sh
archive() { find backups -maxdepth 1 -name 'daten_*.tar.gz' -newer .uebung/marke 2>/dev/null | wc -l; }

# Ausgangslage für den Test herstellen
mkdir -p backups; rm -f backups/daten_*.tar.gz backup.lock
touch -d "20 days ago" backups/daten_2026-01-01_000000.tar.gz
touch -d "10 days ago" backups/daten_2026-01-11_000000.tar.gz
touch -d "30 days ago" backups/wichtig.txt
mkdir -p backups/unterordner; touch -d "30 days ago" backups/unterordner/daten_alt.tar.gz
touch .uebung/marke; sleep 1

timeout 20 ./backup.sh >/dev/null 2>&1; rc=$?
[[ $rc -eq 0 ]] && ok "./backup.sh läuft erfolgreich (Exit 0)" || falsch "./backup.sh endet mit Exit-Code $rc"
neu=$(find backups -maxdepth 1 -name 'daten_*.tar.gz' -newer .uebung/marke | head -n1)
if [[ -n $neu && $(basename "$neu") =~ ^daten_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{6}\.tar\.gz$ ]]; then
  ok "Neues Archiv mit Zeitstempel: $(basename "$neu")"
else
  falsch "Kein neues Archiv mit Namen daten_JJJJ-MM-TT_HHMMSS.tar.gz gefunden"
fi
if [[ -n $neu ]] && tar -tzf "$neu" 2>/dev/null | grep -q 'lager/bestand.csv'; then ok "Archiv ist lesbar und enthält die Daten"; else falsch "Archiv ist nicht lesbar oder unvollständig"; fi
pruefe "20 Tage altes Archiv wurde gelöscht (Standard 14 Tage)" test ! -e backups/daten_2026-01-01_000000.tar.gz
pruefe "10 Tage altes Archiv ist noch da" test -e backups/daten_2026-01-11_000000.tar.gz
pruefe "Andere Dateien in backups bleiben erhalten (wichtig.txt)" test -e backups/wichtig.txt
pruefe "Unterordner werden nicht angefasst" test -e backups/unterordner/daten_alt.tar.gz

timeout 20 ./backup.sh 5 >/dev/null 2>&1
pruefe "Mit ./backup.sh 5 wird das 10 Tage alte Archiv gelöscht" test ! -e backups/daten_2026-01-11_000000.tar.gz

for arg in 0 -3 abc 1.5; do
  touch .uebung/marke; sleep 1
  if timeout 10 ./backup.sh "$arg" >/dev/null 2>&1; then falsch "./backup.sh $arg müsste fehlschlagen"
  elif (( $(archive) > 0 )); then falsch "./backup.sh $arg hat trotz ungültiger Eingabe ein Archiv erstellt"
  else ok "./backup.sh $arg wird abgelehnt"; fi
done

# Sperre belegen und zweiten Lauf versuchen
( exec 9>backup.lock; flock 9; sleep 4 ) & sperre=$!
sleep 1; touch .uebung/marke
if timeout 10 ./backup.sh >/dev/null 2>&1 || (( $(archive) > 0 )); then falsch "Zweiter Lauf trotz belegter Sperre backup.lock gestartet"
else ok "Paralleler Lauf wird durch flock verhindert"; fi
wait "$sperre" 2>/dev/null
pruefe "backup.log enthält Einträge mit Datum" grep -qE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' backup.log
rm -rf backups/unterordner
ergebnis
