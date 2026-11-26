#!/usr/bin/env python3
# Builds the mirrorlist that ships in the Vitra ISO - (c) 2026 34 & Claude - GPL-3.0-or-later
#
# Uses the official Arch mirror status (archlinux.org/mirrors/status/json) at ISO build time:
# only HTTPS mirrors that are fully synced and in good shape, mirrors near Austria first,
# then the best ones worldwide, then Arch's own CDN as the last fallback.
# Many good mirrors = pacman always has somewhere else to go when one is slow.
# Nobody has to run reflector by hand.
#
# usage: make-mirrorlist.py OUTPUT...   (keeps the old files when offline)
import json, sys, time, urllib.request

NEAR = ["AT", "DE", "CH", "CZ", "SI", "SK", "HU", "IT", "NL"]
N_NEAR, N_WORLD = 14, 10
CDN = ["https://geo.mirror.pkgbuild.com/", "https://fastly.mirror.pkgbuild.com/"]

def main(outs: list[str]) -> int:
    out = outs[0]
    try:
        with urllib.request.urlopen("https://archlinux.org/mirrors/status/json/", timeout=20) as r:
            data = json.load(r)
    except Exception as e:  # offline: keep what we have
        print(f"!! mirror status not reachable ({e}), keeping {out}", file=sys.stderr)
        return 0
    good = [u for u in data["urls"]
            if u.get("protocol") == "https" and u.get("active") and (u.get("completion_pct") or 0) >= 1.0
            and u.get("score") is not None and (u.get("delay") or 1e9) < 6 * 3600
            and u["url"] not in CDN]
    good.sort(key=lambda u: u["score"])
    near = [u for u in good if u.get("country_code") in NEAR][:N_NEAR]
    world = [u for u in good if u not in near][:N_WORLD]
    lines = ["#", "# Vitra mirrorlist - made at ISO build time from archlinux.org/mirrors/status",
             f"# {time.strftime('%Y-%m-%d')} - near Austria first, then worldwide, then Arch's CDN",
             "# The installed system gets a fresh list from the installer.", "#", ""]
    for title, group in (("near", near), ("worldwide", world)):
        lines.append(f"## {title}")
        lines += [f"Server = {u['url']}$repo/os/$arch" for u in group]
        lines.append("")
    lines.append("## Arch CDN (fallback)")
    lines += [f"Server = {c}$repo/os/$arch" for c in CDN]
    for o in outs:
        open(o, "w").write("\n".join(lines) + "\n")
    print(f":: mirrorlist: {len(near)} near + {len(world)} worldwide + {len(CDN)} CDN -> {out}")
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
