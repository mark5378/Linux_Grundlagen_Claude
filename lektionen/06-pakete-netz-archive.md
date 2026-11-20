# 06 – Pakete, Netzwerk, Suchen & Archive

## Software installieren (Debian/Ubuntu)

```bash
sudo apt update            # Paketlisten aktualisieren
sudo apt upgrade           # installierte Pakete aktualisieren
sudo apt install htop      # Paket installieren
sudo apt remove htop       # Paket entfernen
apt search editor          # Pakete suchen
```

Andere Distributionen nutzen andere Paketmanager: `dnf` (Fedora), `pacman` (Arch), `zypper` (openSUSE).

## Netzwerk

```bash
ip a                       # eigene IP-Adressen
ip r                       # Routen / Standard-Gateway
ping -c 4 1.1.1.1          # Erreichbarkeit testen
ss -tulpn                  # welche Ports lauschen?
curl -I https://example.org      # HTTP-Kopfzeilen abrufen
curl -O https://example.org/datei.zip   # Datei herunterladen
ssh pi@192.168.1.10        # auf einem anderen Rechner anmelden
scp datei.txt pi@192.168.1.10:~/   # Datei kopieren per SSH
```

Wichtige Dateien: `/etc/hosts` (feste Namenszuordnungen), `/etc/resolv.conf` (DNS-Server).

## Dateien finden – `find`

```bash
find . -name "*.conf"              # nach Namen (rekursiv)
find /var/log -type f -size +10M   # Dateien größer als 10 MB
find . -mtime -1                   # in den letzten 24 h geändert
find . -name "*.tmp" -delete       # finden und löschen (Vorsicht!)
```

Die Anführungszeichen um `"*.conf"` sind wichtig – sonst löst die Shell das Muster schon vorher auf.

## Archive – `tar`

```bash
tar -czf backup.tar.gz ordner/       # packen + komprimieren
tar -tzf backup.tar.gz               # Inhalt anzeigen
tar -xzf backup.tar.gz               # entpacken
tar -xzf backup.tar.gz -C ziel/      # in bestimmten Ordner entpacken
```

Merkhilfe: **c**reate, e**x**tract, lis**t**, **z** = gzip, **f** = Datei, **v** = verbose.

Für ZIP-Dateien: `zip -r archiv.zip ordner/` und `unzip archiv.zip`.

---

✅ **Teste dich:** `./quiz.sh -t 06` &nbsp;·&nbsp; 🛠️ **Übung:** `./uebung.sh start 05`
