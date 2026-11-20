mkdir -p downloads
namen=(linux-server-24.04-amd64.iso linux-server-24.04-arm64.iso linux-desktop-24.04-amd64.iso)
for n in "${namen[@]}"; do head -c 300000 /dev/urandom > "downloads/$n"; done
(cd downloads && sha256sum "${namen[@]}" > SHA256SUMS)
# Eine zufällige Datei nachträglich beschädigen
kaputt=${namen[RANDOM % 3]}
printf 'X' | dd of="downloads/$kaputt" bs=1 seek=$((RANDOM % 1000)) conv=notrunc status=none
echo "$kaputt" > .uebung/erwartet
head -c 50000 /dev/urandom > meine_daten.tar
