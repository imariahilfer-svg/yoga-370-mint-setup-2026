#!/bin/bash
# Refresh this package from the machine it is run on, so the folder always
# holds the current scripts and settings. Run as your normal user:   ./collect.sh
# Home-folder paths are stored as @HOME@ and filled in again by install.sh.
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
strip_home() { sed "s#$HOME/#@HOME@/#g"; }

mkdir -p "$HERE"/{files/bin,files/autostart,files/onboard,settings,extras/bin,extras/autostart,extras/systemd}

cp "$HOME"/.local/bin/{yoga-autorotate,power-auto,yoga-tablet,fwprofile-indicator} "$HERE/files/bin/"
for f in yoga-autorotate power-auto yoga-tablet copyq fwprofile-indicator; do
    strip_home < "$HOME/.config/autostart/$f.desktop" > "$HERE/files/autostart/$f.desktop"
done
rm -rf "$HERE/files/onboard/layouts"
cp -r "$HOME/.local/share/onboard/layouts" "$HERE/files/onboard/"

dconf dump /org/cinnamon/desktop/keybindings/ > "$HERE/settings/keybindings.dconf"
dconf dump /org/cinnamon/gestures/ > "$HERE/settings/gestures.dconf"
dconf dump /org/onboard/ | strip_home > "$HERE/settings/onboard.dconf"
# settings/flatpak-apps.txt is a hand-kept list of suggested apps and is not overwritten here

# Extras made outside the Yoga setup; skipped quietly where they do not exist
# keepassxc-backup is left out on purpose: the packaged copy stays generic
for f in card-menu card-watch; do
    [ -e "$HOME/.local/bin/$f" ] && cp "$HOME/.local/bin/$f" "$HERE/extras/bin/"
done
[ -e "$HOME/.config/autostart/card-watch.desktop" ] &&
    strip_home < "$HOME/.config/autostart/card-watch.desktop" > "$HERE/extras/autostart/card-watch.desktop"
cp "$HOME"/.config/systemd/user/keepassxc-backup.* "$HERE/extras/systemd/" 2>/dev/null || true

echo "Package refreshed in $HERE on $(date +%F)"
