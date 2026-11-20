# Subnetze berechnen

In der Datei `netz.txt` stehen eine IPv4-Adresse mit Präfix und eine zweite Adresse. Die Werte werden bei jedem Start der Übung neu ausgewürfelt – du kannst also beliebig oft üben (`./uebung.sh reset 11`).

Fülle die Datei `antworten.txt` aus (die Vorlage liegt schon da):

```
subnetzmaske=
netzadresse=
broadcast=
erster_host=
letzter_host=
anzahl_hosts=
gleiches_netz=      # ja oder nein: liegt die zweite Adresse im selben Subnetz?
```

Rechne im Kopf oder auf Papier – das ist die Prüfungsfähigkeit, die geübt werden soll. Zur Kontrolle danach kannst du auch `ipcalc` benutzen, falls installiert.

> Rechenweg: Hostbits = 32 − Präfix. Blockgröße = 2^Hostbits. Die Netzadresse ist das Vielfache der Blockgröße, in dem die Adresse liegt; die Broadcast-Adresse ist Netzadresse + Blockgröße − 1. Nutzbare Hosts = Blockgröße − 2.
