# SSH-Server absichern

Im Übungsordner liegt eine Kopie einer SSH-Serverkonfiguration (`sshd_config`) und das Home-Verzeichnis `home_anna` der Administratorin Anna.

**Teil 1 – Konfiguration härten.** Ändere `sshd_config` so, dass gilt:

| Anforderung | Einstellung |
|---|---|
| Keine direkte Anmeldung als root | `PermitRootLogin no` |
| Keine Passwort-Anmeldung, nur Schlüssel | `PasswordAuthentication no`, `KbdInteractiveAuthentication no`, `PubkeyAuthentication yes` |
| Nur `anna` und `ben` dürfen sich anmelden | `AllowUsers anna ben` |
| Höchstens drei Anmeldeversuche pro Verbindung | `MaxAuthTries 3` |
| Keine Weiterleitungen | `X11Forwarding no`, `AllowTcpForwarding no`, `AllowAgentForwarding no` |

⚠️ **Falle:** Bei `sshd_config` gilt für die meisten Optionen der **erste** gefundene Wert! Ein später eingetragenes `PermitRootLogin no` nützt nichts, wenn weiter oben schon `PermitRootLogin yes` aktiv ist.

**Teil 2 – Schlüssel-Rechte reparieren.** Anna bekommt beim Anmelden `Permission denied (publickey)`. Ursache sind zu offene Rechte. Setze:

- `home_anna/.ssh` → `700`
- `home_anna/.ssh/authorized_keys` → `600`

Nützliche Befehle: `nano`, `grep -nEi '^[^#]*(permitroot|password)' sshd_config`, `chmod`, `stat -c %a`

> Auf einem echten Server prüfst du danach mit `sudo sshd -t` die Syntax, startest mit `sudo systemctl restart ssh` neu und testest in einem **zweiten** Terminal, bevor du die laufende Sitzung schließt.
