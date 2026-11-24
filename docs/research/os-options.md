# OS options for SM-J105F (j1minilte) — 2026 assessment

**Date:** 2026-10-23 · **Role:** decision input to ADR-0002 (OS track)
**Device:** Samsung Galaxy J1 Mini 4G, SM-J105F/DS — Spreadtrum **SC9830I**, 4× Cortex-A7 (ARMv7, no AArch64),
Mali-400 MP2, **1 GB RAM**, 480×800, 8 GB eMMC, vendor **Linux 3.10.65**, no mainline support, Samsung S-Boot.
**Method:** every status claim was fetched on 2026-10-23; HTTP status is recorded in §2. Numbers not quoted
from one of those fetches are tagged **INFERENCE**.

---

## 1. Scope

Replace stock Android 5.1.1 with something else and keep the phone demonstrably usable. Options assessed:
Nura (= postmarketOS, renamed 2026), Droidian, Ubuntu Touch, Maemo Leste, Sailfish OS, LineageOS 14.1/15.1,
"direct" distros (Debian armhf / Arch Linux ARM / Alpine armv7), and a purpose-built lightweight configuration
(Nura or Alpine + Sxmo / console).

Four repo-verified facts drive every option:

| Constraint | Evidence | Consequence |
|---|---|---|
| Display stack is **fbdev only** | `kernel/arch/arm/configs/j1minilte_defconfig`: `# CONFIG_DRM is not set`, `CONFIG_FB_SCX35L=y`, `CONFIG_SPRDFB_GEN_PANEL=y`; driver in `kernel/drivers/video/sprdfb` | No KMS. Wayland compositors (sway/wlroots, Phosh, GNOME, Plasma, Lomiri) cannot drive this panel. X11 via `xf86-video-fbdev` can. |
| No GPU driver in the tree | `kernel/drivers/gpu/` = `drm`, `ion`, `host1x`, `sprd_iommu`, `vga`; no Mali symbol in the defconfig | No 3D on any Linux option; rendering is software (llvmpipe/swrast) — fine for 480×800 text/X, painful for GTK4/Qt6 shells. |
| Modem reachable only via SPRD IPC | `j1minilte_linux_defconfig`: `CONFIG_SIPC_LTE=y`, `CONFIG_SIPC_SETH`, `SIPC_SPIPE`, `SETH_RAWIP`; Android uses RIL blobs | Kernel plumbing exists; **no Linux userspace modem driver** exists. Calls/SMS out of scope for Linux options; IP over `seth` theoretically possible (**INFERENCE**). |
| Bootloader takes unsigned images, needs `SEANDROIDENFORCE` | `docs/adr/0002-os-track.md`; packer emits it | Flashing any option works via Odin/Heimdall; KNOX trips permanently. |

Samsung install method is uniform: `boot.img` (kernel + DTB from `device/dtb/stock/`) + rootfs → Heimdall/Odin or a TWRP recovery zip.

---

## 2. Verified sources (fetched 2026-10-23)

| URL | HTTP | Verified claim |
|---|---|---|
| https://postmarketos.org/ | 301 → nura.eco | project renamed; old domain redirects |
| https://nura.eco/blog/2026/09/27/nura-rename/ | 200 | rename announced 2026-09-27; new name **Nura**; `nura.eco` chosen because `nura.org` was taken |
| https://nura.eco/install/ | 200 | stable **v26.06**; "All images below use (close to) mainline kernels"; Galaxy S III (1 GB, armv7) ships v26.06 |
| https://docs.nura.eco/pmaports/main/device-categorization.html | 200 | *testing* needs close-to-mainline kernel + LLVM; *downstream* ports are "a step towards mainline", may be archived at any time, "often unable to support modern userspace components like Docker or systemd"; images only for main/community (+ selected testing) |
| https://wiki.nura.eco/wiki/Samsung_Galaxy_J1_mini_(samsung-j1minilte) | 200 (oldid 103349) | tested on this model but **"device package has not yet been added to the Nura repositories"**, status *"flash, boot bug"*; Downstream; kernel 3.10.65; screen/touch/USB-net work; storage/Wi-Fi/modem untested; flashing *partial* |
| https://wiki.nura.eco/wiki/Samsung_Galaxy_J1_mini_(samsung-j1mini3g) | 200 (oldid 101108) | sibling port **archived** (edited 2026-06-23); `flasher flash_rootfs` fails at 17 %, `flash_kernel` works; install via SD or Android-recovery zip; Wi-Fi needs `download`/`wcnd` blobs from `/system/bin` |
| https://wiki.nura.eco/wiki/Spreadtrum_SC9830 | 200 (oldid 103350) | SoC level: display/audio/video work; **Wi-Fi broken, Bluetooth broken**; modem and GPU untested |
| https://wiki.nura.eco/wiki/Installation | 200 (oldid 108743) | channels stable v26.06 / edge; pmbootstrap for *all* devices; recovery zip; warns calls may not work at all on downstream devices |
| https://gitlab.postmarketos.org/postmarketOS/pmaports/-/blob/main/README.md | 200 | pmaports description "Nura package build recipes"; archived devices live under `device/archived/` |
| https://droidian.org/index.xml | 200 | last blog post **2023-09-16**; no 2024–2026 posts |
| https://github.com/droidian/droidian/commits.atom | 200 | last commit **2024-06-09** |
| http://repo.droidian.org/ | 200 | root serves the **default nginx page**; `/droidian/` and `/droidian/dists/*/Release` return 404 → apt repo not published |
| https://ubports.com/blog | 200 | Ubuntu Touch **24.04-2.1 / 24.04-1.5** released 2026-10-16; Q&A 201 on 2026-10-17 |
| https://devices.ubuntu-touch.io/ | 200 | 111 ports (xenial 66, focal 15, **noble 30**); Samsung list has no j1minilte; only `j1xlte` = J1 2016 (Exynos) |
| https://maemo-leste.github.io/ | 200 | Devuan Daedalus (Debian Bookworm); repos for amd64/**armhf**/arm64; "all supported devices ship with recent mainline Linux kernels" |
| https://maemo-leste.github.io/maemo-leste-2025-daedalus-release.html | 200 | Daedalus release dated **2025-11-08**; NLnet funding; Qt6; Forgejo CI; Trixie port planned |
| https://sailfishos.org/ | 200 | commercial Jolla product; page last modified 2026-07-20 |
| https://forum.sailfishos.org/t/community-hardware-adaptations/14081 | 200 | community ports for **Sailfish 5.0.0** are all arm64 (Xperia/Fairphone/Volla/Xiaomi); Samsung entries stop at 4.x |
| https://blog.jolla.com/ | 200 | "This site will be archived" (2026-07-15); Sailfish 5.0 Tampella announced 2025-02-24 |
| https://lineageos.org/Changelog-32/ | 200 | 2026-10-11: 24.0 (Android 17) launching; 23.2/22.2 maintained; legacy **15.1** gets backported patches "through November 2025"; 4.4/4.9 kernels capped at 22.2; Samsung installs moved to samloader-rs |
| https://wiki.lineageos.org/devices/ | 200 | 596 device pages; **no j1minilte, no J105** |
| https://download.lineageos.org/api/v1/devices | 200 | build branches present include `22.2`; 14.1/15.1 are not build branches |
| https://www.debian.org/ports/arm/ | 200 | armhf is a fully supported Debian port (page built 2026-09-23) |
| https://archlinuxarm.org/ | 200 | rolling armv7hf (NEON) + aarch64, ©2009–2026 |
| https://alpinelinux.org/ | 200 | Alpine **3.24.3** released 2026-10-21; aports commits same day |
| https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/armv7/ | 200 | `alpine-minirootfs-3.24.3-armv7.tar.gz` published 2026-10-21 |
| https://halium.org/ + https://docs.halium.org/en/latest/ | 200 | Halium = Android HAL + libhybris; docs build metadata date **2023-02-15** |
| https://sxmo.org/ | 200 | Sxmo runs on Alpine **and** Nura; Wayland **and** Xorg (legacy) modes |
| https://github.com/NotNoelChannel/android_device_samsung_j1minilte | 200 | branches `cm-13.0`, `cm-14.1`, `lineage-15.1`; **158 tracked files** on cm-13.0, **9** on cm-14.1 |
| https://github.com/djeman/android_device_samsung_sharkls-common/tree/cm-14.1 | 200 | **251 files**, `patches/sprd-diff/*.diff`, `init.j3xnlte.rc`; j1minilte's cm-14.1 `lineage.dependencies` points here |
| https://github.com/djeman/android_kernel_samsung_sharkls | 200 | branches `cm-13.0`, `cm-14.1`, `lineage-15.1` |

---

## 3. Status snapshot

| Project | 2026 state | Evidence |
|---|---|---|
| **Nura** (ex-postmarketOS) | active, renamed 2026-09-27, stable v26.06 | nura.eco/install, rename post |
| **Droidian** | dormant: no posts since 2023-09, no commits since 2024-06, apt repo unpublished | droidian.org/index.xml, repo.droidian.org |
| **Ubuntu Touch / UBports** | very active, 24.04-2.1 on 2026-10-16 | ubports.com/blog |
| **Maemo Leste** | active, Daedalus 2025-11-08, NLnet-funded | maemo-leste.github.io |
| **Sailfish OS** | product alive (5.0, 2025-02); community porting thin, Jolla blog retiring | sailfishos.org, forum adaptations, blog.jolla.com |
| **LineageOS** | very active (24.0/Android 17), 3.10 kernels outside every supported branch | Changelog-32 |
| **Debian / Arch ARM / Alpine** | all three ship armv7 today | ports page, ALARM home, Alpine 3.24.3 tarball |

---

## 4. Option-by-option

### 4.1 Nura (postmarketOS) on the downstream 3.10 kernel

- **Status / arch:** active — v26.06 stable, edge rolling (https://nura.eco/install/); renamed 2026-09-27
  (https://nura.eco/blog/2026/09/27/nura-rename/). armv7 is a first-class target (S III, Tegra armv7 images).
- **Kernel requirement:** official images need close-to-mainline + LLVM (device-categorization doc); this port
  can only be **downstream** (3.10.65), explicitly a stepping stone that "might be moved to archived at any time".
- **Device state:** wiki page (oldid 103349) says tested on this exact model, package never merged, status
  *"flash, boot bug"*; screen, touch, USB-net work.
- **Min RAM:** 1 GB ships elsewhere in the project (S III) — **INFERENCE** that text/X fits, GNOME/Phosh would not.
- **Graphics on fbdev:** X11 only; the sibling's screenshots show XFCE4 and GNOME-on-X on the same SoC family.
  Telephony: none (SoC page: modem *untested*; no Linux SPRD modem driver).
- **Install:** `pmbootstrap init`/`install`, then `flasher flash_kernel`; rootfs via recovery zip or SD because
  `flash_rootfs` dies at 17 % on the sibling.
- **Effort:** **4–7 person-weeks** to a packaged, booting, X-capable image (**INFERENCE**: sibling package +
  local kernel with `j1minilte_defconfig` + wiki recipe); **+2–3 pw** to chase Wi-Fi blobs.
- **Risk / portfolio / "usable":** medium-high risk (quirky flash path, archivable category); high portfolio
  value (APKBUILD, deviceinfo, kernel package); usable = console/X, SSH over USB, storage, charging, reboots —
  not a phone.

### 4.2 Droidian (Halium + Debian)

- **Status:** dormant — last post 2023-09-16 (https://droidian.org/index.xml), last commit 2024-06-09
  (github.com/droidian/droidian), repo root now default nginx with `/droidian/` 404 (http://repo.droidian.org/).
- **Arch / kernel:** Debian armhf/arm64 userspace, but Halium requires an **Android base ROM** matching the
  Halium generation (https://halium.org/) — i.e. the whole §4.6 track first.
- **Min RAM:** 1 GB marginal for Phosh+Debian (**INFERENCE**). Graphics: not fbdev — libhybris/hwcomposer.
- **Telephony:** possible in principle (ofono + hybris RIL, its historical strength); needs RIL blobs from a
  base ROM that does not exist here.
- **Install:** Halium boot image + Debian rootfs; no Samsung tooling.
- **Effort / risk / portfolio:** **12–18 person-weeks** (**INFERENCE**) on an unmaintained distro with an
  offline archive; portfolio value low ("ported to a dead project").
- **"Usable again":** unreachable without §4.6; the distro adds nothing on top.

### 4.3 Ubuntu Touch (UBports, Halium)

- **Status:** strong — 24.04-2.1 and 24.04-1.5 shipped 2026-10-16 (https://ubports.com/blog).
- **Arch:** 111 ports (xenial 66 / focal 15 / noble 30); the armhf line is the old xenial one, noble ports are
  arm64 devices (**INFERENCE** from the device mix). No SC9830 device; the only "J1" is `j1xlte` (Exynos)
  (https://devices.ubuntu-touch.io/).
- **Kernel:** Halium port over an Android base ROM — again presupposes §4.6.
- **Min RAM:** Lomiri on 1 GB is below the comfort line (**INFERENCE**); no noble/armv7 port exists.
- **Graphics:** Lomiri is a Wayland/Mir compositor over hwcomposer, not fbdev. **Telephony:** ofono + RIL
  blobs — plausible *if* the base ROM lands, historically proven on hybris devices.
- **Install:** UBports installer or manual Halium install; Samsung path = Heimdall/Odin.
- **Effort / risk / portfolio:** **14–20 person-weeks** (**INFERENCE**), landing on an architecture UBports is
  retiring; medium portfolio (recognisable OS, but the interesting work is the base ROM).
- **"Usable again":** a real phone UI if everything lands; 1 GB makes it slow.

### 4.4 Maemo Leste (Devuan)

- **Status:** active and funded — Daedalus release 2025-11-08 on Devuan Daedalus/Bookworm, Qt6, Forgejo CI,
  NLnet money (https://maemo-leste.github.io/maemo-leste-2025-daedalus-release.html).
- **Arch:** armhf, arm64, amd64 repos (https://maemo-leste.github.io/).
- **Kernel:** "all supported devices ship with recent mainline Linux kernels" — no downstream story, and SC9830
  has no mainline support.
- **Min RAM:** born on the N900 (256 MB), so 1 GB is generous (**INFERENCE**).
- **Graphics:** best Linux fit — Maemo is X11 + Hildon, `xf86-video-fbdev` drives the panel, GLES optional.
  **Telephony:** ofono, but only for modems it has drivers for (N900, Motorola mapphones); no SPRD support.
- **Install:** their images target supported devices; for us, hand-built rootfs plus our own `boot.img`.
- **Effort / risk / portfolio:** **12–18 person-weeks** (**INFERENCE**: downstream kernel integration, Hildon
  packaging on armv7, display/touch glue, all out-of-tree); high risk (only SC9830 Leste user, no upstream path);
  good story, weak upstreaming.
- **"Usable again":** a coherent retro-computing handheld; no calls.

### 4.5 Sailfish OS (hybris)

- **Status:** the commercial OS is alive (Sailfish 5.0 Tampella, 2025-02-24; sailfishos.org updated 2026-07-20),
  but the community side thins: Jolla's blog is being archived (2026-07-15), `wiki.merproject.org` no longer
  resolves, and the 5.0 community-ports table is all arm64
  (https://forum.sailfishos.org/t/community-hardware-adaptations/14081).
- **Arch / kernel:** armv7hl existed through 4.x; no armv7 entry for 5.0. HADK/hybris wants an Android base plus
  adaptation packages, and the core is proprietary (https://docs.sailfishos.org/Develop/HW_Adaptation/).
- **Min RAM:** 1 GB was the Jolla Phone class; workable (**INFERENCE**). **Graphics:** hybris/hwcomposer, not fbdev.
- **Telephony:** ofono + hybris RIL — its strength, but only on a working base.
- **Install:** HADK-built image flashed over an Android base.
- **Effort / risk / portfolio:** **16–24 person-weeks** (**INFERENCE**) plus licensing friction for publishing
  images; very high risk (proprietary core, armv7 deprecation, no maintainer community); low portfolio value.
- **"Usable again":** a polished phone OS in theory; a dead end in practice.

### 4.6 LineageOS 14.1 (7.1.2), with 15.1 as the ceiling attempt

- **Status:** 14.1 is EOL; 15.1 survives only as a legacy *source* branch (backported patches "through November
  2025", https://lineageos.org/Changelog-32/). Current releases are 24.0/23.2/22.2; devices on 4.4/4.9 kernels
  are capped at 22.2, so a 3.10 kernel is outside every supported branch. Not an official device: 596 wiki
  pages, none is j1minilte (https://wiki.lineageos.org/devices/).
- **Kernel:** the vendor 3.10 tree — exactly what the hardware expects; local `kernel/` has
  `j1minilte_defconfig`, `djeman/android_kernel_samsung_sharkls` has cm-14.1 + lineage-15.1.
- **Existing base:** `NotNoelChannel/android_device_samsung_j1minilte` = **158-file cm-13.0 tree**, **9-file
  cm-14.1 skeleton** whose `lineage.dependencies` pulls `djeman/android_device_samsung_sharkls-common`
  (cm-14.1, **251 files**, `patches/sprd-diff/*.diff`, `init.j3xnlte.rc`), plus `lineage-15.1` branches.
- **Min RAM:** Android 7.1 on 1 GB was mainstream in 2016–17 (**INFERENCE**: comfortable with a lean, GApps-free
  build). **Graphics:** the only option with 3D — SurfaceFlinger + vendor hwcomposer + Mali-400 blobs.
  **Telephony:** RIL blobs + dual-SIM framework; the stock stack is the reference.
- **Install:** TWRP (built, unflashed) → flash `boot`/`system` via Odin/Heimdall; `SEANDROIDENFORCE` handled.
- **Effort:** **6–10 person-weeks** to booting 14.1 with display/touch/RIL/Wi-Fi; **+3–5 pw** for camera,
  sensors, stability (**INFERENCE**: basis = 158-file reference + 251-file common tree with SPRD patches +
  existing kernel; gaps = blob set, board config, boot bring-up).
- **Risk / portfolio:** medium (proven path for this SoC family, but blobs come from the stock dump and every fix
  is out-of-tree forever); medium as a "port", high as "the phone works again".
- **"Usable again":** daily-drivable phone — calls/SMS on both SIMs, Wi-Fi, camera, sane standby.

### 4.7 Direct distros: Debian armhf, Arch Linux ARM, Alpine armv7

- **Status:** all alive — Debian armhf is a fully supported port (https://www.debian.org/ports/arm/), ALARM builds
  armv7hf/NEON (https://archlinuxarm.org/), Alpine publishes `alpine-minirootfs-3.24.3-armv7.tar.gz` (2026-10-21,
  https://dl-cdn.alpinelinux.org/alpine/v3.24/releases/armv7/).
- **Kernel:** none ships an SC9830 kernel; you supply the vendor 3.10 tree, your config, initramfs and `boot.img`.
  armv7hf is correct for Cortex-A7 (NEON); never armel.
- **Min RAM:** console 128–256 MB, X11 + one app ~350–500 MB (**INFERENCE**); 1 GB is plenty.
- **Graphics / telephony:** X11 fbdev and console work, Wayland does not; no modem driver (ModemManager has no
  SPRD SIPC backend).
- **Install:** partition, untar rootfs, build kernel, pack `boot.img`, flash; TWRP for recovery.
- **Effort / risk / portfolio:** **8–14 person-weeks** for a polished image (kernel packaging, first boot, fbdev X,
  touch, Wi-Fi, updates) or **2–4 pw** console-only (**INFERENCE**); low technical risk, permanent maintenance
  burden; high portfolio value only if presented as a reproducible pipeline.
- **"Usable again":** a pocket Linux terminal / tiny X machine — honest and cheap.

### 4.8 Purpose-built lightweight: Nura + Sxmo, or Alpine + framebuffer UI

- **Status:** Sxmo is active and explicitly runs on Alpine and Nura, with Wayland **and** legacy Xorg modes
  (https://sxmo.org/); armv7 phones (PinePhone class) are its home ground.
- **Kernel:** inherits §4.1's downstream kernel. **Min RAM:** Sxmo targets low-power phones (PinePhone class, 2–3 GB), so 1 GB is plausible but below its tested floor (**INFERENCE**); the Xorg variant is the lighter choice.
- **Graphics:** must use the **Xorg** variant here; sway needs DRM. **Telephony:** Sxmo's scripted calls/SMS hooks
  are unavailable — no modem driver.
- **Install:** same pmbootstrap/Heimdall flow as §4.1 with `sxmo-*` packages instead of a desktop.
- **Effort / risk / portfolio:** **1–3 person-weeks** on top of §4.1 (or 2–4 pw standalone on Alpine)
  (**INFERENCE**); inherits §4.1's downstream risk; highest portfolio value per week — a 480×800 SSH-first
  terminal phone with hardware-key menus demos extremely well.
- **"Usable again":** a hackable pocket computer that boots fast; not a phone.

---

## 5. Weighted decision matrix

Weights sum to 100; scores 1 (bad) – 5 (good); weighted total ÷ 5 = score out of 100.

| Option | First boot 15 | Usable 15 | HW coverage 15 | Telephony 10 | 2026 health 15 | SC9830 fit 10 | Portfolio 10 | Risk/reversibility 10 | **Score** |
|---|---|---|---|---|---|---|---|---|---|
| **H. Nura/Alpine + Sxmo or console** | 4 | 4 | 4 | 1 | 3 | 3 | 5 | 4 | **71.0** |
| **A. Nura downstream, desktop-ish UI** | 4 | 3 | 4 | 1 | 3 | 3 | 5 | 4 | **68.0** |
| **F. LineageOS 14.1 from existing tree** | 3 | 4 | 5 | 4 | 2 | 2 | 3 | 3 | **66.0** |
| **G. Debian/Arch/Alpine direct** | 2 | 3 | 3 | 1 | 3 | 2 | 4 | 4 | **55.0** |
| **C. Ubuntu Touch (Halium)** | 1 | 2 | 3 | 3 | 4 | 1 | 4 | 4 | **54.0** |
| **D. Maemo Leste** | 2 | 2 | 3 | 1 | 3 | 1 | 4 | 4 | **50.0** |
| **B. Droidian** | 1 | 2 | 3 | 2 | 1 | 1 | 2 | 4 | **39.0** |
| **E. Sailfish OS** | 1 | 2 | 2 | 2 | 2 | 1 | 2 | 3 | **37.0** |

Score notes (all **INFERENCE** unless tied to a cited fact): *HW coverage* = display, touch, storage, USB-net with
known-good drivers — LineageOS 5 (vendor HAL/blob set covers camera, sensors, modem), Nura 4 (display/touch/USB-net
proven on the sibling, Wi-Fi *broken* at SoC level). *2026 health* = shipping, reviewing, likely to exist in two
years (§3 facts). *Telephony* = can calls/SMS ever work: LineageOS 4, Halium 2–3 (needs the same base + libhybris),
plain Linux 1. *Risk/reversibility* = return to stock via Odin, minus repartition work for Halium options.
Sensitivity: Halium options only beat plain Linux if telephony weight is ≥20 *and* the Android base is assumed
free; with telephony at 10 the ranking is stable for ±5 weight shifts.

---

## 6. Recommendation

**Do the Linux track first as a Nura downstream port with an Sxmo/console UI (H); treat LineageOS 14.1 (F) as the
second, telephony-bearing track.**

1. **Fastest credible artifact.** Kernel, defconfig, DTB and a sibling recipe exist; the wiki documents this exact
   model booting (screen/touch/USB-net) and records both failure modes (`flash_rootfs` at 17 %, *"flash, boot bug"*).
   A booting SSH-able Linux phone is 4–7 weeks (**INFERENCE**) and the only route to a publishable upstream-shape
   artifact (APKBUILD + deviceinfo + kernel package).
2. **Active upstream to cite.** Nura shipped v26.06, renamed in September 2026, and still accepts downstream ports
   while calling them a stepping stone — a checkable story, unlike Droidian (repo offline) or Sailfish (proprietary
   core, no armv7 ports).
3. **LineageOS is the only path to "phone".** It is also the best-evidenced Android option: 158-file reference
   tree, 9-file 14.1 skeleton wired to a 251-file common tree with the SPRD framework patches, and kernel branches
   for 14.1/15.1. Cost 6–10 weeks (**INFERENCE**), return = calls, SMS, data, camera, GPU.
4. **Reject the Halium family (B, C, E) on dependency grounds:** each needs an Android base ROM that does not exist,
   so their true cost is §4.6 *plus* 8–14 weeks, on a 1 GB armv7 device that current Ubuntu Touch does not target
   and Droidian no longer maintains.

Sequence (ADR-0002 gates preserved):

| Step | Work | Exit gate | Est. |
|---|---|---|---|
| 0 | Flash TWRP; prove Odin rollback to stock | recovery boots; stock restored once | 1 wk (TWRP built, unflashed) |
| 1 | `device-samsung-j1minilte` + kernel package from `kernel/` (3.10.65, `j1minilte_defconfig`) | `pmbootstrap install` builds; `flash_kernel` reaches initramfs | 2–3 pw |
| 2 | Rootfs: screen, touch, USB-net, storage, Xorg fbdev | SSH over USB; X on 480×800; three clean reboots | 2–4 pw |
| 3 | Sxmo (Xorg variant) or console UI; publish package + write-up | reproducible build script, screenshots, docs page | 1–3 pw |
| 4 | *(optional)* Wi-Fi via `download`/`wcnd` blobs or a libhybris-lite shim | scan + DHCP, or a written negative result | 2–3 pw |
| 5 | LineageOS 14.1: blob inventory → board config → SPRD patches → boot | calls/SMS on both SIMs, Wi-Fi, camera | 6–10 pw |

Portfolio packaging: public device package (reviewable), a script that reproduces the image, one boot log per
milestone (ADR-0002 §5), and an honest limitations page ("no calls, no 3D, fbdev-only X, downstream archivable").

---

## 7. What would change the recommendation

- **Calls/SMS become the top acceptance criterion** (the phone must replace a daily driver): flip to LineageOS-first.
  No Linux option can fix telephony without a modem driver.
- **A public LineageOS 14.1/15.1 build for j1minilte surfaces:** step 5 drops to near zero; spend the saved weeks
  on the Nura port instead.
- **Blob extraction fails** (incomplete `proprietary-files.txt` from the stock dump): F collapses into "another 15.1
  attempt"; keep Linux as primary and stop treating Android as the phone path.
- **Nura archives downstream support entirely** (explicitly allowed by the category doc; the sibling was archived
  2026-06-23): the port becomes self-hosted Alpine packaging — still viable, but option G rises.
- **A mainline SC9830 effort appears** (arm32 `ARCH_SPRD` work or a sharkls DT): unlocks DRM/lima, Wayland and
  Nura *testing* status — H becomes the clear multi-year winner.
- **A Halium 7.1 base for any SC9830 Samsung appears:** B/C drop from ~20 to ~6 weeks and Ubuntu Touch's active
  maintenance starts to outweigh the 1 GB/armhf penalty.
- **The device dies or the battery swells:** nothing here is worth doing; these artifacts stand alone.

---

## 8. Open items (cheap probes, not blockers)

1. Reproduce the j1minilte wiki's *"flash, boot bug"* locally (step 1); the page carries no boot log.
2. Diff the stock blob set (`/system/lib*`, `/vendor`, `modules/`) against cm-14.1 `proprietary-files.txt` before step 5.
3. Test if libhybris can consume the 5.1 hwcomposer on a 3.10 kernel without a full Halium port (telephony-only concern).
