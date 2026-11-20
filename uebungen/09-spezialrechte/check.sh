source "$UEBUNGEN_LIB"
rechte() { stat -c %a "$1" 2>/dev/null; }
erwarte() { [[ $(rechte "$1") == "$2" ]] && ok "$1 hat $2" || falsch "$1 hat ${3:-$(rechte "$1")}, erwartet $2"; }
erwarte ablage 750
erwarte ablage/team 2770
erwarte ablage/austausch 1770
erwarte ablage/team/plan.txt 660
if [[ -f umrechnung.txt ]] && diff -q <(printf '751\n2770\n1777\n4755\n') <(sed 's/[[:space:]]//g; /^$/d' umrechnung.txt) >/dev/null; then
  ok "umrechnung.txt ist komplett richtig"
else
  falsch "umrechnung.txt fehlt oder enthält falsche Werte"
fi
ergebnis
