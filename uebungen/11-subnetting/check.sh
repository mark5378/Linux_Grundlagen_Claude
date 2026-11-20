source "$UEBUNGEN_LIB"
wert() { grep -m1 "^$1=" "$2" 2>/dev/null | cut -d= -f2 | sed 's/#.*//; s/[[:space:]]//g'; }
zu_zahl() { local a b c d; IFS=. read -r a b c d <<<"$1"; echo $(( (a << 24) | (b << 16) | (c << 8) | d )); }
zu_ip() { echo "$(( ($1 >> 24) & 255 )).$(( ($1 >> 16) & 255 )).$(( ($1 >> 8) & 255 )).$(( $1 & 255 ))"; }
adr=$(wert adresse netz.txt); ip=${adr%/*}; p=${adr#*/}
zahl=$(zu_zahl "$ip"); block=$(( 1 << (32 - p) ))
maske=$(( (0xFFFFFFFF << (32 - p)) & 0xFFFFFFFF ))
netz=$(( zahl & maske )); bc=$(( netz + block - 1 ))
zweite=$(zu_zahl "$(wert zweite_adresse netz.txt)")
(( (zweite & maske) == netz )) && gleich=ja || gleich=nein
declare -A soll=(
  [subnetzmaske]=$(zu_ip $maske) [netzadresse]=$(zu_ip $netz) [broadcast]=$(zu_ip $bc)
  [erster_host]=$(zu_ip $((netz + 1))) [letzter_host]=$(zu_ip $((bc - 1)))
  [anzahl_hosts]=$((block - 2)) [gleiches_netz]=$gleich
)
for k in subnetzmaske netzadresse broadcast erster_host letzter_host anzahl_hosts gleiches_netz; do
  ist=$(wert "$k" antworten.txt); ist=${ist,,}
  if [[ $ist == "${soll[$k]}" ]]; then ok "$k = $ist"; else falsch "$k: '${ist:-leer}' ist falsch"; fi
done
(( FEHLER )) && echo "  (Die Lösung wird nicht verraten – nutze ./uebung.sh hinweis 11)"
ergebnis
