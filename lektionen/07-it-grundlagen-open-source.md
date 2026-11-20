# 07 – IT-Grundlagen, Linux-Aufbau & Open Source

## Wozu ein Betriebssystem?

Ein Betriebssystem verteilt die Hardware an die Programme und sorgt dafür, dass diese sich nicht gegenseitig stören. Zu seinen Kernaufgaben gehören:

| Aufgabe | Beispiel |
|---|---|
| Prozessverwaltung | Welches Programm bekommt wann Rechenzeit? |
| Speicherverwaltung | Jeder Prozess bekommt eigenen, geschützten Arbeitsspeicher |
| Geräteverwaltung | Treiber für Netzwerkkarte, Festplatte, USB |
| Dateiverwaltung | Dateisysteme, Verzeichnisse, Zugriffsrechte |
| Benutzerverwaltung | Wer darf sich anmelden, wer darf was? |

## Das GNU/Linux-Schichtenmodell

```
┌──────────────────────────────┐
│ Anwendungen                  │  Webserver, Datenbank, Browser
├──────────────────────────────┤
│ GNU-Werkzeuge & Bibliotheken │  Bash, ls, cp, grep, glibc, gcc
├──────────────────────────────┤
│ Linux-Kernel                 │  Prozesse, Speicher, Treiber, Dateisysteme
├──────────────────────────────┤
│ Hardware                     │  CPU, RAM, Festplatte, Netzwerkkarte
└──────────────────────────────┘
```

Der **Kernel** allein hat weder Shell noch Befehle wie `ls` oder einen Compiler. Erst zusammen mit den Werkzeugen des **GNU-Projekts** entsteht ein benutzbares System. Daher kommt der Name **GNU/Linux**.

## Kernel-Space und User-Space

- **Kernel-Space:** Hier läuft der Kernel mit vollem Zugriff auf Hardware und Speicher.
- **User-Space:** Hier laufen normale Programme. Sie dürfen nicht direkt auf Hardware zugreifen.

Will ein Programm etwas „Echtes“ tun, also eine Datei lesen oder über das Netz senden, stellt es einen **Systemaufruf** (System Call) an den Kernel. Das kannst du mit `strace` beobachten:

```bash
strace -e trace=openat,read cat /etc/hostname
# openat(AT_FDCWD, "/etc/hostname", O_RDONLY) = 3   → Kernel öffnet die Datei, liefert Dateideskriptor 3
# read(3, "meinrechner\n", 131072) = 12              → Kernel liest 12 Bytes und gibt sie an cat
```

**Warum diese Trennung?**
- **Stabilität:** Stürzt ein Programm ab, läuft der Kernel weiter.
- **Sicherheit:** Der Kernel prüft bei jedem Zugriff die Rechte.

## Kernel-Architekturen

| | Monolithisch (modular) – z. B. Linux | Mikrokernel |
|---|---|---|
| Was läuft im Kernel-Space? | Fast alles, auch Treiber | Nur das Nötigste |
| Erweiterbar? | Ja, über ladbare **Module** (`lsmod`, `modprobe`) | Dienste laufen als Programme im User-Space |
| Vorteil | schnell | ein abstürzender Treiber reißt den Kern nicht mit |

**POSIX** ist ein Standard für Schnittstellen Unix-artiger Systeme. Programme, die sich daran halten, lassen sich leicht auf andere Systeme übertragen.

## Kurze Geschichte

| Jahr | Ereignis |
|---|---|
| 1969 | Unix entsteht bei AT&T Bell Labs |
| 1973 | Unix wird in C neu geschrieben → portabel |
| 1983 | Richard Stallman kündigt das GNU-Projekt an |
| 1987 | Andrew Tanenbaum veröffentlicht Minix (Lehrsystem) |
| 1991 | Linus Torvalds veröffentlicht die erste Linux-Version |
| 1992 | Linux wird unter die **GNU General Public License (GPL)** gestellt |
| 1993 | Erste große Distributionen: Slackware, Debian |
| ab Ende der 1990er | Große IT-Firmen unterstützen Linux. Heute arbeiten viele Firmen am Kernel mit |

## Die Unix-Philosophie

1. Ein Programm erledigt **eine** Aufgabe, und zwar gut.
2. Programme arbeiten **zusammen**: Die Ausgabe des einen ist die Eingabe des nächsten.
3. **Text** ist die universelle Schnittstelle.

```bash
# Die drei häufigsten IP-Adressen in einem Webserver-Log
cut -d' ' -f1 access.log | sort | uniq -c | sort -rn | head -3
```

## Softwarearten und Lizenzen

| | Proprietär | Freeware | Freie Software / Open Source |
|---|---|---|---|
| Kosten | meist kostenpflichtig | kostenlos | meist kostenlos |
| Quellcode | geschlossen | geschlossen | offen |
| Ändern & Weitergeben | verboten / stark eingeschränkt | meist verboten | ausdrücklich erlaubt |

**Kostenlos ist nicht dasselbe wie frei.** Die **vier Freiheiten** Freier Software:

0. Das Programm für **jeden Zweck** ausführen
1. Den Quellcode **studieren** und anpassen
2. Kopien **weitergeben**
3. Verbesserte Versionen **veröffentlichen**

Eine Lizenz, die Personen, Gruppen oder Einsatzzwecke benachteiligt (z. B. „kostenpflichtig ab 150 Mitarbeitenden“), ist **keine** Open-Source-Lizenz.

### Wichtige Lizenzen

| Lizenz | Copyleft | Das Wichtigste |
|---|---|---|
| **GPL** | stark | Gibst du eine veränderte Version weiter, muss das **ganze** abgeleitete Werk unter GPL stehen, mit Quellcode. Rein interne Nutzung löst keine Pflicht aus. |
| **LGPL** | schwach | Für Bibliotheken. Programme, die sie nur nutzen, dürfen eine andere Lizenz haben. Änderungen **an der Bibliothek** müssen offengelegt werden. |
| **AGPL** | stark + Netzwerk | Wie GPL, die Pflicht gilt aber schon, wenn die Software anderen **über ein Netzwerk** bereitgestellt wird. |
| **MPL 2.0** | schwach, dateibasiert | Nur die geänderten MPL-Dateien müssen offen bleiben. |
| **MIT** | keins | Urheberrechtshinweis und Lizenztext beilegen, sonst fast keine Pflichten. |

> Beispiel: Ein Gerätehersteller verändert den Linux-Kernel (GPLv2) und verkauft die Geräte. Dann muss er den Käufern den Quellcode seiner Kernel-Änderungen zugänglich machen.

*(Das ist eine Lernzusammenfassung, keine Rechtsberatung.)*

## Linux-Distributionen

Eine **Distribution** bündelt Kernel, GNU-Werkzeuge, Init-System, Paketmanager, Installer und eine Softwareauswahl zu einem fertigen System.

- **Init-System** (meist `systemd`): erster Prozess nach dem Kernel (PID 1). Startet und überwacht Dienste.
- **Paketmanager:** installiert, aktualisiert und entfernt Software und löst Abhängigkeiten.
- **Repositories:** Paketquellen des Distributors, mit geprüften und signierten Paketen.

| Familie | Vertreter | Paketformat | Werkzeuge |
|---|---|---|---|
| Debian | Debian, Ubuntu, Linux Mint, Kali | `.deb` | `apt`, `dpkg` |
| Red Hat | RHEL, Fedora, AlmaLinux, Rocky | `.rpm` | `dnf`, `rpm` |
| SUSE | SLES, openSUSE | `.rpm` | `zypper`, `rpm` |
| Arch | Arch Linux, Manjaro | `.pkg.tar.zst` | `pacman` |

### Fixed Release oder Rolling Release?

- **Fixed Release** (Ubuntu LTS, Debian, RHEL): Die Versionen bleiben eingefroren und bekommen nur Sicherheits- und Fehlerkorrekturen. Das macht sie vorhersehbar und stabil, ideal für Server.
- **Rolling Release** (Arch, openSUSE Tumbleweed): Das System wird laufend auf die neuesten Versionen aktualisiert. Es ist immer aktuell, aber Änderungen kommen unangekündigt.

**Supportdauer beachten:** Ubuntu LTS hat standardmäßig 5 Jahre Sicherheitsupdates. Soll ein Server 6 Jahre laufen, verlängerst du den Support mit Ubuntu Pro (ESM) oder planst rechtzeitig ein Upgrade auf die nächste LTS.

### Auswahlkriterien im Unternehmen

- **Herstellerfreigabe:** Ist die Fachsoftware nur für RHEL zertifiziert, wird es RHEL.
- **Supportdauer und kommerzieller Support** für produktive Systeme
- **Know-how im Team**, z. B. ob es `apt` schon kennt
- **Zweck:** Server → LTS. Umsteiger-Arbeitsplatz → z. B. Linux Mint. Genehmigter Penetrationstest → Kali.

**Open Source heißt nicht kostenloser Betrieb:** Personal, Hardware, Wartung und Supportverträge kosten trotzdem Geld.

---

✅ **Teste dich:** `./quiz.sh -t 07`
