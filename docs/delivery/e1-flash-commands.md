# E1/E2 — Flash and rollback commands (custom recovery)

For the E-stage device session. All of these are **read twice by the human before anything is flashed**.
Never flash without the human's explicit "yes" in the same session (ROADMAP hard rule).

## 0. Pre-flight assertions (E1)

Run from TWRP (device connected, `adb devices` shows `recovery`):

```powershell
$adb = "$PWD\tools\platform-tools\adb.exe"
& $adb shell "getprop ro.product.device; getprop ro.build.PDA"
```

Expected (risk R3 control):
- `ro.product.device` = `j1minilte`
- `ro.build.PDA` = `J105FXXS0ARD2`

Target partition: **RECOVERY = `/dev/block/mmcblk0p21`, exactly 16,777,216 B** (16 MiB).
Rollback images exist at `device/evidence/stock-backup/` (PC) and `/external_sd/backup/` (microSD),
checksummed in `device/evidence/stock-backup/CHECKSUMS.sha256` (committed).

Image to flash: `device/evidence/build-artifacts/twrp-j1minilte/recovery.img`
(11,890,688 B, sha256 `94e9a4ad18cbe2e1c60e54e33ad156e6d5aaf1c120b593d61da919e60d5ad104` — under the
16 MiB gate; header pgsz 2048, offsets per ROADMAP §1).
Provenance: run `45354249022`, source commit `8bd33c52` (stock TWRP branding `TW_DEVICE_VERSION := 0`,
`PRODUCT_MODEL := SM-J105F`, upstream TWRP splash page, 16 MiB gate).
> **2026-08-14 corrections:** (1) this bundle previously held a stale first-green image (hash `9869d726`,
> run `31469647748`, commit `dfccd4fb`) — **pre-branding** (`0_j1mini_custom`), and its Odin tar was
> built from that same stale image. Replaced with the gated HEAD artifact `799b5e10`; `recovery.tar`
> + `recovery.tar.md5` rebuilt from it (md5 `52067f65…`); `parsed-e1/` re-parsed from it (ramdisk now
> 6,408,794 B). (2) **D3 splash (2026-08-14):** re-synced to run `31801523361` (recovery.img `3651e105`,
> commit `634cb96c`) — carries the custom 480×800 boot splash (`/twres/splash.xml` + `splashlogo.png`,
> patched post-build, fail-closed verified; kernel/dt/cmdline/SEANDROID preserved). `recovery.tar`
> + `recovery.tar.md5` rebuilt (md5 `fb8355dd…`). Do not flash any image whose SHA-256 is not
> `3651e105…`. *(superseded 2026-11-24 by D4 — see next note)*
> **2026-11-24 (D4 — debrand):** the custom splash patch and the author suffix are gone. TWRP now
> reports `3.7.0_9-0` / model `SM-J105F` and ships the upstream splash page (`twres/splash.xml`,
> author `TeamWin`; resolution 1080×1920 identical to `twres/ui.xml`, i.e. the same theme the earlier
> builds carried). Bundle re-synced from run `45354249022` (img `94e9a4ad…`, commit `8bd33c52`);
> `recovery.tar` sha256 `d22620eb…`, `recovery.tar.md5` rebuilt from it (md5 `530a52e8…`);
> `parsed-e1/` re-parsed (kernel 5,146,640 B, ramdisk 6,408,725 B, DTB blob @ 0xb06800, 5×
> SP8835EB byte-identical to `device/dtb/stock/`). Verified inside the built ramdisk:
> `ro.twrp.version=3.7.0_9-0`, `ro.product.model=SM-J105F`, zero occurrences of `j105f-custom`,
> `Project J105F`, `custom TWRP`, `notnoelchannel`. **Do not flash any image whose SHA-256 is not
> `94e9a4ad…`.**

## 1. Flash the custom recovery

### Method A — from the existing TWRP (preferred, least destructive)

```powershell
$adb = "$PWD\tools\platform-tools\adb.exe"
& $adb push device/evidence/build-artifacts/twrp-j1minilte/recovery.img /external_sd/recovery_new.img
& $adb shell "dd if=/external_sd/recovery_new.img of=/dev/block/mmcblk0p21 bs=4096"
# verify the flash read-back (optional but cheap):
& $adb shell "dd if=/dev/block/mmcblk0p21 bs=4096 2>/dev/null | sha256sum"
# must print: 94e9a4ad18cbe2e1c60e54e33ad156e6d5aaf1c120b593d61da919e60d5ad104
```

(Alternative GUI route: TWRP → Install → Install Image → select `recovery_new.img` → partition: **RECOVERY** → swipe.)

### Method B — Odin/AP (fallback)

`recovery.tar` (plain, sha256 `d22620eb…`) or `recovery.tar.md5` (Odin classic, md5 `530a52e8…`) from
`device/evidence/build-artifacts/twrp-j1minilte/`. Odin version used for the successful flash
must be recorded here (D-2 resolution):

```
Odin version: ______ (fill after the successful flash)
```

## 2. First boot (E2)

- Reboot to recovery: `adb reboot recovery` (or VolUp+Home+Power).
- **Success:** TWRP UI boots; About screen shows version `3.7.0_9-0` and model `SM-J105F` (stock TWRP
  branding — no splash watermark, no author suffix). Photograph the About screen.
- **Rollback trigger:** no display, no touch, or repeated boot loop → immediately do step 3.

## 3. Rollback (proven path, images checksummed)

```powershell
# images already on the microSD at /external_sd/backup/ (or re-push from PC):
$adb = "$PWD\tools\platform-tools\adb.exe"
& $adb push device/evidence/stock-backup/recovery_stock.img /external_sd/recovery_stock.img
& $adb shell "dd if=/external_sd/recovery_stock.img of=/dev/block/mmcblk0p21 bs=4096"
& $adb shell "dd if=/dev/block/mmcblk0p21 bs=4096 2>/dev/null | sha256sum"
# must print: 6279f91243653717fe061bc5ff87c60a814b06d6a0bdee76e01625f87a743116
& $adb reboot recovery
```

Stock image is exactly 16,777,216 B; the read-back checksum proves the restore.

## 4. E3 matrix afterwards

Run the test matrix from `docs/plans/device-test-checklist.md`; record verdicts in
`docs/delivery/recovery-test-matrix.md` (create on execution). Anything failing = documented known
limitation, never silently presented as working.