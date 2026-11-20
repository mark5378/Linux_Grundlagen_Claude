mkdir -p logs
cat > import_test.sh <<'SKRIPT'
#!/usr/bin/env bash
# Simulierter fehlerhafter Import: hängt in einer Endlosschleife
while true; do
  echo "$(date '+%F %T') WARN Datensatz konnte nicht importiert werden, neuer Versuch ..." >> logs/import_test.log
  sleep 0.3
done
SKRIPT
chmod +x import_test.sh
yes "2026-11-20 08:00:00 WARN Datensatz konnte nicht importiert werden, neuer Versuch ..." | head -n 60000 > logs/import_test.log
echo "normaler Logeintrag" > logs/system.log
nohup ./import_test.sh >/dev/null 2>&1 &
echo $! > .uebung/pid
