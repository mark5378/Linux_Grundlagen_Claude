# 🐧 Linux-Grundlagen

Lerne die Linux-Kommandozeile Schritt für Schritt – mit kurzen Lektionen, einem **interaktiven Quiz** im Terminal und **praktischen Übungen**, die automatisch geprüft werden.

Komplett auf Deutsch, ohne Abhängigkeiten – du brauchst nur eine Bash.

```
Frage 3/10  [03-rechte]
Welche Oktalzahl entspricht rw-r--r--?
   A) 755
   B) 644
   C) 600
   D) 777
Antwort (ABCD): B
✔ Richtig!
  r=4, w=2, x=1. rw- = 6, r-- = 4, r-- = 4.
```

## 🚀 Schnellstart

```bash
git clone https://github.com/DEIN-NAME/linux-grundlagen.git
cd linux-grundlagen
./quiz.sh            # Quiz mit Themenauswahl
./uebung.sh liste    # praktische Übungen anzeigen
```

**Voraussetzungen:** Linux, ein Raspberry Pi oder **Windows mit WSL** (`wsl --install` in der PowerShell). Bash ab Version 4.

## 📚 Lernpfad

| # | Lektion | Quiz | Übung |
|---|---|---|---|
| 01 | [Einführung & Navigation](lektionen/01-navigation.md) | `./quiz.sh -t 01` | `./uebung.sh start 01` – Schatzsuche |
| 02 | [Dateien & Verzeichnisse](lektionen/02-dateien.md) | `./quiz.sh -t 02` | `./uebung.sh start 02` – Aufräumen |
| 03 | [Benutzer & Dateirechte](lektionen/03-rechte.md) | `./quiz.sh -t 03` | `./uebung.sh start 03` – Rechte setzen |
| 04 | [Textverarbeitung & Pipes](lektionen/04-text-und-pipes.md) | `./quiz.sh -t 04` | `./uebung.sh start 04` – Logdatei |
| 05 | [Prozesse & System](lektionen/05-prozesse.md) | `./quiz.sh -t 05` | – |
| 06 | [Pakete, Netzwerk & Archive](lektionen/06-pakete-netz-archive.md) | `./quiz.sh -t 06` | `./uebung.sh start 05` – Backup |

Empfohlener Ablauf pro Thema: **Lektion lesen → Quiz → Übung**.

## ❓ Das Quiz

```bash
./quiz.sh                # Menü
./quiz.sh -t 03          # nur Thema 03
./quiz.sh -t 01,02 -n 10 # 10 zufällige Fragen aus Thema 01 und 02
./quiz.sh -l             # Themen auflisten
```

Es gibt zwei Fragetypen:

- **Multiple Choice** – Buchstaben eingeben
- **Befehl eintippen** – z. B. „Wie zeigst du das aktuelle Verzeichnis an?" → `pwd`. Gängige Schreibvarianten (`ls -la` / `ls -al`) werden akzeptiert.

Nach jeder Antwort gibt es eine kurze Erklärung, am Ende eine Auswertung mit den Fragen zum Wiederholen.

## 🛠️ Die Übungen

```bash
./uebung.sh start 01     # Übung vorbereiten, Aufgabe anzeigen
cd ~/linux-uebungen/01-schatzsuche
# … Aufgabe mit echten Befehlen lösen …
./uebung.sh pruefen 01   # automatisch prüfen lassen
./uebung.sh hinweis 01   # Tipp, falls du festhängst
./uebung.sh reset 01     # von vorne anfangen
```

Die Übungen laufen in einem eigenen Ordner (`~/linux-uebungen`), du kannst also nichts kaputt machen. Mit `UEBUNGS_HOME=/anderer/pfad` lässt sich der Ort ändern.

## 🤝 Mitmachen

Neue Fragen und Übungen sind herzlich willkommen – das Format ist bewusst einfach. Alles dazu steht in [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 Lizenz

[MIT](LICENSE)
