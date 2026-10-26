# GEMINI.md — onnxruntime-cpu-bin

## Project Overview

This repository is an **Arch Linux packaging project**, not an application
codebase. It contains a single `PKGBUILD` that repackages the official
Microsoft ONNX Runtime CPU-only release tarballs into the Arch package
`onnxruntime-cpu-bin` for both `x86_64` and `aarch64`.

- **Upstream:** https://github.com/microsoft/onnxruntime
- **Package name:** `onnxruntime-cpu-bin`
- **Artifact:** a binary repack (no compilation from source). ONNX Runtime is
  very expensive to build, so the official `onnxruntime-linux-x64-<ver>.tgz`
  and `onnxruntime-linux-aarch64-<ver>.tgz` releases are used directly.
- **Distribution:** packages are published to the GXDE Arch repository
  (`https://repo1.gxde.top/gxde-arch/$arch`), not to the official Arch repos.
- **License:** MIT (see `LICENSE`), maintained by GXDE OS.

The package intentionally `provides`/`conflicts`/`replaces` `onnxruntime-cpu`,
`onnxruntime`, and `onnxruntime-cpu-git` so it satisfies `dtkmultimedia`'s
`dtktablerecognizer` dependency and supersedes older packages.

## Repository Layout

| File | Purpose |
| --- | --- |
| `PKGBUILD` | The package definition. Single source of truth for `pkgver`, per-architecture sources, and checksums. |
| `update.sh` | Queries the GitHub API for the latest ONNX Runtime release and rewrites `pkgver` plus both `sha256sums_*` entries in `PKGBUILD` via `sed`. |
| `build.sh` | Convenience wrapper that `cd`s to the script directory and runs `makepkg -s --noconfirm`. |
| `repo-add.sh` | Copies built `*.pkg.tar.zst` into `repo/aarch64/` and runs `repo-add` to create `gxde-aarch64.db.tar.zst`. |
| `.github/workflows/build.yml` | Scheduled CI: bumps the version, builds both architectures in Arch chroots, uploads tarballs, and creates GitHub releases on tags. |
| `README.md` | User-facing install instructions and update-mechanism description. |
| `.gitignore` | Ignores makepkg output: `src/`, `pkg/`, `repo/`, `*.pkg.tar.*`, `*.src.tar.gz`, `*.log`. |

## Build and Run

All commands must be run on Arch Linux (or inside an Arch chroot) with
`base-devel` installed.

```bash
# Build and install locally (prompts for sudo)
./build.sh
# or, equivalently:
makepkg -si

# Build without installing
makepkg -s --noconfirm
```

Build artifacts (`*.pkg.tar.zst`) land in the repository root and are
git-ignored. A built package can be inspected with `pacman -Qip` /
`pacman -Qlp`.

### Updating to a new upstream release

```bash
./update.sh          # requires curl and jq; rewrites PKGBUILD in place
makepkg -s --noconfirm
```

`update.sh` downloads **both** architecture tarballs to compute SHA-256
checksums, so it needs network access and enough bandwidth for two full
releases. It only edits the three lines (`pkgver`, `sha256sums_x86_64`,
`sha256sums_aarch64`); never hand-edit checksums without re-downloading the
corresponding tarball.

### Local repository generation

```bash
./repo-add.sh        # populates repo/aarch64/ and runs repo-add
```

Note this script currently only handles the `aarch64` path. Adjust it if a
local `x86_64` repository is needed.

## CI Behavior (`.github/workflows/build.yml`)

- Triggered by cron `0 3 */10 * *` (every 10 days) and `workflow_dispatch`.
- **`update` job:** runs `update.sh`, then commits the `PKGBUILD` bump as
  `chore: update onnxruntime [skip ci]` when the diff is non-empty.
- **`build` job:** matrix over `x86_64` (`ubuntu-24.04`) and `aarch64`
  (`ubuntu-24.04-arm`). It clones GXDE-OS/GXDE, uses
  `configure-building-enviroment-arch.sh` to create an Arch chroot, builds with
  `makepkg -s --noconfirm --needed`, strips debug packages, packs a tar, and
  uploads via rsync/ssh to the GXDE package server using repository secrets
  (`PASSWD`, `USERS`, `HOST`, `UPATH`, `UPROGRAM_ARCH`, `UPORT`).
- Both jobs are gated on `github.repository_owner == 'GXDE-OS'`, so forks
  will not run them.
- On tag refs, a GitHub release is created with the built packages attached.

**Do not add secrets or server credentials to the repository.** CI relies
exclusively on GitHub Actions secrets.

## Development Conventions

### PKGBUILD

- Follow standard Arch packaging practices. Keep `pkgver` in sync with the
  upstream release tag (without the leading `v`).
- Architecture-specific sources and checksums **must** use the
  `source_<arch>` / `sha256sums_<arch>` naming convention; both `x86_64` and
  `aarch64` entries must always be present.
- `options=('!strip' '!debug')` is intentional — the upstream `.so` files are
  prebuilt and must not be stripped; debug packages are also removed in CI.
- The `package()` function maps `$CARCH` to the upstream directory name
  (`x64` vs `aarch64`) and errors on anything else.
- Upstream CMake config files hardcode `/lib64/`; the build `sed`s them to
  `/lib/` for Arch's filesystem layout. Preserve this if upstream paths change.
- A pkgconfig file (`/usr/lib/pkgconfig/libonnxruntime.pc`) is generated
  inline in the `PKGBUILD`; keep its `Version:` field tied to `$pkgver`.
- License files (`LICENSE`, `ThirdPartyNotices.txt`) must be installed under
  `/usr/share/licenses/$pkgname/`.

### Shell scripts

- Every script starts with `#!/usr/bin/env bash`, `set -euo pipefail`, and
  `cd "${0%/*}"` so it operates on the repository root regardless of the
  caller's working directory.
- Scripts carry SPDX headers:
  ```bash
  # SPDX-FileCopyrightText: 2026 GXDE OS
  # SPDX-License-Identifier: MIT
  ```
  New files should include the same headers.
- Keep `update.sh` idempotent and limited to the three `sed` edits; avoid
  reformatting unrelated parts of `PKGBUILD`.

### Commits

- Use conventional-style messages, e.g. `chore: update onnxruntime [skip ci]`
  for automated version bumps. The `[skip ci]` marker prevents redundant runs.
- Only `PKGBUILD` is committed by CI; build outputs must remain ignored.

## Important Caveats

- This is a **binary repack**; do not convert it to a source build without an
  explicit request — building ONNX Runtime from source is prohibitively heavy.
- On `x86_64`, installing this package replaces the official
  `extra/onnxruntime-cpu`. Mention this in any user-facing documentation.
- The README recommends `SigLevel = Optional TrustAll` for the GXDE repo; it
  is a testing convenience, not a production recommendation.
- There is no `.SRCINFO` in the repository. If publishing to the AUR, generate
  it with `makepkg --printsrcinfo > .SRCINFO` and keep it in sync with every
  `PKGBUILD` change.
- There are currently no automated tests. Validation is done by building the
  package (`makepkg -s --noconfirm`) and checking the resulting file list.
