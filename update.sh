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

sed -i "s/^pkgver=.*/pkgver=$latest/" PKGBUILD
sed -i "s/^sha256sums_x86_64=.*/sha256sums_x86_64=('$x64_sha')/" PKGBUILD
sed -i "s/^sha256sums_aarch64=.*/sha256sums_aarch64=('$arm_sha')/" PKGBUILD

echo "updated to onnxruntime $latest"
echo "  x86_64:  $x64_sha"
echo "  aarch64: $arm_sha"
