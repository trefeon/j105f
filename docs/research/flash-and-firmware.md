# Flash & Firmware Dossier — SM-J105F/DS (`j1minilte`, SC9830I)

Research date **2026-10-23**; every URL was fetched from this workstation that day.
`[V]` = HTTP status **and** page/body content observed. `[I]` = inferred from verified evidence.
No checksum here is invented: each was printed by the serving page or computed by us on downloaded bytes.
No multi-GB archive was downloaded (largest fetch: 8 MB platform-tools).

## Scope

Stock firmware `J105FXXS0ARD2` (XID) and newer J105F builds; flash tools (Odin, Heimdall, Samsung USB
driver, platform-tools); device procedures (key combos, unlock status, PIT, `dd`/Odin/Heimdall, rollback);
recovery images for `j1minilte`; EFS/IMEI and anti-rollback exposure; an ordered safety checklist.

## Verified sources

| URL | Status | Access | Gave us |
|---|---|---|---|
| `samfrew.com/model/SM-J105F/` | 200, 318 KB | free | full J105F build list (machine-readable Next.js payload) |
| `samfrew.com/firmware/model/SM-J105F/region/XID` | 200, 26 KB | free | 9 XID builds, newest `J105FXXS0ARD2` |
| `samfrew.com/download/Galaxy__J1__mini__/v329/XID/J105FXXS0ARD2/J105FOLE0ARD2` | 200, 62 KB | free standard / premium fast | file name, exact byte size, changelist, CSC |
| `samfrew.com/download/Galaxy__J1__mini__/i4f1/XFV/J105FXXU0ARL3/J105FXFV0ARL4` | 200, 59 KB | same | newest J105F build anywhere |
| `sammobile.com/samsung/galaxy-j1-mini/firmware/SM-J105F/` (+ `/XID/`) | 200, 1.4 MB / 254 KB | free slow / premium fast | independent build dates; "9 builds" for XID |
| `samfw.com/firmware/SM-J105F[/XID][/J105FXXS0ARD2]`, `samfw.com/Odin/` | **403** Cloudflare "Just a moment..." | browser only | exists, unreadable to scripts |
| `firmware.mobi/`, `desktop.firmware.mobi/` | DNS ok (94.75.193.162), TCP 443 timeout | — | **down** |
| `samsungodin.com/` + `/download/Odin3_v3.13.1.zip` | 200 / 200, 3,517,718 B | free | Odin 3.09–3.13.1 mirror, bytes checksummed by us |
| `odinrom.com/odin/` | 200 | free | Odin 3.14.4 listing (page-stated MD5) |
| `technastic.com/odin-download-samsung-latest-all-versions/` | 200 | free | 3.14.1/3.14.4 list + BL/AP/CP/CSC/PIT semantics |
| `sammobile.com/apk/odin/` | **410 Gone** | — | SamMobile's Odin page removed |
| `samfrew.com/odin/` | **404** | — | no Odin page |
| `glassechidna.com.au/heimdall/` | 200 | free | official Heimdall site, last self-hosted = 1.4.0 |
| `git.sr.ht/~grimler/Heimdall` (`/refs`, `/refs/tags`, release zip) | **502** all attempts | — | current-source host **down** |
| `archlinux.org/packages/extra/x86_64/heimdall/` | 200 | free | `heimdall 2.2.2-1`, "grimler fork", built 2025-09-26 |
| `repology.org/api/v1/project/heimdall` | 200 | free | 2.2.2 current in Arch/Alpine/Fedora |
| `packages.msys2.org/package/mingw-w64-ucrt-x86_64-heimdall` | 200 | free | Windows build `r180.3997d5c-3` + SHA256 |
| `mirror.msys2.org/mingw/ucrt64/mingw-w64-ucrt-x86_64-heimdall-r180.3997d5c-3-any.pkg.tar.zst` | 200 | free | live Windows package URL |
| `raw.githubusercontent.com/Benjamin-Dobell/Heimdall/master/Win32/README.txt` | 200, 23 KB | free | Zadig/WinUSB procedure + **Vol-Down+Home+Power** |
| `manpages.debian.org/testing/heimdall-flash/heimdall.1.en.html` | 200 | free | `print-pit --no-reboot`, `--resume`, flash syntax |
| `dl.google.com/android/repository/platform-tools-latest-windows.zip` | 200, 8,044,989 B | free | `Pkg.Revision=37.0.1` (from its `source.properties`) |
| `developer.samsung.com/android-usb-driver` | 200, 83 KB | free, file link JS-gated | "Samsung Android USB Driver for Windows v1.9.5.0" |
| `zadig.akeo.ie/` | 200 | free | Zadig page carrying `2.9` and `2024.06.13` |
| `twrp.me/` | 200 | free | latest TWRP = **3.7.1** (2024-02-21) |
| `dl.twrp.me/j1minilte/`, `twrp.me/samsung/samsunggalaxyj1mini.html` | **404**, **404** | — | **no official TWRP** for this device |
| `github.com/NotNoelChannel/twrp_device_samsung_j1minilte` (raw BoardConfig/README/workflow) | 200 | free | unofficial tree, `TW_DEVICE_VERSION := 0_notnoelchannel`, twrp-6.0 manifest |
| `androidfilehost.com/?fid=529152257862700709` | 200 | free | `TWRP_3.0.3-0_SM-J105-V2.tar`, 14.7 MB, MD5 `49dec7566962610e658eab7b8c6f89b1` |
| `github.com/zacharee/Bifrost` (+releases), `bifrost.zwander.dev` | 200, latest tag `2.1.4` | free | FUS downloader, "method that doesn't require IMEIs" |
| `wiki.postmarketos.org/wiki/Samsung_Galaxy_J1_mini_(samsung-j1minilte)` | **301 → `wiki.nura.eco`**, then Anubis JS challenge | browser only | wiki domain changed; not script-readable |
| `xdaforums.com/t/…4108247`, `…3762572`, `…3545821` | **403** Cloudflare | browser only | project's historical Odin/TWRP links — unverifiable here |

## Findings

### 1. Firmware inventory (J105F)

PDA decoding, checked against the published dates of every build — char 8 = update class (`S` security /
`U` update), char 9 = **bootloader binary revision**, char 11 = year letter, char 12 = month letter
(`P`=2016, `Q`=2017, `R`=2018, `S`=2019; `A`=Jan … `L`=Dec), char 13 = minor revision:

| Build | Date | Changelist | Bin rev | Note |
|---|---|---|---|---|
| `J105FXXS0ARD2` | 2018-04-23 build / 2018-04-25 SamMobile | 9,723,235 | 0 | R=2018, D=April; `S` = security-only |
| `J105FXXS0ARA1` | 2018-01 | — | 0 | older security build |
| `J105FXXS0AQH2/AQG2/AQD1` | 2017-08/07/04 | — | 0 | security builds |
| `J105FXXU0APK1 … APB2` | 2016-11 … 2016-02 | — | 0 | original 5.1.1 line |
| `J105FXXU0ARL3` | **2018-12-26** | 15,048,295 | 0 | newest J105F build, **OJV multi-CSC only** |

- All ten XID builds SamFrew lists (SamMobile's archive shows nine) `[V]` (SamFrew XID region page). Newest XID = **the build already on this unit** (`ro.build.fingerprint=…/J105FXXS0ARD2:user/release-keys`; `androidboot.bootloader=J105FXXS0ARD2` in `device/evidence/cmdline.txt`). There is **no newer Indonesian firmware to move to**.
- XID download identity `[V]` (SamFrew ARD2 download page): `XID-J105FXXS0ARD2-20180508100607.zip`, **1,003,482,272 B** ("approximately 957.0 MB" on page), uploaded 2018-05-08, CSC `J105FOLE0ARD2`, Indonesia, 10 carriers. **No MD5/SHA is published anywhere** — see Gaps 8.
- Newest builds of any region `[V]` (SamFrew ARL3 download page): XFV `XFV-J105FXXU0ARL3-20190222102714.zip` 1,007,850,320 B (961.2 MB); AFR `AFR-J105FXXU0ARL3-20190311130410.zip` 1,056,071,040 B (1007.1 MB). The CSC half (`…OJW0ASA1`, `…XFV0ARL4`) is newer than the PDA half — normal for multi-CSC, not a mismatch.
- OJV `ARL3` regions `[V]`: AFR, MAT, MTZ, TMC, COR, XFE, TUR, MWD, XFV, XFA.
- Paywall model `[V from page text]`: SamFrew — "Fast download uses your premium allowance. **Standard download works without premium bandwidth.**"; SamMobile — "download it for free or at full speed with a Premium account." Both therefore offer a free (slower) path; neither requires an account to start it. Bifrost (FUS client) advertises no-IMEI downloads `[V]`; account-free status `[I]` (we did not pull 1 GB).

### 2. Safe CSC/PDA variants for SM-J105F/DS

- Flash **only `SM-J105F` packages** `[V locally]`. `J105B/H/M/Y` are other models; `J105H/B` (`j1mini3g`) is the 3G `ARCH_SCX30G` platform — incompatible images (see `exact-model-findings.md`).
- `/DS` is packaging only `[V]`: device reports `ro.product.name=j1miniltexx`, `ro.multisim.simslotcount=2`, while every firmware on the SamFrew/SamMobile listings is model `SM-J105F`.
- Region: `XID` is factory CSC. Other J105F CSCs flash fine and re-brand the device; staying on `XID` is the conservative choice because the EFS/NV data and the 2026-08-12 rollback set were captured there.
- Odin slots `[V, technastic Odin guide]`: `BL` bootloader, `AP` PDA/system+recovery, `CP` modem, `CSC` region data. `CSC` wipes userdata, `HOME_CSC` preserves it `[I — widely documented, not re-verified this pass]`. Never enable `Re-Partition`/`NAND Erase` without a PIT and a reason.

### 3. Flash tools

**Odin** — proprietary, never published by Samsung; every download is a third-party mirror `[V]`
(no samsung.com distribution; SamMobile's own Odin page is now 410).

| Version | Host | Evidence |
|---|---|---|
| 3.13.1 | `samsungodin.com/download/Odin3_v3.13.1.zip` | downloaded 3,517,718 B; **sha256 `056aeb87bfc5b7b05abbe4b287c6b494e1c5a660866f14068f8afaffb1ad4933`**, md5 `3ef8aa9709e733b32d6ddc66aaeaaded` (our computation; mirror-specific) |
| 3.14.4 | `odinrom.com/odin/` | page states 4.43 MB, MD5 `096537A9D640C8076A168A58D2A5AFAE` — **page-stated only** (its download route 404'd) |
| 3.14.1 / 3.14.4 | `technastic.com` listing | live list; 3.14.4 zip URL now 404 |
| 3.10.7 | — | **no live verified host** (Gap 4) |

Use **3.13.1**: byte-verified above, already the project's target version
(`docs/plans/device-test-checklist.md`), and 3.14.x adds nothing for a 2016 device. Odin needs the
**Samsung USB driver**, not WinUSB.

**Heimdall** — MIT, same "Odin 3 / Loke" protocol over libusb `[V, glassechidna.com.au/heimdall/ + Heimdall Win32 README]`.

- Last self-hosted binary **1.4.0** (site links a bitbucket win32 zip; direct zip HEAD 403 to scripts, downloads page 200). Current maintained line **2.2.2**, "grimler fork", upstream `https://git.sr.ht/~grimler/Heimdall` — that host answered **502 on every request today**, so no upstream tarball could be checksummed.
- Verifiable Windows binary today: MSYS2 `mingw-w64-ucrt-x86_64-heimdall` `r180.3997d5c-3`, **sha256 `e3baf9fd2f16a42fb1608f58590e704189abf290ea8a7d59166bda66acdbff0b`** (printed by packages.msys2.org); package URL live; install via `pacman -S mingw-w64-ucrt-x86_64-heimdall`.
- Device coverage: no per-device list — anything that boots "Loke"/download mode. Expected PIT names here: `KERNEL`, `RECOVERY`, `SYSTEM` `[I, pending print-pit]`.
- **Windows driver model — the real constraint** `[V, Heimdall Win32 README]`: boot download mode → plug in → run `zadig.exe` → *Options → List All Devices* → pick **"Samsung USB Composite Device"** → *Install Driver* (WinUSB). This **replaces** Samsung's composite driver, so **Odin stops working** until reverted (same README: Device Manager → "Libusb (WinUSB) devices" → *Update Driver* → pick the original Samsung Composite driver). Use one tool per session, or two machines.
- Zadig: `zadig.akeo.ie` live with `2.9` / `2024.06.13` (latest). Heimdall ≤1.4.x bundles `zadig.exe`; 2.x does not.
- Syntax `[V, heimdall(1)]`: `heimdall print-pit --no-reboot` → continue with `--resume`; `heimdall flash --RECOVERY recovery.img --no-reboot`. Firmware `.tar.md5` must be unpacked first — Heimdall takes raw images.
- Known-issue status for SC9830 / 2016 bootloaders: **not established**. Upstream tracker unreachable (502) and XDA is 403 to scripts. Two failure classes exist in the wild and fit the driver model — "device not enumerated" (wrong driver bound) and "PIT transfer not confirmed" (cable/port/hub) — but neither is verified for this unit. Treat Heimdall as **unproven here** (Gap 3, R6).

**Samsung USB driver** — `developer.samsung.com/android-usb-driver` states **"Samsung Android USB Driver
for Windows v1.9.5.0"** `[V]`. The download button is JS-driven; no direct `.zip`/`.exe` URL resolved,
and guessed `/sd2/usb_driver/…` paths all 404 (Gap 5).

**Platform-tools** — `platform-tools-latest-windows.zip`, 8,044,989 B, `Pkg.Revision=37.0.1`, ships
`adb.exe` + `fastboot.exe` `[V, from the zip's own source.properties]`. `fastboot` is irrelevant here:
Samsung 2016 bootloaders expose download mode only, not fastboot `[I]`.

### 4. Device procedures

**Key combos** — download mode `[V, Heimdall Win32 README: "holding Volume Down + Home + Power"]`, then
confirm the warning with `Volume Up`. Recovery = `Volume Up + Home + Power`
`[project-documented in docs/plans/device-test-checklist.md; symmetric mapping, not independently re-verified]`.
Third route, already exercised on this unit: `adb reboot recovery` / `adb reboot download`, and TWRP's
Reboot menu offers download mode (`TW_HAS_DOWNLOAD_MODE := true`, NotNoelChannel `BoardConfig.mk`) `[V]`.

**Bootloader unlock** — none applies `[V locally + I]`. No OEM-unlock toggle, no `fastboot oem unlock`;
the chain is S-Boot (`SBOOT`/`SBOOT2` = `mmcblk0p1`/`p2`), which accepts unsigned images and prints the
red `RECOVERY IS NOT SEANDROID ENFORCING` banner instead of blocking. The practical constraint is the
warranty bit, not unlocking.

**PIT retrieval** `[V syntax; capture still outstanding — ROADMAP A3]`:

```
# phone: Power off → Vol-Down + Home + Power → Download mode → USB
heimdall print-pit --no-reboot --verbose > pit-J105F.txt
```

Live partition map (`device/evidence/byname.txt`, `partitions.txt`) — authoritative for this unit:

| by-name | dev | size | role |
|---|---|---|---|
| `SBOOT` / `SBOOT2` | p1 / p2 | 2048 KiB each | Spreadtrum bootloader — do not touch |
| `l_fixnv1/2`, `l_runtimenv1/2`, `l_modem`, `l_ldsp`, `l_gdsp`, `l_warm` | p3/4/12/13, p8, p7, p9, p10 | 1–16 MiB | LTE modem/NV firmware (closed) |
| `efs` | **p17** | 20,480 KiB | IMEI/NV identity |
| `prodnv` | **p18** | 5,120 KiB | product/NV data |
| `KERNEL` | **p20** | 16,384 KiB (**16 MiB**) | boot image |
| `RECOVERY` | **p21** | 16,384 KiB (**16 MiB**) | recovery image |
| `SYSTEM` | **p25** | 2,199,552 KiB (2148 MiB) | system |
| `HIDDEN` | p26 | 40,960 KiB | preload |
| `userdata` | p27 | 5,054,464 KiB (4936 MiB) | data |

The unofficial tree's `BOARD_BOOTIMAGE_PARTITION_SIZE`/`…RECOVERY…` say **20971520** — wrong by 4 MiB for
this unit; 16,777,216 B is correct (ROADMAP C4/A4; the 2026-08-12 dumps are exactly 16,777,216 B).

**Three flash paths, ranked**

1. **`dd` from the existing TWRP** (proven, no PC driver risk):
   ```
   adb push recovery.img /external_sd/
   adb shell "dd if=/external_sd/recovery.img of=/dev/block/mmcblk0p21 bs=4096"
   adb shell "dd if=/dev/block/mmcblk0p21 bs=4096 | sha256sum"   # read-back check
   ```
   Same for `KERNEL` → `mmcblk0p20`; `SYSTEM` → `mmcblk0p25` only from a rootfs you built, unmounted.
2. **Odin (Windows + Samsung driver)** — `AP` = `recovery.tar` or `recovery.tar.md5`; leave
   `Re-Partition`/`NAND Erase` off. `Auto Reboot` off for recovery flashes `[I — stops the stock system
   from immediately restoring stock recovery]`.
3. **Heimdall** — `heimdall flash --RECOVERY recovery.img --no-reboot`. Unproven here; requires
   switching the Windows driver to WinUSB, which breaks Odin until reverted.

**Rollback** — set exists (2026-08-12): `recovery_stock.img` (p21, 16,777,216 B), `boot_stock.img`
(p20, 16,777,216 B), `efs.img` (p17, 20,971,520 B), `prodnv.img` (p18, 5,242,880 B), plus a TWRP
System/Data backup on the PC. Last resort = four-file XID package via Odin (`BL`/`AP`/`CP`/`CSC`).

### 5. Recovery images

- **Official TWRP: none** `[V]` — `dl.twrp.me/j1minilte/` and the J1 mini device page both 404. Upstream's latest release is 3.7.1 (2024-02-21).
- **Unofficial maintained tree**: `NotNoelChannel/twrp_device_samsung_j1minilte`, last push 2024-05-12, **no GitHub releases** (`[]`) — no prebuilt image published there `[V]`. `BoardConfig.mk` sets `TW_DEVICE_VERSION := 0_notnoelchannel`, builds from `minimal-manifest-twrp/platform_manifest_twrp_omni` branch `twrp-6.0`, uses `BOARD_CUSTOM_RECOVERY_KEYMAPPING` and `BOARD_HAS_NO_SELECT_BUTTON := true`. Its README mislabels the device "Galaxy J1 Nxt"; the tree is the `j1minilte` one.
- **What is on the phone**: TWRP reports `3.7.0_9-0-notnoelchannel` (`device/evidence/stock-backup/CHECKSUMS.sha256:3`). `-0_notnoelchannel` is exactly `TW_DEVICE_VERSION` `[V]`; the `_9` suffix is TWRP's branch tag `[I]`. Corroborated by `adb root` working and four `dd` dumps succeeding.
- **Historic public image, still downloadable** `[V]`: `TWRP_3.0.3-0_SM-J105-V2.tar` (AFH fid `529152257862700709`), 14.7 MB, uploaded 2017-02-05, **MD5 `49dec7566962610e658eab7b8c6f89b1`** (page-printed). Quirky/old — rollback of last resort.
- **This project's build** `[V locally]`: `recovery.img` 11,884,544 B, sha256 `3651e105319cac67fbc78db9d10535d4ffe0a7c3751a2a76fbca1e766232bf4a`; `recovery.tar` sha256 `8229815726651f39e8fe78246375e90b467b25892ec5613e5b0cd484c7c98998`. Under the 16 MiB gate, not flashed.
- Philz/CWM: no `j1minilte` build in any verified source — **absence of evidence**, not proven absence.

### 6. EFS/IMEI and NV

- `efs` = `mmcblk0p17`, 20 MiB, backed up (`efs.img` 20,971,520 B, sha256 `a8c006758b060d0a8142e9a98a965e12d1032285b048be0c1b797bb35aa7070b`) together with `prodnv` (p18). Together they carry identity/NV data on Spreadtrum Samsung devices `[V backup; I for the prodnv split]`.
- Back up `efs`, `prodnv` **and** the LTE NV set (`l_fixnv1/2`, `l_runtimenv1/2`) before any full firmware flash. Never write another device's `efs` — it carries a different IMEI.
- A full CSC flash can overwrite EFS-adjacent data on some Samsung models; on this unit a plain `AP` flash does not `[I]`. Restore order after a bad flash: stock CSC → `dd` back `efs`/`prodnv` → verify IMEI in Settings → About, not only in `getprop`.
- TWRP's "EFS" backup entry can capture only the mount, not the raw partition — the raw `dd` images in `stock-backup/` are the authoritative copies.

### 7. Anti-rollback and fuse exposure

- **Binary revision = 0 for every J105F build ever published** (the ten XID builds SamFrew lists + ARL3) `[V by enumeration]` → no pair of J105F firmwares can trip a "SW REV. CHECK FAIL" downgrade lock. Cross-model flashing is the realistic brick path, not ARB.
- **KNOX warranty bit / eFuse**: `getprop ro.warranty_bit` returned `unknown` on this unit (`device/evidence/getprop.txt:849`) — not exposed to the running TWRP or not set. No verified source establishes eFuse behaviour for SC9830I J1 mini; ADR-0002's "KNOX bit trips permanently" is an **assertion, not evidence**. Either way it is cosmetic on this device (no KNOX features in use).
- **Signature enforcement**: Odin accepts an unsigned locally built recovery here (community 3.0.3-0 and this project's builds) `[V locally]`. Whether `KERNEL` enforces signature ("SECURE FAIL: KERNEL") is **unverified** — hence `boot_stock.img` on the microSD before any boot experiment.
- No AVB/`vbmeta` partition exists (5.1.1 era) `[I from partition map]`.

## Toolchain acquisition state — 2026-11-24

Re-checked live; artifacts staged in `reference/tools/flash/` (gitignored) with `SHA256SUMS`, and
fetchable/verifiable via `bash tools/fetch-flash-tools.sh [--check]`.

| Artifact | Source | Bytes | SHA-256 | State |
|---|---|---|---|---|
| Odin 3.13.1 | `samsungodin.com/download/Odin3_v3.13.1.zip` | 3,517,718 | `056aeb87…4933` | staged; byte-identical to the 2026-10-23 fetch |
| Odin 3.14.4 | `odindownload.com/download/Odin3_v3.14.4.zip` | 4,510,482 | `a8822952…d515` | staged; mirror repack (odinrom.com prints MD5 `096537A9…` for its own repack) |
| Samsung USB driver 1.9.5.0 | `developer.samsung.com/SDP/file/a2fcaf64-7aa3-49f7-b06f-9e646590d528` | 37,216,544 | `0ecc9e47…4a20` | staged; NSIS, `ss_bus.inf` + `ss_mdm*.inf` with `.cat` dated 2026-04-23 |
| Heimdall MSYS2 r180.3997d5c-3 | `mirror.msys2.org/mingw/ucrt64/…-any.pkg.tar.zst` | 270,792 | `e3baf9fd…ff0b` | staged; `heimdall.exe` 497,805 B `cef77a0e…8dff`, PE32+ x86-64, libusb-1.0.30 compiled in |
| Zadig 2.9 (libwdi v1.5.1) | `github.com/pbatard/libwdi/releases/download/v1.5.1/zadig-2.9.exe` | 5,334,088 | `4ecaa95d…039b` | staged; only for the Heimdall/WinUSB path |
| platform-tools 37.0.1 | `dl.google.com/android/repository/platform-tools-latest-windows.zip` | 8,044,989 | — | already vendored at `tools/platform-tools/` |
| Bifrost 2.1.4 | `github.com/zacharee/Bifrost/releases` (windows-amd64 zip) | 110,848,760 | — | not fetched; FUS downloader, no IMEI needed |
| TWRP 3.0.3-0 fallback tar | `androidfilehost.com/?fid=529152257862700709` | 14.7 MB | MD5 `49dec756…89b1` | not fetched (AFH session); optional |
| Stock firmware `J105FXXS0ARD2` | SamFrew download page | 1,003,482,272 | none published | not fetched; free path is browser/captcha-gated |

**Filter finding.** `samsungodin.com/download/Odin3_v3.13.1.zip` comes back on this workstation as a
197,169 B HTML block page (Kaspersky web filter), not the zip. The same URL fetched from an unfiltered
host returns exactly 3,517,718 B / `056aeb87…4933` — the artifact recorded on 2026-10-23. The fetch
script detects the HTML case, deletes the file, and points at the copy-from-elsewhere route.

**Driver link resolved.** The 2026-10-23 page gated the driver behind JS; the current page exposes
`/SDP/file/a2fcaf64-…` directly, so the driver is checksummable (row above).

**SamFrew free download** answers a non-browser client with a 5.6 KB page and no `.zip` link — firmware
acquisition stays manual (browser, 1 GB) or through Bifrost's FUS path.

**Odin 3.13.1 inner files** (for comparing repacks): `Odin3 v3.13.1.exe` 3,172,864 B `370b9750…0d35`,
`SS_DL.dll` 2,555,904 B `66047e60…4d2c`. The exe's embedded PDB path reads `Odin3 v3.07.pdb` (Samsung
never renamed the project), so that string is not a version indicator.

**Linux path** (no Zadig, no Samsung driver): Ubuntu 24.04.5 offers `heimdall-flash 2.0.2-2build2`
(candidate checked on a 24.04.5 host); MSYS2/Arch track the grimler fork at 2.2.2.

## Procedure checklists

### A. Pre-flight (before touching anything)

1. Confirm identity: `adb shell getprop ro.product.device ro.boot.bootloader` → `j1minilte`, `J105FXXS0ARD2`.
2. Verify the rollback set: `sha256sum -c device/evidence/stock-backup/CHECKSUMS.sha256` (4 images, sizes §4).
   **No verified backup → no flash.**
3. Copy `recovery_stock.img`, `boot_stock.img`, `efs.img`, `prodnv.img` to the microSD root as well as the PC.
4. Verify the image to write: size `< 16,777,216 B`, hash matches the build record (`3651e105…` for TWRP).
5. Battery ≥ 60 %, known-good **data** cable, rear USB-2.0 port, no hub.
6. Choose **one** host path for the session (`dd` / Odin / Heimdall) — Odin↔Heimdall needs a driver swap.

### B. Recovery or KERNEL flash via TWRP `dd` (proven path)

1. `adb reboot recovery` (or Vol-Up + Home + Power).
2. `adb push <image> /external_sd/` then `adb shell "sha256sum /external_sd/<image>"`.
3. `adb shell "dd if=/external_sd/<image> of=/dev/block/mmcblk0p21 bs=4096"` (RECOVERY) or `…p20` (KERNEL).
4. Read back: `adb shell "dd if=/dev/block/mmcblk0p21 bs=4096 | sha256sum"` — must equal the source hash.
5. `adb reboot recovery`; confirm the splash/version string on screen.
6. Record tool, image hash, result, timestamp in `docs/delivery/execution-log.md`.

### C. Stock restore via Odin (last resort)

1. Extract the four-file XID package; `HOME_CSC` only if data must survive.
2. Odin 3.13.1 → each file into its slot; `F. Reset Time` on; avoid `Re-Partition`/`NAND Erase`.
3. Flash → wait for `PASS!` → boot → verify IMEI and CSC (`*#1234#` / Settings → About).
4. Blank IMEI → restore `efs.img` + `prodnv.img` by `dd` from TWRP → reboot → re-check.

### D. `heimdall print-pit` (outstanding, ROADMAP A3)

1. Download mode → `heimdall print-pit --no-reboot --verbose > pit-J105F.txt` → save under `docs/`.
2. Reconcile PIT names/sizes against `byname.txt` + `partitions.txt`; expect `KERNEL` 16 MiB, `RECOVERY` 16 MiB.
3. Record any Heimdall error verbatim — that is what converts §3's "unproven" into a fact.

## Risk notes

| ID | Risk | Evidence | Mitigation |
|---|---|---|---|
| R1 | BoardConfig claims 20 MiB partitions; hardware is **16 MiB** | p20/p21 = 16,384 KiB; dumps exactly 16,777,216 B | Size-gate every image at 16,777,216 B |
| R2 | EFS/prodnv loss = permanently broken IMEI | device-unique NV; closed modem firmware | raw `dd` backups on microSD + PC, verified |
| R3 | Wrong-model firmware (J105B/H/M/Y) = hard brick | J105H is `ARCH_SCX30G` 3G platform | `SM-J105F` packages only |
| R4 | Odin tar rebuilt from a stale image | ROADMAP 2026-08-14 correction (stale `9869d726`) | re-hash artifacts against `SHA256SUMS` |
| R5 | Zadig/WinUSB for Heimdall breaks Odin | Heimdall Win32 README install/uninstall steps | one tool per session; document the revert |
| R6 | Heimdall unproven on this bootloader | upstream 502, XDA 403 | prefer `dd`/Odin; Heimdall experimental |
| R7 | No published checksum for stock firmware | none on SamFrew/SamMobile | trust TLS + name/size match (1,003,482,272 B) |
| R8 | Warranty bit may trip permanently | `ro.warranty_bit=unknown`; ADR-0002 assertion | accept as cosmetic; not a blocker |
| R9 | No official TWRP → no upstream fixes | `dl.twrp.me/j1minilte/` 404 | keep the reproducible build + device tree |

## Gaps (account-gated / unavailable / unverified)

1. **SamFw** (`samfw.com/firmware/SM-J105F…`, `/Odin/`) — 403 Cloudflare on every URL. Browser-reachable
   only; nothing sourced from it here.
2. **firmware.mobi** — DNS resolves, TCP 443 times out on apex and `desktop.`. **Down.**
3. **Heimdall upstream** (`git.sr.ht/~grimler/Heimdall`, refs and release paths) — **502** throughout.
   2.2.2 existence is established indirectly (Arch 2.2.2-1, Repology, MSYS2 r180).
4. **Odin 3.10.7** — no live verified host (samsungodin stops at 3.13.1; SamMobile 410; SamFrew none).
5. **Samsung USB driver file** — resolved 2026-11-24: direct `/SDP/file/a2fcaf64-…` URL and SHA-256 in
   *Toolchain acquisition state* above (the 2026-10-23 page gated it behind JS).
6. **XDA threads** (4108247, 3762572, 3545821) — 403 to scripts; browser-only.
7. **postmarketOS wiki** — 301s to `wiki.nura.eco` behind an Anubis proof-of-work challenge, including
   `api.php`. Not usable as evidence.
8. **No stock-firmware checksum exists** on any verified page — any quoted MD5 for `J105FXXS0ARD2` is
   unverifiable.
9. **PIT capture** for this unit outstanding (ROADMAP A3); the table in §4 is the live `by-name` map,
   expected to match the PIT but not the PIT itself.
10. **Philz/CWM** for `j1minilte`: none found (absence of evidence).

## Sources

30 URLs in **Verified sources**, all fetched 2026-10-23. Local evidence:
`device/evidence/{byname,partitions,getprop,cmdline}.txt`,
`device/evidence/stock-backup/{README.md,CHECKSUMS.sha256}`,
`device/evidence/build-artifacts/twrp-j1minilte/SHA256SUMS`, `device/identity.md`,
`docs/delivery/ROADMAP.md` (A3/A4/C3/C4/E1), `docs/plans/device-test-checklist.md`, `docs/adr/0002-os-track.md`.
Cross-reference: `docs/research/exact-model-findings.md` — the SC9830I-vs-sc8830 identification that makes
"flash only J105F firmware" a hard rule.
