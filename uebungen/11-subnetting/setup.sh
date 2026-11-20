praefix=$((20 + RANDOM % 10))           # /20 bis /29
ip="10.$((RANDOM % 256)).$((RANDOM % 256)).$((RANDOM % 254 + 1))"
IFS=. read -r a b c d <<<"$ip"
zahl=$(( (a << 24) | (b << 16) | (c << 8) | d ))
block=$(( 1 << (32 - praefix) ))
if (( RANDOM % 2 )); then
  zweite=$(( (zahl / block) * block + RANDOM % block ))      # im selben Netz
else
  zweite=$(( (zahl / block) * block + block + RANDOM % block )) # im nächsten Netz
fi
zweite_ip="$(( (zweite >> 24) & 255 )).$(( (zweite >> 16) & 255 )).$(( (zweite >> 8) & 255 )).$(( zweite & 255 ))"
printf 'adresse=%s/%s\nzweite_adresse=%s\n' "$ip" "$praefix" "$zweite_ip" > netz.txt
printf 'subnetzmaske=\nnetzadresse=\nbroadcast=\nerster_host=\nletzter_host=\nanzahl_hosts=\ngleiches_netz=\n' > antworten.txt
