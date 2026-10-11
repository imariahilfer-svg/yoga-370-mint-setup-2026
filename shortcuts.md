# ThinkPad Yoga 370 – keyboard shortcuts (Linux Mint 22.3, Cinnamon)

No two shortcuts share the same keys, and every program a shortcut starts is either part of Linux Mint or installed by `install.sh`.
"Win" is the Windows key (Linux calls it Super). Entries marked **new** were added during setup; the rest are Mint defaults.

## System

| Shortcut | Action | |
|---|---|---|
| Win | Open the menu; type to search apps and files | |
| Win+L | Lock screen | **new** |
| Ctrl+Alt+L | Lock screen | |
| Win+I | System settings | **new** |
| Win+R | Run dialog | **new** |
| Alt+F2 | Run dialog | |
| Ctrl+Shift+Esc | System monitor (task manager) | **new** |
| Ctrl+Alt+T | Terminal | |
| Ctrl+Alt+Delete | Log out dialog | |
| Ctrl+Alt+End | Shut down dialog | |
| Ctrl+Alt+Esc | Restart Cinnamon (if the desktop hangs) | |

## Apps and tools

| Shortcut | Action | |
|---|---|---|
| Win+E | File manager | |
| Win+F or Win+S | Find files (Catfish) | **new** |
| Win+V | Clipboard history (CopyQ) | **new** |
| Win+K | Cast to a wireless display | **new** |
| Win+P | Switch display / projector mode | |
| Win+Space | Next keyboard layout (Shift+Win+Space: previous) | |
| Win+1 … Win+9 | Open the 1st … 9th app in the taskbar | |

## Windows

| Shortcut | Action | |
|---|---|---|
| Alt+Tab | Switch windows (Shift+Alt+Tab: backwards) | |
| Alt+F4 | Close window | |
| Win+D or Win+M | Show desktop / minimise everything | Win+M **new** |
| Win+Left / Right / Up / Down | Snap window to that side | |
| Win+Shift+arrow | Move window to another monitor | |
| Alt+F10 | Maximise / restore | |
| Alt+F5 | Un-maximise | |
| Alt+F7 | Move window with the keyboard | |
| Alt+F8 | Resize window with the keyboard | |
| Alt+Space | Window menu | |

## Workspaces and overviews

| Shortcut | Action | |
|---|---|---|
| Win+Tab | Overview of all windows | **new** |
| Ctrl+Alt+Down | Overview of all windows | |
| Ctrl+Alt+Up | Overview of all workspaces | |
| Ctrl+Win+Left / Right | Previous / next workspace | **new** |
| Ctrl+Alt+Left / Right | Previous / next workspace | |
| Ctrl+Shift+Alt+arrow | Move window to another workspace | |

## Screenshots

| Shortcut | Action | |
|---|---|---|
| PrtSc | Whole screen to a file | |
| Alt+PrtSc | Current window to a file | |
| Shift+PrtSc | Selected area to a file | |
| Win+Shift+S | Selected area to the clipboard | **new** |
| Ctrl+PrtSc | Whole screen to the clipboard | |
| Ctrl+Alt+PrtSc | Current window to the clipboard | |
| Ctrl+Shift+PrtSc | Selected area to the clipboard | |
| Ctrl+Shift+Alt+R | Start / stop screen recording | |

## Function keys

| Key | Action |
|---|---|
| F1 | Help |
| F2 | Rename |
| F5 | Refresh |
| F10 | Menu bar |
| F11 | Fullscreen |
| Fn+Esc | Fn lock: swap F1–F12 and the special functions |
| Fn+Space | Keyboard backlight |
| Volume, mute, microphone mute, brightness keys | As printed on the keys |
| Ctrl+Alt+F1 … F6 | Text console (Ctrl+Alt+F7 returns to the desktop) |

## Moved or rarely needed

| Shortcut | Action | |
|---|---|---|
| Ctrl+Win+L | Cinnamon developer console (was Win+L) | moved |
| Ctrl+Win+S | Show desklets (was Win+S) | moved |
| Alt+Win+= / − / 0 | Magnifier zoom in / out / reset | |
| Alt+Win+S | Screen reader on / off | |
| Win+O | Cinnamon's own rotation lock: does nothing here, use the tablet indicator's "Rotation lock" instead | |

## Touch gestures (tablet mode)

| Gesture | Action |
|---|---|
| Three fingers left / right | Next / previous workspace |
| Three fingers up | Workspace overview |
| Three fingers down | Window overview |
| Four fingers up / down | Volume up / down |
| Three-finger tap | Play / pause |

## Pen

| Control | Action |
|---|---|
| Tip | Left click |
| Lower side button | Right click (set for the current session only) |
| Upper side button | Right click |
| Eraser end | Erase, in apps that support it |

## Changing or backing up shortcuts

- Edit: System Settings → Keyboard → Shortcuts. Gestures: System Settings → Gestures.
- Back up to a file: `dconf dump /org/cinnamon/desktop/keybindings/ > cinnamon-shortcuts.conf`
- Restore: `dconf load /org/cinnamon/desktop/keybindings/ < cinnamon-shortcuts.conf`
