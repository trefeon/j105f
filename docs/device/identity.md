# Device — verified facts

Canonical hardware truth for the unit this project targets. Everything here comes from live captures
in `device/evidence/` (ADB/TWRP sessions, 2026-08-12), from the stock firmware/dump, or from the
vendor kernel source. Where a claim is inferred rather than observed it says so.

**Model:** Samsung Galaxy J1 Mini 4G — **SM-J105F/DS**, `j1minilte` / `j1miniltexx`, CSC **XID**
(Indonesia), dual-SIM DSDS.

## Identity

| Property | Value | Source |
|---|---|---|
| SoC | **SC9830I** (Spreadtrum SharkLS, SCX35L LTE family; board SP8835EB) | `getprop ro.chipname`, `ro.product.board`, boot DTS `sprd,sc-id=<0x2666>` |
| Platform string | `sc8830` (family name for SCX35 + SCX35L) | `ro.board.platform`, `ro.hardware`, cpuinfo, dmesg |
| CPU | 4× ARM Cortex-A7, 32-bit ARMv7, ~1.5 GHz | `cpuinfo.txt` |
| GPU | Mali-400 MP2 (vendor `mali.ko`; no mainline/KMS) | `modules.txt`, vendor tree |
| RAM | 941,892 kB ≈ 1 GB | `meminfo.txt` |
| Storage | 7,634,944 KiB eMMC (~7.3 GiB) + microSD | `partitions.txt` |
| Display | 4.0" TFT 480×800 | `input_devices.txt`, device tree |
| Touch | MELFAS MCS8040L, `sec_touchscreen` on `/dev/input/event2` | `input_devices.txt`, kernel DTS |
| Modem | LTE FDD/TDD + WCDMA/GSM, DSDS (`libsec-ril-dsds.so`) | `getprop` |
| Firmware | `J105FXXS0ARD2`, Android 5.1.1 (LMY47V), 2018-04-23 | `getprop.txt` |
| Stock kernel | 3.10.65-9723235, gcc 4.8 | `version.txt` |

Variant boundaries: **SM-J105H/B** = `j1mini3g`, 3G **SC8830** on `CONFIG_ARCH_SCX30G` — a different
kernel platform (no `SIPC_LTE`, no `MACH_SP9830I`); its ROMs/DTBs are references, not bases.
**SM-J106** (`j1minivelte`, SC9830) and **SM-J120** (`j1xlte`, Exynos) are different devices.

## Partition map (authoritative)

Block counts are 1 KiB blocks from `/proc/partitions`, cross-checked against `by-name` symlinks.

| Partition | Node | Size |
|---|---|---|
| KERNEL (boot) | `mmcblk0p20` | **16 MiB** (16,777,216 B) |
| RECOVERY | `mmcblk0p21` | **16 MiB** (16,777,216 B) |
| efs | `mmcblk0p17` | 20 MiB — **IMEI/NV; back up before any flash** |
| prodnv | `mmcblk0p18` | 5 MiB |
| CACHE | `mmcblk0p24` | 200 MiB |
| SYSTEM | `mmcblk0p25` | 2097 MiB — Linux rootfs target |
| HIDDEN (preload) | `mmcblk0p26` | 40 MiB |
| userdata | `mmcblk0p27` | 4819 MiB |

The LTE modem set (`l_modem`, `l_fixnv1/2`, `l_runtimenv1/2`, `l_ldsp`, `l_gdsp`, `l_warm`,
`td_runtimenv1/2`) is listed in `device/evidence/byname.txt`; those partitions hold closed firmware
and are out of scope for both tracks (telephony is excluded from the Linux release).

## Boot image geometry (decoded from stock images)

`ANDROID!` v0, page 2048, kernel offset `0x00008000`, ramdisk `0x01000000`, second `0x00F00000`,
tags `0x00000100`, base `0x0`, cmdline `console=ttyS1,115200n8`, SPRD `dt.img` (5 slots, tag
`0x2666`) appended after the ramdisk, `SEANDROIDENFORCE` suffix on boot images (the stock recovery
has none). Packers/parsers: `tools/bootimg/`.

## Flashing constraints

- Odin accepts an unsigned, locally built recovery on this model (community TWRP 3.0.3-0 and this
  project's builds); the red "RECOVERY IS NOT SEANDROID ENFORCING" warning is expected.
- No AVB/`vbmeta` partition exists (Android 5.1.1 era) — [INFERENCE from the partition map].
- Whether the KERNEL partition enforces signature checks ("SECURE FAIL: KERNEL") is **unverified** for
  this model; the E-stage flash plan therefore keeps a checksummed stock `boot.img` rollback.
- EFS backup is mandatory before any write operation (IMEI loss is unrecoverable).

## Evidence index

`device/evidence/getprop.txt`, `version.txt`, `cpuinfo.txt`, `meminfo.txt`, `partitions.txt`,
`byname.txt`, `cmdline.txt`, `dmesg.txt`, `df.txt`, `modules.txt`, `input_devices.txt`,
`battery.txt`, `stock-backup/` (checksums + rollback images, images not tracked), plus stock DTBs at
`device/dtb/stock/`.
