#!/usr/bin/env bash
# Linux-Grundlagen – praktische Übungen mit automatischer Prüfung
#
#   ./uebung.sh liste             alle Übungen anzeigen
#   ./uebung.sh start NR          Übung vorbereiten und Aufgabe anzeigen
#   ./uebung.sh aufgabe NR        Aufgabe erneut anzeigen
#   ./uebung.sh hinweis NR        einen Tipp anzeigen
#   ./uebung.sh pruefen NR        deine Lösung prüfen
#   ./uebung.sh reset NR          Übung zurücksetzen
#
# Die Übungen laufen in einem eigenen Ordner (Standard: ~/linux-uebungen).
# Mit UEBUNGS_HOME=/anderer/pfad ./uebung.sh ... änderst du den Ort.

set -u

BASIS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UEBUNGEN_DIR="$BASIS/uebungen"
UEBUNGS_HOME="${UEBUNGS_HOME:-$HOME/linux-uebungen}"
export UEBUNGEN_LIB="$UEBUNGEN_DIR/lib.sh"

if [[ -t 1 ]]; then
  FETT=$'\e[1m'; ROT=$'\e[31m'; GRUEN=$'\e[32m'; RESET=$'\e[0m'
else
  FETT=""; ROT=""; GRUEN=""; RESET=""
fi

hilfe() { sed -n '3,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

finde_uebung() {
  local nr=$1 treffer
  [[ $nr =~ ^[0-9]$ ]] && nr="0$nr"
  treffer=("$UEBUNGEN_DIR"/"$nr"-*/)
  if [[ ! -d ${treffer[0]} ]]; then
    echo "${ROT}Übung '$1' gibt es nicht.${RESET}" >&2
    liste >&2
    exit 1
  fi
  UEBUNG_QUELLE=${treffer[0]%/}
  UEBUNG_NAME=$(basename "$UEBUNG_QUELLE")
  SANDBOX="$UEBUNGS_HOME/$UEBUNG_NAME"
}

titel() { head -n1 "$1/aufgabe.md" | sed 's/^#*[[:space:]]*//'; }

liste() {
  local d name status
  echo "${FETT}Verfügbare Übungen:${RESET}"
  for d in "$UEBUNGEN_DIR"/[0-9][0-9]-*/; do
    d=${d%/}; name=$(basename "$d"); status=""
    [[ -f $UEBUNGS_HOME/$name/.uebung/geschafft ]] && status=" ${GRUEN}✔ geschafft${RESET}"
    [[ -z $status && -d $UEBUNGS_HOME/$name ]] && status=" (begonnen)"
    printf '  %s  %s%s\n' "${name:0:2}" "$(titel "$d")" "$status"
  done
}

einrichten() {
  rm -rf "$SANDBOX"
  mkdir -p "$SANDBOX/.uebung"
  (cd "$SANDBOX" && bash "$UEBUNG_QUELLE/setup.sh") || {
    echo "${ROT}Einrichtung fehlgeschlagen.${RESET}"; exit 1; }
}

aufgabe() {
  echo
  cat "$UEBUNG_QUELLE/aufgabe.md"
  echo
  echo "${FETT}Dein Übungsordner:${RESET} $SANDBOX"
  echo "  cd $SANDBOX"
  echo "Wenn du fertig bist: ./uebung.sh pruefen ${UEBUNG_NAME:0:2}"
}

pruefen() {
  if [[ ! -d $SANDBOX ]]; then
    echo "Übung noch nicht gestartet. Erst: ./uebung.sh start ${UEBUNG_NAME:0:2}"; exit 1
  fi
  echo "${FETT}Prüfe $UEBUNG_NAME …${RESET}"
  if (cd "$SANDBOX" && bash "$UEBUNG_QUELLE/check.sh"); then
    touch "$SANDBOX/.uebung/geschafft"
    echo "${GRUEN}${FETT}🎉 Übung bestanden!${RESET}"
  else
    echo "${ROT}Noch nicht ganz. Tipp gefällig? ./uebung.sh hinweis ${UEBUNG_NAME:0:2}${RESET}"
    exit 1
  fi
}

# Nur für CI: jede Übung einrichten, Musterlösung anwenden, prüfen
selbsttest() {
  local d fehler=0
  UEBUNGS_HOME=$(mktemp -d)
  for d in "$UEBUNGEN_DIR"/[0-9][0-9]-*/; do
    finde_uebung "$(basename "$d" | cut -c1-2)"
    einrichten
    if (cd "$SANDBOX" && bash "$UEBUNG_QUELLE/check.sh" >/dev/null 2>&1); then
      echo "${ROT}$UEBUNG_NAME: Prüfung besteht schon ohne Lösung!${RESET}"; fehler=1
    fi
    (cd "$SANDBOX" && bash "$UEBUNG_QUELLE/loesung.sh" >/dev/null 2>&1)
    if (cd "$SANDBOX" && bash "$UEBUNG_QUELLE/check.sh" >/dev/null 2>&1); then
      echo "${GRUEN}$UEBUNG_NAME: ok${RESET}"
    else
      echo "${ROT}$UEBUNG_NAME: Musterlösung besteht die Prüfung nicht!${RESET}"; fehler=1
    fi
  done
  rm -rf "$UEBUNGS_HOME"
  return $fehler
}

befehl=${1:-}
case $befehl in
  liste|"") liste ;;
  start)    finde_uebung "${2:?Nummer fehlt}"; einrichten; aufgabe ;;
  aufgabe)  finde_uebung "${2:?Nummer fehlt}"; aufgabe ;;
  hinweis)  finde_uebung "${2:?Nummer fehlt}"; echo "💡 $(cat "$UEBUNG_QUELLE/hinweis.txt")" ;;
  pruefen)  finde_uebung "${2:?Nummer fehlt}"; pruefen ;;
  reset)    finde_uebung "${2:?Nummer fehlt}"; einrichten; echo "Übung zurückgesetzt."; aufgabe ;;
  selbsttest) selbsttest ;;
  -h|--help|hilfe) hilfe ;;
  *) echo "Unbekannter Befehl: $befehl"; hilfe; exit 1 ;;
esac
