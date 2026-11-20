# 04 – Textverarbeitung, Umleitungen & Pipes

Die große Stärke von Linux: Viele kleine Werkzeuge, die jeweils eine Sache gut können – und die man beliebig kombiniert.

## Die drei Datenkanäle

| Nr. | Name | Bedeutung |
|---|---|---|
| 0 | stdin | Eingabe (Tastatur) |
| 1 | stdout | normale Ausgabe |
| 2 | stderr | Fehlermeldungen |

## Umleitungen

```bash
ls > liste.txt          # Ausgabe in Datei (überschreibt!)
date >> protokoll.txt   # Ausgabe anhängen
sort < namen.txt        # Datei als Eingabe
find / -name x 2> /dev/null   # Fehlermeldungen verwerfen
befehl > alles.txt 2>&1 # Ausgabe und Fehler in dieselbe Datei
```

`/dev/null` ist der „Mülleimer" – alles, was dort hineingeht, verschwindet.

## Pipes `|`

Die Pipe gibt die Ausgabe des linken Befehls als Eingabe an den rechten weiter:

```bash
ls | wc -l                          # Wie viele Einträge?
cat /etc/passwd | grep mark         # Zeile mit mark
ps aux | grep firefox               # läuft Firefox?
history | tail -n 10                # letzte 10 Befehle
```

## Die wichtigsten Textwerkzeuge

### `grep` – Zeilen suchen

```bash
grep ERROR log.txt         # Zeilen mit ERROR
grep -i error log.txt      # Groß-/Kleinschreibung egal
grep -v DEBUG log.txt      # Zeilen OHNE DEBUG
grep -c ERROR log.txt      # nur die Anzahl
grep -r "TODO" projekt/    # rekursiv in allen Dateien
grep -n main code.c        # mit Zeilennummern
```

### `wc` – zählen

```bash
wc -l datei     # Zeilen
wc -w datei     # Wörter
wc -c datei     # Bytes
```

### `sort` und `uniq`

```bash
sort namen.txt            # alphabetisch
sort -n zahlen.txt        # numerisch
sort -r namen.txt         # umgekehrt
sort namen.txt | uniq     # Duplikate entfernen
sort -u namen.txt         # dasselbe, kürzer
sort namen.txt | uniq -c  # wie oft kommt jede Zeile vor?
```

> `uniq` entfernt nur **direkt aufeinanderfolgende** Duplikate – deshalb immer erst sortieren.

### `cut` – Spalten ausschneiden

```bash
cut -d: -f1 /etc/passwd       # 1. Feld, Trennzeichen :
cut -d' ' -f4 server.log      # 4. Feld, Trennzeichen Leerzeichen
```

### `tee` – gleichzeitig anzeigen und speichern

```bash
ls -l | tee liste.txt
```

## Alles zusammen

Die 5 häufigsten IP-Adressen in einem Log:

```bash
cut -d' ' -f4 server.log | sort | uniq -c | sort -rn | head -n 5
```

Lies so eine Kette von links nach rechts: Spalte ausschneiden → sortieren → zählen → nach Anzahl sortieren → Top 5.

---

✅ **Teste dich:** `./quiz.sh -t 04` &nbsp;·&nbsp; 🛠️ **Übung:** `./uebung.sh start 04`
