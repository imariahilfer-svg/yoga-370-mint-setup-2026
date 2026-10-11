# ThinkPad Yoga 370 on Linux Mint: tablet-mode setup (community edition)

Scripts and settings that make a Lenovo ThinkPad Yoga 370 behave like a proper convertible under Linux Mint 22.3 (Cinnamon, X11): the screen rotates when you fold it into a tablet, an on-screen keyboard appears when you need it, power modes switch by themselves, and the firewall opens the phone-link ports only on your home network.

The Yoga 370 is a 2017 machine that Windows 11 does not support. This package is one way to keep it useful.

> **Status: works on one machine.** Everything here was built and used on a single Yoga 370. The installer has not yet been run on a fresh installation. Read [What has been tested](#what-has-been-tested) before you rely on it, and please report what you find.

## What you get

| Feature | What it does | Where it lives |
|---|---|---|
| Screen auto-rotation | Follows the accelerometer while the screen is folded back; laptop mode always returns to landscape. Touch and pen follow the rotation | `files/bin/yoga-autorotate` |
| Tablet indicator | Panel menu with rotation lock, palm rejection (touch off while the pen is near), touch gestures, and a larger interface in tablet mode | `files/bin/yoga-tablet` |
| On-screen keyboard | Onboard with a compact Austrian/German QWERTZ layout (ü ö ä keys, emoji page). Runs only in tablet mode and pops up on text entry | `files/onboard/`, `settings/onboard.dconf` |
| Automatic power modes | Panel indicator: Maximum on AC, Silent after two idle minutes on battery, Balanced under load. Manual choice is possible | `files/bin/power-auto` |
| Home / Public firewall profiles | Opens the KDE Connect ports (1714–1764) only on networks you marked as home, and only while the router is the one seen when you marked it. Re-checked on every network change | `firewall/`, `files/bin/fwprofile-indicator` |
| Windows-style shortcuts | Win+L lock, Win+R run, Win+I settings, Win+V clipboard history and more. Full list in [shortcuts.md](shortcuts.md) | `settings/keybindings.dconf` |
| Touch gestures | Cinnamon's three- and four-finger gestures, switched on | `settings/gestures.dconf` |
| Clipboard history | CopyQ, started at login | `files/autostart/copyq.desktop` |
| Extras (optional) | A menu that opens when you insert an SD card or USB stick (health check, fake-capacity test, Raspberry Pi Imager), and an hourly versioned backup of a KeePassXC database | `extras/` |

## Requirements

- Lenovo ThinkPad Yoga 370. Other ThinkPad Yoga models may work but use different sensor and device names; see [Adapting to another model](#adapting-to-another-model).
- Linux Mint 22.3 with the Cinnamon desktop on X11. Wayland is not supported.
- `ufw` as the firewall (Mint's default) for the firewall profiles.

## Install

1. Install Linux Mint 22.3 Cinnamon.
2. Download this repository and open a terminal in its folder.
3. Run the installer as your normal user (it asks for sudo when needed):

   ```bash
   ./install.sh
   ```

   Options:

   | Option | Effect |
   |---|---|
   | `--user-only` | Skip everything that needs sudo (no packages, no CPU cap rule) |
   | `--extras` | Also install the SD-card menu and the KeePassXC backup timer |
   | `--fingerprint` | Also install the fingerprint driver and enrol a finger (see the warning below) |
   | `--flatpaks` | Also install the three suggested apps in `settings/flatpak-apps.txt` |

4. Optional, for the firewall profiles:

   ```bash
   sudo firewall/install-firewall.sh
   ```

   Then connect to your home network and tick "This network is a home network" in the firewall panel indicator.

5. Log out and back in.

### What the installer changes

- Installs packages with `apt` (sensor proxy, Wacom driver, Onboard, Touchégg, CopyQ, Catfish and a few others; the list is at the top of `install.sh`).
- Copies scripts to `~/.local/bin` and autostart entries to `~/.config/autostart`.
- **Overwrites your Cinnamon keyboard shortcuts, gesture settings and Onboard settings** with the ones in `settings/`. Back yours up first if you have customised them:

  ```bash
  dconf dump /org/cinnamon/desktop/keybindings/ > my-shortcuts.backup
  ```

- Writes `/etc/tmpfiles.d/power-auto.conf`, which lets members of the `sudo` group switch off turbo boost and cap the CPU in Silent mode.
- The firewall installer adds a root helper in `/usr/local/sbin`, a NetworkManager dispatcher script and a small systemd unit, and removes blanket `ufw` rules for ports 1714–1764 if you had added them.

### Fingerprint reader

`--fingerprint` adds the third-party PPA `ppa:uunicorn/open-fprintd` and installs `python3-validity`, a community driver for the Validity 138a:0097 reader. It is not maintained by Lenovo, Ubuntu or Linux Mint. On the source machine the reader stops responding after suspend until the driver service is restarted; a fix for that is not part of this package.

## After installing: per-machine steps

- **Pen calibration.** Only if the pen tip is visibly off: run `xinput_calibrator --device "Wacom Pen and multitouch sensor Pen stylus"` and write the four values as one line `MinX MinY MaxX MaxY` into `~/.config/yoga-tablet/pen-area`.
- **KeePassXC backup** (with `--extras`): put your database path into `~/.config/keepassxc-backup.conf`, for example `DB="$HOME/Passwords.kdbx"`. Without it the timer does nothing.
- **Saved Wi-Fi networks from an older Mint installation:** mount the old root partition and run `sudo python3 wifi-import.py /mnt/old-disk`. It merges the saved networks, keeps the newer copy when both systems know a network, and never prints passwords.
- **BIOS choices** such as the Fn lock default and the Fn/Ctrl swap.

## What has been tested

| Item | State |
|---|---|
| Screen rotation, touch and pen mapping after rotation | Confirmed in daily use |
| `collect.sh` followed by `install.sh --user-only --extras` on the source machine | Leaves the machine unchanged |
| Firewall profiles | In use on the source machine with KDE Connect |
| Power modes on battery, palm rejection, rotation lock, automatic pop-up of the on-screen keyboard | Set up, not yet confirmed in real use |
| `install.sh` on a fresh installation, the package step, the CPU cap rule, `--fingerprint`, `--flatpaks` | **Not tested** |
| The generic `keepassxc-backup` and the path argument of `wifi-import.py` | Changed for this edition, syntax-checked only |

## Adapting to another model

The scripts assume these names. Check them on your machine and edit the constants at the top of each script.

| What | Value used here | How to check |
|---|---|---|
| Internal display | `eDP-1` | `xrandr` |
| Tablet-mode switch | `/sys/devices/platform/thinkpad_acpi/hotkey_tablet_mode` | `cat` the file while folding |
| Pen and touch devices | `Wacom Pen and multitouch sensor …` | `xinput list` |
| Fingerprint reader | Validity `138a:0097` | `lsusb` |

## Technical notes

- Cinnamon has no auto-rotation of its own, but it does remap Wacom touch and pen when the screen rotates. Do not rotate the input devices a second time with `xsetwacom`, or they end up rotated twice.
- `yoga-tablet` accepts `YOGA_TABLET_SWITCH=<file>` to simulate folding in tests.
- Rotation lock is the flag file `$XDG_RUNTIME_DIR/yoga-autorotate.hold`, written by `yoga-tablet` and read by `yoga-autorotate`.
- Power modes use power-profiles-daemon. A profile change made by anything else counts as a manual choice. The fan is left to the ThinkPad firmware.
- Firewall profiles: the root helper is `/usr/local/sbin/fwprofile`, called by a NetworkManager dispatcher script and by the panel indicator through `pkexec`. Home networks are stored in `/etc/fwprofile/home.json` as connection UUID plus router MAC address. Run the helper as a normal user with `FWPROFILE_TEST_DIR=<dir>` for a dry run that prints the `ufw` commands. Add further home-only ports in `HOME_PORTS`.
- Paths to the home folder are stored as `@HOME@` in the packaged files and filled in by `install.sh`.

## Keeping your own copy current

`./collect.sh` refreshes the folder from the machine it runs on, so you can keep your own tuned version. **It copies your live settings into the folder. Check the result for anything personal before you publish it.**

## How this was made

The scripts were written over a few days in dialogue with an AI coding assistant, then used on a real machine. They were reviewed, but they are not the work of a professional maintainer. Read a script before you run it with sudo.

## Contributing

Reports from other machines are the most useful contribution: which model, which Mint version, what worked and what did not. Open an issue or a pull request.

## License

GPL-3.0-or-later, see [LICENSE](LICENSE). The on-screen keyboard layout in `files/onboard/` is derived from the layouts of [Onboard](https://launchpad.net/onboard), © Francesco Fumanti and marmuta, which is licensed under the GPL version 3 or later.
