# Mitmachen

Danke, dass du das Projekt verbessern möchtest! 🎉

## Neue Quizfragen

Fragen liegen in `quiz/fragen/NN-thema.txt`. Die **erste Kommentarzeile** ist der Thementitel. Fragen werden durch eine **Leerzeile** getrennt.

| Präfix | Bedeutung | Pflicht |
|---|---|---|
| `F:` | Fragetext | ja |
| `A:` bis `D:` | Antwortoptionen (Multiple Choice) | nein |
| `L:` | Lösung – bei Multiple Choice der Buchstabe, sonst der Befehl. Mehrere `L:`-Zeilen = mehrere richtige Schreibweisen | ja |
| `E:` | Erklärung, die nach der Antwort angezeigt wird | empfohlen |
| `#` | Kommentar | – |

**Multiple Choice:**

```
F: Welche Oktalzahl entspricht rw-r--r--?
A: 755
B: 644
C: 600
D: 777
L: B
E: r=4, w=2, x=1. rw- = 6, r-- = 4, r-- = 4.
```

**Befehl eintippen** (keine Optionen):

```
F: Wie listest du alle Dateien inklusive versteckter in Langform auf?
L: ls -la
L: ls -al
E: -l zeigt Details, -a auch versteckte Dateien.
```

Mehrfache Leerzeichen in der Eingabe werden ignoriert, ansonsten wird exakt verglichen. Gib also alle gängigen Varianten als eigene `L:`-Zeile an.

Vor dem Commit prüfen:

```bash
./quiz.sh --pruefen
```

## Neue Übungen

Eine Übung ist ein Ordner `uebungen/NN-name/` mit fünf Dateien:

| Datei | Zweck |
|---|---|
| `aufgabe.md` | Aufgabentext (erste Zeile = Titel) |
| `setup.sh` | Baut die Ausgangssituation im (leeren) Übungsordner auf. Hilfsdaten gehören nach `.uebung/` |
| `check.sh` | Prüft die Lösung. Beginnt mit `source "$UEBUNGEN_LIB"` und endet mit `ergebnis` |
| `hinweis.txt` | Ein Tipp für Festhängende |
| `loesung.sh` | Musterlösung – wird nur vom automatischen Test verwendet |

In `check.sh` stehen die Helfer aus `uebungen/lib.sh` bereit:

```bash
source "$UEBUNGEN_LIB"
pruefe "Ordner projekt existiert" test -d projekt
[[ $(stat -c %a datei) == 600 ]] && ok "Rechte stimmen" || falsch "Rechte falsch"
ergebnis
```

Testen:

```bash
./uebung.sh selbsttest
```

Der Selbsttest stellt sicher, dass die Prüfung **ohne** Lösung fehlschlägt und **mit** Musterlösung besteht. Er läuft auch automatisch bei jedem Push (GitHub Actions).
