source "$UEBUNGEN_LIB"
# Erster aktiver Wert einer Option (Groß-/Kleinschreibung egal, Match-Blöcke werden ignoriert)
erster_wert() {
  awk -v k="${1,,}" '
    /^[[:space:]]*#/ || NF == 0 { next }
    tolower($1) == "match" { exit }
    tolower($1) == k { $1 = ""; sub(/^[[:space:]]+/, ""); print; exit }
  ' sshd_config
}
soll() { local wert; wert=$(erster_wert "$1")
  [[ ${wert,,} == "${2,,}" ]] && ok "$1 $2" || falsch "$1 ist '${wert:-nicht gesetzt}', erwartet '$2'"; }
soll PermitRootLogin no
soll PasswordAuthentication no
soll KbdInteractiveAuthentication no
soll PubkeyAuthentication yes
soll MaxAuthTries 3
soll X11Forwarding no
soll AllowTcpForwarding no
soll AllowAgentForwarding no
users=$(erster_wert AllowUsers | tr ' ' '\n' | sed '/^$/d' | sort | tr '\n' ' ')
[[ $users == "anna ben " ]] && ok "AllowUsers erlaubt genau anna und ben" || falsch "AllowUsers ist '${users:-nicht gesetzt}', erwartet 'anna ben'"
pruefe "Port 22 ist weiterhin eingetragen (nicht versehentlich gelöscht)" grep -qE '^[[:space:]]*Port[[:space:]]+22' sshd_config
[[ $(stat -c %a home_anna/.ssh) == 700 ]] && ok ".ssh hat 700" || falsch ".ssh hat $(stat -c %a home_anna/.ssh), erwartet 700"
[[ $(stat -c %a home_anna/.ssh/authorized_keys) == 600 ]] && ok "authorized_keys hat 600" || falsch "authorized_keys hat $(stat -c %a home_anna/.ssh/authorized_keys), erwartet 600"
ergebnis
