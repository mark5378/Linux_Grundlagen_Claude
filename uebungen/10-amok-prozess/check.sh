source "$UEBUNGEN_LIB"
pid=$(cat .uebung/pid)
[[ -f pid.txt && $(tr -d '[:space:]' < pid.txt) == "$pid" ]] && ok "pid.txt enthält die richtige PID" || falsch "pid.txt fehlt oder enthält die falsche PID"
laeuft() { local st; st=$(ps -o stat= -p "$1" 2>/dev/null); [[ -n $st && $st != Z* ]]; }
for _ in 1 2 3 4 5 6 7 8 9 10; do laeuft "$pid" || break; sleep 0.3; done
if laeuft "$pid"; then falsch "Der Prozess $pid läuft noch"; else ok "Der Prozess ist beendet"; fi
pruefe "logs/import_test.log existiert noch (geleert, nicht gelöscht)" test -f logs/import_test.log
groesse=$(stat -c %s logs/import_test.log 2>/dev/null || echo 999999999)
(( groesse < 10000 )) && ok "Die Logdatei ist geleert" || falsch "Die Logdatei ist noch $groesse Bytes groß"
pruefe "logs/system.log ist unangetastet" grep -q "normaler Logeintrag" logs/system.log
pruefe "freier_platz.txt enthält eine df-Ausgabe" grep -qE 'Size|Größe|Avail|Verf' freier_platz.txt
ergebnis
