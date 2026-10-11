#!/bin/bash
# Apply the Yoga 370 setup to a fresh Linux Mint 22.3 Cinnamon install.
# Run as your normal user from inside this folder:   ./install.sh [options]
#
#   --user-only     skip everything that needs sudo (no packages, no CPU cap rule)
#   --extras        also install the SD-card menu and the KeePassXC backup timer
#   --fingerprint   also install the fingerprint reader driver (138a:0097) and enrol a finger
#   --flatpaks      also install the suggested Flatpak apps listed in settings/flatpak-apps.txt
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
USER_ONLY=0; EXTRAS=0; FINGERPRINT=0; FLATPAKS=0
for arg in "$@"; do
    case "$arg" in
        --user-only)   USER_ONLY=1 ;;
        --extras)      EXTRAS=1 ;;
        --fingerprint) FINGERPRINT=1 ;;
        --flatpaks)    FLATPAKS=1 ;;
        *) echo "unknown option: $arg" >&2; exit 2 ;;
    esac
done

[ "$(id -u)" -ne 0 ] || { echo "run as your normal user, not with sudo" >&2; exit 1; }
[ "$(cat /sys/class/dmi/id/product_version 2>/dev/null)" = "ThinkPad Yoga 370" ] ||
    echo "warning: this is not a ThinkPad Yoga 370; sensor and device names may differ"

step() { printf '\n== %s\n' "$1"; }

# Copy a file, replacing the @HOME@ placeholder with this user's home folder
place() { mkdir -p "$(dirname "$2")"; sed "s#@HOME@#$HOME#g" "$1" > "$2"; }

if [ "$USER_ONLY" -eq 0 ]; then
    step "Packages"
    sudo apt update
    sudo apt install -y iio-sensor-proxy xinput x11-xserver-utils xserver-xorg-input-wacom \
        power-profiles-daemon python3-gi gir1.2-xapp-1.0 onboard touchegg \
        xinput-calibrator catfish copyq gnome-network-displays

    step "CPU cap rule for Silent mode"
    printf '%s\n' \
        'z /sys/devices/system/cpu/intel_pstate/no_turbo 0664 root sudo' \
        'z /sys/devices/system/cpu/intel_pstate/max_perf_pct 0664 root sudo' |
        sudo tee /etc/tmpfiles.d/power-auto.conf >/dev/null
    sudo systemd-tmpfiles --create /etc/tmpfiles.d/power-auto.conf
fi

step "Scripts, autostart and on-screen keyboard layout"
mkdir -p "$HOME/.local/bin" "$HOME/.config/autostart" "$HOME/.config/yoga-tablet" \
         "$HOME/.local/share/onboard"
install -m 755 "$HERE"/files/bin/* "$HOME/.local/bin/"
for f in "$HERE"/files/autostart/*.desktop; do
    place "$f" "$HOME/.config/autostart/$(basename "$f")"
done
cp -r "$HERE/files/onboard/layouts" "$HOME/.local/share/onboard/"

step "Desktop settings"
dconf load /org/cinnamon/desktop/keybindings/ < "$HERE/settings/keybindings.dconf"
dconf load /org/cinnamon/gestures/ < "$HERE/settings/gestures.dconf"
sed "s#@HOME@#$HOME#g" "$HERE/settings/onboard.dconf" | dconf load /org/onboard/
gsettings set org.cinnamon.desktop.interface toolkit-accessibility true
gsettings set org.gnome.desktop.interface toolkit-accessibility true

if [ "$EXTRAS" -eq 1 ]; then
    step "Extras: SD-card menu and KeePassXC backup"
    [ "$USER_ONLY" -eq 1 ] || sudo apt install -y python3-pyudev f3 smartmontools zenity
    install -m 755 "$HERE"/extras/bin/* "$HOME/.local/bin/"
    place "$HERE/extras/autostart/card-watch.desktop" "$HOME/.config/autostart/card-watch.desktop"
    mkdir -p "$HOME/.config/systemd/user"
    cp "$HERE"/extras/systemd/* "$HOME/.config/systemd/user/"
    systemctl --user daemon-reload
    systemctl --user enable --now keepassxc-backup.timer
    echo "Set your database path in ~/.config/keepassxc-backup.conf (see extras/bin/keepassxc-backup)."
fi

if [ "$FLATPAKS" -eq 1 ]; then
    step "Flatpak apps"
    xargs -a "$HERE/settings/flatpak-apps.txt" flatpak install -y flathub
fi

if [ "$FINGERPRINT" -eq 1 ] && [ "$USER_ONLY" -eq 0 ]; then
    step "Fingerprint reader"
    sudo add-apt-repository -y ppa:uunicorn/open-fprintd
    sudo apt update
    sudo apt install -y open-fprintd fprintd-clients python3-validity
    sudo pam-auth-update --enable fprintd || true
    echo "Enrol a finger now (swipe when asked):"
    fprintd-enroll
fi

step "Done"
echo "Log out and back in to start the panel indicators and the on-screen keyboard."
echo "Still to do by hand: see 'Per-machine steps' in README.md"
