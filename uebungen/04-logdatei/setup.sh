stufen=(INFO INFO INFO INFO WARN ERROR)
pfade=(/index.html /login /api/daten /bilder/logo.png /kontakt)
methoden=(GET GET GET POST)
: > server.log
for i in $(seq 1 300); do
  s=${stufen[RANDOM % ${#stufen[@]}]}
  ip="192.168.1.$(( RANDOM % 25 + 2 ))"
  printf '2026-11-20 %02d:%02d:%02d %s %s %s %s\n' $((i / 60 % 24)) $((i % 60)) $((RANDOM % 60)) \
    "$s" "$ip" "${methoden[RANDOM % 4]}" "${pfade[RANDOM % 5]}" >> server.log
done
