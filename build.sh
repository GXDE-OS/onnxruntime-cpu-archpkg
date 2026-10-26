#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 GXDE OS
# SPDX-License-Identifier: MIT
set -euo pipefail

cd "${0%/*}"
makepkg -s --noconfirm
