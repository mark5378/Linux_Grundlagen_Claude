# 10 – Sicherheit, Firewall & SSH

## Anmeldung unter Linux und PAM

- `/etc/passwd`: Name, UID, GID, Kommentar, Home, Shell. Das Passwortfeld enthält nur `x`.
- `/etc/shadow`: Passwort-Hashes und Ablaufdaten. Nur für root lesbar.

**PAM** (Pluggable Authentication Modules) entkoppelt Programme wie `login`, `sshd` und `sudo` von der eigentlichen Anmeldetechnik. Die Konfiguration liegt in `/etc/pam.d/`.

| Modultyp | Aufgabe | Beispielmodule |
|---|---|---|
| `auth` | Identität prüfen (Passwort, Fehlversuche zählen) | `pam_unix`, `pam_faillock` |
| `account` | Darf das Konto sich jetzt anmelden? (abgelaufen, gesperrt) | `pam_unix` |
| `password` | Regeln beim Ändern des Passworts | `pam_pwquality` |
| `session` | Aufgaben bei An- und Abmeldung (Limits, Protokoll) | `pam_limits`, `pam_systemd` |

- **Authentifizierung:** Wer bist du?
- **Autorisierung:** Was darfst du?

### Passwortregeln

```ini
# /etc/security/pwquality.conf
minlen = 12      # mindestens 12 Zeichen
minclass = 3     # aus mindestens 3 Zeichenklassen (groß, klein, Ziffer, Sonderzeichen)
```

```bash
sudo chage -d 0 tbecker   # Passwortänderung bei der nächsten Anmeldung erzwingen (oder: passwd -e)
sudo chage -l tbecker     # Ablaufdaten anzeigen
```

`/etc/login.defs` enthält **Standardwerte für neue** Konten. `chage` ändert die Werte eines **bestehenden** Kontos.

### Sperre nach Fehlversuchen: pam_faillock

```ini
# /etc/security/faillock.conf
deny = 5            # nach 5 Fehlversuchen sperren
unlock_time = 900   # für 900 s = 15 Minuten
```

```bash
sudo faillock --user tbecker           # Fehlversuche anzeigen
sudo faillock --user tbecker --reset   # Konto freigeben
```

> ⚠️ **Vorsicht bei PAM-Änderungen:** Ein Fehler kann **alle** Anmeldungen blockieren. Deshalb: Konfiguration sichern (`/etc/pam.d`, `/etc/security`), zuerst in einer Test-VM ausprobieren und eine Root-Sitzung offen lassen, bis die Anmeldung in einem **zweiten** Fenster klappt. Unter Ubuntu `pam-auth-update` verwenden, statt Dateien von Hand umzubauen.

## Zugriffskontrolle: DAC und MAC

- **DAC** (Discretionary Access Control): die klassischen Rechte `rwx`. Der Besitzer entscheidet.
- **MAC** (Mandatory Access Control): zentrale Richtlinien, die der Kernel erzwingt. Auch root und der Besitzer können sie nicht einfach aushebeln.

| | AppArmor | SELinux |
|---|---|---|
| Prinzip | **pfadbasiert**: Profile erlauben einem Programm bestimmte Pfade | **labelbasiert**: Dateien, Prozesse und Ports tragen Sicherheitskontexte |
| Typisch bei | Ubuntu, Debian, SUSE | RHEL, Fedora |
| Status | `sudo aa-status` | `getenforce`, `sestatus` |

**Beispiel:** Das Datenverzeichnis eines Datenbankdienstes wird nach `/srv/mysql` verschoben. Trotz korrekter `rwx`-Rechte steht im Log `apparmor="DENIED" ... profile="/usr/sbin/mysqld" name="/srv/mysql/ibdata1"`. Das Profil kennt nur den alten Pfad. Die richtige Lösung ist, das Profil zu **erweitern**, nicht AppArmor abzuschalten:

```bash
# /etc/apparmor.d/local/usr.sbin.mysqld   (lokale Ergänzungen überstehen Updates)
/srv/mysql/ r,
/srv/mysql/** rwk,

sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld   # Profil neu laden
```

## Server härten

**Prinzipien:**
- **Least Privilege:** nur so viele Rechte und Dienste wie nötig
- **Defense in Depth:** mehrere unabhängige Schutzschichten

**Dienste prüfen und entfernen:**

```bash
sudo ss -tulpn                       # Was lauscht auf welchem Port?
systemctl status vsftpd              # Status eines Dienstes
sudo systemctl disable --now vsftpd  # stoppen und Autostart abschalten
sudo apt purge vsftpd                # ganz entfernen
```

Jeder unnötige Dienst ist ein mögliches **Einfallstor**.

**Härtungs-Checkliste**

| Prüfpunkt | Befehl | Soll |
|---|---|---|
| Root-Passwort gesperrt | `sudo passwd -S root` | `L` (locked) |
| Nur benötigte Ports offen | `sudo ss -tulpn` | z. B. nur 22 und 80/443 |
| Automatische Sicherheitsupdates | `systemctl status unattended-upgrades` | active |
| MAC aktiv | `sudo aa-status` | Profile im enforce-Modus |
| Firewall aktiv | `sudo ufw status verbose` | active, eingehend: deny |
| Fehlversuche im Blick | `sudo faillock`, `sudo journalctl -u ssh` | keine Auffälligkeiten |
| sudo-Berechtigte | `getent group sudo` | nur Administratoren |

## Anmeldeversuche auswerten

```
sshd[3121]: Invalid user admin from 10.0.5.23 port 40512
sshd[3121]: Failed password for invalid user admin from 10.0.5.23 port 40512 ssh2
sshd[3125]: Failed password for ben from 10.0.5.23 port 40530 ssh2
```

- **Invalid user:** Den Benutzernamen gibt es auf dem Server nicht.
- **Failed password:** falsches Passwort, bei einem echten oder unbekannten Konto.
- Viele Versuche in kurzer Zeit von **einer** IP mit Standardnamen wie `admin` deuten auf einen automatisierten Angriff hin. Ein **einzelner** Fehlversuch ist dagegen meist ein Tippfehler.

```bash
sudo journalctl -u ssh | grep "Failed password"
sudo grep "Failed password" /var/log/auth.log | grep -oE 'from [0-9.]+' | sort | uniq -c | sort -rn
last / lastb                         # erfolgreiche / fehlgeschlagene Anmeldungen
```

### fail2ban – angreifende IPs sperren

```ini
# /etc/fail2ban/jail.local
[sshd]
enabled  = true
maxretry = 3          # 3 Fehlversuche ...
findtime = 10m        # ... innerhalb von 10 Minuten ...
bantime  = 1h         # ... führen zu 1 Stunde Sperre
ignoreip = 127.0.0.1/8 ::1 10.40.20.15   # Admin-PC nie sperren
```

```bash
sudo systemctl restart fail2ban
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip 10.0.5.23
```

| pam_faillock | fail2ban |
|---|---|
| sperrt das **Benutzerkonto**, egal von wo | sperrt die **IP-Adresse** über die Firewall, für alle Konten |

## Firewall mit UFW

| Aktion | Wirkung |
|---|---|
| ACCEPT / `allow` | durchlassen |
| DROP / `deny` | still verwerfen, der Absender läuft in einen **Timeout** |
| REJECT / `reject` | ablehnen und Fehlermeldung zurückschicken, der Absender sieht sofort **refused** |

```bash
# 1. Standardrichtlinien
sudo ufw default deny incoming
sudo ufw default allow outgoing
# 2. Erlaubnisregeln – SSH ZUERST, sonst sperrst du dich aus!
sudo ufw allow from 10.40.20.0/24 to any port 22 proto tcp
sudo ufw allow from 10.40.0.0/16  to any port 80 proto tcp
sudo ufw allow from 10.40.0.0/16  to any port 443 proto tcp
# 3. Erst jetzt aktivieren
sudo ufw enable
sudo ufw status numbered
```

**Reihenfolge zählt:** Die **erste passende** Regel gewinnt. Steht `22/tcp DENY Anywhere` vor `22/tcp ALLOW 10.40.20.0/24`, wird auch das Admin-Netz blockiert. Lösung: `sudo ufw delete 1`. Die pauschale Sperre übernimmt ohnehin die Standardrichtlinie.

## SSH sicher einrichten

**Schlüssel erzeugen und übertragen** (auf dem Admin-Rechner):

```bash
ssh-keygen -t ed25519 -C "anna@admin-pc"     # mit Passphrase!
ssh-copy-id -i ~/.ssh/id_ed25519.pub anna@10.40.10.21
```

- **Privater Schlüssel** (`id_ed25519`): bleibt geheim auf deinem Rechner.
- **Öffentlicher Schlüssel** (`.pub`): kommt auf dem Server in `~/.ssh/authorized_keys`.
- **Passphrase:** verschlüsselt den privaten Schlüssel. Wird er gestohlen, ist er so nicht direkt nutzbar.

**Serverkonfiguration** `/etc/ssh/sshd_config` (oder besser eine eigene Datei in `/etc/ssh/sshd_config.d/`):

```
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AllowUsers anna ben
MaxAuthTries 3
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
```

> ⚠️ Bei `sshd_config` gilt für die meisten Optionen der **erste** gefundene Wert. Das gilt auch für Werte aus Dateien, die per `Include` weiter oben eingebunden werden. Mit `sudo sshd -T | grep -i passwordauth` siehst du, welcher Wert wirklich gilt.

```bash
sudo sshd -t                    # Syntax prüfen
sudo systemctl restart ssh      # neu starten
# Laufende Sitzung NICHT schließen! In einem zweiten Terminal testen:
ssh anna@10.40.10.21                                              # muss klappen
ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password anna@10.40.10.21  # muss scheitern
```

Beide Tests gehören dazu. Der erste zeigt, dass die erlaubte Anmeldung funktioniert. Der zweite zeigt, dass der unsichere Weg wirklich gesperrt ist.

### Typische SSH-Fehler

| Meldung | Ursache | Prüfung |
|---|---|---|
| `Connection refused` | Dienst läuft nicht, falscher Port oder Firewall-REJECT | `systemctl status ssh`, `ss -tlnp`, `ufw status` |
| `Connection timed out` | Pakete kommen nicht an: falsche IP, Routing oder Firewall-DROP | `ping`, `ip route`, Firewall |
| `Permission denied (publickey)` | Schlüssel fehlt in `authorized_keys` oder Rechte zu offen | `ls -la ~/.ssh`: `.ssh` 700, `authorized_keys` 600, `ssh -v` |
| `Host key verification failed` | Server-Schlüssel hat sich geändert: Neuinstallation **oder Angriff** | Schlüssel-Fingerprint prüfen, dann `ssh-keygen -R HOST` |

---

✅ **Teste dich:** `./quiz.sh -t 10` &nbsp;·&nbsp; 🛠️ **Übungen:** `./uebung.sh start 12` (SSH-Härtung), `./uebung.sh start 08` (Log-Analyse)
