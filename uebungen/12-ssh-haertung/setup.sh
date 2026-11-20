cat > sshd_config <<'CFG'
# SSH-Serverkonfiguration (Übungskopie)
# Zeilen mit # sind Kommentare. Für die meisten Optionen gilt der erste Wert.

Include /etc/ssh/sshd_config.d/*.conf

Port 22
#AddressFamily any
#ListenAddress 0.0.0.0

PermitRootLogin yes
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#PubkeyAuthentication yes
#AuthorizedKeysFile .ssh/authorized_keys

# Für Tests vorübergehend eingeschaltet – später wieder abschalten!
PasswordAuthentication yes
#PermitEmptyPasswords no

KbdInteractiveAuthentication no
UsePAM yes

AllowAgentForwarding yes
#AllowTcpForwarding yes
X11Forwarding yes
PrintMotd no

AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server

# Sicherheitseinstellungen
PermitRootLogin no
CFG
mkdir -p home_anna/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBeispielSchluesselNurZumUeben anna@admin-pc" > home_anna/.ssh/authorized_keys
chmod 777 home_anna/.ssh
chmod 666 home_anna/.ssh/authorized_keys
