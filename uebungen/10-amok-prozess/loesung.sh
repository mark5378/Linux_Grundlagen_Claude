pgrep -f import_test.sh > pid.txt
kill "$(cat pid.txt)"
sleep 0.5
truncate -s 0 logs/import_test.log
df -h . > freier_platz.txt
