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
git clone https://github.com/mark5378/Linux_Grundlagen_Claude.git
cd Linux_Grundlagen_Claude
chmod +x quiz.sh uebung.sh   # nur nötig, falls "Keine Berechtigung" erscheint
./quiz.sh            # Quiz mit Themenauswahl
./uebung.sh liste    # praktische Übungen anzeigen
```

**Voraussetzungen:** Linux, ein Raspberry Pi oder **Windows mit WSL** (`wsl --install` in der PowerShell). Bash ab Version 4.

## 📚 Lernpfad

**Teil 1 – Kommandozeile**

| # | Lektion | Quiz | Übungen |
|---|---|---|---|
| 01 | [Einführung & Navigation](lektionen/01-navigation.md) | `./quiz.sh -t 01` | 01 Schatzsuche |
| 02 | [Dateien, Verzeichnisse & Links](lektionen/02-dateien.md) | `./quiz.sh -t 02` | 02 Aufräumen · 07 Links |
| 03 | [Benutzer, Gruppen & Dateirechte](lektionen/03-rechte.md) | `./quiz.sh -t 03` | 03 Rechte setzen · 09 Spezialrechte |
| 04 | [Textverarbeitung, Regex & Pipes](lektionen/04-text-und-pipes.md) | `./quiz.sh -t 04` | 04 Logdatei · 08 Logs & Regex |
| 05 | [Prozesse & Systemressourcen](lektionen/05-prozesse.md) | `./quiz.sh -t 05` | 10 Amok-Prozess |
| 06 | [Pakete, Netzwerk & Archive](lektionen/06-pakete-netz-archive.md) | `./quiz.sh -t 06` | 05 Backup |

**Teil 2 – Systemadministration**

| # | Lektion | Quiz | Übungen |
|---|---|---|---|
| 07 | [IT-Grundlagen, Linux-Aufbau & Open Source](lektionen/07-it-grundlagen-open-source.md) | `./quiz.sh -t 07` | – |
| 08 | [Installation, Virtualisierung & Systemaufbau](lektionen/08-installation-system.md) | `./quiz.sh -t 08` | 06 Prüfsummen |
| 09 | [Netzwerkgrundlagen & Fehlersuche](lektionen/09-netzwerk.md) | `./quiz.sh -t 09` | 11 Subnetting (immer neue Zahlen) |
| 10 | [Sicherheit, Firewall & SSH](lektionen/10-sicherheit-firewall.md) | `./quiz.sh -t 10` | 12 SSH-Härtung |
| 11 | [Bash-Skripte, Automatisierung & Datenträger](lektionen/11-bash-administration.md) | `./quiz.sh -t 11` | 13 Systemcheck · 14 Backup-Skript · 15 Cron & fstab |

Übungen startest du mit `./uebung.sh start NR`. Empfohlener Ablauf pro Thema: **Lektion lesen → Quiz → Übung**.

Insgesamt: **11 Lektionen, über 220 Quizfragen, 15 automatisch geprüfte Übungen.**

> **Zum Weiterüben:** Das kostenlose Wargame [OverTheWire Bandit](https://overthewire.org/wargames/bandit/) trainiert die Kommandozeile spielerisch über SSH.

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
