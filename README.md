# onnxruntime-cpu-bin

Arch Linux `x86_64` and `aarch64` binary package for the CPU-only ONNX
Runtime.

Official Arch only ships `onnxruntime-cpu` for `x86_64`. This repository
repackages the latest official `onnxruntime-linux-x64` and
`onnxruntime-linux-aarch64` releases and publishes them to the GXDE Arch
repository.

## Install and update

Add the GXDE repository to `/etc/pacman.conf`:

```ini
[gxde]
SigLevel = Optional TrustAll
Server = https://repo1.gxde.top/gxde-arch/$arch
```

Then:

```bash
sudo pacman -Syyu
sudo pacman -S onnxruntime-cpu-bin
```

The package provides `onnxruntime-cpu` and `onnxruntime`, so it satisfies
`dtkmultimedia`'s `dtktablerecognizer` dependency. It also replaces the old
`onnxruntime-cpu` and `onnxruntime-cpu-git` packages.

On `x86_64`, the official `extra/onnxruntime-cpu` package already exists.
`onnxruntime-cpu-bin` tracks a newer upstream release and will replace the
official package if installed. If you prefer the official package, do not
install `onnxruntime-cpu-bin` on `x86_64`.

## Update mechanism

- GitHub Actions runs every 10 days.
- `update.sh` queries the latest Microsoft ONNX Runtime release and updates
  `pkgver` plus both architecture checksums.
- The GXDE `configure-building-enviroment-arch.sh` script creates the matching
  Arch chroot (`x86_64` or `aarch64`) and builds the package with `makepkg`.
- Each architecture's package tar is uploaded to the GXDE package server;
  `UPROGRAM_ARCH` adds it to the pacman repository.
- Users receive updates with `pacman -Syyu`.

## Versioning

- New upstream release: `pkgver` changes and `pkgrel` resets to 1.
- Packaging-only change without a `pkgver` change: bump `pkgrel` manually.
- If Microsoft republishes the same version with different tarballs,
  `update.sh` detects the checksum change and bumps `pkgrel` automatically.

## Required secrets

`PASSWD`, `USERS`, `HOST`, `UPATH`, `UPORT`, `UPROGRAM_ARCH`, and optionally
`RELEASE_TOCKEN_GITHUB`.

## Build manually

```bash
makepkg -si
```

## Notes

- This is a binary repack, not a source build from git. Building ONNX Runtime
  from source is very heavy; the official release tarballs are used.
- `SigLevel = Optional TrustAll` is convenient for testing. For production,
  sign the repository and distribute the public key.
