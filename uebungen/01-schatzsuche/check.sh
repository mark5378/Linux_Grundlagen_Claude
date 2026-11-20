source "$UEBUNGEN_LIB"
erwartet=$(cat .uebung/erwartet)
pruefe "gefunden.txt liegt im Übungsordner" test -f gefunden.txt
pruefe "gefunden.txt enthält den richtigen Schatz" grep -qx "$erwartet" gefunden.txt
pruefe "Das Original schatz.txt ist noch an seinem Platz" test -f wald/tanne/sued/unterholz/.moos/schatz.txt
ergebnis
