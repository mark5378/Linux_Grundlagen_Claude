# Hilfsfunktionen für die check.sh-Skripte der Übungen.
# Einbinden mit:  source "$UEBUNGEN_LIB"

FEHLER=0

ok()     { echo "  ✔ $*"; }
falsch() { echo "  ✘ $*"; FEHLER=1; }

# pruefe "Beschreibung" befehl args...  → ✔ wenn der Befehl erfolgreich ist
pruefe() {
  local text=$1; shift
  if "$@" >/dev/null 2>&1; then ok "$text"; else falsch "$text"; fi
}

ergebnis() { exit "$FEHLER"; }
