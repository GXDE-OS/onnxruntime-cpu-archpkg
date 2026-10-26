#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 GXDE OS
# SPDX-License-Identifier: MIT
set -euo pipefail

cd "${0%/*}"

api='https://api.github.com/repos/microsoft/onnxruntime/releases/latest'
latest=$(curl -fsSL "$api" | jq -r '.tag_name // empty' | sed 's/^v//')

if [[ -z $latest || $latest == null ]]; then
    echo 'failed to resolve the latest ONNX Runtime release' >&2
    exit 1
fi

base="https://github.com/microsoft/onnxruntime/releases/download/v$latest"
x64_url="$base/onnxruntime-linux-x64-$latest.tgz"
arm_url="$base/onnxruntime-linux-aarch64-$latest.tgz"
x64_sha=$(curl -fsSL "$x64_url" | sha256sum | cut -d' ' -f1)
arm_sha=$(curl -fsSL "$arm_url" | sha256sum | cut -d' ' -f1)

current_ver=$(sed -n 's/^pkgver=//p' PKGBUILD)
current_rel=$(sed -n 's/^pkgrel=//p' PKGBUILD)
current_x64=$(sed -n "s/^sha256sums_x86_64=('\([^']*\)')/\1/p" PKGBUILD)
current_arm=$(sed -n "s/^sha256sums_aarch64=('\([^']*\)')/\1/p" PKGBUILD)

if [[ $latest != "$current_ver" ]]; then
    # New upstream release: pkgver changes and pkgrel resets to 1.
    sed -i "s/^pkgver=.*/pkgver=$latest/" PKGBUILD
    sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD
    echo "upstream version: $current_ver -> $latest (pkgrel reset to 1)"
elif [[ $x64_sha != "$current_x64" || $arm_sha != "$current_arm" ]]; then
    # Same version, different tarball: bump pkgrel so pacman sees an update.
    new_rel=$((current_rel + 1))
    sed -i "s/^pkgrel=.*/pkgrel=$new_rel/" PKGBUILD
    echo "tarball checksum changed for $latest (pkgrel $current_rel -> $new_rel)"
else
    echo "already up to date: $latest-$current_rel"
fi

sed -i "s/^sha256sums_x86_64=.*/sha256sums_x86_64=('$x64_sha')/" PKGBUILD
sed -i "s/^sha256sums_aarch64=.*/sha256sums_aarch64=('$arm_sha')/" PKGBUILD

echo "  x86_64:  $x64_sha"
echo "  aarch64: $arm_sha"
