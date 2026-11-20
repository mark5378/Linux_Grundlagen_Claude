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

---

✅ **Teste dich:** `./quiz.sh -t 03` &nbsp;·&nbsp; 🛠️ **Übung:** `./uebung.sh start 03`
