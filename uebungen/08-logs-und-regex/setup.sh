mkdir -p logs
stufen=(INFO INFO INFO INFO INFO WARN WARN ERROR ERROR ERROR CRITICAL)
module=(tracking datenbank export login)
nummern=()
for i in 1 2 3 4 5 6; do nummern+=("WK-$((100000 + RANDOM % 900000))"); done
: > logs/portal.log
for i in $(seq 1 120); do
  s=${stufen[RANDOM % ${#stufen[@]}]}
  m=${module[RANDOM % ${#module[@]}]}
  case $((RANDOM % 6)) in
    0) text="Sendung ${nummern[RANDOM % 6]} nicht gefunden" ;;
    1) text="Anfrage ${nummern[RANDOM % 6]} gestartet" ;;
    2) text="Ungueltige Nummer WK-$((10000 + RANDOM % 90000)) abgelehnt" ;;
    3) text="Altformat WK-$((1000000 + RANDOM % 9000000)) ignoriert" ;;
    4) text="Zeitueberschreitung nach $((RANDOM % 30)) s" ;;
    *) text="Verarbeitung abgeschlossen" ;;
  esac
  printf '2026-11-20T%02d:%02d:%02d %s %s %s\n' $((8 + i / 60)) $((i % 60)) $((RANDOM % 60)) "$s" "$m" "$text" >> logs/portal.log
done
ips=(10.0.5.23 10.0.5.23 10.0.5.23 10.0.5.23 192.0.2.50 192.0.2.50 198.51.100.7)
: > logs/auth.log
for i in $(seq 1 40); do
  ip=${ips[RANDOM % ${#ips[@]}]}
  case $((RANDOM % 4)) in
    0) zeile="Accepted publickey for anna from 10.0.9.4 port $((40000 + RANDOM % 9999)) ssh2" ;;
    1) zeile="Failed password for invalid user admin from $ip port $((40000 + RANDOM % 9999)) ssh2" ;;
    2) zeile="Failed password for ben from $ip port $((40000 + RANDOM % 9999)) ssh2" ;;
    *) zeile="Invalid user test from $ip port $((40000 + RANDOM % 9999))" ;;
  esac
  printf 'Nov 20 10:%02d:%02d server01 sshd[%d]: %s\n' $((i % 60)) $((RANDOM % 60)) $((3000 + i)) "$zeile" >> logs/auth.log
done
