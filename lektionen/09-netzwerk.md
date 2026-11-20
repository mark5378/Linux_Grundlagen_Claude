# 09 – Netzwerkgrundlagen & Fehlersuche

## OSI- und TCP/IP-Modell

| OSI-Schicht | Name | Beispiele | TCP/IP-Modell |
|---|---|---|---|
| 7 | Anwendung | DNS, HTTP, SSH | Anwendung |
| 6 | Darstellung | TLS-Verschlüsselung, Kodierung | Anwendung |
| 5 | Sitzung | | Anwendung |
| 4 | Transport | **TCP, UDP** | Transport |
| 3 | Vermittlung | **IPv4, IPv6, Router** | Internet |
| 2 | Sicherung | **Ethernet, Switch**, MAC-Adressen | Netzzugang |
| 1 | Bitübertragung | Kabel, Funk | Netzzugang |

Das OSI-Modell ist ein theoretisches Referenzmodell. Das TCP/IP-Modell mit seinen 4 Schichten bildet ab, wie das Internet tatsächlich arbeitet.

### TCP oder UDP?

| TCP | UDP |
|---|---|
| verbindungsorientiert | verbindungslos |
| bestätigt, sortiert, wiederholt verlorene Pakete | keine Garantien, dafür schnell |
| SSH, HTTP(S), E-Mail | DNS-Anfragen, Streaming, VoIP |

**3-Wege-Handshake:** `SYN` → `SYN-ACK` → `ACK`. Danach steht die Verbindung.

## Netzwerkzustand untersuchen

```bash
ip link              # Schnittstellen und Status
ip -br addr          # Adressen kompakt
ip route             # Routingtabelle, Standard-Gateway
ip neigh             # Nachbarn (ARP-Cache): MAC-Adressen im lokalen Netz
resolvectl status    # DNS-Server und Suchdomäne
```

Wichtige Begriffe in der Ausgabe:

- `UP`: Die Schnittstelle ist im System eingeschaltet.
- `LOWER_UP`: Der Link steht („Kabel steckt“).
- **MAC-Adresse**: Hardware-Adresse der Netzwerkkarte (Schicht 2).
- **lo / 127.0.0.1**: Loopback. Damit spricht der Rechner mit sich selbst.
- **fe80::/64**: IPv6-*Link-Local*-Adresse. Sie entsteht automatisch und gilt nur im lokalen Segment. Sie ist **kein** Ersatz für eine richtige Adresse.

Steht die Schnittstelle auf DHCP, im Netz läuft aber kein DHCP-Server, bekommt sie keine IPv4-Adresse. Ohne Adresse gibt es auch keine passende Route, und `ping` meldet `Network is unreachable`.

## IPv4-Subnetting

Eine IPv4-Adresse hat 32 Bit. Das **Präfix** (`/24`, `/26` …) gibt an, wie viele Bits zum Netz gehören.

**Rechenweg am Beispiel 10.40.10.70/26:**

1. Hostbits = 32 − 26 = **6**
2. Blockgröße = 2⁶ = **64**, also Blöcke 0, 64, 128, 192 im letzten Oktett
3. Die 70 liegt im Block **64–127**
4. Netzadresse **10.40.10.64**, Broadcast **10.40.10.127**
5. Nutzbare Hosts: **.65 bis .126**, also 64 − 2 = **62**
6. Maske: 26 Bit = `11111111.11111111.11111111.11000000` = **255.255.255.192**

| Präfix | Maske | Blockgröße | nutzbare Hosts |
|---|---|---|---|
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /28 | 255.255.255.240 | 16 | 14 |
| /29 | 255.255.255.248 | 8 | 6 |
| /30 | 255.255.255.252 | 4 | 2 |
| /22 | 255.255.252.0 | 4 × 256 | 1022 |

**Im selben Netz?** Liegen zwei Adressen im selben Block, sind sie im selben Netz. Bei /26 liegt .60 im Block 0–63 und .70 im Block 64–127, also verschiedene Netze.

🛠️ **Übung (immer neue Zahlen):** `./uebung.sh start 11`

## Adressvergabe und Netzwerkdienste

- **Statisch:** feste Adresse, z. B. für **Server**, damit Dienste immer gleich erreichbar sind.
- **DHCP:** Ein Server vergibt Adressen automatisch und befristet, gut für **Arbeitsplätze**.
- **Standard-Gateway:** Router, über den Pakete in **andere** Netze gehen.
- **DNS:** übersetzt Namen in IP-Adressen.
- **NAT:** übersetzt private Adressen in eine öffentliche, z. B. am Internetanschluss.

## Konfiguration: temporär und dauerhaft

**Temporär mit `ip`** (weg nach dem Neustart, ideal zum Testen):

```bash
sudo ip addr add 10.40.10.21/24 dev eth0
sudo ip route add default via 10.40.10.1 dev eth0
sudo ip addr del 10.40.10.21/24 dev eth0      # wieder entfernen
```

**Dauerhaft mit Netplan** (Ubuntu). Netplan beschreibt die Konfiguration in YAML und übergibt sie an ein Backend: `systemd-networkd` auf Servern, `NetworkManager` auf Desktops.

```yaml
# /etc/netplan/01-netcfg.yaml  – nur Leerzeichen, keine Tabs!
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 10.40.10.21/24
      routes:
        - to: default
          via: 10.40.10.1
      nameservers:
        addresses: [10.40.10.2, 10.40.10.3]
        search: [firma.example]
```

```bash
sudo chmod 600 /etc/netplan/01-netcfg.yaml
sudo netplan generate   # nur prüfen und Backend-Konfiguration erzeugen
sudo netplan try        # vorläufig anwenden – ohne Bestätigung automatisches Zurückrollen
sudo netplan apply      # sofort und dauerhaft anwenden
```

Sicher vorgehen:
1. Alte Datei sichern, z. B. `50-cloud-init.yaml`, damit sich keine Einstellungen widersprechen.
2. Netzwerkänderungen möglichst über die **lokale Konsole** machen (z. B. Hyper-V-Konsole). Eine SSH-Verbindung kann dabei abreißen.
3. `netplan try` statt sofort `apply`.
4. Nach einem **Neustart** mit `ip -br addr`, `ip route` und `resolvectl status` prüfen, ob die Einstellungen geblieben sind.

**Rechnername:** `hostname` zeigt den Kurznamen, `hostname -f` den vollständigen Namen (FQDN). Ein Eintrag in `/etc/hosts` sieht so aus:
```
10.40.10.21  server01.firma.example  server01
```

## Namensauflösung unter Linux

```
Programm → /etc/nsswitch.conf ("hosts: files dns")
             ├─ files → /etc/hosts
             └─ dns   → /etc/resolv.conf → systemd-resolved (127.0.0.53) → DNS-Server
```

- `getent hosts name` fragt genau so wie normale Programme, also inklusive `/etc/hosts`.
- `dig name` / `nslookup name` fragen **direkt** einen DNS-Server.
- Klappt `name.firma.example`, aber nicht `name` allein, fehlt die **Suchdomäne** (`search:` in Netplan).

## Systematische Fehlersuche (bottom-up)

Man prüft von unten nach oben. Fällt eine untere Schicht aus, kann darüber nichts funktionieren.

| # | Prüfen | Befehl |
|---|---|---|
| 1 | Link / Schnittstelle | `ip link` |
| 2 | IP-Adresse und Präfix | `ip -br addr` |
| 3 | Standardroute | `ip route` |
| 4 | Erreichbarkeit Gateway / Ziel | `ping -c 3 GATEWAY`, `ip neigh`, `tracepath ZIEL` |
| 5 | Namensauflösung | `getent hosts NAME`, `resolvectl status` |
| 6 | Dienst / Port | `ss -tlnp` (lokal), `nc -zv HOST PORT`, `curl -I http://HOST` |

| Werkzeug | Wofür |
|---|---|
| `ping` | Erreichbarkeit per ICMP. Wird oft von Firewalls blockiert, ein Fehlschlag heißt also nicht „Host aus“ |
| `tracepath` / `traceroute` | Welchen Weg (welche Router) nehmen die Pakete? |
| `ss` | Welche Ports sind **auf diesem Rechner** offen, welche Verbindungen bestehen? |
| `nc -zv` | Ist ein bestimmter TCP-Port auf einem anderen Rechner erreichbar? |
| `curl` | Antwortet ein Webdienst richtig? |

### Typische Störungen

| Symptom | Wahrscheinliche Ursache | Maßnahme |
|---|---|---|
| Lokales Netz geht, fremde Netze nicht; `ip neigh` zeigt das Gateway als `FAILED` | falsches Gateway eingetragen | `sudo ip route replace default via RICHTIGES_GW`, dann Netplan korrigieren |
| FQDN wird aufgelöst, Kurzname nicht | Suchdomäne fehlt | `search:` in Netplan ergänzen, `netplan apply` |
| `Connection refused` | Host erreichbar, aber kein Dienst auf dem Port | `ss -tlnp` prüfen: Lauscht der Dienst auf dem richtigen Port und der richtigen Adresse? |
| Timeout | keine Antwort: Host aus, Routing falsch oder Firewall verwirft (DROP) | Erreichbarkeit, Route und Firewall prüfen |

Ein Dienst, der auf `127.0.0.1:8080` lauscht, ist **nur lokal** und **nicht auf Port 80** erreichbar. Lösung: In der Dienstkonfiguration (bei nginx `listen 80;`) Port und Adresse anpassen, die Syntax prüfen (`sudo nginx -t`) und den Dienst neu starten.

---

✅ **Teste dich:** `./quiz.sh -t 09` &nbsp;·&nbsp; 🛠️ **Übung:** `./uebung.sh start 11`
