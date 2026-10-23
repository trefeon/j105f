# linux/ — Linux userspace for the J1 Mini

Track B: postmarketOS/Alpine on the Samsung 3.10.65 vendor kernel (there is no mainline SCX35L
support; see `docs/adr/0002-os-track.md`).

## What exists

- `initramfs/init` — the H1 debug initramfs: mounts proc/sys/devtmpfs/devpts/tmpfs, writes a boot
  evidence log to the serial console, and starts interactive shells on `ttyS1` (serial) and `tty1`
  (panel, when fbcon is up). Built into `out/ramdisk.cpio.gz` by `tools/initramfs/build_initramfs.sh`
  (busybox 1.36.1, static armv7), fail-closed verified in CI.
- Kernel side: `kernel/arch/arm/configs/j1minilte_linux_defconfig` (`ARCH_SCX35L`, `MACH_J1MINILTE`,
  `MACH_SP9830I`, `SIPC_LTE`, devtmpfs, VT, fbcon).

## What comes next

The rootfs phase: a pmbootstrap device package (`device-samsung-j1minilte`) derived from the archived
`samsung-j1mini3g` package (archived 2026-06-22), whose deviceinfo already encodes this boot chain:
`armv7`, `flash_method=heimdall-bootimg`, base `0`, kernel `0x00008000`, ramdisk `0x01000000`, second
`0x00F00000`, tags `0x100`, page 2048, `bootimg_qcdt=true` + SPRD `dt.img`,
`bootimg_append_seandroidenforce=true`, `flash_sparse_samsung_format=1`. Kernel package wraps `kernel/`
with the GCC-compat patches; expect the archived port's flashing quirk (`flash_rootfs` fails at 17 % —
install via `--android-recovery-zip` or `flash_kernel` + TWRP rootfs, which is exactly what our recovery
gives us).

Install must leave RECOVERY untouched (SYSTEM p25 = 2097 MiB, microSD as fallback). Hardware order and
gates are in `docs/delivery/ROADMAP.md` Stage H; the modem is closed firmware and telephony is
explicitly out of scope for the first release. Known limits from the same-SoC port: no GPU
acceleration, Wi-Fi/BT are the highest-risk items, battery reporting partial.
