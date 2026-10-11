#!/bin/bash
# Install the Home/Public firewall profiles. Run:   sudo ./install-firewall.sh
set -eu
[ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
HERE="$(cd "$(dirname "$0")" && pwd)"

install -o root -g root -m 755 "$HERE/fwprofile" /usr/local/sbin/fwprofile

# re-evaluate whenever a connection comes up or goes down
cat > /etc/NetworkManager/dispatcher.d/90-fwprofile <<'EOF'
#!/bin/sh
case "$2" in
    up|down) /usr/local/sbin/fwprofile event ;;
esac
EOF
chmod 755 /etc/NetworkManager/dispatcher.d/90-fwprofile

# close the Home ports at boot, before any network is up
cat > /etc/systemd/system/fwprofile-clear.service <<'EOF'
[Unit]
Description=Close Home-profile firewall ports until the network is known
After=ufw.service
Before=NetworkManager.service

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/fwprofile clear

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable fwprofile-clear.service

# the blanket rules from the KDE Connect instructions, if they were ever added
ufw --force delete allow 1714:1764/udp >/dev/null 2>&1 || true
ufw --force delete allow 1714:1764/tcp >/dev/null 2>&1 || true

/usr/local/sbin/fwprofile event
/usr/local/sbin/fwprofile status
