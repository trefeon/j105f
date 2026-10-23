# tools/

Host/CI tooling. Every script is standard-library Python 3 or POSIX sh; nothing here is required to
boot anything — it produces and inspects the images.

| Path | Purpose |
|---|---|
| `bootimg/pack_bootimg.py` | Pack an `ANDROID!` v0 boot image (mkbootimg geometry decoded from this device's stock images), optional `SEANDROIDENFORCE` suffix. |
| `bootimg/parse_bootimg.py` | Parse/verify a boot or recovery image: header, geometry, embedded SPRD dt.img, DTBs. |
| `bootimg/pack_dtimg.py` | Build the SPRD dt.img (`SPRD` table, 5 slots). `--verify-dtb` fails closed on any byte mismatch; `--compare-dtb` is diagnostic only. |
| `bootimg/patch_splash.py` | Post-build surgical splash patch (replaces exactly `twres/splash.xml` + `twres/images/splashlogo.png` in the ramdisk, repacks with the original geometry). Requires its sibling `pack_bootimg.py`. |
| `dev/make-splash.py` | Regenerate the 480×800 splash assets (`android/device/samsung/j1minilte/splash/`). |
| `initramfs/build_initramfs.sh` | Download (sha512-pinned), build static busybox 1.36.1 and pack `linux/initramfs/init` into `out/ramdisk.cpio.gz`. |
| `kernel/make_linux_defconfig.sh` | Regenerate `kernel/arch/arm/configs/j1minilte_linux_defconfig` from the vendor defconfig using the kernel's own `scripts/config`. |
| `local/build-kernel.sh` | Full local Linux build (toolchain fetch → zImage → initramfs → dt.img gate → boot.img → verify). Linux host / WSL2. |
| `local/build-recovery.sh` | Full local recovery build (twrp-6.0 sync → device+kernel copy → recoveryimage → splash → 16 MiB gate). Linux host / WSL2. |

CI entry points are `.github/workflows/recovery.yml` and `.github/workflows/kernel.yml` (manual
`workflow_dispatch` only); they mirror `local/build-*.sh` rather than sharing code, so a local green
build and a CI green build are comparable but not identical.
