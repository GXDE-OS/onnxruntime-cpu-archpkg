#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 GXDE OS
# SPDX-License-Identifier: MIT
set -euo pipefail

cd "${0%/*}"

repo_dir=repo/aarch64
mkdir -p "$repo_dir"

cp -f ./*.pkg.tar.zst "$repo_dir"/
repo-add "$repo_dir/gxde-aarch64.db.tar.zst" "$repo_dir"/*.pkg.tar.zst
