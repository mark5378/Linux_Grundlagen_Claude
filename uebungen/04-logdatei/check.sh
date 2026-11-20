source "$UEBUNGEN_LIB"
erwartet_fehler=$(grep -c ' ERROR ' server.log)
if [[ -f fehler_anzahl.txt && $(tr -d '[:space:]' < fehler_anzahl.txt) == "$erwartet_fehler" ]]; then
  ok "fehler_anzahl.txt enthält die richtige Anzahl"
else
  falsch "fehler_anzahl.txt fehlt oder die Zahl stimmt nicht"
fi
if [[ -f ips.txt ]] && diff -q <(cut -d' ' -f4 server.log | sort -u) <(sed '/^$/d' ips.txt) >/dev/null; then
  ok "ips.txt enthält alle IPs sortiert und ohne Doppelte"
else
  falsch "ips.txt fehlt, ist unsortiert oder enthält Doppelte"
fi
if [[ -f warnungen.txt ]] && diff -q <(grep ' WARN ' server.log) warnungen.txt >/dev/null; then
  ok "warnungen.txt enthält genau die WARN-Zeilen"
else
  falsch "warnungen.txt fehlt oder ist nicht korrekt"
fi
ergebnis
