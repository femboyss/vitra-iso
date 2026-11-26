#!/usr/bin/env bash
# Builds the Vitra ISO with archiso.  (c) 2026 34 & Claude - GPL-3.0-or-later
#   ./build.sh            -> out/vitra-YYYY.MM.DD-x86_64.iso
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
command -v mkarchiso >/dev/null || { echo "!! archiso fehlt: sudo pacman -S archiso"; exit 1; }
WORK="${WORK:-/tmp/vitra-iso-work}"   # needs a few GB, /tmp is usually RAM: set WORK=... if short
sudo rm -rf "$WORK"
mkdir -p "$ROOT/out"
rm -f "$ROOT/out/vitra-$(date +%Y.%m.%d)-x86_64.iso"   # rebuild of the same day
# fresh mirrors for the live system and the installer (keeps the old list when offline)
python3 "$ROOT/scripts/make-mirrorlist.py" "$ROOT/profile/airootfs/etc/pacman.d/mirrorlist" \
    "$ROOT/profile/airootfs/etc/pacman.d/vitra-mirrorlist"
sudo mkarchiso -v -r -w "$WORK" -o "$ROOT/out" "$ROOT/profile"
sudo chown "$(id -u):$(id -g)" "$ROOT"/out/*.iso
iso=$(ls -t "$ROOT"/out/vitra-*.iso | head -1)
size=$(stat -c %s "$iso")
printf ':: %s  (%s MiB)\n' "$iso" "$(( size / 1024 / 1024 ))"
(( size < 1900 * 1024 * 1024 )) && echo ":: passt in ein GitHub-Release-Asset (< 2 GiB)" \
    || echo ":: groesser als 1,9 GiB: release.sh teilt es in Teile auf"
echo ":: testen:  ./test-vm.sh   (QEMU mit Testplatte, --fresh = neue leere Platte)"
