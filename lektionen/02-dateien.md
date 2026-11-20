# 02 – Dateien & Verzeichnisse bearbeiten

## Anlegen

```bash
touch notizen.txt              # leere Datei anlegen
mkdir projekt                  # Verzeichnis anlegen
mkdir -p projekt/src/main      # mit allen fehlenden Elternordnern
```

## Kopieren, Verschieben, Umbenennen

```bash
cp brief.txt brief-kopie.txt   # Datei kopieren
cp -r fotos backup             # Verzeichnis rekursiv kopieren
mv alt.txt neu.txt             # umbenennen
mv bericht.txt Dokumente/      # verschieben
```

> Es gibt keinen eigenen Umbenennen-Befehl – `mv` erledigt beides.

## Löschen

```bash
rm datei.txt          # Datei löschen
rm -i *.txt           # vor jedem Löschen nachfragen
rmdir leer            # nur leere Verzeichnisse
rm -r ordner          # Verzeichnis samt Inhalt
```

⚠️ **Achtung:** Es gibt **keinen Papierkorb**. Was mit `rm` gelöscht ist, ist weg. Prüfe `rm -r` und Platzhalter immer zweimal.

## Inhalte ansehen

```bash
cat datei.txt          # ganze Datei ausgeben
less lang.txt          # seitenweise blättern (q = beenden, / = suchen)
head -n 5 datei.txt    # die ersten 5 Zeilen
tail -n 20 log.txt     # die letzten 20 Zeilen
tail -f log.txt        # Datei live verfolgen (Strg+C beendet)
file bild.jpg          # Dateityp anhand des Inhalts bestimmen
```

## Platzhalter (Wildcards)

Die Shell ersetzt Muster durch passende Dateinamen, **bevor** der Befehl startet.

| Muster | Bedeutung | Beispiel |
|---|---|---|
| `*` | beliebig viele Zeichen | `*.txt` – alle Textdateien |
| `?` | genau ein Zeichen | `bild?.jpg` – bild1.jpg, bildA.jpg |
| `[abc]` | eines der Zeichen | `[ab]*.md` – beginnt mit a oder b |
| `{a,b}` | Aufzählung | `mkdir {src,docs,tests}` |

**Tipp:** Teste ein Muster erst mit `ls`, bevor du `rm` benutzt: `ls *.tmp` → dann `rm *.tmp`.

## Texteditor

Für schnelle Änderungen eignet sich `nano`:

```bash
nano notizen.txt       # Strg+O speichern, Strg+X beenden
```

---

✅ **Teste dich:** `./quiz.sh -t 02` &nbsp;·&nbsp; 🛠️ **Übung:** `./uebung.sh start 02`
