#!/bin/bash
# Local build of the recovery track (TWRP 3.7.0_9 device tree on the omni twrp-6.0
# manifest) without GitHub Actions.
#
# Requires a Linux host (WSL2 Ubuntu 22.04 matches .github/workflows/recovery.yml):
#   sudo apt-get install -y git-core gnupg flex bison gperf build-essential zip curl \
#     zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses-dev \
#     x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc \
#     unzip fontconfig lzop pngcrush schedtool squashfs-tools imagemagick libbz2-dev \
#     lzma ncftp liblz4-tool python3 ccache bc libncurses5 libtinfo5
# plus Python 2.7 (AOSP 6.0 scripts) and JDK 8.
#
# Usage: bash tools/local/build-recovery.sh [WORKDIR]   (default: $HOME/j105f-twrp)
# Output: $WORKDIR/TWRP/out/target/product/j1minilte/recovery.img (+ tar, SHA256SUMS)
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
WORK=${1:-$HOME/j105f-twrp}
SRC=$WORK/TWRP

command -v python2 >/dev/null || { echo "FAIL: python2 missing (AOSP 6.0 build scripts)"; exit 1; }
java -version 2>&1 | grep -q '1\.8' || { echo "FAIL: JDK 8 required"; exit 1; }
command -v repo >/dev/null || { echo "FAIL: repo tool missing"; exit 1; }

mkdir -p "$SRC"
cd "$SRC"
if [ ! -d .repo ]; then
    repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-6.0
fi
repo sync -c --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune -j"$(nproc)"

# committed sources -> AOSP paths (same contract as CI)
rm -rf "$SRC/device/samsung/j1minilte" "$SRC/kernel/samsung/j1minilte"
mkdir -p "$SRC/device/samsung" "$SRC/kernel/samsung"
cp -r "$ROOT/android/device/samsung/j1minilte" "$SRC/device/samsung/"
cp -r "$ROOT/kernel" "$SRC/kernel/samsung/j1minilte"

export ALLOW_MISSING_DEPENDENCIES=true LC_ALL=C
export KERNEL_TOOLCHAIN=${KERNEL_TOOLCHAIN:-/opt/toolchains/arm-eabi-4.8/bin}
[ -x "$KERNEL_TOOLCHAIN/arm-eabi-gcc" ] || { echo "FAIL: arm-eabi-4.8 not at $KERNEL_TOOLCHAIN"; exit 1; }

source build/envsetup.sh
lunch omni_j1minilte-eng
make -j"$(nproc)" recoveryimage

OUT=$SRC/out/target/product/j1minilte
python3 "$ROOT/tools/bootimg/patch_splash.py" \
    "$OUT/recovery.img" "$ROOT/android/device/samsung/j1minilte/splash" --out "$OUT/recovery.img"

cd "$OUT"
SIZE=$(stat -c%s recovery.img)
echo "recovery.img: $SIZE bytes (limit 16777216)"
[ "$SIZE" -lt 16777216 ] || { echo "FAIL: recovery.img exceeds the 16 MiB RECOVERY partition"; exit 1; }
tar -cf recovery.tar recovery.img
sha256sum recovery.img recovery.tar > SHA256SUMS
cat SHA256SUMS
