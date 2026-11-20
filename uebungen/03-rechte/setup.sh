printf '#!/usr/bin/env bash\necho "Deployment erfolgreich" > deploy.log\necho "Deployment erfolgreich"\n' > deploy.sh
echo "-----BEGIN PRIVATE KEY----- (nur ein Beispiel) -----END PRIVATE KEY-----" > geheim.key
echo "Öffentliche Informationen" > info.txt
chmod 666 deploy.sh geheim.key
chmod 600 info.txt
