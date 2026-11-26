# vitra-iso

The live / installer ISO of **Vitra**, an Arch-based Linux distribution.
Boot it and **vitrainstall** starts right away, fullscreen (no desktop, no top bar).

(c) 2026 34 & Claude. Licensed under GPL-3.0-or-later. Based on archiso's `releng` profile.

## Download

```
curl -fsSL https://github.com/femboyss/vitra-iso/releases/latest/download/downloadvitra | bash
```

`downloadvitra` gets the newest ISO (also when it is split into parts because of
GitHub's 2 GiB limit per file), puts it together and checks the SHA256 sum.
Then put it on a USB stick (erases the stick):

```
sudo dd if=vitra-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Laptop does not boot from USB?

Some firmware (school laptops ...) refuses USB boot. If the machine already runs Linux
with systemd-boot, start the live ISO from the internal disk instead:

```
curl -fsSL https://raw.githubusercontent.com/femboyss/vitra-iso/main/vitra-from-disk -o vitra-from-disk
sudo bash vitra-from-disk            # takes the ISO from the plugged-in Vitra stick
reboot
```

The next start goes straight into Vitra (once). `sudo bash vitra-from-disk --remove` cleans up.

## Build

```
sudo pacman -S --needed archiso
./build.sh                 # -> out/vitra-YYYY.MM.DD-x86_64.iso
./test-vm.sh               # test in QEMU (UEFI, 30 GB test disk, --fresh / --disk)
./release.sh               # GitHub release (splits if > 1.9 GiB)
```

## What is different from the Arch ISO

- `[vitra]` repo in the build and in the live system
- extra packages: vitrainstall, vitra-branding, sway, cage, qt6-wayland, mesa, vulkan-swrast, fonts
- tty1 starts `vitra-live`: vitrainstall fullscreen in sway as a kiosk (no bar, no borders),
  so the keyboard layout picked in the installer works right away; cage and the
  framebuffer are fallbacks for hardware where sway does not start;
  Ctrl+Alt+F2 gives a text console, `vitra-live` starts the installer again
- boot menu (with the Vitra logo), hostname, os-release, ISO name and label say Vitra
- mirrors: `build.sh` runs `scripts/make-mirrorlist.py`, which picks ~26 good HTTPS mirrors
  from the official Arch mirror status (near Austria first, then worldwide, then Arch's CDN).
  The live system and the installer use that list; nobody has to run reflector by hand

---

## Deutsch

Live-/Installations-ISO von **Vitra**. Booten, und vitrainstall startet sofort im Vollbild.
Download mit dem Befehl oben (`downloadvitra` setzt geteilte ISOs selbst zusammen und prueft sie),
bauen mit `./build.sh`, veroeffentlichen mit `./release.sh`.

(c) 2026 34 & Claude. Lizenz: GPL-3.0-or-later.
