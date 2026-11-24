#!/usr/bin/env bash
# Boot the newest Vitra ISO in QEMU (UEFI, GTK window, no GL: works with Nvidia + Wayland,
# where run_archiso's SDL display crashes). Comes with a 30 GB test disk (/dev/vda in the VM),
# your real disks are never visible to the VM.  (c) 2026 34 & Claude - GPL-3.0-or-later
#
#   ./test-vm.sh            boot the ISO (test disk is kept between runs)
#   ./test-vm.sh --fresh    new empty test disk
#   ./test-vm.sh --disk     boot the test disk (after an install), no ISO
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
DISK="${VITRA_TEST_DISK:-/tmp/vitra-test.qcow2}"
VARS="${DISK%.qcow2}-vars.fd"
CODE=/usr/share/edk2/x64/OVMF_CODE.4m.fd
command -v qemu-system-x86_64 >/dev/null || { echo "!! qemu fehlt: sudo pacman -S qemu-desktop edk2-ovmf"; exit 1; }
[[ -f $CODE ]] || { echo "!! UEFI-Firmware fehlt: sudo pacman -S edk2-ovmf"; exit 1; }
[[ ${1:-} == --fresh ]] && rm -f "$DISK" "$VARS"
[[ -f $DISK ]] || qemu-img create -q -f qcow2 "$DISK" 30G
[[ -f $VARS ]] || cp /usr/share/edk2/x64/OVMF_VARS.4m.fd "$VARS"
boot=()
if [[ ${1:-} != --disk ]]; then
    iso=$(ls -t "$ROOT"/out/vitra-*.iso 2>/dev/null | head -1)
    [[ -n $iso ]] || { echo "!! keine ISO in out/, erst ./build.sh"; exit 1; }
    echo ":: $iso"
    boot=(-cdrom "$iso" -boot d)
fi
echo ":: Testplatte: $DISK (in der VM: /dev/vda)"
exec qemu-system-x86_64 -enable-kvm -machine q35 -cpu host -smp "$(( $(nproc) > 8 ? 8 : $(nproc) ))" -m 4G \
    -drive if=pflash,format=raw,readonly=on,file="$CODE" \
    -drive if=pflash,format=raw,file="$VARS" \
    -drive file="$DISK",if=virtio \
    "${boot[@]}" \
    -device virtio-vga -display gtk -nic user,model=virtio-net-pci \
    -name "Vitra test"
