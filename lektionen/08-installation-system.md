# 08 – Installation, Virtualisierung & Systemaufbau

## Begriffe der Virtualisierung

| Begriff | Bedeutung |
|---|---|
| **Host** | Der physische Rechner mit der echten Hardware |
| **Hypervisor** | Software, die VMs erzeugt und die Hardware des Hosts verteilt (Hyper-V, KVM, VirtualBox, VMware) |
| **Gast** | Das Betriebssystem in der virtuellen Maschine |
| **ISO-Datei** | Abbild eines Installationsmediums |

Eine **VM für Tests** ist sinnvoll: Fehler bleiben in der VM, und per Prüfpunkt springst du zurück. Außerdem lässt sich die VM als Vorlage klonen.

### Sinnvolle VM-Planung (Beispiel Ubuntu Server unter Hyper-V)

| Einstellung | Empfehlung | Warum |
|---|---|---|
| Generation | **2** (UEFI) | Generation 1 emuliert ein altes BIOS |
| Secure Boot | an, Vorlage **„Microsoft UEFI Certificate Authority“** | Die Vorlage „Microsoft Windows“ blockiert Linux-Bootloader |
| RAM | 4 GB | 2 GB werden schnell knapp |
| vCPUs | 2 | |
| Festplatte | ≥ 40 GB, dynamisch | Platz für Logs, Updates, Tests |
| Netzwerk | internes Netz/NAT für Experimente | Ein externer Switch hängt die VM direkt ins Firmennetz |

## Installationsmedium prüfen

Zwei verschiedene Fragen:

- **Integrität:** Ist die Datei vollständig und unverändert? → **Prüfsumme** (SHA-256)
- **Echtheit:** Stammt die Prüfsummendatei wirklich vom Herausgeber? → **GPG-Signatur**

```bash
# Echtheit der Prüfsummendatei
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys <SCHLÜSSEL-ID>
gpg --verify SHA256SUMS.gpg SHA256SUMS        # erwartet: "Good signature"

# Integrität der ISO
sha256sum -c SHA256SUMS --ignore-missing      # erwartet: "...iso: OK"
```

Eine gültige Signatur nützt nichts, wenn die ISO selbst `FAILED` meldet. Dann gilt: **nicht installieren**, die Datei löschen, neu herunterladen und erneut prüfen.

🛠️ **Übung:** `./uebung.sh start 06`

## Der Startvorgang

```
UEFI/BIOS → Bootloader GRUB → Kernel + initramfs → systemd (PID 1) → Dienste → Login
```

- **GRUB** lädt Kernel und initiale RAM-Disk in den Speicher. Über sein Menü kannst du auch einen älteren Kernel starten.
- Nach der Installation das **ISO auswerfen**, sonst startet wieder der Installer.

## LVM – flexibler Speicher

```
Festplatten/Partitionen → Physical Volumes (PV) → Volume Group (VG) → Logical Volumes (LV) → Dateisystem
```

Wird ein LV zu klein, vergrößerst du es im laufenden Betrieb, z. B. mit `lvextend` und `resize2fs`. Dafür musst du nicht neu partitionieren.

## Prüfpunkte (Snapshots) sind kein Backup

Ein Prüfpunkt sichert den Zustand der VM (Festplatte, Konfiguration, ggf. RAM). Er liegt aber **auf demselben Host**: Fällt dessen Speicher aus, sind VM und Prüfpunkte weg. Lange Prüfpunktketten bremsen außerdem.

## Typische Installationsprobleme

| Problem | Ursache | Lösung |
|---|---|---|
| Nach dem Neustart startet wieder der Installer | ISO noch eingelegt | ISO auswerfen, Festplatte zuerst booten |
| „The signed image's hash is not allowed (DB)“ | falsche Secure-Boot-Vorlage | auf „Microsoft UEFI Certificate Authority“ umstellen |
| Richtiges Passwort wird abgelehnt | falsches Tastaturlayout bei der Installation (z ↔ y) | Layout prüfen, ggf. Passwort im Recovery-Modus neu setzen |
| Schwarzer Bildschirm beim Installer | Grafikproblem / Gen-1-VM | Generation 2 oder Bootparameter `nomodeset` |

## Der Prompt

```
anna@server01:~$
 │     │      │ └── $ = normaler Benutzer, # = root
 │     │      └── aktuelles Verzeichnis (~ = Home)
 │     └── Rechnername
 └── Benutzername
```

Hilfreiche Befehle zur Selbsthilfe:

```bash
type ls          # Alias, eingebaut oder Programm?
apropos kopieren # Befehle zu einem Stichwort suchen
man ls           # Handbuch
ls --help        # Kurzhilfe
```

## Software verwalten mit apt

```bash
sudo apt update              # Paketlisten aktualisieren (installiert nichts!)
apt list --upgradable        # verfügbare Updates anzeigen
sudo apt upgrade             # Updates installieren, entfernt nichts
sudo apt full-upgrade        # darf auch Pakete entfernen/neu installieren
sudo apt install tree htop   # installieren
apt show tree                # Paketinfos
sudo apt remove tree         # entfernen, Konfiguration bleibt
sudo apt purge tree          # entfernen inklusive Konfiguration
sudo apt autoremove          # nicht mehr benötigte Abhängigkeiten entfernen
dpkg -S /usr/bin/ls          # zu welchem Paket gehört die Datei? → coreutils
dpkg -l | grep nginx         # installierte Pakete durchsuchen
```

| Werkzeug | Ebene |
|---|---|
| `dpkg` | Low-Level: installiert einzelne `.deb`, löst **keine** Abhängigkeiten |
| `apt` | High-Level: Repositories, Abhängigkeiten, Updates |
| Snap / Flatpak | distributionsunabhängig, bringt eigene Bibliotheken isoliert mit |

**„Could not get lock /var/lib/dpkg/lock-frontend“** bedeutet: Ein anderer Paketvorgang läuft gerade, oft die automatischen Updates. Dann **warten** und mit `ps aux | grep -E 'apt|dpkg'` nachsehen. Lock-Dateien nie vorschnell löschen, sonst kann die Paketdatenbank beschädigt werden. Nach einem abgebrochenen Vorgang hilft `sudo dpkg --configure -a`.

## Wichtige Verzeichnisse (FHS)

| Verzeichnis | Inhalt |
|---|---|
| `/etc` | systemweite Konfiguration |
| `/home` | Benutzerverzeichnisse |
| `/var/log` | Logdateien |
| `/boot` | Kernel, initramfs, GRUB-Dateien |
| `/dev` | Gerätedateien (Festplatten, Terminals) |
| `/tmp` | temporäre Dateien, wird oft beim Neustart geleert |
| `/usr/bin` | Programme und Befehle für alle Benutzer (`/bin` ist heute meist ein Link darauf) |
| `/srv` | Daten von Diensten, z. B. Dateiablagen |
| `/mnt`, `/media` | Einhängepunkte für zusätzliche Datenträger |

Das erste Zeichen bei `ls -l`: `-` Datei, `d` Verzeichnis, `l` symbolischer Link, `b` Blockgerät, `c` Zeichengerät.

## Dateisysteme und Einhängen

**Mounten** heißt: Ein Datenträger wird an einem Verzeichnis (dem *Einhängepunkt*) in den Verzeichnisbaum eingebunden.

```bash
findmnt /        # Welches Dateisystem liegt auf /?
df -hT           # Belegung und Typ aller Dateisysteme
cat /etc/fstab   # Was wird beim Start automatisch eingehängt?
```

| Dateisystem | Stärke | Typischer Einsatz |
|---|---|---|
| ext4 | bewährt, robust | Standard für Server und Desktop |
| XFS | sehr große Dateien und Datenmengen | Storage, Datenbanken (Standard bei RHEL) |
| Btrfs | Copy-on-Write, Snapshots, Prüfsummen | Systeme mit Snapshot-Bedarf (openSUSE) |

- **Journaling:** Änderungen werden vorab protokolliert. Nach einem Absturz ist das Dateisystem dadurch schnell wieder konsistent.
- **Inode:** speichert die Metadaten einer Datei (Rechte, Besitzer, Größe, Speicherorte), aber **nicht** ihren Namen. Den Namen speichert der Verzeichniseintrag.

---

✅ **Teste dich:** `./quiz.sh -t 08` &nbsp;·&nbsp; 🛠️ **Übung:** `./uebung.sh start 06`
