source "$UEBUNGEN_LIB"
# Vergleicht uniq -c-Ausgaben unabhängig von Leerzeichen und Reihenfolge gleich häufiger Zeilen
normal() { sed 's/^[[:space:]]*//; s/[[:space:]]\{1,\}/ /g; /^$/d' "$1" | sort; }
absteigend() { awk '{print $1}' "$1" | sort -nc -r 2>/dev/null; }
vergleiche() { # datei erwartet-befehl beschreibung [sortiert]
  local datei=$1 erwartet=$2 text=$3 sortiert=${4:-}
  if [[ ! -f $datei ]]; then falsch "$text – $datei fehlt"; return; fi
  if diff -q <(normal "$datei") <(eval "$erwartet" | sed 's/^[[:space:]]*//; s/[[:space:]]\{1,\}/ /g' | sort) >/dev/null; then
    if [[ -n $sortiert ]] && ! absteigend "$datei"; then falsch "$text – Werte stimmen, aber nicht absteigend sortiert"; return; fi
    ok "$text"
  else
    falsch "$text – Inhalt stimmt nicht"
  fi
}
vergleiche berichte/stufen.txt "awk '{print \$2}' logs/portal.log | sort | uniq -c" "stufen.txt: Häufigkeit pro Stufe" sortiert
vergleiche berichte/fehler_module.txt "awk '\$2==\"ERROR\" {print \$3}' logs/portal.log | sort | uniq -c" "fehler_module.txt: ERROR pro Modul"
vergleiche berichte/sendungen.txt "grep -oE '\bWK-[0-9]{6}\b' logs/portal.log | sort | uniq -c" "sendungen.txt: gültige Sendungsnummern"
erw=$(grep -c 'Failed password' logs/auth.log)
[[ -f berichte/ssh_fehlversuche.txt && $(tr -d '[:space:]' < berichte/ssh_fehlversuche.txt) == "$erw" ]] \
  && ok "ssh_fehlversuche.txt: Anzahl stimmt" || falsch "ssh_fehlversuche.txt fehlt oder Anzahl stimmt nicht"
vergleiche berichte/ssh_ips.txt "grep 'Failed password' logs/auth.log | grep -oE 'from [0-9.]+' | awk '{print \$2}' | sort | uniq -c" "ssh_ips.txt: Fehlversuche pro IP"
pruefe "gefunden.txt enthält die vorhandene Datei" grep -q 'portal.log' berichte/gefunden.txt
pruefe "fehler.txt enthält die Fehlermeldung" grep -q 'gibtsnicht' berichte/fehler.txt
if grep -q 'gibtsnicht' berichte/gefunden.txt 2>/dev/null; then falsch "gefunden.txt enthält auch die Fehlermeldung – stderr nicht getrennt"; fi
ergebnis
