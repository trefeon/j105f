# Resource inventory — Project J105F

**Date:** 2026-10-23 · **Scope:** everything required to port an OS to the SM-J105F and to build a
custom Linux userspace for it. Two classes of material:

- **Committed evidence** — small, citable, lives in this repository.
- **Reference corpus** — large third-party trees, gitignored, reproducible via
  `tools/fetch-reference.sh` (pinned commits, verified `--check`).

Facts here are observations made on this workstation on 2026-10-23. Anything not observed is marked
**INFERENCE**. Upstream project names are current as of this date: postmarketOS now presents as
**Nura** (`postmarketos.org` → 301 → `nura.eco`); the packaging repos remain on
`gitlab.postmarketos.org`.

---

## 1. Device under test (verified live, 2026-08-11/12)

| Fact | Value | Source |
|---|---|---|
| Model / codename | SM-J105F/DS, `j1minilte` / `j1miniltexx` | `device/evidence/getprop.txt` |
| SoC / board | Spreadtrum SC9830I (family `sc8830`), board `SP8835EB` | `getprop.txt`, stock DTB id-string |
| CPU / RAM | 4× Cortex-A7 ARMv7, 941,892 kB MemTotal | `cpuinfo.txt`, `meminfo.txt` |
| Display / touch | 480×800, `sec_touchscreen` = `/dev/input/event2` | `input_devices.txt` |
| Stock firmware | Android 5.1.1, `J105FXXS0ARD2`, CSC XID, kernel 3.10.65 | `version.txt`, `getprop.txt` |
| eMMC / microSD | `mmcblk0` 7.3 GiB / `mmcblk1p1` 3.7 GiB | `partitions.txt` |
| Partitions | KERNEL p20 16 MiB · RECOVERY p21 16 MiB · SYSTEM p25 2097 MiB · CACHE p24 200 MiB · userdata p27 4819 MiB · efs p17 20 MiB · prodnv p18 5 MiB · HIDDEN p26 40 MiB | `partitions.txt`, `byname.txt` |
| Boot geometry | page 2048, kernel `0x8000`, ramdisk `0x01000000`, tags `0x100`, SPRD `dt.img` 5 slots, `SEANDROIDENFORCE` | `out/local-verify.txt` |
| Kernel cmdline | `console=ttyS1,115200n8` | `device/evidence/cmdline.txt` |

**Hard constraints for OS choice:** fbdev only (`CONFIG_DRM` unset, `CONFIG_FB_SCX35L=y`), no Mali
userspace outside Android, no Linux modem driver (`CONFIG_SIPC_LTE` exists, no userspace stack).
See `docs/research/os-options.md`.

---

## 2. Committed evidence and rollback set

| Asset | Location | SHA-256 / size | Notes |
|---|---|---|---|
| Stock KERNEL p20 | `device/evidence/stock-backup/boot_stock.img` | `ab58375c…5738b`, 16,777,216 B | local only (gitignored) |
| Stock RECOVERY p21 | `device/evidence/stock-backup/recovery_stock.img` | `6279f912…3116`, 16,777,216 B | local only |
| efs / prodnv | `device/evidence/stock-backup/efs.img`, `prodnv.img` | `a8c00675…`, `3bb43e39…` | local only; never commit |
| TWRP full backup | `device/evidence/stock-backup/TWRP/` | — | System + Data, pulled from microSD |
| Rollback procedure | `device/evidence/stock-backup/README.md` | — | exact `dd` commands |
| Custom TWRP | `device/evidence/build-artifacts/twrp-j1minilte/recovery.img` | `3651e105…bf4a`, source `634cb96c` | splash build, 11.87 MB, under 16 MiB gate |
| Linux debug boot.img | `device/evidence/build-artifacts/kernel-m31/linux-boot-j1minilte/boot.img` | `e3125677…41b2`, source `f649d5a5` | H1 busybox shell, serial + fbcon |
| Stock DTB set | `device/dtb/stock/dtb_00..04.dtb` | packed `dt.img` = `f29f3d90…042d` | 5× SP8835EB, byte-gate for every build |

All four rollback images exist on disk and on the phone's microSD. **No image has been flashed yet.**

---

## 3. Reference corpus (gitignored, 6.3 GB, pinned)

Reproduce with `bash tools/fetch-reference.sh`; verify with `--check`. Paths are relative to `reference/`.

| Path | Source | Pin | Size | License | Purpose |
|---|---|---|---|---|---|
| `pmaports/` | `gitlab.postmarketos.org/postMarketOS/pmaports` | `c7940da7b44e` | 2.0 MB | GPL-3.0 | Nura packaging: archived `device/archived/device-samsung-j1mini3g`, `linux-samsung-j1mini3g` + 8 kernel patches, `dtbtool-sprd`, `mkbootimg-osm0sis`, `boot-deploy`, `postmarketos-mkinitfs`, `sm-sparse-image-tool`, `postmarketos-zram`, SPRD patches |
| `j1minilte-dump/` | `Galaxy-J105F-Resources/samsung_j1minilte_dump` | `aceed8396fa3` | 2.9 GB | none stated (proprietary dump) | Stock `boot.img`, `recovery.img`, unpacked stock ramdisk (init scripts, `sprdwl.ko`, `mali.ko`), `bootdts/`, `ikconfig`, full `/system` (vendor HALs + `sc2331_fw.bin` / `sc2331_fdl.bin`), TWRP device tree copy |
| `android/device_j1minilte_cm13/` | `NotNoelChannel/android_device_samsung_j1minilte` @ `cm-13.0` | `52b80ac79c9e` | 2.1 MB | Apache-2.0 headers | Full 158-file SPRD device tree: BoardConfig, sepolicy, RIL shim, configs, TWRP fstab |
| `android/twrp_device_j1minilte/` | `NotNoelChannel/twrp_device_samsung_j1minilte` @ `twrp-5.1` | `f5b96747e059` | 584 KB | AGPL-3.0 (COPYING) | Minimal TWRP tree (the base of this repo's `android/device/samsung/j1minilte`) |
| `android/vendor_j1minilte_cm13/` | `NotNoelChannel/proprietary_vendor_samsung_j1minilte` @ `cm-13.0` | `f674dd4157bf` | 22 MB | proprietary blobs | Vendor tree for CM13 baseline |
| `android/device_sharkls-common_cm141/` | `djeman/android_device_samsung_sharkls-common` @ `cm-14.1` | `d0b1da8f1411` | 37 MB | Apache-2.0 headers | 251-file common tree for sharkls (SC9830 family) + `patches/sprd-diff/*` |
| `kernels/sharkls_cm141/` | `djeman/android_kernel_samsung_sharkls` @ `cm-14.1` | `0502c3a5bb4d` | 637 MB | GPL-2.0 | 3.10.100 kernel, 58 DTS, `j1minilte` rev00–rev04 DTS, j3xnlte defconfigs |
| `kernels/j1minilte_mayuri/` | `MayuriLabs/android_kernel_samsung_j1minilte` @ `master` | `5f4f03bd4899` | 638 MB | GPL-2.0 | 3.10.65 stock kernel + `j1minilte_defconfig` (cross-check of committed `kernel/`) |
| `kernels/j1mini3g_ikgapirov/` | `IKGapirov/android_kernel_samsung_j1mini3g` @ `6a377f7c43a8` | `6a377f7c43a8` | 639 MB | GPL-2.0 | 3.10.106 sibling kernel used by the Nura recipe (`lineage_j1mini3g_defconfig`) |
| `kernels/sharkls_g105f/` | `Galaxy-J105F-Resources/kernel_samsung_sharkls` @ `cm-14.1` | `1df22d20250a` | 639 MB | GPL-2.0 | 3.10.100 + **native `j1minilte_defconfig`**; the only kernel that satisfies the cm-14.1 device triple (2022 ROM lineage) |
| `android/vendor_sprd_cm141/` | `Galaxy-J105F-Resources/android_vendor_sprd` @ `cm-14.1` | `087a5490809f` | 315 MB | proprietary blobs | Surviving mirror of the DMCA-taken-down SPRD HAL/vendor tree (`gps`, `modules`, `open-source`, `proprietaries`, `wcn`) |
| `android/vendor_samsung_common_cm141/` | `djeman/android_vendor_samsung_common` @ `cm-14.1` | `8cae5ca14cad` | 64 MB | proprietary blobs | Samsung common blobs required by `sharkls-common` |
| `tools/pmbootstrap/` | `gitlab.postmarketos.org/postMarketOS/pmbootstrap` | tag `3.12.1` = `7d23010a125c` | 1.5 MB | GPL-3.0 | Nura build/flash tool; not on PyPI — install from source |
| `tools/heimdall/` | `Benjamin-Dobell/Heimdall` | `3997d5cc607e` | 13 MB | MIT | Samsung flashing tool source (Windows build required) |
| `tools/heimdall-bin/heimdall-msys2-r180.3997d5c-3.pkg.tar.zst` | `mirror.msys2.org` | sha256 `e3baf9fd2f16…ff0b` | 271 KB | MIT | Verified Windows Heimdall build (MSYS2 UCRT64 package) |
| `alpine/alpine-minirootfs-3.24.3-armv7.tar.gz` | `dl-cdn.alpinelinux.org` | sha256 `dc1ddfaf03ed…f0c1` | 3.18 MB | MIT (rootfs: mixed) | Baseline custom Linux userspace |

Key hashes from the dump (byte-identical rollback reference, not the same file as the raw partition dump):
`boot.img` `6246b521…22c1c`, `recovery.img` `9dad1ba1…08eb`, `boot/dt.img` `f29f3d90…042d`,
`boot/kernel` `4a34decb…367f`, `boot/ramdisk.packed` `ef09c86b…c62`.

---

## 4. Build and host tooling

| Tool | Version / pin | Where | Status |
|---|---|---|---|
| `adb` / `fastboot` | 37.0.1-15733141 | `tools/platform-tools/` (gitignored) | present |
| Python | 3.14.7 | Windows host | present |
| Git / GitHub CLI | 2.55.0 / 2.102.0 (authenticated `trefeon`) | Windows host | present |
| WSL2 | — | Windows host | **not installed** |
| Docker | — | Windows host | **not installed** |
| Local Linux build host | Ubuntu 24.04, 2C/4T, 16 GB RAM, ~300 GB free, Docker, sudo | on the desk | verified 2026-10-23 |
| Cloud VPS | Ubuntu 7.0-azure, 2 vCPU, 887 MB RAM, 14 GB free | remote | verified; cross-compile only |
| GitHub Actions | `ubuntu-22.04`, manual dispatch | `.github/workflows/` | wire-ready; not dispatched during research |
| `arm-eabi-4.8` | android-5.1.1_r38 | fetched by CI/local scripts | proven for 3.10 kernel |
| Nura kernel toolchain | GCC 12+ with archived patches (**INFERENCE**) | local build host via pmbootstrap | to provision |

Windows cannot build AOSP or a 3.10 kernel: path/case limits and no POSIX toolchain. All builds go to
the local Linux build host or CI.

---

## 5. Upstream assets still to acquire

| Asset | Why needed | Status |
|---|---|---|
| Stock firmware `J105FXXS0ARD2` (Odin tar) | last-resort restore, PIT, modem/EFS reference | **not local.** XID build `XID-J105FXXS0ARD2-20180508100607.zip`, 1,003,482,272 B; free-but-slow path at SamFrew, no published checksum. Newest XID build = the one already on the phone. See `docs/research/flash-and-firmware.md` |
| Odin 3.13.1 | Samsung-native flash path | **not gathered** — the mirror responds, but the workstation's Kaspersky web filter substituted an HTML block page (191,499 B, not a zip). Documented hash from the research pass: sha256 `056aeb87…4933` |
| Heimdall Windows binary | `print-pit`, scripted flash | **gathered**: MSYS2 UCRT64 package, sha256 `e3baf9fd…ff0b`; source also cloned. Requires WinUSB (Zadig), which disables Odin until reverted |
| PIT (`heimdall print-pit`) | authoritative partition geometry (ROADMAP A3) | **outstanding** — requires Download Mode + USB |
| Samsung USB driver | Windows device enumeration in Download Mode | version 1.9.5.0 confirmed; direct file link is JS-gated — install from the vendor page |
| Wi-Fi firmware | `sprdwl` bring-up | **acquired** in the stock dump: `system/etc/firmware/sc2331_fw.bin`, `sc2331_fdl.bin` |
| 2022 LineageOS 14.1 ROM | reference build for the Android track | documented (`lineage-14.1-20221024-UNOFFICIAL-j1minilte.zip`, PDA `J105FXXS0ARD2`), build stack reconstructed from source; download shortlink now returns **403** — not downloaded |
| Historic TWRP 3.0.3-0 tar | last-resort recovery | `TWRP_3.0.3-0_SM-J105-V2.tar` (14.7 MB, MD5 `49dec756…`) on AndroidFileHost; not downloaded |
| Mali userspace | 3D on Linux | not available; Android-only — accepted limitation |

---

## 6. What was verified locally

- `bash tools/fetch-reference.sh --check` → every pin matches; corpus 6.3 GB.
- `tools/bootimg/parse_bootimg.py` on stock and built images: page 2048, 5 DTBs SP8835EB,
  `dt.img` byte-identical to stock (`out/local-verify.txt`).
- Rollback images: exact partition sizes (16 MiB boot/recovery) and recorded SHA-256.
- Alpine armv7 minirootfs checksum matches the published file.
- Windows path hazards handled: `aux.c` needs `core.protectNTFS=false`; the dump's
  `bootimg/01_dtbdump_@0<`.dtb` is excluded from checkout (not needed).
- **Nura kernel patch set applies cleanly to the committed 3.10.65 tree.** On the build host
  (`~/j105f-build/src/kernel`), `git apply --check` passed for all seven real patches
  (`gcc7`, `gcc8`, `gcc10`, `linux3.4-ARM-8933`, `linux3.4-piggy.gzip.S`,
  `sprdfb-fix-swapped-colors`, `sprdfb-check-for-buffering`). The symlinks in
  `device/archived/linux-samsung-j1mini3g/` resolve to `device/.shared-patches/linux/`.
  No patch porting is required for a downstream Nura kernel package.
- **Kernel build measured on the build host** (2026-10-23, `j1minilte_linux_defconfig` + ZRAM/USB_ETH/
  RNDIS/fbcon deltas): `make -j4 zImage` = **856 s** (14 min 16 s), zImage **5,208,936 B**,
  sha256 `9e671935ef581d4812407cd84acc80f1267aa6f9ad3c358b41807d5df1b615bf`, objects 1.9 GB,
  arm-eabi-4.8 (tag `android-5.1.1_r38`) = 110 MB. A 2C/4T CPU is enough for iteration; use CI for
  release builds. Workspace left at `~/j105f-build/src` and `~/toolchains/arm-eabi-4.8`.

## 7. Rules

- `reference/` is never committed and never flashed from. Only `device/evidence/build-artifacts/`
  bundles with a recorded SHA-256 and size gate are flash candidates.
- Device images, EFS, modem firmware and full dumps stay out of Git.
- Nothing is flashed without an explicit human "yes" in the session (ROADMAP hard rule).

## 8. Related documents

- `docs/research/os-options.md` — OS decision matrix and recommendation (Nura downstream first,
  LineageOS 14.1 second).
- `docs/research/pmos-ecosystem.md`, `source-landscape.md`, `flash-and-firmware.md`,
  `build-environment.md`, `porting-methodology.md` — parallel research dossiers.
- `docs/guides/` — the actionable porting and custom-Linux guides.
