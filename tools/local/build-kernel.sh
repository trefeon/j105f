#!/bin/bash
# Local build of the Linux track: zImage -> dt.img (byte-gated) -> initramfs -> boot.img.
#
# Runs without GitHub Actions. Requires a Linux host (WSL2 Ubuntu 22.04 is the
# match for .github/workflows/kernel.yml): build-essential, gcc-arm-linux-gnueabi,
# bc, cpio, bzip2, curl, git, python3.
#
# Usage: bash tools/local/build-kernel.sh
# Output: out/{zImage,dt.img,ramdisk.cpio.gz,boot.img,kernel.config,SHA256SUMS}
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
OUT=$ROOT/out
TC_DIR=${TC_DIR:-$OUT/toolchains}
TC=$TC_DIR/arm-eabi-4.8/bin/arm-eabi-

mkdir -p "$OUT"

# --- toolchain (same prebuilt as CI) --------------------------------------
if [ ! -x "$TC_DIR/arm-eabi-4.8/bin/arm-eabi-gcc" ]; then
    echo "== fetching arm-eabi-4.8 into $TC_DIR"
    mkdir -p "$TC_DIR"
    git clone --depth 1 --branch android-5.1.1_r38 --single-branch \
        https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8 \
        "$TC_DIR/arm-eabi-4.8" \
    || git clone --depth 1 --branch android-5.1.1_r38 --single-branch \
        https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-eabi-4.8 \
        "$TC_DIR/arm-eabi-4.8"
fi
"${TC}gcc" --version | head -1

# --- kernel ---------------------------------------------------------------
make -C "$ROOT/kernel" ARCH=arm CROSS_COMPILE="$TC" j1minilte_linux_defconfig
make -C "$ROOT/kernel" ARCH=arm CROSS_COMPILE="$TC" olddefconfig
make -C "$ROOT/kernel" ARCH=arm CROSS_COMPILE="$TC" -j"$(nproc)" zImage
grep -E "CONFIG_(MACH_J1MINILTE|DEVTMPFS|VT|FRAMEBUFFER_CONSOLE)=" "$ROOT/kernel/.config"

# --- initramfs (busybox 1.36.1, static) -----------------------------------
bash "$ROOT/tools/initramfs/build_initramfs.sh"

# --- dt.img from the stock DTBs (fail closed) -----------------------------
DTB=$ROOT/device/dtb/stock
python3 "$ROOT/tools/bootimg/pack_dtimg.py" --verify-dtb "$DTB" \
    "$DTB/dtb_00.dtb" "$DTB/dtb_01.dtb" "$DTB/dtb_02.dtb" "$DTB/dtb_03.dtb" "$DTB/dtb_04.dtb" \
    --out "$OUT/dt.img"

# --- boot.img -------------------------------------------------------------
python3 "$ROOT/tools/bootimg/pack_bootimg.py" \
    --kernel "$ROOT/kernel/arch/arm/boot/zImage" \
    --ramdisk "$OUT/ramdisk.cpio.gz" \
    --dt "$OUT/dt.img" \
    --cmdline "console=ttyS1,115200n8" \
    --out "$OUT/boot.img"

# --- verify ---------------------------------------------------------------
mkdir -p "$OUT/parsed-boot"
python3 "$ROOT/tools/bootimg/parse_bootimg.py" "$OUT/boot.img" "$OUT/parsed-boot"
SIZE=$(stat -c%s "$OUT/boot.img")
echo "boot.img: $SIZE bytes (limit 16777216)"
[ "$SIZE" -lt 16777216 ] || { echo "FAIL: boot.img exceeds the 16 MiB KERNEL partition"; exit 1; }

cp "$ROOT/kernel/arch/arm/boot/zImage" "$OUT/zImage"
cp "$ROOT/kernel/.config" "$OUT/kernel.config"
( cd "$OUT" && sha256sum zImage dt.img ramdisk.cpio.gz boot.img kernel.config > SHA256SUMS && cat SHA256SUMS )

echo "== done: $OUT/boot.img"
