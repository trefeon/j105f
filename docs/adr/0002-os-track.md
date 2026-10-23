# ADR-0002 — Two tracks: newest feasible Android, and Linux on the vendor kernel

- **Status:** accepted (2026-10-23)
- **Context:** operator goal — make the SM-J105F usable again, either on the newest possible Android or
  as a full Linux device.

## Constraints that decide everything

| Constraint | Fact | Consequence |
|---|---|---|
| SoC | Spreadtrum **SC9830I**, 4× Cortex-A7 **32-bit** ARMv7, Mali-400 MP2 | No 64-bit userspace, no Treble/VNDK, no GSI |
| RAM | 941,892 kB ≈ 1 GB | Android 8+ is tight; a full desktop is unrealistic |
| Kernel | vendor **3.10.65** only; SCX35L has **zero mainline support** (torvalds/linux v7.x has no `ARCH_SPRD` in `arch/arm/Kconfig`, no `arch/arm/boot/dts/sprd`, no `drivers/soc/sprd`; the arm64 `sprd/` support covers only sc9836/sc9860/sc9863a/ums512/ums9620 — and even the J3 port notes its custom timer must be ported first) | A modern-kernel port means writing clock/pinctrl/timer/PMIC/display drivers from scratch — rejected |
| Blobs | camera/GPU/RIL/Wi-Fi firmware closed; `android_vendor_sprd` was DMCA'd off GitHub (local snapshot is precious) | Android track depends on a local blob snapshot; Linux track cannot have telephony |
| Bootloader | S-Boot accepts unsigned images; Odin needs the literal `SEANDROIDENFORCE` string (present in our packer); KNOX bit trips permanently | Flashing works; no way to un-trip KNOX — accept it |
| Variants | `j1minilte` ≠ `j1mini3g` (3G SC8830, different kernel platform) ≠ `j1minive3g` | Only SM-J105F evidence may be used as a base |

## Options considered

| Option | Verdict |
|---|---|
| **A — Custom Android ROM (LineageOS)** | **Chosen (primary).** Android 7.1.2 is the highest any public build reached for this exact model (unofficial 2022 LineageOS 14.1, link now dead); Android 8.1 is the source-only ceiling (sharkls 15.1 trees boot on the same-SoC J3, never built for j1minilte). Android 9+ impossible. |
| **B — postmarketOS / Alpine Linux on the 3.10 vendor kernel** | **Chosen (parallel track).** The only realistic "full Linux": Alpine userspace, console + fbdev first. pmOS's `samsung-j1mini3g` port — **archived 2026-06-22**, kernel 3.10.106 fork, wiki status *booting=yes* with screen/touch/USB-net working, `flash_rootfs` failing at 17 % (`flash_kernel` works; `--android-recovery-zip` fallback) — is a recipe reference; its kernel is `SCX30G`, not this unit. A `samsung-j1minilte` wiki page exists with `bootimg`/`qcdt` facts but **no merged device/kernel package**. |
| **C — mainline Linux (modern, 6.x/7.x)** | Rejected. No SCX35L support at all; would be a multi-year driver project. |
| **D — Linux chroot on stock Android** (Termux/UserLAnd/LinuxDeploy/Droidspaces) | Not a goal, but kept as the zero-risk fallback if flashing is ever unsafe. Cannot replace the OS. |
| **E — Halium / Ubuntu Touch** | Stretch only. Halium 7.1 was proven on the same platform (J3), but 1 GB RAM and the audio HAL make it a worse bet than B for the same effort. |

## Decision

1. **Shared foundation first:** the custom TWRP recovery (built, CI-verified) is the entry point for
   both tracks; no track advances until it is flashed and rollback is proven (ROADMAP E2–E4).
2. **Track A (Android)** targets **LineageOS 14.1 (7.1.2)** first — the highest version actually
   demonstrated on this model — with 8.1 as an explicit, evidence-gated ceiling attempt. Plan:
   `docs/plans/android-rom-port-plan.md`.
3. **Track B (Linux)** targets **postmarketOS/Alpine on the vendor 3.10 kernel**, console + framebuffer
   + touch + storage + USB networking first, Xorg after. Plan: ROADMAP Stage H, `docs/plans/linux-port-plan.md`.
   Only the *packaging shape* is inherited from the archived `samsung-j1mini3g` package (deviceinfo
   fields, `heimdall-bootimg`, SPRD `dt.img`, `SEANDROIDENFORCE`, sparse Samsung format); kernel,
   config and DTBs are this unit's **LTE SC9830I** ones in `kernel/` and `device/dtb/stock/`.
   The 3G sibling's kernel config (`SCX30G`) is never used.
4. **Both tracks share one kernel tree** (`kernel/`) with two defconfigs, and one recovery device tree.
5. **No version chasing without evidence:** a milestone is only claimed with a boot log from this unit.

## Consequences

- Telephony, GPU acceleration and (initially) audio are declared **out of scope** for the Linux track;
  Wi-Fi is the highest-risk component (firmware from the stock `/system/vendor`).
- The Android track needs a Linux build host (AOSP 7.1 ≈ 150 GB) and a blob snapshot; it cannot be
  built on this Windows workstation.
- Effort order is fixed by dependency, not preference: recovery flash → Android 14.1 bring-up and/or
  Linux H2–H11. They compete for the same human-gated device sessions, so the operator schedules them.
- If Android 14.1 turns out unusable on 1 GB, the Linux track is the fallback — and vice versa; neither
  decision forecloses the other because both use the same kernel and recovery.

## Evidence

`docs/device/identity.md`, `docs/research/exact-model-findings.md`,
`docs/research/J105F-CustomOS-Research.md`, `docs/research/driver-bring-up-h2h3.md`,
`docs/plans/android-rom-port-plan.md`, ROADMAP Stages G–H.
