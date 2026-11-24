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

## 3. Explicitly excluded (not LTE-model)

| Repo | Why excluded |
|---|---|
| `IKGapirov/android_kernel_samsung_j1mini3g` @ `6a377f7c43a84b578df39300dcce9fb9cb387a21` | 3G SC8830, `CONFIG_ARCH_SCX30G`, no j1minilte board DTS (only two panel dtsi). Kept in corpus solely as the *patch/config delta source* for the Nura recipe, never as this unit's kernel |
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
