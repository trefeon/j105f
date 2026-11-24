# LTE-model resource registry (SM-J105F / `j1minilte` only)

**Verified 2026-11-24.** This is the allow-list of upstream resources that are genuinely for the
LTE model. The 3G sibling `j1mini3g` and the J3 family (`j3xlte`/`j3xnlte`) are **not** in this list:
their `CONFIG_ARCH_SCX30G` / `SIPC_WCDMA` configs and board DTS do not boot this `SC9830I` unit.
Evidence for the exclusion: `docs/research/source-landscape.md` F8/F9/F13,
`docs/research/exact-model-findings.md`.

Everything below is pinned by full commit SHA in `tools/fetch-reference.sh`; `--check` verifies the
local clone. Re-fetch: `bash tools/fetch-reference.sh`.

## 1. Exact-model ground truth (local, committed)

| Item | Pin / value |
|---|---|
| Committed vendor kernel | this repo `kernel/` @ `38837a6` tree — 3.10.65, `j1minilte_defconfig`, `j1minilte_linux_defconfig`, 5× `SP8835EB` board DTS; `dt.img` `f29f3d90…`, byte-identical to stock |
| Exact-PDA stock dump | `Galaxy-J105F-Resources/samsung_j1minilte_dump` @ `aceed8396fa345b17434ca2980b5f34abf021c5c` (branch `j1miniltexx-user-5.1.1-LMY47V-J105FXXS0ARD2-release-keys`): `boot.img`, 5 DTBs, `bootdts/`, `ikconfig`, full `/system` incl. `sc2331_fw.bin` / `sc2331_fdl.bin` |
| Proprietary vendor blobs (LTE) | `NotNoelChannel/proprietary_vendor_samsung_j1minilte` @ `f674dd4157bfab6cbc740a3908284de620e48505` (`cm-13.0`, 105 files) — the only public j1minilte blob repo |
| Surviving SPRD vendor mirror | `Galaxy-J105F-Resources/android_vendor_sprd` @ `087a5490809fd8ce29d65013e9895c3f4bb2f16c` (`cm-14.1`, 3,323 files); original `djeman/android_vendor_sprd` is DMCA'd |
| Samsung common blobs | `djeman/android_vendor_samsung_common` @ `8cae5ca14cad355d523ed4b4db3f59ae7ddc157f` (`cm-14.1`) |
| TWRP device tree | `NotNoelChannel/twrp_device_samsung_j1minilte` @ `f5b96747e059e501e5e81b79a319561a692e1e9a` (`twrp-5.1`) — base of the committed, debranded `android/device/samsung/j1minilte` |
| Full LOS device-tree reference | `NotNoelChannel/android_device_samsung_j1minilte` @ `52b80ac79c9edfd3e1a55bf42fb3b328f0a2082b` (`cm-13.0`, 158 files: sepolicy, init rc, overlays, libshims, RIL shim, SPRD patches) |
| LOS 14.1 skeleton | `NotNoelChannel/android_device_samsung_j1minilte` @ `f7d0398eecce40d3f8a0ca0a203defc5928d5f9f` (`cm-14.1`, 9 files) |
| LOS 14.1 kernel with native defconfig | `Galaxy-J105F-Resources/kernel_samsung_sharkls` @ `1df22d20250a335561f5f2bebd2fe95f62c2f4ee` (`cm-14.1`, 3.10.100 + `j1minilte_defconfig`) |
| Boot manifests | `minimal-manifest-twrp/platform_manifest_twrp_omni` @ `d6b4f184703db7ca418cffc00e5d87b44a21e489` (`twrp-6.0`) · `LineageOS/android` @ `3053abb15b4427431b42505a13e7465e92fc2920` (`cm-14.1`) |

## 2. LTE-only kernel mirrors (new pins, 2026-11-24)

All three were resolved with `git ls-remote --heads` on 2026-11-24 and cloned shallow under
`reference/kernels/` (~131 MB each). `--check` confirms all pins present. Each clone contains
`arch/arm/configs/j1minilte_defconfig`; the SHA-256 values below are over CRLF-stripped bytes,
comparable with our committed defconfig (`bd1bb9e3…`, 90,912 B). None is byte-identical to ours —
they are cross-checks, not replacements.

| Repo | Branch | Full SHA | Note |
|---|---|---|---|
| `TeamWin/android_kernel_samsung_j1minilte` | `android-5.1` | `7641d1bbd0f8ed29595fd4d1fab55741f36bcd9a` | Upstream TWRP-side j1minilte kernel mirror, 3.10.65 + `j1minilte_defconfig` (sha256 `06c6226a…`, 90,852 B after CRLF strip); cross-check, not identical to ours |
| `napoleonlijun/android_kernel_samsung_j1minilte` | `master` | `9b41876e97c1b034a45a7d65efc24790af2b54fe` | 3.10.65 + `j1minilte_defconfig` (sha256 `15007c8e…`, 90,845 B); unmodified-looking mirror, cross-check only |
| `NotNoelChannel/android_kernel_samsung_j1minilte` | `cm-14.1` | `3127397b465d223da75a51095e21d447a8d2d995` | 3.10.**94**, `j1minilte_defconfig` sha256 `d637bdb2…`, 90,905 B; differs from ours in 16 lines (F6); fallback if 3.10.65 fails bring-up |

## 3. Explicitly excluded (not LTE-model — no 3G source kept in `reference/`)

| Repo | Why excluded |
|---|---|
| `IKGapirov/android_kernel_samsung_j1mini3g` @ `6a377f7c43a84b578df39300dcce9fb9cb387a21` | 3G SC8830, `CONFIG_ARCH_SCX30G`, no j1minilte board DTS. **Quarantined to `.reference_delete/j1mini3g_ikgapirov/` (gitignored) 2026-11-24**; no 3G source remains in `reference/`. Only the generic patch/config facts in §5 are retained |
| `djeman/android_kernel_samsung_sharkls` @ `0502c3a5bb4de36a399ad075fe945761428a5a2c` | Same SoC family but **no** `j1minilte_defconfig` — cannot satisfy the LOS device triple |
| `MayuriLabs/android_kernel_samsung_j1minilte` @ `5f4f03bd4899c988d33302b0d7543ff8a0694996` | LTE model but not stock: `CONFIG_LOCALVERSION="-JohnKernel_v1"`; mirror/cross-check only |
| `QQQQWAS/android_device_samsung_j1mini3g` | 3G platform, 6-file tree |
| `NotNoelChannel/android_device_samsung_j1minilte` `lineage-15.1` / `old` | j3xnlte content with identical SHAs to the J3 trees (F13) |
| `FlyingThaCat/kernel_samsung_j1minilte` | `git ls-remote` returns zero refs — dead |

## 4. Rule for the custom-Linux rootfs phase

1. Kernel source stays the committed LTE 3.10.65 tree; add the downstream/Nura GCC-compat and
   sprdfb patches (from `reference/pmaports/device/.shared-patches/linux/`) on top.
2. Author `device-samsung-j1minilte` by copying the `j1mini3g` package **shape only** (boot offsets,
   `heimdall-bootimg`, `bootimg_qcdt`, `SEANDROIDENFORCE`, sparse-samsung) and replacing the config,
   DTB, codename, touch node and kernel source with the LTE values above.
3. Never flash from `reference/` — only from checksummed `device/evidence/build-artifacts/` bundles.
4. Verify before every build: `bash tools/fetch-reference.sh --check`.

## 5. Archived Nura recipe — facts kept, 3G sources quarantined (2026-11-24)

The 3G clone (`reference/kernels/j1mini3g_ikgapirov`, 639 MB) and the two archived pmaports packages
were moved to `.reference_delete/` (gitignored) so no later agent can accidentally build from them.
The reusable **shape** of the archived recipe is recorded here instead; no 3G source, config or
binary remains under `reference/`.

| Kept fact | Value |
|---|---|
| Device package shape | `deviceinfo`: armv7, 480×800, `dev_touchscreen=/dev/input/event2`, `flash_method=heimdall-bootimg`, `bootimg_qcdt=true`, `append_seandroidenforce`, offsets base `0x0`/kernel `0x8000`/ramdisk `0x1000000`/second `0xf00000`/tags `0x100`, pagesize 2048, sparse samsung format 1 |
| Kernel package shape | `downstreamkernel_prepare/package`, `dtbTool-sprd -s 2048 -p scripts/dtc/ -o arch/arm/boot/dt.img arch/arm/boot/dts/`, `make ARCH=arm CC=gcc`, `!strip !check !tracedeps pmb:cross-native` |
| 7 reusable patches | `gcc7-give-up-on-ilog2`, `gcc8-fix-put-user`, `gcc10-extern_YYLOC`, `linux3.4-ARM-8933`, `linux3.4-fix-piggy.gzip.S`, `sprdfb-fix-swapped-colors`, `sprdfb-check-for-buffering` — all present as real files in `reference/pmaports/device/.shared-patches/linux/` (and `…/linux/sprd/`), not symlinks into the 3G package |
| 7-patch set sha512 list | verified from the real files below, not the 3G package stub list |
| Real patch file | SHA-512 (shared corpus) |
|---|---|
| `gcc7-give-up-on-ilog2-const-optimizations.patch` | `77eba606a71eafb36c32e9c5fe5e77f5e4746caac292440d9fb720763d766074a964db1c12bc76fe583c5d1a5c864219c59941f5e53adad182dbc70bf2bc14a7` |
| `gcc8-fix-put-user.patch` | `197d40a214ada87fcb2dfc0ae4911704b9a93354b75179cd6b4aadbb627a37ec262cf516921c84a8b1806809b70a7b440cdc8310a4a55fca5d2c0baa988e3967` |
| `gcc10-extern_YYLOC_global_declaration.patch` | `2b48f1bf0e3f70703d2cdafc47d5e615cc7c56c70bec56b2e3297d3fa4a7a1321d649a8679614553dde8fe52ff1051dae38d5990e3744c9ca986d92187dcdbeb` |
| `linux3.4-ARM-8933-1-replace-Sun-Solaris-style-flag-on-section.patch` | `9e3b067fa1b19ad02500c4fce1b6142051df3845c508e615788beb650c4f953683107ac2d80670c4e3df38f532e0e91060d2d13ec04c9ec985abd2dfa82e900b` |
| `linux3.4-fix-piggy.gzip.S.patch` | `080745ca4ecaa804ee1df26ea81975ca93b74372e0c08322a6c481e97807495ae6ceb6cc77653afa24f9f2df45da8ebf8e5de6b06037fbb08e0279877ce42188` |
| `sprd/sprdfb-fix-swapped-colors.patch` | `6836001b24508d413a059f19b0c6f6f547037f68886c22159ad51be91d1a089e3d1d9ed79c3c62724648df7f810cd81d96a83f4a34368b373524b649e5539656` |
| `sprd/sprdfb-check-for-buffering.patch` | `e33ed12de874c1c8bc9231aea3b0389b18ee0ff804e39c0f47d9cbf657ea19015370d6114846c2d142fbdb88f472f0e65811c53b9b335feb8ae2f30dffdf4846` |
| 3G config delta (F10) | Nura config `config-samsung-j1mini3g.armv7` sha256 `8f56fa7382b339e112ddd1253887dc1c803bb0f1b94e13edc949f43a07c234c6` (95633 B) vs IKG defconfig `85884d6d…` (95563 B); 21-line delta: LOCALVERSION, `ANDROID_PARANOID_NETWORK=n`, `DEVTMPFS=y` + `DEVTMPFS_MOUNT=n`, `DEVPTS_MULTIPLE_INSTANCES=y`, `DRM=y`, `HDMI=y` — historical fact only, never apply the 3G config |
| Restoring the 3G sources | `git clone --depth 1 --branch cm-14.1 https://github.com/IKGapirov/android_kernel_samsung_j1mini3g.git reference/kernels/j1mini3g_ikgapirov` then `git -C reference/kernels/j1mini3g_ikgapirov checkout 6a377f7c43a84b578df39300dcce9fb9cb387a21`; package dirs via `git -C reference/pmaports sparse-checkout add device/archived/device-samsung-j1mini3g device/archived/linux-samsung-j1mini3g`. **Never do this for a build of this device.** |

## 6. Hard rule for future agents

`j1mini3g` = **3G SC8830, wrong platform**. Do not use its kernel tree, defconfig, DTBs,
deviceinfo, config file or image as a base, patch source or flash candidate for SM-J105F. The
only permitted legacy use of the archived recipe is the documented packaging *shape* and the
7 generic patches that physically live in `device/.shared-patches/linux/`. Any action that
references `reference/kernels/j1mini3g_ikgapirov/` or `device/archived/*-j1mini3g/` means the
operator explicitly overrode this rule.
