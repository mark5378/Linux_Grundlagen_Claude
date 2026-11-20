cat > backup.sh <<'SKRIPT'
#!/usr/bin/env bash
# Sichert ./daten nach ./backups und löscht alte Sicherungen
# Aufruf: ./backup.sh [TAGE]   (Standard: 14)
set -euo pipefail

QUELLE="daten"
ZIEL="backups"
LOG="backup.log"
TAGE="${1:-14}"

log() { echo "$(date '+%F %T') $*" >> "$LOG"; }

if [[ ! $TAGE =~ ^[1-9][0-9]*$ ]]; then
  echo "Fehler: Aufbewahrungsdauer muss eine positive ganze Zahl sein (war: $TAGE)" >&2
  log "FEHLER ungültige Aufbewahrungsdauer: $TAGE"
  exit 1
fi

exec 9>backup.lock
if ! flock -n 9; then
  echo "Fehler: Es läuft bereits eine Sicherung" >&2
  log "FEHLER Sperre belegt"
  exit 1
fi

[[ -d $QUELLE ]] || { echo "Quelle $QUELLE fehlt" >&2; log "FEHLER Quelle fehlt"; exit 1; }
mkdir -p "$ZIEL"

archiv="$ZIEL/daten_$(date +%F_%H%M%S).tar.gz"
tar -czf "$archiv" "$QUELLE"
tar -tzf "$archiv" > /dev/null
log "OK Sicherung erstellt: $archiv"

find "$ZIEL" -maxdepth 1 -type f -name 'daten_*.tar.gz' -mtime +"$TAGE" -print -delete | while read -r f; do
  log "Alte Sicherung gelöscht: $f"
done
SKRIPT
chmod +x backup.sh
