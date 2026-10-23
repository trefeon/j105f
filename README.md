# Project J105F — Samsung Galaxy J1 Mini (SM-J105F) revival

Single repository for bringing a 2016 `j1minilte` unit back into service on two tracks:

| Track | Target | State |
|---|---|---|
| **Recovery** (shared foundation) | Custom TWRP 3.7.0_9 built from committed source | Built + CI-verified, **not yet flashed** |
| **A — Android** | Newest realistically buildable Android for this SoC: LineageOS 14.1 (7.1.2), ceiling LineageOS 15.1 (8.1) | Port not started (no ROM ever shipped for this model) |
| **B — Linux** | postmarketOS / Alpine on the Samsung 3.10 vendor kernel | Kernel + debug initramfs `boot.img` built and CI-verified; **not yet flashed** |

Device facts, evidence and the reasoning behind these targets: `docs/device/identity.md`,
`docs/adr/0002-os-track.md`.

## Repository layout

```text
android/                 AOSP-side sources (paths mirror an AOSP checkout)
  device/samsung/j1minilte/   device tree used by the recovery build (later: ROM tree)
kernel/                  Samsung/Spreadtrum 3.10.65 vendor kernel (GPL-2.0), shared by both tracks
  arch/arm/configs/j1minilte_defconfig        recovery / Android config
  arch/arm/configs/j1minilte_linux_defconfig  Linux-port config
linux/                   Linux userspace: debug initramfs (Alpine/pmOS rootfs lands here)
device/                  hardware evidence (live captures) + stock DTBs used as byte-exact gates
docs/                    ADRs, device facts, plans, research, build reports, delivery roadmap
tools/                   host + CI tooling (boot image packers, splash patcher, initramfs builder)
.github/workflows/       recovery.yml (TWRP), kernel.yml (Linux boot.img)
```

Build outputs go to `out/` (ignored). Proprietary device images, EFS dumps, modem firmware and
third-party reference clones never enter Git (see `.gitignore`).

## Build and verify

Builds are **local-first** (`tools/local/`), on a Linux host — WSL2 Ubuntu 22.04 matches the
workstation setup; Windows itself cannot build AOSP or a 3.10 kernel. The GitHub workflows exist for
reproducibility but are `workflow_dispatch` only: pushes do not consume CI minutes.

```sh
bash tools/local/build-kernel.sh            # zImage -> dt.img (byte-gated) -> initramfs -> boot.img
bash tools/local/build-recovery.sh         # AOSP 6.0 sync -> TWRP recoveryimage -> splash patch
```

What the scripts do:

- Kernel: fetch `arm-eabi-4.8` (same prebuilt as CI) → `j1minilte_linux_defconfig` → zImage → busybox
  1.36.1 static initramfs → `dt.img` rebuilt from `device/dtb/stock/` and byte-compared → `boot.img`
  (mkbootimg v0 + `SEANDROIDENFORCE`) → parse-and-size verify, checksums in `out/`.
- Recovery: sync the omni `twrp-6.0` manifest → copy `android/device/samsung/j1minilte` and `kernel/`
  into the checkout → `lunch omni_j1minilte-eng` → `make recoveryimage` → splash patch → 16 MiB gate.

Host tooling (works on Windows, no Linux needed):

```sh
python3 tools/bootimg/parse_bootimg.py <boot|recovery>.img <out-dir>   # inspect geometry
python3 tools/bootimg/patch_splash.py recovery.img android/device/samsung/j1minilte/splash --out out/recovery.img
python3 tools/bootimg/pack_dtimg.py --verify-dtb device/dtb/stock device/dtb/stock/dtb_0?.dtb --out out/dt.img
```

CI (manual only): `.github/workflows/recovery.yml`, `.github/workflows/kernel.yml`.

## Device safety rules

- Never flash without an explicit human "yes" in the current session (`docs/delivery/ROADMAP.md` hard rules).
- RECOVERY and KERNEL partitions are exactly 16 MiB each; CI fails closed at that limit.
- A checksummed rollback set (stock recovery/kernel/efs/prodnv + TWRP backup) exists on the PC and the
  phone's microSD — `device/evidence/stock-backup/`.
- Never claim a capability that was not observed on the device. "Built and verified in CI" is not "boots".

## Provenance

This repository was consolidated on 2026-10-23 from three repositories that were then deleted:
`trefeon/Project_J105F` (docs/evidence), `trefeon/twrp_j1minilte` (recovery tree + CI),
`trefeon/linux-samsung-j1minilte` (kernel + CI). The kernel tree existed in both former repositories;
it is stored once here. Commit SHAs and CI run numbers cited in `docs/` refer to those former
repositories — they are historical evidence, not links. Kernel source lineage and licensing:
`kernel/NOTICE.md`.

## Status detail

The authoritative execution state is `docs/delivery/ROADMAP.md` plus `docs/delivery/execution-log.md`.
Summary as of consolidation: Stages A–D complete (evidence, rollback set, CI, 16 MiB gates, branding,
splash), E/F device validation and release pending a human-supervised flash, G (kernel foundation) and
H1 (debug initramfs) complete in CI, H2–H11 device-gated.
