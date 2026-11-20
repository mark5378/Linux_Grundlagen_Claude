# Baut einen verschachtelten Verzeichnisbaum mit einer versteckten Schatzdatei
for a in eiche buche tanne; do
  for b in nord sued; do
    mkdir -p "wald/$a/$b/unterholz"
    echo "Nur Laub hier." > "wald/$a/$b/laub.txt"
  done
done
ziel="wald/tanne/sued/unterholz/.moos"
mkdir -p "$ziel"
geheim="SCHATZ-$RANDOM-$RANDOM"
echo "$geheim" > "$ziel/schatz.txt"
echo "$geheim" > .uebung/erwartet
