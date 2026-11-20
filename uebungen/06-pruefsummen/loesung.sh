cd downloads
sha256sum -c SHA256SUMS 2>/dev/null | grep FAILED | cut -d: -f1 > ../defekt.txt
xargs rm < ../defekt.txt
cd ..
sha256sum meine_daten.tar > meine_daten.sha256
