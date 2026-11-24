# Porting methodology — a stage-gated method for `j1minilte` (and any old phone)

> **2026-11-24 — 3G material quarantined.** Any `j1mini3g` (SCX30G) source, config or
> package referenced below was moved to `.reference_delete/` (gitignored); the paths no longer
> exist in `reference/`. Do not rebuild or re-pin them for this device. Allow-list and hard rule:
> `docs/research/lte-models.md`; reusable recipe shape: same file §5.


**Date:** 2026-10-23 · **Status:** method dossier; no device writes performed · **Feeds:** ROADMAP stages
E/G/H and both OS tracks.

**Tagging.** `[V]` = URL fetched and content read on 2026-10-23 (status recorded in §2). `[R]` = verified
inside this repository (path given). `[I]` = inference, stated as such. Nothing here asserts tool
behaviour that was not read from a primary source or observed in this repo.

## 1. Scope

In scope: the *method* for taking a stock Android 5.1.1 Samsung/Spreadtrum phone to a self-built OS —
postmarketOS/Alpine Linux (Track B) and LineageOS 14.1 (Track A) — from intake to release, with an
explicit entry condition, command set, artifact, pass/fail gate, rollback and evidence requirement per
stage.

Out of scope: OS choice (`docs/adr/0002-os-track.md`), firmware inventory (`flash-and-firmware.md`), host
capability measurement (`build-environment.md`), driver-level patches (`driver-bring-up-h2h3.md`). Those
are inputs; this file is the order of operations and the gates between them.

Sources distilled: the pmOS porting-guide series and initramfs/troubleshooting pages `[V]`, the
LineageOS charter and build workflow `[V]`, AOSP boot-header/partition docs `[V]`, Samsung PIT/Odin docs
plus `heimdall(1)` `[V]`, and the kernel's ramoops/fbcon/zram docs `[V]`.

Two rules make the method safe on a device with no accessible UART, no fastboot, no AVB:

1. **Every stage must produce an artifact that rolls back to the previous stage's artifact.** A stage
   whose rollback is unproven is not entered.
2. **A gate passes on observed device evidence, never on a successful build log** — the ROADMAP hard rule
   ("kernel compiled is not device boots") applied per stage.

Host roles: **W** = Windows workstation (adb/heimdall/Odin; no pmbootstrap, no WSL —
`[R] docs/research/build-environment.md`); **L** = Linux builder (CI `ubuntu-22.04` or a Linux VPS);
**D** = the phone.

## 2. Verified sources

| # | Source | URL | Status | Establishes |
|---|---|---|---|---|
| 1 | pmOS porting guide (overview + generating packages) | `https://wiki.postmarketos.org/wiki/Porting_to_a_new_device`, `https://wiki.postmarketos.org/wiki/Porting_to_a_new_device/Generating_device-specific_packages` | 200 `[V]` | device/kernel/firmware package split; downstream-vs-mainline decision; `init` prompts; `bootimg_analyze` |
| 2 | …kernel package (downstream) | `https://wiki.postmarketos.org/wiki/Porting_to_a_new_device/Kernel_package/Downstream` | 200 `[V]` | APKBUILD source pinning, defconfig naming, DTB location, `kconfig check/edit`, GCC-era patch work |
| 3 | …device package | `https://wiki.postmarketos.org/wiki/Porting_to_a_new_device/Device_package` | 200 `[V]` | deviceinfo edits, `checksum`/`build`, heimdall partition names |
| 4 | …image, flashing, first boot | `https://wiki.postmarketos.org/wiki/Porting_to_a_new_device/Generating_image_and_flashing`, `https://wiki.postmarketos.org/wiki/Porting_to_a_new_device/First_boot` | 200 `[V]` | `install`, `flasher flash_rootfs/flash_kernel`, `export`, SSH at 172.16.42.1, rebuild loop |
| 5 | pmOS initramfs | `https://wiki.postmarketos.org/wiki/Initramfs` | 200 `[V]` | mkinitfs + boot-deploy split, `initramfs-extra`, `switch_root`, cmdline args |
| 6 | pmOS deviceinfo reference | `https://docs.postmarketos.org/pmaports/main/packaging/device-packages/deviceinfo-reference.html` | 200 `[V]` | every `deviceinfo_*` used here (qcdt, seandroidenforce, offsets, sparse, zram) |
| 7 | pmbootstrap CLI | `https://docs.postmarketos.org/pmbootstrap/main/usage.html` | 200 `[V]` | exact subcommands/flags (`install --split/--sparse`, `flasher … --partition`, `export --odin`, `initfs extract`) |
| 8 | pmOS boot troubleshooting | `https://wiki.postmarketos.org/wiki/Troubleshooting_on-device_issues/Booting_problems` | 200 `[V]` | `last_kmsg`/`console-ramoops`, netconsole, debug shell, initramfs step-through |
| 9 | pmOS USB networking + serial | `https://wiki.postmarketos.org/wiki/USB_Network`, `https://wiki.postmarketos.org/wiki/Serial_debugging` | 200 `[V]` | 172.16.42.1/24 + unudhcpd, gadget configs, zero-MAC symptom, UART/earlyprintk/pstore |
| 10 | SoC + device pages | `https://wiki.postmarketos.org/wiki/Spreadtrum_SC9830`, `https://wiki.postmarketos.org/wiki/Samsung_Galaxy_J1_mini_(samsung-j1minilte)`, `https://wiki.postmarketos.org/wiki/Samsung_Galaxy_J3_2016_(samsung-j3xnlte)` | 200 `[V]` | family feature matrix; upstream-reported j1minilte state; same-family commands/traps |
| 11 | LineageOS build + blobs | `https://wiki.lineageos.org/devices/klte/build/`, `https://wiki.lineageos.org/extracting_blobs_from_zips.html`, `https://wiki.lineageos.org/submitting_device.html` | 200 `[V]` | `repo init -b cm-14.1`, `breakfast`, `brunch`, `./extract-files.py` |
| 12 | LineageOS requirements | `https://raw.githubusercontent.com/LineageOS/charter/main/device-support-requirements.md` | 200 `[V]` | SELinux enforcing, kernel from source, device-tree structure, blob provenance |
| 13 | AOSP boot header + partitions | `https://source.android.com/docs/core/architecture/bootloader/boot-image-header`, `https://source.android.com/docs/core/architecture/partitions`, `https://source.android.com/docs/security/features/selinux` | 200 `[V]` | v0 `boot_img_hdr` (Android ≤8); boot/recovery/system/cache/userdata roles |
| 14 | Samsung PIT + Odin | `https://samsung-loki.github.io/samsung-docs/docs/PIT/`, `https://samsung-loki.github.io/samsung-docs/docs/Odin/Flashing/` | 200 `[V]` | PIT magic `0x12349876`, 132-byte entries; Odin 128 KiB packets/sequence rules |
| 15 | heimdall | `https://git.sr.ht/~grimler/Heimdall`, `https://manpages.debian.org/testing/heimdall-flash/heimdall.1.en.html` | 200 `[V]` | Loke + "Odin 3 protocol"; `print-pit --no-reboot`, `flash --KERNEL`/`--RECOVERY`, `--resume` |
| 16 | kernel: ramoops, fbcon | `https://www.kernel.org/doc/html/latest/admin-guide/ramoops.html`, `https://www.kernel.org/doc/html/latest/fb/fbcon.html` | 200 `[V]` | `mem_address/mem_size/record_size/ecc`; `fbcon=map:`, `fbcon=rotate:` |
| 17 | kernel: zram, initramfs, netconsole | `https://www.kernel.org/doc/html/latest/admin-guide/blockdev/zram.html`, `https://www.kernel.org/doc/html/latest/filesystems/ramfs-rootfs-initramfs.html`, `https://www.kernel.org/doc/html/latest/networking/netconsole.html` | 200 `[V]` | compressed RAM block device; rootfs-initramfs/switch_root; udp console |
| 18 | android-tools, dtbtool-sprd | `https://github.com/nmeum/android-tools`, `https://gitlab.com/Grimler/dtbtool-sprd` | 200 `[V]` | `mkbootimg`, `unpack_bootimg`, `img2simg`/`simg2img`; SPRD dt.img generator |
| 19 | e2fsprogs, apk-tools | `https://man7.org/linux/man-pages/man8/mke2fs.8.html` (+`resize2fs.8`, `e2fsck.8`); `https://gitlab.alpinelinux.org/alpine/apk-tools/-/raw/master/doc/apk.8.scd` | 200 `[V]` | ext4 create/check/grow; `apk --root/-p ROOT` out-of-tree assembly |

Access note: `wiki.`/`docs.postmarketos.org` are served today through a mirror that renames the project in
page text (`wiki.nura.eco` / `docs.nura.eco`); page bodies, oldids and the sources behind them are upstream.
Scripted `curl` of the wiki hits a JS challenge, so those pages were read through a reader proxy (status from
the redirect chain). pmaports' canonical host is `gitlab.postmarketos.org` (API project 226, branch `main`);
`gitlab.com/postmarketOS/pmaports` still answers 200 as a read-only mirror.

## 3. Stage-gated method (S0–S9)

| Stage | Name | Exit gate in one line |
|---|---|---|
| S0 | Intake and model lock | variant, firmware, SoC and partition map proven from the live unit |
| S1 | Safety net | restorable backup set + PIT + checksummed rollback path |
| S2 | Image forensics and toolchain freeze | locally repacked boot image byte-matches stock sections |
| S3 | Recovery foothold | custom recovery boots, touch + adb + storage work, stock restore re-proven |
| S4 | Kernel bring-up | a kernel this project built produces *observed* output on the device |
| S5 | Initramfs → userspace foothold | initramfs reaches a shell and leaves a log |
| S6 | Rootfs and boot-to-login | login prompt + SSH over USB + zram active |
| S7 | Peripheral ladder | each peripheral passes its own isolated gate, in a fixed order |
| S8 | Android track parity | LineageOS boots with display/touch/RIL as scoped, SELinux enforcing |
| S9 | Release and handoff | reproducible rebuild + rollback re-proven + docs/upstream |

### S0 — Intake and model lock
- **Entry:** phone in hand, USB cable, adb from `tools/platform-tools/adb.exe` `[R]`.
- **Do (D):**
  ```sh
  adb shell getprop ro.product.device     # must print j1minilte
  adb shell getprop ro.build.PDA          # record the value (J105FXXS0ARD2 today)
  adb shell getprop ro.board.platform; adb shell getprop ro.chipname
  adb shell cat /proc/partitions
  adb shell ls -l /dev/block/platform/*/by-name
  ```
- **Artifact / evidence:** refreshed `device/evidence/{getprop,partitions,byname}.txt`, a one-line
  variant verdict, and the raw outputs with timestamps (say which value came from `getprop` vs `/proc`).
- **Pass:** `j1minilte`/`SM-J105F`, SoC `SC9830I`, board `SP8835EB`, sizes agree with
  `docs/device/identity.md` `[R]`. Variant mismatch (`j1mini3g`, `j1minivelte`, `j1xlte`) stops here.
- **Fail → rollback:** nothing was written; correct the target or stop.

### S1 — Safety net (this stage *is* the rollback for every later stage)
- **Entry:** S0 passed; human present (`HUMAN GATE`).
- **Do (D via rooted recovery; W for PIT):**
  ```sh
  dd if=/dev/block/mmcblk0p20 of=/external_sd/backup/boot_stock.img bs=4096
  dd if=/dev/block/mmcblk0p21 of=/external_sd/backup/recovery_stock.img bs=4096
  dd if=/dev/block/mmcblk0p17 of=/external_sd/backup/efs.img bs=4096
  dd if=/dev/block/mmcblk0p18 of=/external_sd/backup/prodnv.img bs=4096
  heimdall print-pit --no-reboot > pit-J105F.txt   # the next heimdall command needs --resume
  ```
  plus a TWRP nandroid of System/Data to microSD, pulled to the PC.
- **Artifact / evidence:** four `.img` + `CHECKSUMS.sha256` in `device/evidence/stock-backup/` (images
  gitignored), committed `pit-J105F.txt`, `sha256sum` of each image, the `dd` read-back hash, and the PIT
  excerpt for KERNEL/RECOVERY.
- **Pass:** boot/recovery exactly 16,777,216 B; efs 20,971,520 B; prodnv 5,242,880 B; PIT names/sizes
  reconcile with `/proc/partitions`; one restore has been *executed* and read back with a matching hash.
- **Fail → rollback:** no backup, no flash — S3+ stay blocked.

### S2 — Boot-image forensics and toolchain freeze (offline)
- **Entry:** S1 passed; stock boot/recovery images local.
- **Do (W/L):**
  ```sh
  python3 tools/bootimg/parse_bootimg.py boot_stock.img out/parsed-boot
  unpack_bootimg --boot_img boot_stock.img
  python3 tools/bootimg/pack_dtimg.py --out out/dt.img --verify-dtb device/dtb/stock \
      device/dtb/stock/dtb_0*.dtb
  python3 tools/bootimg/pack_bootimg.py --kernel zImage --ramdisk ramdisk.cpio.gz --dt out/dt.img --out out/boot.img
  ```
  Rebuild the *stock* image from parsed parts first: `[R] tools/bootimg/{parse,pack}_bootimg.py` implement
  the v0 header, the SPRD `dt.img` table (magic `SPRD`, 20-byte entries, slots at `0x800 + i*0x10000`)
  and the `SEANDROIDENFORCE` suffix.
- **Artifact / evidence:** `out/parsed-*` (kernel, ramdisk, `dtb_NN_*.dtb`), a geometry table, `sha256`
  per DTB, and a `cmp -l` summary against stock.
- **Pass:** header fields match decoded stock values (page 2048, kernel `0x8000`, ramdisk `0x01000000`,
  second `0x00F00000`, tags `0x100`, cmdline `console=ttyS1,115200n8`); the 5 DTBs are byte-identical to
  `device/dtb/stock/`; repack differences are enumerated (header `id`/padding), not hand-waved.
- **Fail → rollback:** stop — a geometry or dt.img error here becomes an unbootable image later.

### S3 — Recovery foothold
- **Entry:** S1+S2 passed; recovery image under the 16 MiB gate `[R] ROADMAP R1`.
- **Do (D, human "yes"):**
  ```sh
  adb push recovery.img /external_sd/recovery_new.img
  adb shell "dd if=/external_sd/recovery_new.img of=/dev/block/mmcblk0p21 bs=4096"
  adb shell "dd if=/dev/block/mmcblk0p21 bs=4096 2>/dev/null | sha256sum"   # must equal pushed hash
  ```
  Odin fallback: AP slot with `recovery.tar`/`.tar.md5`. Heimdall flashes raw images by partition name
  (`heimdall flash --RECOVERY recovery.img --no-reboot` `[V] heimdall(1)`); a firmware `.tar.md5` must be
  unpacked first `[R] flash-and-firmware.md`.
- **Artifact / evidence:** flashed recovery, read-back hash, TWRP About-screen photo, flash tool+version,
  and `adb pull /tmp/recovery.log`.
- **Pass:** recovery boots, display and touch work, `adb devices` shows `recovery`, all partitions mount,
  a nandroid round-trip succeeds (`[R] docs/plans/device-test-checklist.md`).
- **Fail → rollback:** `dd` the stock `recovery_stock.img` back and re-verify the hash
  (`[R] docs/delivery/e1-flash-commands.md`).

### S4 — Kernel bring-up (downstream 3.10)
- **Entry:** S3 passed; kernel tree + defconfig present (`[R] kernel/`, `j1minilte_defconfig`).
- **Do (L):**
  ```sh
  pmbootstrap init            # vendor=samsung codename=j1minilte downstream armv7 heimdall
  pmbootstrap checksum linux-samsung-j1minilte
  pmbootstrap kconfig check  linux-samsung-j1minilte
  pmbootstrap build          linux-samsung-j1minilte
  ```
  APKBUILD shape fixed by the archived sibling `[V] linux-samsung-j1mini3g/APKBUILD`: pinned source
  tarball + `_commit`, `config-$_flavor.armv7`, `downstreamkernel_prepare/package`, and
  `dtbTool-sprd -s 2048 -p scripts/dtc/ -o arch/arm/boot/dt.img arch/arm/boot/dts/`. Track A instead
  builds in-tree via `TARGET_KERNEL_CONFIG`/`TARGET_KERNEL_SOURCE` in
  `[R] android/device/samsung/j1minilte/BoardConfig.mk`.
- **Artifact / evidence:** kernel `.apk` with `zImage`, `dt.img` (or `/boot/dt.img` for deviceinfo qcdt),
  modules; kernel sha256, defconfig hash, `dmesg`/pstore capture, panel photo, boot count.
- **Pass:** flashed kernel yields *observed* output — fbcon text, a `ttyS1` line, or a pstore record — on
  three consecutive boots `[R] ROADMAP Gate D`.
- **Fail → rollback:** reflash the stock/previous `boot.img` from S1; the rootfs is still untouched.

### S5 — Initramfs → userspace foothold
- **Entry:** S4 passed.
- **Do (L build, D boot):**
  ```sh
  sh tools/initramfs/build_initramfs.sh      # static busybox 1.36.1 + linux/initramfs/init
  python3 tools/bootimg/pack_bootimg.py --kernel zImage \
      --ramdisk out/ramdisk.cpio.gz --dt out/dt.img --out out/boot.img
  ```
  pmOS equivalent: `pmbootstrap initfs build`, `pmbootstrap initfs hook_add debug-shell`,
  `pmbootstrap initfs extract` `[V]`; its init mounts the root partition at `/sysroot` and hands over with
  busybox `switch_root` `[V]`. Here the init must mount `proc/sys/dev/devpts`, print a `BOOT_EVIDENCE`
  block and `exec` a shell on `/dev/tty1` with a second on `/dev/console` `[R] linux/initramfs/init`.
- **Artifact / evidence:** boot.img with the initramfs, full captured log, `cat /proc/cmdline`,
  `cat /proc/partitions`, photo or serial transcript.
- **Pass:** the evidence line appears (serial, panel or pstore) and a shell accepts input on at least one
  channel; `pmos.debug-shell` is the pmOS equivalent `[V]`.
- **Fail → rollback:** previous `boot.img` (S4 artifact).

### S6 — Rootfs and boot-to-login
- **Entry:** S5 passed; S1 backup still restorable.
- **Do (L):**
  ```sh
  pmbootstrap install --filesystem ext4 --split --sparse    # images for SYSTEM + KERNEL
  pmbootstrap flasher flash_rootfs --partition=SYSTEM      # 2097 MiB partition [R]
  pmbootstrap flasher flash_kernel                         # KERNEL per deviceinfo default
  pmbootstrap export --odin                                # Samsung tar for the W-side path
  ```
  Manual equivalent (documented, not default): `truncate -s <size> rootfs.img` → `mke2fs -t ext4 -F
  rootfs.img` → `apk -p <dir> --arch armv7 --allow-untrusted add alpine-base openssh` `[V]` → `e2fsck -f`, `resize2fs`
  if grown; `img2simg rootfs.img rootfs.sparse.img` for consumers that require sparse `[V] android-tools`.
- **Artifact / evidence:** rootfs image, installed `/etc/fstab` and `/etc/deviceinfo`, serial/panel log,
  `ip a`, `free -m`, `mount`.
- **Pass:** login/getty reached, `ssh user@172.16.42.1` works over USB `[V]`, zram swap active
  (`deviceinfo_zram_swap_pct/algo` honoured `[V]`).
- **Fail → rollback:** reflash the previous rootfs or the stock SYSTEM nandroid; kernel rollback as S4.

### S7 — Peripheral ladder (fixed order, one change per iteration)
- **Entry:** S6 passed — a remote shell exists, so every later rung is debuggable from W.
- **Do:** apply one patch or config change, rebuild, boot, probe each rung in §5's order:
  ```sh
  dmesg | grep -i -E 'sprdfb|melfas|mip4|sprdwl|mmc|zram|power_supply'
  cat /proc/fb; evtest /dev/input/event2; ip a; cat /sys/class/power_supply/*/capacity
  ```
- **Artifact / evidence:** per-rung patch/config delta + probe transcript; before/after logs and photos;
  one row per rung in the execution log.
- **Pass:** the rung's own observable (correct pixels, coordinates 0..479/0..799, mount survives reboot,
  an interface with an IP, scan results, battery % tracking).
- **Fail → rollback:** revert that single change only; the previous kernel/rootfs artifact is the fallback.

### S8 — Android track parity (LineageOS 14.1)
- **Entry:** S1+S3 passed; Track A decision recorded.
- **Do (L):**
  ```sh
  repo init -u https://github.com/LineageOS/android.git -b cm-14.1 --git-lfs --no-clone-bundle
  repo sync
  source build/envsetup.sh && breakfast j1minilte
  ./extract-files.py lineage-*.zip    # or extract-files.sh with the device attached
  brunch j1minilte
  ```
  Device-tree anatomy the build expects: `AndroidProducts.mk` + `lineage_j1minilte.mk`, `BoardConfig.mk`
  (arch, kernel offsets, `BOARD_MKBOOTIMG_ARGS`, partition sizes, recovery flags `[R]`),
  `lineage.dependencies`, `recovery.fstab`/root `fstab`, `init*.rc`, `extract-files.py`, `prebuilt/` `[V]`.
- **Artifact / evidence:** `lineage-14.1-*.zip`, `recovery.img`, vendor blob tree with per-file
  provenance; `getprop ro.build.version.*`, `getenforce`, `logcat`/`dmesg`, `ls -Z` sample.
- **Bring-up order inside the track:** recovery → kernel → display → touch → adb → RIL/Wi-Fi/camera;
  each probe is the same one used in S7 (no new gate type).
- **Pass:** boots to UI on the stock layout, display/touch/adb work, SELinux **enforcing** `[V] charter`,
  and the charter's hardware list is met or documented as an approved deviation.
- **Fail → rollback:** restore stock SYSTEM + boot + recovery from S1.

### S9 — Release and handoff
- **Entry:** S7 (Linux) or S8 (Android) gate passed, plus a rollback rehearsal in the same session.
- **Do:** `pmbootstrap checksum <pkg>`; `pmbootstrap build --force <pkg>`; `sha256sum out/*.img >
  SHA256SUMS`; write `BUILD_INFO.txt`. Publish: device page, deviceinfo + APKBUILD to pmaports (MR) or a
  tagged release here, plus the evidence index.
- **Artifact / evidence:** checksummed images, `BUILD_INFO.txt` (toolchain, commit, defconfig, cmdline),
  rollback instructions, test matrix, full build log, hash-comparison table, rollback transcript.
- **Pass:** a clean rebuild from a fresh clone reproduces the hashes (or differences are explained), and
  the rollback has been executed from the released artifact.
- **Fail → rollback:** keep the previous tagged artifact as latest-known-good; do not publish.

## 4. Portability: the same method on another old phone

Stages are device-independent; only §5 changes. Intake checklist for a new target:

| # | Check | Stop condition |
|---|---|---|
| 1 | Codename/variant from `ro.product.device` + model sticker + `ro.build.PDA` | third source disagrees |
| 2 | SoC + platform string (`ro.board.platform`, `ro.chipname`), mainline status | neither mainline nor downstream viable |
| 3 | Flash path (fastboot / Odin / mtkclient / none) | no flash path at all |
| 4 | Partition map from `/proc/partitions` **and** by-name, reconciled with PIT/firmware | sizes disagree and no backup exists |
| 5 | Boot image format (v0/v2 header, dtb/QCDT/SPRD, SEANDROIDENFORCE) parsed offline | parser cannot round-trip |
| 6 | Recovery available (TWRP/official/self-built) | no recovery and no `dd` route |
| 7 | Kernel source + defconfig obtainable (vendor OSS drop, Lineage tree) | only prebuilt kernel — no upstreamable pmOS port `[V]` |
| 8 | RAM/storage budget vs UI choice (~1 GB ⇒ zram + light UI) | rootfs fits no partition |
| 9 | Display/touch driver in the kernel tree | no framebuffer ⇒ need UART/pstore first |
| 10 | Network fallback (USB RNDIS/NCM) | no USB net and no Wi-Fi ⇒ no remote debug |
| 11 | Debug channel (serial pads, pstore, LED/vibrator hook) | none ⇒ every boot is blind |
| 12 | Ownership, EFS/IMEI backup, warranty-bit expectation | otherwise stop |

## 5. Device-specific notes — `j1minilte` (SM-J105F/DS, SC9830I)

Hardware truth and partition sizes: `[R] docs/device/identity.md`. Boot geometry decoded from stock and
re-implemented in `[R] tools/bootimg/`: `ANDROID!` v0, page 2048, kernel `0x00008000`, ramdisk
`0x01000000`, second `0x00F00000`, tags `0x00000100`, base `0x0`, cmdline `console=ttyS1,115200n8`, SPRD
`dt.img` with 5 slots (tag `0x2666`), `SEANDROIDENFORCE` on boot images and absent on stock recovery.

| Partition | Node | Size | Role |
|---|---|---|---|
| KERNEL | `mmcblk0p20` | 16 MiB | kernel + initramfs + dt.img container (S4/S5) |
| RECOVERY | `mmcblk0p21` | 16 MiB | foothold (S3); rollback carrier |
| SYSTEM | `mmcblk0p25` | 2097 MiB | Linux rootfs (S6) / LineageOS system (S8) |
| CACHE | `mmcblk0p24` | 200 MiB | scratch, pmOS cache |
| userdata | `mmcblk0p27` | 4819 MiB | alternate rootfs/home |
| efs / prodnv | p17 / p18 | 20 / 5 MiB | IMEI/NV — backup only, never write |

Decisions the method forces here:

- **Flashing path.** Proven: TWRP `dd` to a `by-name` partition. Odin/AP is the documented fallback;
  **heimdall is unproven on this unit** `[R] flash-and-firmware.md Gap 3`. Odin accepts an unsigned
  recovery on this model (red `RECOVERY IS NOT SEANDROID ENFORCING` banner expected), and each flash trips
  the KNOX/warranty bit permanently `[R] docs/adr/0002-os-track.md`.
- **pmOS deviceinfo shape.** Copy the archived 3G sibling's *shape*, never its SoC values `[V]
  pmaports device/archived/device-samsung-j1mini3g/deviceinfo`: `heimdall-bootimg`, `generate_bootimg=true`,
  `bootimg_qcdt=true`, `bootimg_append_seandroidenforce=true`, offsets base/kernel/ramdisk/second/tags =
  0/0x8000/0x1000000/0xf00000/0x100,
  `flash_pagesize=2048`, `flash_sparse=true`, `flash_sparse_samsung_format=1`, touch
  `/dev/input/event2`, 480×800. With `bootimg_qcdt` and no `qcdt_type`, boot-deploy expects `/boot/dt.img`
  from the kernel APKBUILD; with `bootimg_qcdt_type="sprd"` it runs `dtbTool-sprd` itself and requires
  `deviceinfo_dtb` `[V] boot-deploy-functions.sh`.
- **Kernel-era traps.** The vendor 3.10 tree needs the gcc7/8/10 patches plus
  `sprdfb-fix-swapped-colors` and `sprdfb-check-for-buffering` before a modern GCC builds it and before
  colours are correct `[V] linux-samsung-j1mini3g/APKBUILD`, `[R] driver-bring-up-h2h3.md`.
- **Upstream state (reported, not our evidence).** The pmOS wiki page for this codename lists Downstream,
  kernel 3.10.65, *booting: yes*, status "flash, boot bug", screen/touchscreen/USB-networking "works",
  flashing "partial", battery "partial", Wi-Fi "untested" `[V]` (read 2026-10-23) — a hypothesis to
  reproduce, not Gate D evidence.
- **Same-SoC reference.** `samsung-j3xnlte` (archived) documents the working command sequence and the
  traps that matter: custom SoC timer blocks mainline, only LXQt/SXMO worked, Wi-Fi broken `[V]`; its
  `linux-samsung-j3xnlte` package is a second packaging reference.

Bring-up ladder (each rung a gate, in this order because each enables the next):

| Rung | Why here | First probe | Known trap |
|---|---|---|---|
| Display (sprdfb) | without pixels every later failure is blind | `cat /proc/fb`, panel photo | ABGR888 default renders R/B swapped → one-line patch to BGR565 `[R]`; triple-buffer rejects `FBIOPUT_VSCREENINFO` until `check_var` fixed |
| Touch (MELFAS MCS8040L) | needs the panel for feedback | `evtest /dev/input/event2` (busybox lacks it — `hexdump` fallback) | node is `event2`, `sec_touchscreen`; DTS gpios 53/93/91 `[R]` |
| Storage (eMMC/SD) | rootfs and evidence live here | `mount`, `df`, read-back `dd` | 16 MiB boot/recovery ceiling; never write efs/prodnv |
| USB gadget (RNDIS/NCM) | remote shell for all later work | `ip a`; host `dmesg`/`lsusb` | old Samsung composite can hand out a zero MAC → set one host-side `[V]`; needs `CONFIG_USB_G_ANDROID` or `USB_ETH(+RNDIS)` |
| Wi-Fi (`sprdwl`) | replaces the USB tether | `dmesg` filtered on `sprdwl`, `ip a` | module + firmware blobs required; highest risk, USB net is the declared fallback `[R] R7` |
| Battery / backlight | power policy, usability | `cat /sys/class/power_supply/*/capacity` | `ktd2801-bl` backlight node; charging-splash freezes reported on the sibling family page (flagged possibly outdated there) `[V]` |
| zram | 1 GB RAM makes it mandatory | `free -m`, `cat /proc/swaps` | `CONFIG_ZRAM` absent from the current defconfig vs `y` in the sibling config `[R]` |

## 6. Evidence requirements

1. **Per stage, four things:** artifact sha256; exact commands with tool versions (copy-pasteable);
   device-side observation (log excerpt, photo, hash read-back); the rollback available at that moment.
2. **Gate D rule:** three consecutive boots with captured logs before any kernel/initramfs claim. One boot
   is a data point; no log is not a data point `[R] ROADMAP`.
3. **Tag claims** `[V]`/`[R]`/`[I]`; a build log never upgrades to `[V]` for on-device behaviour.
4. **Store under `device/evidence/<stage>/`** with `SHA256SUMS` + `README.md`; images and blobs stay out of
   git (`.gitignore` already excludes them) `[R]`.
5. **Any boot log must include** `/proc/cmdline`, `/proc/version`, `/proc/partitions`, `dmesg`, and
   `/sys/fs/pstore/console-ramoops` (or `/proc/last_kmsg`) after a crash `[V]`.
6. **No-UART debug ladder, cheapest first:** pstore/ramoops → fbcon panic text on the panel
   (`fbcon=nodefer` forces immediate binding `[V]`; photograph the panel) → recovery ADB → USB RNDIS/telnet → serial `ttyS1`
   via MUIC/jig `[V]`. Escalate only when the cheaper channel is dark.
7. **Flash records:** tool+version, target node, image hash, read-back hash, outcome; one line per task in
   `docs/delivery/execution-log.md` `[R]`. Negative results are committed, not deleted.

## 7. Common failure modes

| Symptom | Most likely cause | First probe | Fix / rollback |
|---|---|---|---|
| "Kernel" flashed, device boots straight to Android | wrote SYSTEM/CACHE instead of KERNEL, or bootloader restored stock | `by-name` mapping vs written node | rewrite to `mmcblk0p20`; read-back hash |
| Flash ok, black screen, USB enumerates | fbcon/driver missing or colour swap; kernel alive | host `lsusb`/`dmesg`, then pstore | `CONFIG_FRAMEBUFFER_CONSOLE`, colour patch |
| Instant reboot loop, no USB | panic before console init | `console-ramoops`/`last_kmsg` from recovery | fix dt.img/cmdline; reflash S1 boot |
| "image too large" / hang at flash | image ≥ partition (16 MiB) | `stat -c%s boot.img` | size gate before flash; `create_initfs_extra` |
| "bad boot image header" | v0 header geometry/page size wrong | `parse_bootimg.py` fields | repack with S2 values |
| Display works, touch dead | melfas node/IRQ gpio wrong or event number changed | `cat /proc/bus/input/devices`, `hexdump /dev/input/event*` | fix DTS/`deviceinfo_dev_touchscreen` |
| No `usb0`/NCM interface on host | gadget config missing or zero MAC | `ip a` (device), `lsusb` (host) | enable `USB_G_ANDROID`/`USB_ETH_RNDIS`, set MAC `[V]` |
| Ping ok, SSH refused | sshd keys never generated (power cut) or fsck failed | console log, `/etc/ssh` | reinstall rootfs; let initramfs finish `[V]` |
| Initramfs waits forever on splash | boot/root partition not found | `pmos.debug-shell`, then source `init_functions.sh` | fix labels/`pmos_root=` `[V]` |
| Wi-Fi absent | `sprdwl.ko` + firmware missing | `dmesg` filtered on `sprdwl`, `ls /lib/firmware` | ship module+firmware or declare unsupported |
| OOM-dead at ~1 GB | no zram | `free -m`, `cat /proc/swaps` | `CONFIG_ZRAM` + `deviceinfo_zram_swap_pct` |
| Android: `getenforce` → Permissive | SELinux never re-enabled | `dmesg` filtered on `avc` | fix denials; charter requires enforcing `[V]` |
| Android: no calls/data | RIL blobs missing / DSDS variant mismatch | `logcat` RIL lines | `extract-files.py`; DSDS libs required `[R]` |
| Android: black UI / no HW accel | graphics HAL/blob mismatch (Mali is Android-bound) | `logcat` gralloc/EGL | software rendering; document deviation |
| AOSP build dies early (`print` syntax, `missing separator`) | Python 2 / make ≥4.3 against an AOSP-6.0 tree | failing step's stderr | pin python2 + make in CI `[R] ci-investigation.md` |
| eMMC unreadable after a bad flash | overflow corrupted a neighbour partition `[R] ROADMAP R1` | recovery `dmesg`, `dd` of p20/p21 | restore S1 images; never flash oversized images |

## 8. Sources

Exact URLs, access status and what each establishes are in §2 (rows 1–19); this section is the index by
project, plus the sources that are not external URLs.

**postmarketOS** — porting-guide series (`Generating_device-specific_packages`, `Kernel_package`,
`Kernel_package/Downstream`, `Device_package`, `Generating_image_and_flashing`, `First_boot`), `Initramfs`,
`USB_Network`, `Serial_debugging`, `Troubleshooting_on-device_issues/Booting_problems`,
`Spreadtrum_SC9830`, `Samsung_Galaxy_J1_mini_(samsung-j1minilte)`, `Samsung_Galaxy_J3_2016_(samsung-j3xnlte)`
— §2 rows 1–5, 8–10. Docs: pmbootstrap `usage.html`, pmaports `deviceinfo-reference.html`,
`kernel-packages.html` — rows 6–7. pmaports code via the GitLab API on `gitlab.postmarketos.org`
(project 226, branch `main`): `device/archived/device-samsung-j1mini3g/deviceinfo`,
`device/archived/device-samsung-j3xnlte/deviceinfo`, `device/archived/linux-samsung-j1mini3g/APKBUILD`,
`main/dtbtool-sprd/APKBUILD`, `main/postmarketos-mkinitfs/APKBUILD` (2.12.0),
`main/boot-deploy/APKBUILD` (0.25.0), and `postMarketOS/boot-deploy` →
`boot-deploy-functions.sh` (qcdt dispatch, `SEANDROIDENFORCE` append, mkbootimg arguments) — 200 `[V]`.

**LineageOS / AOSP** — `klte/build`, `extracting_blobs_from_zips`, `submitting_device`,
`LineageOS/charter/device-support-requirements.md`, AOSP `boot-image-header`, AOSP `partitions`, AOSP
`selinux` — §2 rows 11–13. (`submitting_device.html` and the SELinux page were status-checked only and are
cited for the submission/SELinux pointers, not for quoted text.)

**Samsung / flashing** — PIT format, Odin flashing protocol, Heimdall project page, `heimdall(1)` — rows
14–15.

**Kernel / userspace tools** — ramoops, fbcon, zram, ramfs-rootfs-initramfs, netconsole, android-tools,
dtbtool-sprd, e2fsprogs man pages, apk-tools `apk.8.scd` — rows 16–19.

**Repository ground truth** — `docs/device/identity.md`, `docs/delivery/ROADMAP.md`,
`docs/delivery/e1-flash-commands.md`, `docs/plans/device-test-checklist.md`,
`docs/research/driver-bring-up-h2h3.md`, `docs/research/build-environment.md`,
`docs/research/flash-and-firmware.md`, `docs/build-reports/ci-investigation.md`,
`android/device/samsung/j1minilte/BoardConfig.mk`, `tools/bootimg/{parse,pack}_bootimg.py`,
`tools/bootimg/pack_dtimg.py`, `linux/initramfs/init`, `tools/initramfs/build_initramfs.sh` — `[R]`.

**Gaps (not facts).** XDA threads linked from older docs (403 Cloudflare), `samfw.com` (403), the heimdall
releases page (502 at sibling measurement), and whether heimdall works on this exact bootloader `[I-open]`.
