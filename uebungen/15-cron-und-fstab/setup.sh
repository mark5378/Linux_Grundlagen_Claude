uuid=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || printf '%08x-%04x-4%03x-a%03x-%012x' $RANDOM$RANDOM $RANDOM $((RANDOM % 4096)) $((RANDOM % 4096)) $RANDOM$RANDOM$RANDOM)
echo "$uuid" > .uebung/uuid
cat > blkid_ausgabe.txt <<TXT
/dev/sda1: UUID="7A1B-3C4D" TYPE="vfat" PARTLABEL="EFI System Partition"
/dev/sda2: UUID="0d9f2c7e-1b44-4f6a-9c2e-5a8d3f1e2b70" TYPE="ext4"
/dev/sdb1: LABEL="backup" UUID="$uuid" TYPE="ext4" PARTUUID="a1b2c3d4-01"
TXT
