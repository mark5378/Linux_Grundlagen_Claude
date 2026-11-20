#!/usr/bin/env bash
# Linux-Grundlagen – interaktives Quiz im Terminal
# Aufruf: ./quiz.sh [-t THEMA[,THEMA...]] [-n ANZAHL] [-l] [--pruefen] [-h]

set -u

BASIS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAGEN_DIR="$BASIS/quiz/fragen"

# Farben nur, wenn wir in ein Terminal schreiben
if [[ -t 1 ]]; then
  GRUEN=$'\e[32m'; ROT=$'\e[31m'; GELB=$'\e[33m'; BLAU=$'\e[36m'; FETT=$'\e[1m'; RESET=$'\e[0m'
else
  GRUEN=""; ROT=""; GELB=""; BLAU=""; FETT=""; RESET=""
fi

declare -a F_TEXT=() F_OPTS=() F_LOES=() F_ERKL=() F_THEMA=()
FEHLER_BEIM_LADEN=0

hilfe() {
  cat <<EOF
${FETT}Linux-Grundlagen Quiz${RESET}

Verwendung: ./quiz.sh [Optionen]

  -t THEMA     Nur bestimmte Themen abfragen, z. B. -t 01 oder -t 01,03
  -n ANZAHL    Maximal so viele Fragen stellen (Standard: alle)
  -l           Verfügbare Themen auflisten
  --pruefen    Alle Fragedateien auf Formatfehler prüfen (für CI)
  -h           Diese Hilfe anzeigen

Ohne Optionen erscheint ein Auswahlmenü.
EOF
}

# Leerzeichen am Rand entfernen und mehrfache Leerzeichen zusammenfassen
normalisiere() {
  local -a woerter
  read -ra woerter <<<"$1"
  printf '%s' "${woerter[*]}"
}

speichere_frage() {
  local datei=$1 zeilennr=$2 text=$3 opts=$4 loes=$5 erkl=$6
  [[ -z $text && -z $opts && -z $loes ]] && return 0
  if [[ -z $text || -z $loes ]]; then
    echo "${ROT}Formatfehler${RESET} in $datei (Block endet vor Zeile $zeilennr): F: und L: sind Pflicht." >&2
    FEHLER_BEIM_LADEN=1
    return 0
  fi
  if [[ -n $opts ]]; then
    if [[ ! $loes =~ ^[A-D]$ ]] || ! grep -q "^$loes:" <<<"$opts"; then
      echo "${ROT}Formatfehler${RESET} in $datei (vor Zeile $zeilennr): Lösung '$loes' ist keine vorhandene Option." >&2
      FEHLER_BEIM_LADEN=1
      return 0
    fi
  fi
  F_TEXT+=("$text"); F_OPTS+=("$opts"); F_LOES+=("$loes"); F_ERKL+=("$erkl")
  F_THEMA+=("$(basename "$datei" .txt)")
}

lade_datei() {
  local datei=$1 zeile text="" opts="" loes="" erkl="" nr=0
  while IFS= read -r zeile || [[ -n $zeile ]]; do
    nr=$((nr + 1))
    zeile=${zeile%$'\r'}
    case $zeile in
      "#"*) ;;
      F:*) text=$(normalisiere "${zeile#F:}") ;;
      [A-D]:*) opts+="${zeile:0:1}: $(normalisiere "${zeile:2}")"$'\n' ;;
      L:*) loes+="${loes:+$'\n'}$(normalisiere "${zeile#L:}")" ;;
      E:*) erkl=$(normalisiere "${zeile#E:}") ;;
      "")
        speichere_frage "$datei" "$nr" "$text" "$opts" "$loes" "$erkl"
        text=""; opts=""; loes=""; erkl=""
        ;;
      *)
        echo "${GELB}Warnung${RESET}: $datei Zeile $nr wird ignoriert: $zeile" >&2
        ;;
    esac
  done <"$datei"
  speichere_frage "$datei" "$((nr + 1))" "$text" "$opts" "$loes" "$erkl"
}

themen_titel() {
  # Erste Kommentarzeile der Datei ist der Titel
  local t
  t=$(grep -m1 '^#' "$1" | sed 's/^#[[:space:]]*//')
  printf '%s' "${t:-$(basename "$1" .txt)}"
}

liste_themen() {
  local d
  for d in "$FRAGEN_DIR"/*.txt; do
    printf '  %s  %s\n' "$(basename "$d" .txt | cut -c1-2)" "$(themen_titel "$d")"
  done
}

pruefen() {
  local d anzahl=0
  for d in "$FRAGEN_DIR"/*.txt; do
    local vorher=${#F_TEXT[@]}
    lade_datei "$d"
    echo "$(basename "$d"): $(( ${#F_TEXT[@]} - vorher )) Fragen"
  done
  anzahl=${#F_TEXT[@]}
  if (( FEHLER_BEIM_LADEN )); then
    echo "${ROT}Prüfung fehlgeschlagen.${RESET}"; exit 1
  fi
  echo "${GRUEN}Alles in Ordnung – $anzahl Fragen.${RESET}"
  exit 0
}

menue() {
  echo "${FETT}Welches Thema möchtest du üben?${RESET}"
  liste_themen
  echo "  00  Alle Themen gemischt"
  local wahl
  read -r -p "Auswahl (z. B. 01 oder 01,03): " wahl || exit 0
  [[ -z $wahl || $wahl == 0 || $wahl == 00 ]] && wahl=""
  THEMEN=$wahl
}

frage_stellen() {
  local i=$1 nr=$2 gesamt=$3 antwort korrekt=0
  echo
  echo "${BLAU}Frage $nr/$gesamt${RESET}  ${GELB}[${F_THEMA[$i]}]${RESET}"
  echo "${FETT}${F_TEXT[$i]}${RESET}"

  if [[ -n ${F_OPTS[$i]} ]]; then
    local zeile buchstaben=""
    while IFS= read -r zeile; do
      [[ -z $zeile ]] && continue
      echo "   ${zeile:0:1})${zeile:2}"
      buchstaben+=${zeile:0:1}
    done <<<"${F_OPTS[$i]}"
    while true; do
      read -r -p "Antwort ($buchstaben): " antwort || { echo; return 2; }
      antwort=$(normalisiere "$antwort"); antwort=${antwort^^}
      [[ ${#antwort} -eq 1 && $buchstaben == *"$antwort"* ]] && break
      echo "Bitte einen der Buchstaben $buchstaben eingeben."
    done
    [[ $antwort == "${F_LOES[$i]}" ]] && korrekt=1
  else
    read -r -p "Befehl / Antwort: " antwort || { echo; return 2; }
    antwort=$(normalisiere "$antwort")
    local alt
    local -a alternativen
    mapfile -t alternativen <<<"${F_LOES[$i]}"
    for alt in "${alternativen[@]}"; do
      [[ $antwort == "$(normalisiere "$alt")" ]] && korrekt=1
    done
  fi

  if (( korrekt )); then
    echo "${GRUEN}✔ Richtig!${RESET}"
  else
    local richtig=${F_LOES[$i]}
    [[ -z ${F_OPTS[$i]} ]] && richtig=${richtig%%$'\n'*}
    echo "${ROT}✘ Leider falsch.${RESET} Richtig ist: ${FETT}$richtig${RESET}"
  fi
  [[ -n ${F_ERKL[$i]} ]] && echo "  ${F_ERKL[$i]}"
  (( korrekt )) && return 0 || return 1
}

# ---------- Hauptprogramm ----------
THEMEN=""
ANZAHL=0
while [[ $# -gt 0 ]]; do
  case $1 in
    -t) THEMEN=${2:-}; shift 2 ;;
    -n) ANZAHL=${2:-0}; shift 2 ;;
    -l) liste_themen; exit 0 ;;
    --pruefen) pruefen ;;
    -h|--help) hilfe; exit 0 ;;
    *) echo "Unbekannte Option: $1"; hilfe; exit 1 ;;
  esac
done

if [[ ! $ANZAHL =~ ^[0-9]+$ ]]; then
  echo "-n erwartet eine Zahl."; exit 1
fi

[[ -z $THEMEN && -t 0 ]] && menue

dateien=()
if [[ -z $THEMEN ]]; then
  dateien=("$FRAGEN_DIR"/*.txt)
else
  IFS=',' read -ra liste <<<"$THEMEN"
  for t in "${liste[@]}"; do
    t=$(normalisiere "$t")
    [[ $t =~ ^[0-9]$ ]] && t="0$t"
    treffer=("$FRAGEN_DIR"/"$t"*.txt)
    if [[ -e ${treffer[0]} ]]; then
      dateien+=("${treffer[@]}")
    else
      echo "Thema '$t' nicht gefunden. Verfügbar:"; liste_themen; exit 1
    fi
  done
fi

for d in "${dateien[@]}"; do lade_datei "$d"; done
gesamt=${#F_TEXT[@]}
(( gesamt == 0 )) && { echo "Keine Fragen gefunden."; exit 1; }

mapfile -t reihenfolge < <(seq 0 $((gesamt - 1)) | shuf)
(( ANZAHL > 0 && ANZAHL < gesamt )) && reihenfolge=("${reihenfolge[@]:0:ANZAHL}")
gesamt=${#reihenfolge[@]}

echo "${FETT}Los geht's – $gesamt Fragen.${RESET} (Abbrechen mit Strg+C)"
punkte=0; nr=0; falsch=()
for i in "${reihenfolge[@]}"; do
  nr=$((nr + 1))
  frage_stellen "$i" "$nr" "$gesamt"
  case $? in
    0) punkte=$((punkte + 1)) ;;
    1) falsch+=("$i") ;;
    2) gesamt=$((nr - 1)); break ;;
  esac
done

(( gesamt == 0 )) && exit 0
prozent=$(( punkte * 100 / gesamt ))
echo
echo "${FETT}════════ Ergebnis ════════${RESET}"
echo "$punkte von $gesamt richtig ($prozent %)"
if   (( prozent == 100 )); then echo "${GRUEN}Perfekt! Du bist bereit für das nächste Thema.${RESET}"
elif (( prozent >= 80 ));  then echo "${GRUEN}Sehr gut!${RESET}"
elif (( prozent >= 50 ));  then echo "${GELB}Ganz ordentlich – lies die Lektion noch einmal quer.${RESET}"
else                            echo "${ROT}Da geht noch was – arbeite die Lektion nochmal durch.${RESET}"
fi

if (( ${#falsch[@]} > 0 )); then
  echo
  echo "${FETT}Zum Wiederholen:${RESET}"
  for i in "${falsch[@]}"; do
    echo "  • [${F_THEMA[$i]}] ${F_TEXT[$i]}"
  done
fi
