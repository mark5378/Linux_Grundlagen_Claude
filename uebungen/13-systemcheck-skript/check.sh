source "$UEBUNGEN_LIB"
skript="$PWD/systemcheck.sh"
pruefe "systemcheck.sh existiert und ist ausführbar" test -x "$skript"
[[ -f $skript ]] || ergebnis
pruefe "Erste Zeile ist ein Bash-Shebang" bash -c "head -n1 '$skript' | grep -qE '^#!.*bash'"
pruefe "Syntax ist fehlerfrei (bash -n)" bash -n "$skript"
anz=$(grep -cE '^[[:space:]]*(function[[:space:]]+)?[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)' "$skript")
(( anz >= 2 )) && ok "Mindestens zwei Funktionen definiert" || falsch "Nur $anz Funktion(en) gefunden, erwartet mindestens 2"

testfall() { # beschreibung erwarteter_exit belegung dienste [zeilen-regex...]
  local text=$1 soll=$2 bel=$3 die=$4; shift 4
  local tmp; tmp=$(mktemp -d)
  printf '%b' "$bel" > "$tmp/belegung.txt"; printf '%b' "$die" > "$tmp/dienste.txt"
  local ausgabe ist
  ausgabe=$(cd "$tmp" && timeout 10 "$skript" 2>&1); ist=$?
  rm -rf "$tmp"
  local fehlt=""
  for muster in "$@"; do grep -qE "$muster" <<<"$ausgabe" || fehlt+=" [$muster]"; done
  if [[ $ist -eq $soll && -z $fehlt ]]; then ok "$text"
  else
    local grund=""
    [[ $ist -ne $soll ]] && grund="Exit-Code $ist statt $soll"
    [[ -n $fehlt ]] && grund+="${grund:+; }keine passende Ausgabezeile für:$fehlt"
    falsch "$text – $grund"
  fi
}
testfall "Alles in Ordnung → Exit 0" 0 '/ 40\n/mnt/backup 79\n' 'nginx active\nssh active\n' \
  '^OK: /( |$)' '^OK: /mnt/backup' '^OK: nginx' '^OK: ssh'
testfall "Grenzwert 80 % → WARNUNG, Exit 1" 1 '/ 80\n' 'ssh active\n' '^WARNUNG: /( |$)'
testfall "Grenzwert 90 % → KRITISCH, Exit 2" 2 '/ 50\n/mnt/backup 90\n' 'ssh active\n' '^OK: /( |$)' '^KRITISCH: /mnt/backup'
testfall "Ausgefallener Dienst → KRITISCH, alle Prüfungen laufen weiter" 2 '/ 10\n' 'cron inactive\nnginx active\nssh failed\n' \
  '^KRITISCH: cron' '^OK: nginx' '^KRITISCH: ssh'
testfall "Warnung nach kritischem Befund überschreibt Exit 2 nicht" 2 '/mnt/backup 95\n/ 85\n' 'ssh active\n' '^KRITISCH: /mnt/backup' '^WARNUNG: /( |$)'
testfall "Das Beispiel aus der Aufgabe" 2 '/ 84\n/mnt/backup 92\n' 'nginx active\nssh active\ncron inactive\nfail2ban active\n' \
  '^WARNUNG: /( |$)' '^KRITISCH: /mnt/backup' '^KRITISCH: cron' '^OK: fail2ban'
ergebnis
