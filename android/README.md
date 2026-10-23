# android/ — AOSP-side sources

Paths here mirror the layout inside an AOSP/TWRP checkout, so CI only has to copy a directory:

```text
android/device/samsung/j1minilte/   →  <checkout>/device/samsung/j1minilte/
kernel/                             →  <checkout>/kernel/samsung/j1minilte/
```

## What is here today

`device/samsung/j1minilte/` is the **recovery (TWRP 3.7.0_9, omni twrp-6.0 manifest)** device tree:
`BoardConfig.mk`, `omni_j1minilte.mk`, `recovery/` (fstab, keymap), `prebuilt/dtb` (SPRD dt.img,
329,728 B, byte-identical to the stock image), `splash/` (custom 480×800 splash sourced by
`tools/bootimg/patch_splash.py`), `COPYING` (AGPL-3.0, NotNoelChannel base).

It is deliberately **not** a LineageOS device tree yet. Track A adds:

- `android/device/samsung/j1minilte/` lineage variant (`lineage.mk`, `extract-files.sh`,
  `proprietary-files.txt`) — modeled on djeman's `j3xnlte` sharkls tree;
- `android/vendor/samsung/` + `android/vendor/sprd/` proprietary blobs, extracted from a stock
  firmware/dump, never committed if licence-encumbered;
- the `sharkls-common` patches required by the Sprd framework diff.

See `docs/adr/0002-os-track.md` for the target versions and `docs/plans/` for the port plan.
