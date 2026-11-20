# 01 – Einführung & Navigation im Dateisystem

## Was ist die Shell?

Die **Shell** ist ein Programm, das deine Befehle entgegennimmt und ausführt. Die verbreitetste Shell ist **Bash**. Du öffnest sie über ein **Terminal**.

Ein Befehl besteht meist aus drei Teilen:

```
ls    -l       /etc
│     │        └── Argument (worauf?)
│     └── Option (wie?)
└── Befehl (was?)
```

## Das Dateisystem

Linux hat **einen** Verzeichnisbaum, der bei `/` (Wurzel, „root") beginnt. Laufwerksbuchstaben wie `C:` gibt es nicht.

| Verzeichnis | Inhalt |
|---|---|
| `/home` | Persönliche Ordner der Benutzer (z. B. `/home/mark`) |
| `/etc` | Konfigurationsdateien des Systems |
| `/bin`, `/usr/bin` | Programme |
| `/var` | Veränderliche Daten, z. B. Logs unter `/var/log` |
| `/tmp` | Temporäre Dateien |
| `/root` | Home-Verzeichnis des Administrators |

## Wo bin ich? – `pwd`

```bash
pwd          # /home/mark
```

## Was ist hier? – `ls`

```bash
ls           # Inhalt anzeigen
ls -l        # Langform: Rechte, Besitzer, Größe, Datum
ls -a        # auch versteckte Dateien (beginnen mit .)
ls -lah      # alles kombiniert, Größen menschenlesbar
ls /etc      # ein anderes Verzeichnis anzeigen
```

## Verzeichnis wechseln – `cd`

```bash
cd Dokumente     # relativ: in den Unterordner Dokumente
cd /var/log      # absolut: von der Wurzel aus
cd ..            # eine Ebene nach oben
cd               # zurück ins Home-Verzeichnis (wie cd ~)
cd -             # zurück ins vorherige Verzeichnis
```

**Absolute Pfade** beginnen mit `/`. **Relative Pfade** gehen vom aktuellen Verzeichnis aus.
`.` ist das aktuelle Verzeichnis, `..` das übergeordnete, `~` dein Home-Verzeichnis.

## Hilfe finden

```bash
man ls        # Handbuchseite (beenden mit q, suchen mit /wort)
ls --help     # Kurzhilfe der meisten Befehle
```

## Profi-Tipps

- **Tab** vervollständigt Befehle und Pfade. Zweimal Tab zeigt alle Möglichkeiten.
- **Pfeil hoch/runter** blättert durch frühere Befehle.
- **Strg+R** durchsucht die Befehlshistorie.
- **Strg+L** (oder `clear`) leert den Bildschirm.

---

✅ **Teste dich:** `./quiz.sh -t 01` &nbsp;·&nbsp; 🛠️ **Übung:** `./uebung.sh start 01`
