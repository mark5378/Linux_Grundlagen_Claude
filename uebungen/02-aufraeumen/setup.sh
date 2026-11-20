mkdir -p chaos
for n in readme anleitung notizen changelog; do echo "# $n" > "chaos/$n.md"; done
for n in backup start aufraeumen; do printf '#!/bin/bash\necho %s\n' "$n" > "chaos/$n.sh"; done
for n in a b c d e; do echo "müll" > "chaos/cache_$n.tmp"; done
