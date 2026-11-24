#!/usr/bin/env bash
# Publishes the newest ISO as a GitHub release of femboyss/vitra-iso.
# (c) 2026 34 & Claude - GPL-3.0-or-later
# ISOs over 1.9 GiB are split into parts (GitHub allows < 2 GiB per file);
# downloadvitra puts them back together and checks SHA256SUMS.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
GH_REPO="${GH_REPO:-femboyss/vitra-iso}"
LIMIT=$(( 1900 * 1024 * 1024 ))
iso=$(ls -t "$ROOT"/out/vitra-*.iso 2>/dev/null | head -1)
[[ -n $iso ]] || { echo "!! no ISO in out/, run ./build.sh first"; exit 1; }
name=$(basename "$iso")
ver=$(sed -E 's/^vitra-(.*)-x86_64\.iso$/\1/' <<<"$name")
tag="v$ver"
stage="$ROOT/out/release-$ver"
rm -rf "$stage"; mkdir -p "$stage"

echo ":: SHA256 of $name"
(cd "$ROOT/out" && sha256sum "$name") >"$stage/SHA256SUMS"
files=()
if (( $(stat -c %s "$iso") > LIMIT )); then
    echo ":: splitting into parts of 1900 MiB"
    split -b 1900M -d -a 2 "$iso" "$stage/$name.part"
    (cd "$stage" && sha256sum "$name".part* >>SHA256SUMS)
    files+=("$stage/$name".part*)
else
    ln "$iso" "$stage/$name" 2>/dev/null || cp "$iso" "$stage/$name"
    files+=("$stage/$name")
fi
cp "$ROOT/downloadvitra" "$stage/downloadvitra"
files+=("$stage/SHA256SUMS" "$stage/downloadvitra")

notes="Vitra $ver (c) 2026 34 & Claude

Download and check in one go:
\`\`\`
curl -fsSL https://github.com/$GH_REPO/releases/latest/download/downloadvitra | bash
\`\`\`
Then write it to a USB stick (all data on it is erased):
\`\`\`
sudo dd if=$name of=/dev/sdX bs=4M status=progress oflag=sync
\`\`\`
Packages: https://femboyss.github.io/vitra-web"
gh release create "$tag" -R "$GH_REPO" --title "Vitra $ver" --notes "$notes" --latest "${files[@]}"
echo ":: https://github.com/$GH_REPO/releases/tag/$tag"
