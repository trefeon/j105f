# Track A — Android ROM port plan (j1minilte)

**Goal:** the newest Android that can actually run well on SC9830I / 1 GB RAM / Mali-400.
**Answer up front:** the highest Android any public build reached for this exact model is **LineageOS
14.1 (Android 7.1.2)** — an unofficial 2022 build whose download is already dead. **Android 8.1
(LineageOS 15.1) is the theoretical ceiling** built from source off the same-SoC sharkls trees (proven
on the J3, never on `j1minilte`); Android 9+ is impossible here — see `docs/adr/0002-os-track.md`.

Nothing is currently downloadable and nothing ever shipped officially for SM-J105F. This is a real
port, not a download.

## Inputs that already exist

| Input | Where | Note |
|---|---|---|
| Working recovery | `android/device/samsung/j1minilte` + CI artifacts | Escape hatch for every flash |
| Vendor kernel 3.10.65 | `kernel/` | `j1minilte_defconfig` already present; DTB byte-identical to stock |
| Stock firmware / system dump | `device/dumps/` (local, ignored), public dump of `J105FXXS0ARD2` | Blob source |
| Platform trees | `reference/` (local clone) | djeman `sharkls-common` + `j3xnlte` (LOS 15.1), `Galaxy-J105F-Resources` kernel + vendor |
| Hardware evidence | `device/evidence/` | Inputs, partitions, modem set |

## Version decision

| Candidate | Kernel | Verdict |
|---|---|---|
| CM 12.1 / 13 (5.1 / 6.0) | 3.10.65 | Easiest, snappiest; only worth it as a bring-up stepping stone |
| **LOS 14.1 (7.1.2)** | 3.10.x (sharkls cm-14.1 carries `j1minilte_defconfig`) | **Primary target** — the highest version ever built for this model (unofficial, 2022, link dead); best balance of app support and 1 GB RAM |
| LOS 15.1 (8.1) | 3.10.x (djeman sharkls, proven booting on J3 SC9830) | **Ceiling hypothesis** — source-only path; never built for `j1minilte`. Attempt only after 14.1 is stable |
| LOS 16+ (9+) | needs 4.4+/Treble/64-bit | Not feasible: 32-bit ARMv7 userspace, no `/vendor`/VNDK, no GSI |

## Work breakdown

Each task has an acceptance gate; no task is "done" on a compile alone.

### A1 — Device safety net (blocked on E2)
- Flash the custom TWRP, run the E3 matrix, prove rollback (ROADMAP E2–E4).
- Re-verify EFS/boot/recovery images and checksums on PC + microSD.
- **Gate:** recovery boots, rollback demonstrated.

### A2 — Blob inventory
- Extract `system/` from `J105FXXS0ARD2` (or a device dump) on a Linux box (`simg2img` + `ext4`).
- Build `proprietary-files.txt` from the `j3xnlte` template, pruned to what this unit actually loads
  (`getprop`, `dmesg`, `modules.txt` in `device/evidence/` are the source of truth).
- Keep blobs out of Git unless the licence allows redistribution; ship an extraction script instead.
- **Gate:** every blob has a provenance line and a licence verdict.

### A3 — Lineage device tree
- New tree (separate from the TWRP one): `android/device/samsung/j1minilte-lineage/` modeled on
  `j3xnlte` + `sharkls-common` (`lineage.mk`, `BoardConfigCommon`, `fstab.sc8830`, `sepolicy`,
  `init`, `keylayout`, `libshims`). NotNoelChannel publishes `android_device_samsung_j1minilte`
  (kernel/vendor too) — source only, never built or released; use it as the model-specific reference,
  the sharkls-common trees as the platform contract.
- Reuse this project's verified values: 16 MiB boot/recovery, 480×800, `sec_touchscreen`,
  `libsec-ril-dsds.so` (DSDS), `TW_*` only in the recovery variant.
- **Gate:** `breakfast j1minilte` configures without missing-variable errors.

### A4 — Kernel for the ROM
- Start from the cm-14.1 sharkls tree (`j1minilte_defconfig` exists there) or this vendor tree;
  build with `arm-eabi-4.8`, same geometry as `kernel/README.md`.
- First boot may use the vendor kernel unchanged — do not mix kernel bring-up with ROM bring-up.
- **Gate:** zImage + dt.img identical geometry to the recovery image; size < 16 MiB.

### A5 — Framework patches
- Apply `sharkls-common/patches/apply_sprd-diff.sh` (Sprd framework/AV/base diff) pinned to the
  manifest revision.
- **Gate:** the patch set applies cleanly at the pinned revision and is recorded in `BUILD_INFO`.

### A6 — Build environment
- AOSP 7.1 tree: ~150 GB disk, 16 GB RAM, Linux (WSL2 or a build VPS). GH Actions can run the build
  with swap (proven pattern in `recovery.yml`) but expect long jobs; keep ccache off for the first
  green build.
- Pin the manifest revision at first green sync; record it in `BUILD_INFO.txt`.
- **Gate:** clean runner produces `system.img` + `boot.img`.

### A7 — Bring-up order (one change, one boot, one log)
1. Display (sprdfb) → 2. Touch (MELFAS MCS8040L) → 3. ADB/RNDIS → 4. Storage/SD → 5. RIL/DSDS →
6. Wi-Fi (`sprdwl`/`sc2331` + firmware) → 7. Audio → 8. Camera → 9. Sensors → 10. GPS/Bluetooth.
- Capture `dmesg` + `logcat` per attempt; keep them under `docs/build-reports/`.
- **Gate per item:** evidence committed; unsupported items documented, never implied working.

### A8 — Daily-usable gate
- Three consecutive clean boots; calls/SMS/data on both SIM slots; Wi-Fi; camera; battery drain
  measured over 1 h idle; no watchdog reboots.
- **Gate:** explicit pass/fail table in `docs/delivery/`.

### A9 — Ceiling attempt (optional)
- Port `sharkls-common` + djeman lineage-15.1 kernel to `j1minilte`, reusing the 14.1 device tree and
  the A7 evidence. Only start after A8 passes; keep 14.1 artifacts as the fallback.

## Risks

| Risk | Impact | Control |
|---|---|---|
| No community ROM for this exact model | High | Port from the same-SoC J3 trees; treat every J105B/C statement as reference only |
| Proprietary blobs not redistributable | Medium | Extraction script + `proprietary-files.txt`; no blobs in Git |
| 1 GB RAM / 32-bit userspace | Medium | 14.1 first, measure; 15.1 only if 14.1 is stable |
| Modem/IMEI damage | Critical | EFS backup, never flash modem partitions |
| Build host too small | Medium | CI with swap, or a rented Linux builder; no local Windows build |
