sed -i -E \
  -e 's/^PermitRootLogin yes/PermitRootLogin no/' \
  -e 's/^PasswordAuthentication yes/PasswordAuthentication no/' \
  -e 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' \
  -e 's/^#MaxAuthTries 6/MaxAuthTries 3/' \
  -e 's/^AllowAgentForwarding yes/AllowAgentForwarding no/' \
  -e 's/^#AllowTcpForwarding yes/AllowTcpForwarding no/' \
  -e 's/^X11Forwarding yes/X11Forwarding no/' sshd_config
echo "AllowUsers anna ben" >> sshd_config
chmod 700 home_anna/.ssh
chmod 600 home_anna/.ssh/authorized_keys
