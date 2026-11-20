cat > systemcheck.sh <<'SKRIPT'
#!/usr/bin/env bash
# Systemcheck: bewertet Speicherplatz (belegung.txt) und Dienste (dienste.txt)
# Exit-Codes: 0 = OK, 1 = Warnung, 2 = kritisch
set -uo pipefail

gesamt=0
setze_status() { (( $1 > gesamt )) && gesamt=$1; return 0; }

pruefe_platz() {
  local ort=$1 prozent=$2
  if (( prozent >= 90 )); then echo "KRITISCH: $ort ist zu $prozent % belegt"; setze_status 2
  elif (( prozent >= 80 )); then echo "WARNUNG: $ort ist zu $prozent % belegt"; setze_status 1
  else echo "OK: $ort ist zu $prozent % belegt"; fi
}

pruefe_dienst() {
  local name=$1 status=$2
  if [[ $status == active ]]; then echo "OK: $name läuft"
  else echo "KRITISCH: $name ist $status"; setze_status 2; fi
}

while read -r ort prozent; do [[ -n ${ort:-} ]] && pruefe_platz "$ort" "$prozent"; done < belegung.txt
while read -r name status; do [[ -n ${name:-} ]] && pruefe_dienst "$name" "$status"; done < dienste.txt
exit "$gesamt"
SKRIPT
chmod +x systemcheck.sh
