# Execution Log

Protocol per `docs/delivery/ROADMAP.md` §0 item 4: append one row per completed task:

`<TASK-ID> | <ISO date> | done|blocked | <one-line result> | <commit sha or artifact ref>`

Rows for tasks completed before this file existed were reconstructed from the ROADMAP checkboxes,
the git history, and CI run metadata on 2026-08-12.

| Task | Date | Status | Result | Ref |
|---|---|---|---|---|
| A1 | 2026-08-11 | done | ROADMAP committed as the execution spine; supersede banners + corrections C2/C3/C4 applied inline | `64ae684` |
| A2 | 2026-08-12 | done | Rollback set created: dd of p21/p20/p17/p18 → PC `stock-backup/` (recovery/boot exactly 16,777,216 B — stop rule passed; efs 20 MiB, prodnv 5 MiB match table); CHECKSUMS.sha256 + README committed; TWRP backup System 2.09 GB + Data 1.29 GB (.sha2) pulled to PC; cmdline/dmesg/df re-captured real (`console=null`, bootloader J105FXXS0ARD2); TWRP identified as 3.7.0_9-0-notnoelchannel | `stock-backup/` (gitignored imgs), run `db9a2d6b` |
| A3 | 2026-08-11 | blocked | Live `/proc/partitions` applied as C4 (p20/p21 = 16,384 KiB); heimdall PIT capture outstanding (needs phone in Download Mode) | `device/evidence/partitions.txt` |
| A4 | 2026-08-11 | done | BoardConfig BOOT+RECOVERY partition sizes 16777216 with evidence comment | twrp `0f7f3586` |
| A4b | 2026-08-11 | done | kernel.yml size gate tightened to 16777216 (fail closed) | kernel `f31f090a` |
| B1 | 2026-08-11 | done | Python 2 blocker fixed via source-built 2.7.18 + libncurses5; build advanced past `lunch` | run `31465251155` |
| B2 | 2026-08-11 | done | recovery.img produced; 6 root causes fixed one per iteration (docs/build-reports/ci-investigation.md) | runs `31469647748`/`31472573689`/`31474055688` |
| B3 | 2026-08-11 | done | Pre-build kernel assertions: defconfig, arm-eabi-gcc, prebuilt DTB | twrp workflow |
| C1 | 2026-08-11 | done | Fail-closed ≥ 16 MiB gates in both repos; R1 closed; green runs re-verified | `0f7f3586` + `f31f090a`; runs `31524994619`/`31524994372` |
| C2 | 2026-08-11 | done | SHA256SUMS + BUILD_INFO.txt + manifest-pinned.xml published with TWRP and kernel artifacts | `build-artifacts/` |
| C3 | 2026-08-12 | done | `recovery.tar.md5` created and verified (tar + 32-char MD5 appended, delta 32 B, re-hash matches `6ba01d34…`); `tar -tf` lists exactly `recovery.img`. Odin version naming stays open until E2 | `build-artifacts/twrp-j1minilte/recovery.tar.md5` |
| D1 | 2026-08-11 | done | Branding `0_j105f-custom` + PRODUCT_MODEL; strings verified in final ramdisk | twrp `2d63e410` |
| D2 | 2026-08-11 | done | AGPL COPYING preserved; NotNoelChannel attribution explicit | twrp README |
| E1 | 2026-08-12 | blocked | Pre-flight parse recorded: pgsz 2048, kernel 5,146,640 B, ramdisk 6,408,655 B, DTB blob @ 0xb06800, 5× DTBs SP8835EB (byte-identical sizes vs stock). Remaining checks + flash need A2 rollback set + `HUMAN GATE` | `build-artifacts/twrp-j1minilte/parsed-e1/` |
| G1 | 2026-08-11 | done | CI-first host decision (D5); kernel builds reproducibly on ubuntu-22.04 | kernel repo |
| G2 | 2026-08-11 | done | Kernel forked to `trefeon/linux-samsung-j1minilte` (vendor tree, K1) | `90cfeaa5` |
| G3 | 2026-08-11 | done | boot.img 6.53 MiB assembled in CI; fail-closed VERIFY PASS (header/size/dt.img byte-identical) | runs `31519306192`/`31520084805` |
| G4 | 2026-08-11 | blocked | First kernel flash attempt — rollback set now READY (A2 done 2026-08-12); awaiting human approval for the flash session (`HUMAN GATE`); restore `boot_stock.img` to p20 for rollback | — |

**Next actionable items:** (phone absent) → on phone return: capture LTE modem CP set (`docs/plans/modem-firmware-capture-plan.md`) → A3 heimdall PIT (Download Mode — optional) → E2 flash of custom recovery (human "yes") → G4 kernel flash (human "yes").

**2026-08-14 (exact-model research, no phone):** two parallel research lanes (local-dump mining + web) confirmed the unit as **SM-J105F/DS LTE** — SoC **SC9830i** (SharkLS, SCX35L family), board SP8835EB, 1 GB RAM; `sc8830` strings are the platform-family name, **not** the 3G chip; the 3G sibling `j1mini3g` (SM-J105H/B) is a different kernel platform (`ARCH_SCX30G`), reference recipe only. Artifacts: `docs/research/exact-model-findings.md` (new), stale `SC8830-as-chip` claims corrected in `docs/research/J105F-CustomOS-Research.md`, kernel README identity section (kernel repo `73a2f74a`), ROADMAP identity row clarified, `docs/plans/modem-firmware-capture-plan.md` (new — 12 CP partitions to capture pre-flash).

| H1 | 2026-08-14 | done | Debug initramfs boots to shell: init mounts basics + writes Gate-D boot evidence to serial, interactive shell on ttyS1 (PID 1) + tty1 (setsid -c) when fbcon up; CI fail-closed verifies initramfs (init + sh -n + static busybox 1.36.1); stripped vendor CMDLINE mem=128M landmine; boot.img 6,850,560 B < 16 MiB; all checksums verified locally | kernel `f649d5a5`, run `31799705308`, boot.img `e3125677…` |

| D3 | 2026-08-14 | done | 480×800 custom boot splash (J105F/custom TWRP). TWRP 3.7.0_9 splash is a theme page (/twres/splash.xml + images/splashlogo.png, 8-bit PNG — source-verified). Surgical post-build patch: tools/patch_splash.py + pack_bootimg.py in twrp repo; kernel/dt/cmdline/SEANDROID preserved, fail-closed verify. **CI green run `31801523361` @ `634cb96c`**: recovery.img 11,884,544 B < 16 MiB, splash.xml (J105F marker) + splashlogo.png (18,479 B PNG) verified inside the built ramdisk, checksums match. Flash bundle re-synced (recovery.img sha256 `3651e105…`), tar + tar.md5 rebuilt (md5 `fb8355dd…`); e1-flash-commands.md updated. Visual confirmation at E2 | twrp `634cb96c`; parent `tools/make-splash.py` |

| D4 | 2026-11-24 | done | Debrand to stock TWRP: `TW_DEVICE_VERSION := 0`, `PRODUCT_MODEL := SM-J105F`; splash patcher + custom art + CI/local build steps deleted. Run `45354249022` green (9m40s): recovery.img 11,890,688 B < 16 MiB (sha256 `94e9a4ad…`); built ramdisk verified `ro.twrp.version=3.7.0_9-0`, `ro.product.model=SM-J105F`, upstream splash page (`TeamWin`), 0 hits for `j105f-custom`/`Project J105F`/`custom TWRP`/`notnoelchannel`; DTB set byte-identical to `device/dtb/stock/`; tar `d22620eb…`, tar.md5 md5 `530a52e8…`; flash bundle + parsed-e1 re-synced | twrp `8bd33c52`, run `45354249022` |

**2026-08-14 (H2/H3/H5/H6 research pack, no phone):** `docs/research/driver-bring-up-h2h3.md` committed — sprdfb color-swap fix (`sprdfb_main.c:67` ABGR888→BGR565, archived patch applies cleanly) + check_var buffering fix (H10); MELFAS MCS8040L touch (`mip4.c:1257` registers `sec_touchscreen`, DTS binding `melfas_mip4@48` on i2c1 with 480×800) — driver already enabled, no delta; zram **gap** (`CONFIG_ZRAM` absent vs proven `y` in archived j1mini3g config); RNDIS: android composite `rndis_function` in-tree + `CONFIG_USB_ETH`+`USB_ETH_RNDIS` recommended (no gadget configfs in this 3.10 tree). Config deltas deferred to the G4 gate.

**2026-08-14 correction (C3/E1 artifacts):** the `twrp-j1minilte/` bundle (recovery.img + recovery.tar + recovery.tar.md5) was discovered to contain a **stale first-green image** — hash `9869d726`, run `31469647748`, commit `dfccd4fb`, **pre-branding** (`0_j1mini_custom` in ramdisk). Replaced with the gated HEAD artifact `799b5e10` (run `31524994619`, commit `0f7f3586`, branding `0_j105f-custom`); `recovery.tar` + `recovery.tar.md5` rebuilt from it (md5 `52067f65…`). `e1-flash-commands.md` corrected accordingly. Stock rollback images untouched.

**2026-08-14 correction (G3/kernel bundle):** `kernel-m31/` flash bundle re-synced from pre-gate run `31519306192` (boot.img `a8603c2d`, commit `05c7b22a`) to the gate-verified HEAD run `31524994372` (boot.img `671a576a`, commit `f31f090a`). Kernel source identical (top-3 commits workflow-only); dt.img unchanged (`f29f3d90…`).

**2026-10-23 (repository consolidation — ADR-0001, ADR-0002):** the three repositories (`Project_J105F`, `twrp_j1minilte`, `linux-samsung-j1minilte`) became one: `android/`, `kernel/`, `linux/`, `device/`, `docs/`, `tools/`, `.github/workflows/{recovery,kernel}.yml`. The 3.10 kernel tree now exists once and feeds both workflows (recovery: `j1minilte_defconfig`; Linux: `j1minilte_linux_defconfig`). Workflows are path-filtered. Doc paths rewritten; historical SHAs/run IDs kept as evidence. The 13 NTFS-invalid kernel paths (`drivers/gpu/drm/nouveau/.../aux.c` + 12 case variants) are committed from fetched blobs and marked skip-worktree in the Windows index. Track A (Android) scoped in `docs/plans/android-rom-port-plan.md` — LOS 14.1 primary, 8.1 gated ceiling, 9+ rejected; Track B evidence updated with the archived pmOS `samsung-j1mini3g` package (kernel 3.10.106, heimdall-bootimg, `flash_rootfs` 17 % quirk) and the confirmed absence of SC9830 mainline support. Device state unchanged: **nothing flashed**.

**2026-10-23 (research + guides pass, no phone):** six parallel research lanes and a pinned corpus fetch.
OS decision refreshed in `docs/research/os-options.md`: **Nura (postmarketOS) downstream port first**,
LineageOS 14.1 second (telephony-bearing). New dossiers: `source-landscape.md` (device tree `f7d0398`,
`sharkls-common` `d0b1da8`, G105F kernel `1df22d2`, vendor blobs `f674dd4`/`087a549`/`8cae5ca`,
LineageOS manifest `3053abb`), `pmos-ecosystem.md` (Nura rename; pmbootstrap 3.12.1 `7d23010`; pmaports
`c7940da7`; j1mini3g recipe + 17 % heimdall failure), `flash-and-firmware.md` (TWRP `dd` proven, heimdall
unproven, Odin fallback), `build-environment.md` (measured kernel build), `porting-methodology.md`,
`resource-inventory.md` (6.3 GB corpus, every pin verified). Guide:
`docs/guides/01-porting-an-os-to-a-phone.md` (the custom-Linux and LineageOS tracks remain dossier
material: `pmos-ecosystem.md` §4, `source-landscape.md` §5.2). Verified: all seven Nura SPRD/GCC kernel
patches `git apply --check` clean against `kernel/` (on the local Linux build host); `make -j4 zImage`
856 s, zImage 5,208,936 B `9e671935…`; pmbootstrap
re-pinned to tag 3.12.1. Corrected repo claims: an unofficial 2022 LineageOS 14.1 build exists for this
exact PDA (README, ADR-0002). No device access; nothing flashed.
