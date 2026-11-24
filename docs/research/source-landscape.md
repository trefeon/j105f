# Source landscape — j1minilte (SM-J105F/DS, SC9830I / SCX35L, sharkls)

> **2026-11-24 — 3G material quarantined.** Any `j1mini3g` (SCX30G) source, config or
> package referenced below was moved to `.reference_delete/` (gitignored); the paths no longer
> exist in `reference/`. Do not rebuild or re-pin them for this device. Allow-list and hard rule:
> `docs/research/lte-models.md`; reusable recipe shape: same file §5.


**Verified:** 2026-10-23. Every row below was checked by `git ls-remote`, a shallow/blobless
clone (`git ls-tree`, `git show HEAD:<path>`), a raw fetch, or a GitLab API call — never from
memory. Anything not directly observed is marked `[INFERENCE]`.

**Cost note:** unauthenticated GitHub API quota was exhausted mid-pass (60 req/h, `remaining: 0`).
Repo sizes that came from an early `GET /users/<u>/repos` or `GET /repos/<r>` are quoted as
"GitHub size"; the rest are marked `n/m` (not measured) and carry a measured file/pack count
instead. GitLab (Nura) API was unlimited and used for all pmaports/Nura facts.

---

## 1. Scope

1. Kernel candidates: vendored 3.10.65 in this repo; IKGapirov `android_kernel_samsung_j1mini3g`;
   the cm-14.1 `sharkls` 3.10.100 tree that carries a native `j1minilte_defconfig`;
   a stock MayuriLabs tree; every other j1minilte kernel repo found.
2. Device trees: `NotNoelChannel/android_device_samsung_j1minilte` (all four branches), the
   standalone TWRP tree, `sharkls-common`, and SC9830 sibling trees usable as bases.
3. Vendor blobs: TheMuppets and every other Samsung/SPRD vendor repo reachable today.
4. Manifests: LineageOS 14.1/15.1, minimal-manifest-twrp, AOSP 7.1.2 tags.
5. Assessment: best base per track (Linux/Nura, LineageOS 14.1) and the exact gaps.

## 2. Verification method

- `git ls-remote --heads <url>` for existence + exact branch SHA (all rows).
- `git clone --depth 1 --filter=blob:none --no-checkout` + `git ls-tree -r --name-only` for tree
  contents and file counts; `git show HEAD:<file>` for content (lazy blob fetch).
- Raw URL fetches for `Makefile`, defconfigs, `BoardConfig.mk`, fstabs, `deviceinfo`, `APKBUILD`.
- SHA-256 comparison of defconfigs across trees (`sha256sum`, with CRLF normalisation).
- Repo "size" = GitHub-reported size in KB (git object size) when available.

---

## 3. Verified sources

### 3.1 Kernel trees

| URL | branch/commit | size | license | contents | verified |
|---|---|---|---|---|---|
| this repo `kernel/` | local commit `38837a6` tree | 3.10.65 | GPL-2.0 (`COPYING`) + `NOTICE.md` | Vendor SM-J105F kernel. `j1minilte_defconfig` (3516 lines, **CRLF**) + `j1minilte_linux_defconfig` (3523 lines, LF). 5 board DTS (`sprd-scx35l_sharkls_j1minilte_rev00..04.dts`) + 5 j1minilte panel dtsi. Defconfig sha256 (CRLF-stripped) `bd1bb9e3…` | yes |
| github.com/IKGapirov/android_kernel_samsung_j1mini3g | default `android-5.1` `a9699b4a97a13b003aa070c5f097cdcc7da22aa3`; `cm-14.1` `6a377f7c43a84b578df39300dcce9fb9cb387a21`; `lineage-15.1` `d5bfac8c3f67502146fc9a63fb6e396cb80c48b8`; `cm-13.0`/`cm-12.1` `11c626c8…` | 134,235 KB | GPL-2.0 (`COPYING`) | `cm-14.1`=3.10.**106**, 45,291 files; `android-5.1`=3.10.65. Defconfigs: `j1mini3g-dt_defconfig` (3656 l), `lineage_j1mini3g_defconfig` (3664 l). **No j1minilte defconfig**; only 2 j1minilte *panel* dtsi, no board DTS | yes |
| github.com/djeman/android_kernel_samsung_sharkls | `cm-14.1` `0502c3a5bb4de36a399ad075fe945761428a5a2c` (2020-01-03); `cm-13.0` `3085a87e…`; `lineage-15.1` `048746da…` | 134,014 KB | GPL-2.0 | 3.10.**100**, 44,962 files. Defconfigs: `j3xlte`, `j3xlte_permissive`, `j3xnlte`, `j3xnlte_permissive`, `old_j3xnlte` — **no j1minilte defconfig**. j1minilte board DTS rev00–04 *do* exist | yes |
| github.com/Galaxy-J105F-Resources/kernel_samsung_sharkls | `cm-14.1` `1df22d20250a335561f5f2bebd2fe95f62c2f4ee` (HEAD author `dodyirawan85`, 2022-02-19) | 627,345 KB | `COPYING`; GitHub license field `Other/NOASSERTION` | 3.10.100, 45,114 files. **Native `j1minilte_defconfig`** (505-line savedefconfig) + j3 defconfigs + j1minilte DTS. History: djeman `0502c3a` then `dodyirawan85` "configs: Initial/Regenerate/Import j1minilte changes", "external_module: Drop wifi drivers", "security: Make Always Enforcing Configurable" | yes |
| github.com/MayuriLabs/android_kernel_samsung_j1minilte | `master` `5f4f03bd4899c988d33302b0d7543ff8a0694996` (2017-05-09, "Initial Import From SM-J105F_SEA_LL_Opensource") | 132,573 KB | GPL-2.0 | 3.10.65, 45,083 files, `j1minilte_defconfig` 3512 lines with `CONFIG_LOCALVERSION="-JohnKernel_v1"`; 11 j1minilte DTS paths | yes |
| github.com/TeamWin/android_kernel_samsung_j1minilte | `android-5.1` `7641d1bbd0f8ed29595fd4d1fab55741f36bcd9a` | n/m (45,071 files) | GPL-2.0 | 3.10.65 + `j1minilte_defconfig`; upstream TWRP-side kernel mirror | yes |
| github.com/NotNoelChannel/android_kernel_samsung_j1minilte | `cm-14.1` `3127397b465d223da75a51095e21d447a8d2d995` (3.10.**94**); `android-7.1` `56faf0b7…` (3.10.66); `android-6.0` `5642844b…`; `recovery` `4fdbbff8dd7a5db9ec1c6fc5cd9d943c76a92019` (3.10.65) | 142,653 KB | GPL-2.0 | j1minilte defconfig in every branch (3.10.94 one = 3516 lines; differs from ours in **16 lines** after CRLF strip: F2FS on, `IP_NF_MATCH_RPFILTER`/`IP6_NF_MATCH_RPFILTER` on, `PROC_AVC`/`ANDROID_RAM_CONSOLE`/`DEBUG_SECTION_MISMATCH` absent) | yes |
| github.com/napoleonlijun/android_kernel_samsung_j1minilte | `master` `9b41876e97c1b034a45a7d65efc24790af2b54fe` | n/m | GPL-2.0 | 3.10.65 + `j1minilte_defconfig`; unmodified-looking mirror | yes |
| github.com/TeamWin/android_kernel_samsung_j1minilte | `android-5.1` `7641d1bbd0f8ed29595fd4d1fab55741f36bcd9a` | n/m | GPL-2.0 | 3.10.65 + `j1minilte_defconfig`; upstream TWRP-side mirror; cloned + defconfig-hashed 2026-11-24, see `lte-models.md` | yes |
| github.com/FlyingThaCat/kernel_samsung_j1minilte | — | — | — | `git ls-remote` returns **zero refs**; HTML carries a 404 marker. Dead/empty | yes (negative) |

### 3.2 Android device trees

| URL | branch/commit | size | license | contents | verified |
|---|---|---|---|---|---|
| github.com/NotNoelChannel/android_device_samsung_j1minilte | `cm-13.0` `52b80ac79c9edfd3e1a55bf42fb3b328f0a2082b` | 37,063 KB | Apache-2.0 headers, no `LICENSE` file | **158 files**, standalone: `BoardConfig.mk` (full geometry, `TARGET_KERNEL_SOURCE := kernel/samsung/j1minilte`), `AndroidBoard.mk`, `device.mk`, `init/init_j1minilte.cpp`, `rootdir/etc/init.*.rc` (12), 66 `sepolicy/*` files (`.te` + contexts), `patches/sprd-diff/*.diff` (14 framework/HAL patches + apply scripts), `libshims/{ril_shim,libdmitry}.c`, `ril/…/SlteRIL.java`, `twrp.fstab`, `recovery.fstab`, keylayouts, overlays | yes |
| ″ | `cm-14.1` `f7d0398eecce40d3f8a0ca0a203defc5928d5f9f` | ″ | ″ | **9 files only** — skeleton that inherits `device/samsung/sharkls-common` and `vendor/samsung/j1minilte`; `BoardConfig.mk` sets only `TARGET_KERNEL_CONFIG := j1minilte_defconfig`; `lineage.dependencies` pins `djeman/android_device_samsung_sharkls-common` + 3 NXP-NFC repos (all `cm-14.1`). No kernel pin | yes |
| ″ | `lineage-15.1` `b6a17068968c28e0dd249dcf9b11c5997d301cda` | ″ | ″ | **14 files, not j1minilte**: `TARGET_KERNEL_CONFIG := j3xnlte_permissive_defconfig`; commit SHA is *identical* to `djeman/android_device_samsung_j3xnlte` `lineage-15.1` | yes |
| ″ | `old` `6e3e1b916a820cd2a237730dcbf14f76c2bdc5c5` | ″ | ″ | **17 files**, also j3xnlte content (`device_j3xnlte.mk`, `cm.mk`) | yes |
| github.com/NotNoelChannel/twrp_device_samsung_j1minilte | `twrp-5.1` `f5b96747e059e501e5e81b79a319561a692e1e9a` | pack 108.5 KiB, 16 files | `COPYING` present | Standalone recovery tree: `prebuilt/dtb` **329,728 B**, `recovery/twrp.fstab` + `recovery/recovery.fstab` (partition names `KERNEL/SYSTEM/userdata/CACHE/RECOVERY/efs/prodnv/HIDDEN`), `recovery.root/*` , `TW_THEME := portrait_hdpi`, `TW_DEVICE_VERSION := 0_notnoelchannel`, `BOARD_MKBOOTIMG_ARGS … --dt prebuilt/dtb`, CI = minimal-manifest-twrp `twrp-6.0` | yes |
| github.com/djeman/android_device_samsung_sharkls-common | `cm-14.1` `d0b1da8f14117f88d9e9a1b9b00d2c868afce063`; `lineage-15.1` `43ac7d5b40d9c6f639846a02f4cebd452ab82972` | 34,740 KB | Apache-2.0 headers | **251 files**: `BoardConfigCommon.mk` (`TARGET_KERNEL_SOURCE := kernel/samsung/sharkls`, `BOARD_KERNEL_SEPARATED_DT`, `TARGET_CUSTOM_DTBTOOL := dtbToolSprd`, camera/GPU/RIL flags, `USE_CAMERA_STUB`), `modules.mk` (Mali + sc2331 wifi out-of-tree modules), `ril/`, `gps/`, `ims/`, `init_rc/` (37 rc files) | yes |
| github.com/djeman/android_device_samsung_j3xnlte | `cm-14.1` `48dc75b93fc6fd53776dfabdd97a6bca13407382`; `cm-13.0` `4008bca1…`; `lineage-15.1` `b6a1706…`; `old` `6e3e1b9…` | 36,782 KB | Apache-2.0 | 14-file skeleton on `sharkls-common`, `j3xnlte_defconfig` | yes |
| github.com/djeman/android_device_samsung_j3xlte | `cm-14.1` `ad87c5cccff8edbbc33488c1e5ccc830f9c78079` | 41,124 KB | Apache-2.0 | 11-file skeleton, `j3xlte_defconfig` | yes |
| github.com/QQQQWAS/android_device_samsung_j1mini3g | `main` `0823371d5ace50303220361757681d9952e5c93e` | n/m | none stated | 6 files; `TARGET_OTA_ASSERT_DEVICE := j1mini3g,SM-J105H`; kernel `kernel/samsung/j1mini3g`; `lineage_j1mini3g_defconfig`. The only j1mini3g device tree found | yes |
| github.com/MayuriLabs/android_device_samsung_sprd-common | `cm-14.1` `90c5b6ca0224ab14b565d898200ee680d8e51de7` (+`cm-11.0`…`cm-13.0`) | 23,682 KB | Apache-2.0 | Alternative generic SPRD common tree (2017, pre-sharkls layout) | yes |

### 3.3 Vendor blobs

| URL | branch/commit | size | license | contents | verified |
|---|---|---|---|---|---|
| github.com/NotNoelChannel/proprietary_vendor_samsung_j1minilte | `cm-13.0` `f674dd4157bfab6cbc740a3908284de620e48505` | pack 6.56 MiB, 105 files | none (proprietary blob dump) | `proprietary/{bin,etc,etc/firmware,lib,hw,soundfx,vendor,media}`: `rild`, `modemd`, `sc2331_fw.bin`, `sensors.sc8830.so`, SoundAlive libs, `j1minilte-vendor.mk`, `BoardConfigVendor.mk` | yes |
| github.com/TheMuppets/proprietary_vendor_samsung | `cm-14.1` `a421a47fc343e0ee56a26fa5be996feb7b3f28a8` (+`lineage-15.0`/`15.1`) | n/m (9,843 files) | — | **No `j1minilte` and no `j1mini3g` directory.** j-series not covered | yes (negative) |
| github.com/djeman/android_vendor_sprd | `cm-14.1` | 39,847 KB (pre-takedown) | — | **Unavailable: "Repository unavailable due to DMCA takedown" (Unisoc, `github/dmca` 2026-02-03-unisoc-3.md), HTTP 403 on fetch.** Was the SPRD vendor tree referenced by `sharkls-common` | yes (negative) |
| github.com/Galaxy-J105F-Resources/android_vendor_sprd | `cm-14.1` `087a5490809fd8ce29d65013e9895c3f4bb2f16c` | 39,846 KB; 3,323 files | none | **Surviving mirror** of the DMCA'd tree: `gps/ modules/ open-source/ proprietaries/ wcn/` | yes |
| github.com/djeman/android_vendor_samsung_common | `cm-14.1` `8cae5ca14cad355d523ed4b4db3f59ae7ddc157f` (+`cm-13.0`, `lineage-15.1`) | 12,919 KB | — | Samsung common blobs required by `sharkls-common` | yes |

### 3.4 Build manifests and tooling

| URL | branch/commit | size | license | contents | verified |
|---|---|---|---|---|---|
| github.com/LineageOS/android (manifest) | `cm-14.1` `3053abb15b4427431b42505a13e7465e92fc2920`; `lineage-15.1` `5b74c7aac0aac13fcc11908d767aa4c1455947d5`; `cm-14.0` `3f0dea0b…` | n/m | Apache-2.0 | 7.1.2 branch is named **`cm-14.1`** (there is no `lineage-14.1` branch). `default.xml` fetches AOSP as remote `aosp`, review at `review.lineageos.org`. Branch alive, EOL | yes |
| github.com/minimal-manifest-twrp/platform_manifest_twrp_omni | `twrp-6.0` `d6b4f184703db7ca418cffc00e5d87b44a21e489`; `twrp-7.1` `361ae1e5…`; `twrp-5.1` `480e606e…`; `twrp-8.1`, `9.0` | n/m | Apache-2.0 | TWRP minimal build manifests; `twrp-6.0` is what the j1minilte TWRP CI actually uses | yes |
| android.googlesource.com/platform/manifest | tag `android-7.1.2_r36` = `2419f99de73cbd0195a33c69adde4c141ceb1882` → commit `e6cc29c8b85130cda6392b8e5505f63161db30af` | n/m | Apache-2.0 | AOSP 7.1.2 base tag for a hand-rolled LineageOS-14.1-era build | yes |
| github.com/IKGapirov/android_system_tools_dtbtool | `lineage-15.1` = `lineage-16.0` = `a2b9e476be722a49ef7a056a0548072cb6babb75` | 20 KB | Apache-2.0 | `dtbToolSprd`, required by `TARGET_CUSTOM_DTBTOOL := dtbToolSprd` in both BoardConfigs | yes |
| github.com/NotNoelChannel/j3_manifest, `…/j3xlte_manifest` | `main` `90f2278f…` / `df57855e…` | ~1 KB each | — | Tiny `local_manifest.xml` examples for the sharkls family — template only | yes |

### 3.5 Nura (ex-postmarketOS) packages

Branding verified: `https://postmarketos.org/` → **301**, `https://wiki.postmarketos.org/` → **301**,
`https://nura.eco/` → **200**, `<title>Nura // real Linux distribution for phones</title>`,
`https://wiki.nura.eco/` → 301 → `/wiki/Main_Page`. `pmaports/README.md` (main) opens with
"# Nura aports repository". GitLab group is still `postmarketOS`, host `gitlab.postmarketos.org`.

| URL | branch/commit | size | license | contents | verified |
|---|---|---|---|---|---|
| gitlab.postmarketos.org/postmarketOS/pmaports | `main` `c7940da7b44e934c103261d1f41a5559f4c4be8f` (activity 2026-10-23) | n/m | GPL-3.0 (`LICENSE`) | Layout: `device/{testing,community,archived,downstream}`, `main/`, `cross/`, `modem/`. Device dir entries: testing 340, community 105, archived **989**, downstream 38 | yes |
| pmaports `device/archived/linux-samsung-j1mini3g` | 3.10.106-r8, upstream `IKGapirov/…@6a377f7c43a84b578df39300dcce9fb9cb387a21` | 9 files | GPL-2.0-only | Arch `armv7`, patch set: `gcc7-give-up-on-ilog2`, `gcc8-fix-put-user`, `gcc10-extern_YYLOC`, `linux3.4-ARM-8933`, `linux3.4-fix-piggy.gzip.S`, `sprdfb-fix-swapped-colors`, `sprdfb-check-for-buffering`; builds `dt.img` with `dtbTool-sprd -s 2048`; `config-samsung-j1mini3g.armv7` (3669 lines) | yes |
| pmaports `device/archived/device-samsung-j1mini3g` | pkgver 4 | 3 files | MIT | `deviceinfo`: 480x800, `dev_touchscreen=/dev/input/event2`, `flash_method=heimdall-bootimg`, `generate_bootimg`, `bootimg_qcdt`, `append_seandroidenforce`, offsets base `0x0`/kernel `0x8000`/ramdisk `0x01000000`/second `0x00f00000`/tags `0x100`, pagesize 2048, sparse `samsung_format=1`; depends `linux-samsung-j1mini3g mkbootimg mdss-fb-init-hack` | yes |
| pmaports `device/archived/linux-samsung-j3xnlte` | 3.10.100-r7, upstream `djeman/android_kernel_samsung_sharkls@e3381e42b00e1ff977815b365cea53f18afff7a8` | 10 files | GPL-2.0-only | Same patch family **plus** `fix_recordmcount`, `fix_touchscreen`; `dtbTool-sprd -p scripts/dtc/ -o …/dt.img` (no `-s`); config based on `j3xnlte_defconfig` | yes |
| pmaports `device/archived/device-samsung-j3xnlte` | pkgver 4 | 3 files | MIT | `deviceinfo`: 720x1280, `flash_method=heimdall-bootimg`, same SPRD offsets, depends `… soc-sprd-audio-sc8830`; `kernel-cmdline.conf` = `console=ttyS1,115200n8` (identical to our BoardConfig cmdline) | yes |
| pmaports `device/downstream/soc-sprd-audio` | pkgver 1-r2 | — | BSD-3-Clause | Provides subpackage `soc-sprd-audio-sc8830` (asound.conf, `90-sprdphone.rules`, `sc8830/sprdphone.conf`) | yes |
| pmaports `main/dtbtool-sprd` | 1.1.2-r2, MIT, upstream `gitlab.com/Grimler/dtbtool-sprd` | — | MIT | Compiles DTB set into SPRD `dt.img`; required by every SPRD device package | yes |
| pmaports `main/{mkbootimg-osm0sis,mdss-fb-init-hack,boot-deploy,devicepkg-dev}` | present | — | — | Boot-image tooling present in `main/` (HTTP 200 on APKBUILD) | yes |

### 3.6 Reference artifacts (not source trees, load-bearing)

| URL | ref | size | contents | verified |
|---|---|---|---|---|
| github.com/Galaxy-J105F-Resources/samsung_j1minilte_dump | HEAD `aceed8396fa345b17434ca2980b5f34abf021c5c`, branch `j1miniltexx-user-5.1.1-LMY47V-J105FXXS0ARD2-release-keys` | 944,251 KB; 2,170 files | Full stock dump of **our exact PDA (`J105FXXS0ARD2`)**: `boot.img`, `recovery.img`, `bootimg/` (`00_kernel` + 5 `dtbdump_Spreadtrum_SP8835EB_board.dtb`), `bootdts/` (5 `dtsdump`), `bootRE/boot.elf` + kallsyms, `ikconfig`, `system/` (2,097 files: `lib` 523, `etc` 324, `app` 219, `bin` 218, `media` 145, `framework` 130, `fonts` 130, `build.prop`), `twrp-device-tree/samsung/j1minilte` = **gitlink submodule** `dc102899…` (not fetchable as plain blob) | yes |
| irawansprjkt.my.id/blog/2022-10-26-lineageos-j105f/ | article (updated 2026-03-03) | — | Documents **`lineage-14.1-20221024-UNOFFICIAL-j1minilte.zip`**, devices `SM-J105F`, firmware `J105FXXS0ARD2`, vanilla/no-GApps, known issues: **camera, UI glitch in some cases, wrong device name**; download shortlink `khaddavi.net/RNx77` → HTTP **200** (redirect target opaque, mirror unverified) | yes |

---

## 4. Findings

**F1 — The 2022 ROM exists; the repo's "no ROM ever shipped" claim is false.**
`README.md:8` says "no ROM ever shipped for this model". A 24 Oct 2022 unofficial
`lineage-14.1-20221024-UNOFFICIAL-j1minilte.zip` is documented with screenshots, built for
firmware **`J105FXXS0ARD2`** — byte-for-byte the PDA this device runs. `docs/adr/0002-os-track.md:22`
already says "unofficial 2022 LineageOS 14.1, link now dead", so the docs contradict each other.
Correct statement: *no maintained/official ROM; exactly one known unofficial 14.1 build (2022).*

**F2 — That ROM's stack is reconstructible, and it is not the stack the docs name.**
`Galaxy-J105F-Resources/kernel_samsung_sharkls` (`cm-14.1`, HEAD `dodyirawan85` 2022-02-19) is
djeman's `0502c3a` plus `dodyirawan85` commits dated 2022-09-25/2022-10-24 — the same window as the
ROM — adding `j1minilte` configs. `dodyirawan85` is the blog author (`irawansprjkt`). `[INFERENCE]`
This fork is the kernel that produced the 2022 ROM.

**F3 — The cm-14.1 kernel dependency is implicit, and djeman's tree cannot satisfy it.**
`NotNoelChannel/…j1minilte@cm-14.1` pins only `sharkls-common`; the kernel path comes from
`sharkls-common/BoardConfigCommon.mk` → `TARGET_KERNEL_SOURCE := kernel/samsung/sharkls`, while the
device tree overrides only the *config* (`j1minilte_defconfig`). djeman's `sharkls` tree has **no**
`j1minilte_defconfig`, so that exact triple cannot build. The G105F fork supplies the missing
defconfig — that is why it exists.

**F4 — Our vendored kernel is the NotNoelChannel `recovery` branch (3.10.65).**
After stripping CRLF, `kernel/arch/arm/configs/j1minilte_defconfig` sha256 = `bd1bb9e37093…` =
`NotNoelChannel/android_kernel_samsung_j1minilte@4fdbbff:arch/arm/configs/j1minilte_defconfig`.
`NOTICE.md` says as much (TWRP repo import); this pins it exactly.

**F5 — Repo hygiene bug: the committed `j1minilte_defconfig` is CRLF.**
3516/3516 lines contain `\r`; `j1minilte_linux_defconfig` is LF. Any config diff against upstream
trees shows a full-file rewrite until normalised. Worth normalising before further kernel work.

**F6 — Vendored 3.10.65 config vs the 3.10.94 tree: 16 lines, four of them matter.**
`CONFIG_F2FS_FS` is **off** in ours and on in 3.10.94 (cm-14.1 `fstab` uses f2fs for `/cache`);
`IP_NF_MATCH_RPFILTER`/`IP6_NF_MATCH_RPFILTER` moved from off to on; `CONFIG_PROC_AVC`,
`CONFIG_ANDROID_RAM_CONSOLE`, `CONFIG_DEBUG_SECTION_MISMATCH` were removed upstream in 3.10.94.
`[INFERENCE]` A 14.1 build on the vendored config would ship without f2fs support.

**F7 — `MayuriLabs` is not stock: it is "JohnKernel v1".**
`CONFIG_LOCALVERSION="-JohnKernel_v1"`, 14-line delta from our config, single 2017 "Initial Import
From SM-J105F_SEA_LL_Opensource" commit. Usable as a mirror, not as an authority.

**F8 — IKGapirov is a j1mini3g tree, not a j1minilte tree.**
`cm-14.1`/`lineage-15.1` are 3.10.106 with **no** `j1minilte` defconfig and only two j1minilte
*panel* dtsi — no board DTS. Its 3.10.65 `android-5.1` branch carries the 3G `j1mini3g-dt_defconfig`.

**F9 — pmOS/Nura port packages exist for the siblings and are archived, but the closest SoC
reference is the J3, not the J1 mini 3G.**
`device/archived/linux-samsung-j3xnlte` is built from djeman's **sharkls 3.10.100** — the same
kernel family as ours — with `dtbtool-sprd`, SPRD offsets and `console=ttyS1,115200n8`.
`linux-samsung-j1mini3g`'s config is `CONFIG_ARCH_SCX30G` + `CONFIG_MACH_J1MINI3G` +
`CONFIG_FB_SCX30G` + `CONFIG_SIPC_WCDMA` (no LTE): a **3G SC8830** config, unusable as-is on an
SCX35L/LTE SC9830I. No `device-samsung-j1minilte` package exists anywhere in pmaports.

**F10 — The Nura delta to a downstream kernel config is 21 lines.**
`config-samsung-j1mini3g.armv7` differs from IKG's `lineage_j1mini3g_defconfig` by 21 lines:
`LOCALVERSION`, `ANDROID_PARANOID_NETWORK=n`, `DEVTMPFS=y`+`DEVTMPFS_MOUNT=n`,
`DEVPTS_MULTIPLE_INSTANCES=y`, `DRM=y` (UDL/TILCDC off), `HDMI=y`. That is the reusable recipe for
turning our Android config into a bootable Linux config.

**F11 — Our `j1minilte_linux_defconfig` is already SCX35L-correct but Android-flavoured.**
`ARCH_SCX35L=y`, `MACH_J1MINILTE=y`, `MACH_SP9830I=y`, `SIPC_LTE=y`, `FB_SCX35L=y`,
`SPRDFB_GEN_PANEL=y`, `LCD_GENERIC=y`, `F2FS` off, `DEVTMPFS=y`, `ANDROID_PARANOID_NETWORK=y`,
**no `CONFIG_DRM`**.

**F12 — The 2022 build's device tree is a 9-file skeleton: it cannot build alone.**
`cm-14.1` keeps only `BoardConfig.mk`, `j1minilte.mk`, `lineage.mk`, `lineage.dependencies`,
`proprietary-files.txt`, `Android.mk` + 3 scripts. Everything else (sepolicy, init rc set, overlays,
libshims, SPRD framework patches, keylayouts) lives only in `cm-13.0`.

**F13 — The `lineage-15.1` and `old` branches of the j1minilte device tree are j3xnlte content.**
`lineage-15.1` SHA `b6a17068…` is *identical* to `djeman/android_device_samsung_j3xnlte@lineage-15.1`;
`old` `6e3e1b9…` is also identical. Neither is a j1minilte tree; 15.1 for this device is source-only
fantasy until a real per-device tree is written.

**F14 — Resolution is wrong in both SPRD board configs.**
`DEVICE_RESOLUTION := 720x1280` in `j1minilte/cm-13.0/BoardConfig.mk` **and** in
`sharkls-common/BoardConfigCommon.mk` (`TARGET_SCREEN_WIDTH/HEIGHT 720/1280`). The device is
**480x800**. `[INFERENCE]` This explains the 2022 ROM's "UI glitch" and "wrong device name" notes,
and it must be overridden per-device in any rebuild.

**F15 — Image sizes in the trees disagree with the real partition table.**
`BOARD_BOOTIMAGE_PARTITION_SIZE`/`BOARD_RECOVERYIMAGE_PARTITION_SIZE` = 20,971,520 B vs 16 MiB
(16,777,216 B) real; `BOARD_USERDATAIMAGE_PARTITION_SIZE` = 5,272,240,128 B vs ~4819 MiB userdata.
Already tracked as C4 in `ROADMAP.md`; the userdata overshoot is an additional, unlogged risk.

**F16 — Vendor blobs have exactly one public source, and the SPRD HAL tree's original is DMCA'd.**
TheMuppets has no j1minilte/j1mini3g directory (verified across 9,843 files of `cm-14.1`).
`NotNoelChannel/proprietary_vendor_samsung_j1minilte@cm-13.0` (105 files, Android 5.1/6.0-era) is the
only blob repo. `djeman/android_vendor_sprd` now 403s with a **Unisoc DMCA** notice dated 2026-02-03;
`Galaxy-J105F-Resources/android_vendor_sprd@087a549` (3,323 files) is the surviving mirror and is now
a single point of failure — it must be mirrored locally before any build is attempted.

**F17 — A stock-system dump for our exact PDA is available and covers the gap.**
`samsung_j1minilte_dump` contains the full `system/` (2,097 files), the stock kernel config, five
SP8835EB DTB dumps and five DTS dumps of `J105FXXS0ARD2`. This is the fallback source of every blob
and the ground truth for DTB comparison when the GitHub vendor trees disappear.

**F18 — Everything except the TWRP tree and the blob dump is dormant.**
Last-commit evidence: djeman kernel 2020-01-03; j3xnlte tree 2019-05-30; G105F kernel 2022-02-19;
NotNoelChannel device tree cm-13.0 content is 2016-era (repo-level push 2024-06-06);
NotNoelChannel kernel cm-14.1 3.10.94 (repo push 2024-06-08); twrp device tree 2024-05-12;
proprietary vendor 2024-03-31. No upstream will fix anything — every gap below is ours to close.

**F19 — Both 14.1 build inputs are still fetchable.**
`LineageOS/android@cm-14.1` (`3053abb`) and AOSP `android-7.1.2_r36` (`2419f99`→`e6cc29c`) resolve, and
minimal-manifest-twrp `twrp-6.0` (`d6b4f18`) is the recipe the existing TWRP CI already uses.

---

## 5. Base-selection recommendation

### 5.1 Track B — Linux (Nura/Alpine on the vendor kernel)

**Kernel base: keep the committed 3.10.65 vendor tree.** Reasons: it is the only tree whose config is
`ARCH_SCX35L` + `MACH_J1MINILTE` + `MACH_SP9830I` + `SIPC_LTE`, it has all five board DTS plus the
five j1minilte panel dtsi, its DTBs were already proven byte-identical to stock, and TWRP builds from
it in CI today. Secondary (only if 3.10.65 fails a specific bring-up): `NotNoelChannel@cm-14.1`
3.10.94, which is the same config ±16 lines. **Do not** base on IKGapirov 3.10.106 (SCX30G config,
no board DTS) or MayuriLabs (JohnKernel branding).

**Kernel packaging:** copy `device/archived/linux-samsung-j3xnlte`'s APKBUILD shape (sharkls family,
`dtbTool-sprd`, downstreamkernel_prepare) and **its** eight-patch set; take
`config-samsung-j1mini3g.armv7` only as the delta dict (see F10) — not as a config.

**Device package:** copy `device/archived/device-samsung-j1mini3g` (same 480x800 panel class, same
bootloader) and change codename/deps/DTB; keep `heimdall-bootimg`, `bootimg_qcdt`,
`append_seandroidenforce`, sparse-samsung, offsets `0x8000/0x1000000/0xf00000/0x100`, pagesize 2048.

### 5.2 Track A — LineageOS 14.1

Build the exact triple that is internally consistent, then fix the known defects:

1. `device/samsung/j1minilte` ← `NotNoelChannel/…j1minilte@cm-14.1` (`f7d0398`) **plus** everything
   only present in its `cm-13.0` (`52b80ac`): 66 sepolicy files, 12 init rc files, overlays,
   `libshims/`, `ril/SlteRIL.java`, keylayouts, `patches/sprd-diff/*`.
2. `device/samsung/sharkls-common` ← `djeman/…sharkls-common@cm-14.1` (`d0b1da8`).
3. `kernel/samsung/sharkls` ← `Galaxy-J105F-Resources/kernel_samsung_sharkls@1df22d2` (3.10.100 +
   native `j1minilte_defconfig`). This is the only combination in which `TARGET_KERNEL_CONFIG` and
   `TARGET_KERNEL_SOURCE` both resolve.
4. `vendor/samsung/j1minilte` ← `NotNoelChannel/…j1minilte@f674dd4`; `vendor/samsung/common` ←
   `djeman/android_vendor_samsung_common@8cae5ca`; `vendor/sprd` ←
   `Galaxy-J105F-Resources/android_vendor_sprd@087a549`; the three NXP-NFC repos from
   `lineage.dependencies`.
5. Override `DEVICE_RESOLUTION`/`TARGET_SCREEN_*` to 480x800 and correct BOOT/RECOVERY to 16 MiB.

Rejected bases: `lineage-15.1`/`old` branches (j3xnlte content, F13); `QQQQWAS/j1mini3g` (6 files,
3G platform); TWRP tree (recovery-only, `TW_*` flags, no Android framework).

### 5.3 Pin set (copy-paste)

```
KERNEL_VENDOR      = repo@38837a6 kernel/ (3.10.65, SCX35L)
KERNEL_LOS         = Galaxy-J105F-Resources/kernel_samsung_sharkls @ 1df22d20250a335561f5f2bebd2fe95f62c2f4ee
KERNEL_LOS_ALT     = NotNoelChannel/android_kernel_samsung_j1minilte @ 3127397b465d223da75a51095e21d447a8d2d995 (3.10.94)
KERNEL_UNUSABLE    = IKGapirov/android_kernel_samsung_j1mini3g @ 6a377f7c43a84b578df39300dcce9fb9cb387a21 (3.10.106, SCX30G)
DEVICE_LOS         = NotNoelChannel/android_device_samsung_j1minilte @ f7d0398e... (cm-14.1)
DEVICE_FULL_REF    = NotNoelChannel/android_device_samsung_j1minilte @ 52b80ac79c9edfd3e1a55bf42fb3b328f0a2082b (cm-13.0)
COMMON             = djeman/android_device_samsung_sharkls-common @ d0b1da8f14117f88d9e9a1b9b00d2c868afce063
VENDOR_BLOBS       = NotNoelChannel/proprietary_vendor_samsung_j1minilte @ f674dd4157bfab6cbc740a3908284de620e48505
VENDOR_SPRD        = Galaxy-J105F-Resources/android_vendor_sprd @ 087a5490809fd8ce29d65013e9895c3f4bb2f16c
VENDOR_SAMSUNG     = djeman/android_vendor_samsung_common @ 8cae5ca14cad355d523ed4b4db3f59ae7ddc157f
TWRP_TREE          = NotNoelChannel/twrp_device_samsung_j1minilte @ f5b96747e059e501e5e81b79a319561a692e1e9a
TWRP_MANIFEST      = minimal-manifest-twrp/platform_manifest_twrp_omni @ d6b4f184703db7ca418cffc00e5d87b44a21e489 (twrp-6.0)
LOS_MANIFEST       = LineageOS/android @ 3053abb15b4427431b42505a13e7465e92fc2920 (cm-14.1)
DTBTOOL            = IKGapirov/android_system_tools_dtbtool @ a2b9e476be722a49ef7a056a0548072cb6babb75
PMAPORTS_REF       = pmaports @ c7940da7b44e934c103261d1f41a5559f4c4be8f (device/archived/{linux,device}-samsung-{j1mini3g,j3xnlte})
```

---

## 6. Gaps

### 6.1 Linux / Nura

- **No `device-samsung-j1minilte` and no `linux-samsung-j1minilte` package anywhere** (verified across
  all four pmaports device categories: 340/105/989/38 entries). Both must be authored.
- `j1minilte_linux_defconfig` needs the F10 deltas: `CONFIG_DRM` (SCX35L has no DRM KMS driver —
  `[INFERENCE]` fbdev+`sprdfb` remains the display path), `DEVPTS_MULTIPLE_INSTANCES=y`,
  `ANDROID_PARANOID_NETWORK=n`, and a decision on `CONFIG_DEVTMPFS_MOUNT`.
- The 3.10.65 tree has no GCC-compat patches: the 8-patch set from `linux-samsung-j3xnlte` /
  `linux-samsung-j1mini3g` must be applied and re-verified (toolchain in the repo's CI is not modern
  enough to skip them).
- `dtbTool-sprd` invocation for j1minilte is unverified: j1mini3g uses `-s 2048`, j3xnlte omits it.
  Our pagesize is 2048 → start with `-s 2048`, validate `dt.img` against `bootimg/0{2..6}_dtbdump*`.
- Touchscreen device node (`/dev/input/event2` from the 3G sibling) and USB-net (`SPRD_VETH` is
  **off** in the j1mini3g config) are unconfirmed for this unit.
- Modem: `SIPC_LTE` is enabled in our config; the 3G sibling's `SIPC_WCDMA` recipe does not cover LTE
  bring-up (`[INFERENCE]` modem in Linux is out of scope for first boot).
- Flashing: Nura's deviceinfo uses `heimdall-bootimg`; this unit's documented flash path is Odin/`dd`.
  Must be proven before first flash (kernel and rootfs are separate partitions, `KERNEL` p20 / `SYSTEM` p25).

### 6.2 LineageOS 14.1

- **SELinux for 7.1 does not exist for this device.** The 66 `sepolicy/*` files in `cm-13.0` are
  Marshmallow-era; 7.1 needs `file_contexts`/`property_contexts` rework, and `[INFERENCE]` several
  rules will be missing for `dex2oat`/`installd`/`netd` on nougat.
- **Vendor blobs are 5.1/6.0-era** and the SPRD HAL tree comes from a DMCA'd repo mirrored once.
  `USE_CAMERA_STUB := true` is still set in `sharkls-common`, matching the 2022 ROM's "camera broken".
- `libshims` (ril_shim, libdmitry) are pre-7.1; expect symbol-version work.
- Device tree overrides needed: resolution (F14), boot/recovery/userdata sizes (F15),
  `TARGET_OTA_ASSERT_DEVICE := j1minilte,j1miniltexx,j1minilteobxx` (keep), and a decision whether to
  keep `TARGET_IGNORE_RO_BOOT_REVISION`.
- No `local_manifest.xml` exists for this device; `j3_manifest`/`j3xlte_manifest` are the only template.
- 3.10.100 `j1minilte_defconfig` is a 505-line savedefconfig — it must be expanded with a full
  `make savedefconfig` round-trip before trusting feature coverage (F6's f2fs point applies here too).
- 1 GB RAM / 32-bit: 14.1 is the ceiling; 15.1 requires a device tree that does not exist (F13).

### 6.3 Cross-cutting

- Mirror `Galaxy-J105F-Resources/android_vendor_sprd`, `NotNoelChannel/proprietary_vendor_samsung_j1minilte`
  and `samsung_j1minilte_dump` locally — three of the four blob sources are single-copy, and one
  equivalent tree has already been DMCA'd.
- Normalise the CRLF `j1minilte_defconfig` (F5).
- Reconcile the docs: README's "no ROM ever shipped" vs ADR-0002's "unofficial 2022 build (link dead)",
  vs the verified live shortlink (F1).

---

## 7. Unverified / open

- `khaddavi.net/RNx77` returns 200 but the redirect target is opaque; the zip was **not** downloaded or
  hashed, so the 2022 ROM's exact contents/build date are unconfirmed.
- `FlyingThaCat/kernel_samsung_j1minilte` advertises `main` in the GitHub API but `git ls-remote`
  returns zero refs and the HTML carries a 404 marker — treated as dead, not proven empty.
- Repo sizes marked `n/m` (TeamWin kernel, napoleonlijun, QQQQWAS, LineageOS manifest,
  minimal-manifest-twrp, TheMuppets) were not measurable after the API quota ran out.
- `twrp-device-tree/samsung/j1minilte` in the stock dump is a gitlink (`dc102899…`) whose target repo
  could not be resolved (promisor fetch refused the ref); it is *not* confirmed to be
  `NotNoelChannel/twrp_device_samsung_j1minilte`.
- Whether `NotNoelChannel@cm-13.0` was ever actually compiled into a ROM is unknown (no release
  artifacts found); its value here is source content only.
- `pkgrel`/last-build status of the archived Nura packages is recorded from `APKBUILD`, not from a
  live build.
