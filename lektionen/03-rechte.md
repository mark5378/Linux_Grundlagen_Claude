# 03 – Benutzer & Dateirechte

## Wer bin ich?

```bash
whoami         # Benutzername
id             # Benutzer-ID, Gruppen
groups         # nur die Gruppen
```

Der Administrator heißt **root** (Benutzer-ID 0) und darf alles. Im Alltag arbeitest du als normaler Benutzer und holst dir Adminrechte nur für einzelne Befehle:

```bash
sudo apt update
```

## Rechte lesen

```
$ ls -l
-rwxr-x---  1 mark entwickler  512 Nov 20 10:00 deploy.sh
│└┬┘└┬┘└┬┘     │    │
│ │  │  │      │    └── Gruppe
│ │  │  │      └── Besitzer
│ │  │  └── Andere (others)
│ │  └── Gruppe (group)
│ └── Besitzer (user)
└── Typ: - Datei, d Verzeichnis, l Link
```

| Recht | bei Dateien | bei Verzeichnissen |
|---|---|---|
| `r` (read) | Inhalt lesen | Inhalt auflisten |
| `w` (write) | Inhalt ändern | Dateien anlegen/löschen |
| `x` (execute) | als Programm ausführen | betreten (`cd`) |

## Rechte ändern – `chmod`

### Symbolisch

```bash
chmod u+x skript.sh      # Besitzer darf ausführen
chmod g-w datei.txt      # Gruppe darf nicht mehr schreiben
chmod o= datei.txt       # Andere: keine Rechte
chmod a+r info.txt       # alle dürfen lesen
```

`u` = user, `g` = group, `o` = others, `a` = all

### Oktal

Jedes Recht hat einen Wert: **r = 4, w = 2, x = 1**. Pro Gruppe werden sie addiert.

| Oktal | Rechte | typisch für |
|---|---|---|
| `755` | `rwxr-xr-x` | Programme, Skripte, Verzeichnisse |
| `750` | `rwxr-x---` | Skripte nur für Besitzer & Gruppe |
| `644` | `rw-r--r--` | normale Dateien |
| `600` | `rw-------` | private Dateien, SSH-Schlüssel |
| `777` | `rwxrwxrwx` | fast nie eine gute Idee! |

```bash
chmod 600 ~/.ssh/id_ed25519
```

## Besitzer ändern – `chown`

```bash
sudo chown mark datei.txt          # Besitzer
sudo chown mark:entwickler datei   # Besitzer und Gruppe
sudo chown -R mark ordner/         # rekursiv
```

## Skripte ausführen

Ein Skript im aktuellen Verzeichnis startest du mit `./`:

```bash
chmod +x hallo.sh
./hallo.sh
```


## Benutzer und Gruppen verwalten

| Datei | Inhalt |
|---|---|
| `/etc/passwd` | Name, UID, GID der Primärgruppe, Home, Shell |
| `/etc/shadow` | Passwort-Hashes, Ablaufdaten (nur root lesbar) |
| `/etc/group` | Gruppen, GID, Mitglieder |

Die **Primärgruppe** bekommen neue Dateien standardmäßig. **Sekundärgruppen** geben zusätzliche Rechte.

```bash
sudo groupadd lager
sudo useradd -m -s /bin/bash -G lager,austausch tbecker   # kein Leerzeichen nach dem Komma!
sudo passwd tbecker
sudo usermod -aG lager lnowak      # Gruppe HINZUFÜGEN (-a!), ohne -a werden alle anderen entfernt
sudo gpasswd -d lnowak dispo       # aus Gruppe entfernen
groups lnowak                      # Kontrolle (wirkt erst nach neuer Anmeldung)
getent passwd tbecker; getent group lager
sudo userdel -r lnowak             # Benutzer samt Home löschen
```

**Persönliche Konten statt Sammelkonten:** Nur so ist nachvollziehbar, wer was getan hat, und Rechte lassen sich pro Person vergeben und entziehen.

**sudo:** `sudo befehl` führt einen Befehl als root aus, `sudo -i` öffnet eine Root-Shell, `su - benutzer` wechselt komplett den Benutzer. Wer `sudo` darf, regelt die Gruppe `sudo` bzw. `/etc/sudoers`. Diese Datei **nur mit `sudo visudo`** bearbeiten, das prüft die Syntax.

## Spezialrechte

| Bit | Oktal | bei Dateien | bei Verzeichnissen | in `ls -l` |
|---|---|---|---|---|
| SetUID | 4000 | läuft mit den Rechten des Besitzers (z. B. `passwd`) | – | `s` bei Besitzer |
| SetGID | 2000 | läuft mit den Rechten der Gruppe | neue Dateien **erben die Gruppe** des Verzeichnisses | `s` bei Gruppe |
| Sticky | 1000 | – | jeder darf nur **eigene** Dateien löschen (z. B. `/tmp`) | `t` am Ende |

Ein **großes** `S` oder `T` bedeutet: Das Spezialbit ist gesetzt, das `x` darunter aber nicht.

**Beispiel einer Abteilungsablage:**

```bash
sudo mkdir -p /srv/daten/{lager,dispo,austausch}
sudo chown root:lager /srv/daten/lager
sudo chmod 2770 /srv/daten/lager        # drwxrws--- : nur Gruppe, Gruppe wird vererbt
sudo chown root:austausch /srv/daten/austausch
sudo chmod 1770 /srv/daten/austausch    # drwxrwx--T : jeder nur eigene Dateien löschen
stat -c '%a %A %U:%G %n' /srv/daten/*
```

Ob du eine Datei **löschen** darfst, hängt nicht von den Rechten der Datei ab, sondern von den Rechten am **Verzeichnis** (`w` + `x`) und dem Sticky Bit.

## umask

Die **umask** legt fest, welche Rechte neuen Dateien **weggenommen** werden. Dateien starten bei `666`, Verzeichnisse bei `777`.

| umask | neue Dateien | neue Verzeichnisse | typisch für |
|---|---|---|---|
| `022` | 644 `rw-r--r--` | 755 `rwxr-xr-x` | Standard |
| `002` | 664 `rw-rw-r--` | 775 `rwxrwxr-x` | Teamordner: Gruppe darf mitschreiben |
| `077` | 600 | 700 | private Daten |

🛠️ **Übung:** `./uebung.sh start 09`

---

✅ **Teste dich:** `./quiz.sh -t 03` &nbsp;·&nbsp; 🛠️ **Übung:** `./uebung.sh start 03`
