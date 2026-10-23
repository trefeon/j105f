# Custom TWRP for Samsung Galaxy J1 Mini (SM-J105F, j1minilte)

Custom-built TWRP recovery for the Samsung SM-J105F (j1minilte / SC8830
"sharkls" platform), built from source in this repository's
`device/samsung/j1minilte` and `kernel/samsung/j1minilte` paths.

## What this is

- A TWRP device tree for `j1minilte`, derived from the
  [NotNoelChannel/twrp_device_samsung_j1minilte](https://github.com/NotNoelChannel/twrp_device_samsung_j1minilte)
  tree (branch `twrp-5.1`), with:
  - custom version branding (`TW_DEVICE_VERSION := 0_j105f-custom`)
  - kernel source committed in-tree (`kernel/samsung/j1minilte`,
    NotNoelChannel recovery kernel, 3.10.65, `j1minilte_defconfig`)
  - a CI workflow that builds entirely from this repository (the only
    external downloads are the upstream omni twrp-6.0 base manifest and
    the arm-eabi-4.8 toolchain)
- CI artifacts: `recovery.img` + Odin `recovery.tar` + `SHA256SUMS` +
  `BUILD_INFO.txt` + pinned manifest snapshot.

## Target device

| Field | Value |
|---|---|
| Codename | j1minilte (j1miniltexx, CSC XID) |
| Model | SM-J105F (single-SIM; SM-J105F/DS dual-SIM variant shares board) |
| SoC | Spreadtrum SC8830 (board SP8835EB) |
| RAM | 1 GB |
| Recovery partition | 20 MiB (20971520 bytes) |
| Boot image | Android boot format, page 2048, `--dt` SPRD dt.img (5 DTBs) |

## Build

```bash
export ALLOW_MISSING_DEPENDENCIES=true
source build/envsetup.sh
lunch omni_j1minilte-eng
make -j$(nproc) recoveryimage
```

or trigger the GitHub Actions workflow. Artifacts:
`out/target/product/j1minilte/recovery.{img,tar}`.

## Flash / rollback

- Flash `recovery.tar` via Odin (AP slot) in download mode, or `dd` the
  image onto the RECOVERY partition from an existing recovery.
- Stock recovery image is preserved at `device/evidence/stock-backup/`
  in the Project_J105F repository for rollback.
- Flashing is only done with explicit user approval per the project
  delivery plan (Phase 2 gates).

## License

This tree is derived from NotNoelChannel's AGPL-3.0-licensed work;
`COPYING` (AGPL-3.0) applies. See `docs/plans/twrp-build-plan.md` and
`docs/delivery/tasks.md` in the Project_J105F repository for the full
plan, build report and device test matrix.
