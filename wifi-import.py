#!/usr/bin/python3
"""Merge saved Wi-Fi networks from an old Linux Mint disk into this system.

Mount the old root partition first, then run:
    sudo python3 wifi-import.py /mnt/old-disk
Never prints passwords.
  - only Wi-Fi connections are imported
  - same network name on both systems: the more recently saved one wins,
    the other is moved to a backup folder
  - interface / MAC pins from the old machine are dropped
"""
import glob
import os
import shutil
import subprocess
import sys
import time

import yaml

NEW = "/etc/netplan"
BACKUP = "/root/wifi-import-backup-" + time.strftime("%Y%m%d-%H%M%S")
PINS = ("connection.interface-name", "wifi.mac-address", "802-11-wireless.mac-address")

if os.geteuid() != 0 or len(sys.argv) != 2:
    sys.exit("run with: sudo python3 %s /path/to/mounted/old/root" % sys.argv[0])
OLD = os.path.join(sys.argv[1], "etc/netplan")
if not os.path.isdir(OLD):
    sys.exit("no saved networks found: %s does not exist" % OLD)


def load(folder):
    found = {}
    for path in sorted(glob.glob(folder + "/90-NM-*.yaml")):
        with open(path) as f:
            data = yaml.safe_load(f) or {}
        wifis = (data.get("network") or {}).get("wifis") or {}
        ssids = [s for w in wifis.values() for s in (w.get("access-points") or {})]
        found[path] = (data, ssids[0] if ssids else None)
    return found


def backup(path):
    os.makedirs(BACKUP, mode=0o700, exist_ok=True)
    shutil.move(path, BACKUP)


def has_password(data):
    text = yaml.safe_dump(data)
    # "key-management: psk" alone is not a password
    return "password:" in text or ".psk:" in text


old, new = load(OLD), load(NEW)
imported = {os.path.basename(p) for p in old}
# networks saved on this system itself (not files from an earlier import run)
native = {ssid: (path, data) for path, (data, ssid) in new.items()
          if ssid and os.path.basename(path) not in imported}
report = []

for path, (data, ssid) in old.items():
    name = os.path.basename(path)
    if not ssid:
        report.append(("skipped (not Wi-Fi)", name))
        continue
    target = os.path.join(NEW, name)
    verdict = "added"
    if ssid in native:
        native_path, native_data = native[ssid]
        if not has_password(native_data) and has_password(data):
            backup(native_path)
            verdict = "replaced this system's copy, which had no password"
        elif os.path.getmtime(native_path) >= os.path.getmtime(path):
            if os.path.exists(target):
                backup(target)
            report.append(("kept this system's newer copy", ssid))
            continue
        else:
            backup(native_path)
            verdict = "replaced by the old system's newer copy"

    dropped = []
    for wifi in data["network"]["wifis"].values():
        # "match: {}" means any Wi-Fi card and must stay, or the profile is invalid
        if wifi.get("match"):
            dropped.append("match")
        wifi["match"] = {}
        for ap in wifi.get("access-points", {}).values():
            passthrough = (ap.get("networkmanager") or {}).get("passthrough") or {}
            for key in PINS:
                if passthrough.pop(key, None) is not None:
                    dropped.append(key)
    fd = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        yaml.safe_dump(data, f, default_flow_style=False, allow_unicode=True)
    report.append((verdict + (" (dropped old-machine pins: %s)" % ", ".join(dropped)
                              if dropped else ""), ssid))

for verdict, what in report:
    print("%-28s %s" % (what, verdict))
if os.path.isdir(BACKUP):
    print("replaced files were moved to", BACKUP)

for cmd in (["netplan", "generate"], ["nmcli", "connection", "reload"]):
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode:
        print("FAILED:", " ".join(cmd), result.stderr.strip())
        sys.exit(1)
print("network manager reloaded")
