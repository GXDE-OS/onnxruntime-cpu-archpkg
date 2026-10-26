# Maintainer: CharOfString <root@charofstring.cc>
# SPDX-FileCopyrightText: 2026 GXDE OS
# SPDX-License-Identifier: MIT

# Binary repack of the official Microsoft ONNX Runtime releases for x86_64
# and aarch64.  update.sh bumps pkgver and both checksums to the latest
# release; CI rebuilds and uploads the packages to the GXDE Arch repository.
pkgname=onnxruntime-cpu-bin
pkgver=1.31.0
pkgrel=1
pkgdesc='Cross-platform, high performance scoring engine for ML models (CPU-only, x86_64/aarch64 binary)'
arch=('x86_64' 'aarch64')
url='https://github.com/microsoft/onnxruntime'
license=('MIT')
depends=('glibc' 'libstdc++' 'libgcc')
provides=('onnxruntime-cpu' 'onnxruntime')
conflicts=('onnxruntime-cpu' 'onnxruntime' 'onnxruntime-cpu-git')
replaces=('onnxruntime-cpu' 'onnxruntime-cpu-git')
options=('!strip' '!debug')

source_x86_64=("onnxruntime-linux-x64-$pkgver.tgz::https://github.com/microsoft/onnxruntime/releases/download/v$pkgver/onnxruntime-linux-x64-$pkgver.tgz")
sha256sums_x86_64=('cc5c72baf5ae5c8238a6841f0897227be2d02826b9cf98eaf02fdefaeeb03a57')
source_aarch64=("onnxruntime-linux-aarch64-$pkgver.tgz::https://github.com/microsoft/onnxruntime/releases/download/v$pkgver/onnxruntime-linux-aarch64-$pkgver.tgz")
sha256sums_aarch64=('c5b8b3cca31f3d643a3b313b8f42e2d0f16a4fcefd02cda343d97bd5306afaab')

package() {
    local ort_arch
    case $CARCH in
        x86_64) ort_arch=x64 ;;
        aarch64) ort_arch=aarch64 ;;
        *) error "unsupported architecture: $CARCH" ;;
    esac

    local src="$srcdir/onnxruntime-linux-$ort_arch-$pkgver"

    install -d "$pkgdir"/usr/lib \
               "$pkgdir"/usr/include/onnxruntime \
               "$pkgdir"/usr/lib/pkgconfig \
               "$pkgdir"/usr/lib/cmake/onnxruntime \
               "$pkgdir"/usr/share/licenses/$pkgname

    cp -a "$src"/lib/libonnxruntime.so* "$pkgdir"/usr/lib/
    install -m755 "$src"/lib/libonnxruntime_providers_shared.so "$pkgdir"/usr/lib/

    cp -a "$src"/include/. "$pkgdir"/usr/include/onnxruntime/
    cp -a "$src"/lib/cmake/onnxruntime/. "$pkgdir"/usr/lib/cmake/onnxruntime/

    # The upstream CMake package hardcodes lib64; Arch installs to /usr/lib.
    sed -i 's|/lib64/|/lib/|g' "$pkgdir"/usr/lib/cmake/onnxruntime/*.cmake

    cat > "$pkgdir"/usr/lib/pkgconfig/libonnxruntime.pc <<EOF
prefix=/usr
libdir=\${prefix}/lib
includedir=\${prefix}/include/onnxruntime

Name: onnxruntime
Description: ONNX runtime
URL: https://github.com/microsoft/onnxruntime
Version: $pkgver
Libs: -L\${libdir} -lonnxruntime
Cflags: -I\${includedir}
EOF

    install -m644 "$src"/LICENSE "$pkgdir"/usr/share/licenses/$pkgname/LICENSE
    install -m644 "$src"/ThirdPartyNotices.txt "$pkgdir"/usr/share/licenses/$pkgname/ThirdPartyNotices.txt
}
