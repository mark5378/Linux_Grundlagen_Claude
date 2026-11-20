python3 - <<'PY'
import ipaddress
d = dict(l.strip().split("=", 1) for l in open("netz.txt") if "=" in l)
n = ipaddress.ip_interface(d["adresse"]).network
hosts = list(n.hosts())
gleich = "ja" if ipaddress.ip_address(d["zweite_adresse"]) in n else "nein"
with open("antworten.txt", "w") as f:
    f.write(f"subnetzmaske={n.netmask}\nnetzadresse={n.network_address}\nbroadcast={n.broadcast_address}\n"
            f"erster_host={hosts[0]}\nletzter_host={hosts[-1]}\nanzahl_hosts={len(hosts)}\ngleiches_netz={gleich}\n")
PY
