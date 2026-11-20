source "$UEBUNGEN_LIB"
rechte() { stat -c %a "$1" 2>/dev/null; }
[[ $(rechte deploy.sh) == 750 ]] && ok "deploy.sh hat 750 (rwxr-x---)" || falsch "deploy.sh hat $(rechte deploy.sh), erwartet 750"
[[ $(rechte geheim.key) == 600 ]] && ok "geheim.key hat 600 (rw-------)" || falsch "geheim.key hat $(rechte geheim.key), erwartet 600"
[[ $(rechte info.txt) == 644 ]] && ok "info.txt hat 644 (rw-r--r--)" || falsch "info.txt hat $(rechte info.txt), erwartet 644"
pruefe "deploy.sh wurde ausgeführt (deploy.log existiert)" grep -q "Deployment erfolgreich" deploy.log
ergebnis
