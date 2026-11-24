# postmarketOS → Nura ecosystem dossier (`j1mini3g` → `j1minilte` port)

Research date **2026-10-23**. Every URL was fetched live with `curl` (status recorded); pins come
from the GitLab REST API of the canonical host.

## 0. Corrected canonical names (read first)

postmarketOS **renamed to Nura**, announced 2026-09-27 (`https://nura.eco/blog/2026/09/27/nura-rename/`, 200).
Unchanged: GitLab group path `postmarketOS`, repo names, the tool name **`pmbootstrap`** (there is no
`nurabootstrap`), and all package names (`postmarketos-base`, `postmarketos-mkinitfs`, `device-samsung-*`;
`main/nura-base` → 404). Only domains and descriptions moved:

| Old (redirects → new, HTTP 200) | New canonical | GitLab |
|---|---|---|
| `postmarketos.org` | `nura.eco` | `gitlab.postmarketos.org` (never renamed; descriptions now say "Nura") |
| `wiki.postmarketos.org` | `wiki.nura.eco` | `gitlab.com/postmarketOS/pmaports` = read-only mirror ("Moved to gitlab.postmarketos.org…") |
| `docs./images./pkgs./build./mirrors.postmarketos.org` | `docs./images./pkgs./build.nura.eco`, `nura.eco/mirrors/` | |

## 1. Scope

What a `j1minilte` (SM-J105F/DS, SC9830I, armv7) downstream port must target now: repos + pins,
whether `j1mini3g` device/kernel packages survive and what they contain, pmbootstrap release/install/CLI
model, wiki/docs sources, Alpine armv7 status, reproducible commands. Out of scope: choosing the
`j1minilte` kernel tree, bootloader unlock, flashing.

## 2. Verified sources

| URL | pin | license | what | status |
|---|---|---|---|---|
| `gitlab.postmarketos.org/postMarketOS/pmaports` (API 226) | `main` = `c7940da7b44e934c103261d1f41a5559f4c4be8f` (2026-10-23T14:13:16Z) | GPL-3.0 | package recipes | 200 |
| `…/pmaports/-/raw/main/pmaports.cfg`, `channels.cfg`, `deviceinfo_schema.toml` | same | GPL-3.0 | repo schema 7, channel→alpine map, 122 deviceinfo keys | 200 |
| `…/raw/main/device/archived/device-samsung-j1mini3g/{deviceinfo,APKBUILD,kernel-cmdline.conf}` | same (bytes identical to pre-archive pin) | `license="MIT"` | archived 3G device pkg | 200 |
| `…/raw/main/device/archived/linux-samsung-j1mini3g/APKBUILD` + `config-samsung-j1mini3g.armv7` | same | `GPL-2.0-only` | archived 3.10.106 kernel pkg | 200 |
| `…/api/v4/projects/226/repository/commits/cfbc1de3…` | `cfbc1de3c7de…c313aa12` (2026-06-22; parent `a1ceca3530ecc009a74441da5d5fc4c0d84fef3c`) | GPL-3.0 | "archive unmaintained packages under device/" | 200 |
| `…/raw/main/main/soc-sprd-audio/APKBUILD`, `main/dtbtool-sprd`, `main/devicepkg-dev` | same | BSD-3 / GPL-3 | live SC8830 helpers | 200 |
| `gitlab.postmarketos.org/postMarketOS/pmbootstrap` (API 235) | tag **3.12.1** = `7d23010a125ca7386fec4e390d14128b6c24d266` (2026-10-13) | GPL-3.0-or-later | bootstrap tool | 200 |
| `…/pmbootstrap/-/raw/3.12.1/{pyproject.toml,README.md}` | 3.12.1 | GPL-3.0+ | `requires-python>=3.10`, host reqs | 200 |
| `…/pmb/{config/__init__.py,core/arch.py,helpers/devices.py,parse/arguments.py,flasher/*.py,install/_install.py}` | 3.12.1 | GPL-3.0+ | flasher table, arch enum, categories, CLI, sparse path | 200 |
| `gitlab.postmarketos.org/postMarketOS/boot-deploy` (API 193) | tag `0.25.0` = `a50452a054233c2d7bf6142cbc332c94c79cc18f` (= `main`, md5-matched) | GPL-3.0+ | boot.img/dt.img generation | 200 |
| `docs.nura.eco/pmaports/main/packaging/{device-packages/deviceinfo-reference,device-categorization,kernel-packages/kernel-cmdline}.html` | docs build of pmaports `main` | GPL-3.0 | field reference, category policy, cmdline system | 200 |
| `wiki.nura.eco/wiki/Samsung_Galaxy_J1_mini_(samsung-j1mini3g)` | last edit 2026-06-23T07:56:37Z (Knuxibot) | CC BY-SA 4.0 | device page | 200 |
| `wiki.nura.eco/wiki/Samsung_Galaxy_J1_mini_(samsung-j1minilte)` | last edit 2026-07-24T16:19:00Z (37nx) | CC BY-SA | target device page | 200 |
| `wiki.nura.eco/wiki/Pmbootstrap/Installation`, `…/Pmbootstrap/Using_pmbootstrap`, `…/Downstream_kernel` | live | CC BY-SA | install + workflow docs | 200 |
| `nura.eco/install/` | live | — | "latest stable release is Nura v26.06"; images mainline-based | 200 |
| `alpinelinux.org/releases/`; `dl-cdn.alpinelinux.org/alpine/{v3.24,edge}/main/`; `…/v3.24/releases/armv7/` | live | — | v3.24 (2026-06-09, EOL 2028-06-01), `armv7` present, `alpine-minirootfs-3.24.1-armv7.tar.gz` | 200 |
| `images.nura.eco/bpo/edge/` (+ `edge/nvidia-tegra-armv7/`) | live (67 entries) | — | armv7 images still built; no `samsung-j1*` | 200 |
| `pkgs.alpinelinux.org/package/v3.24/community/x86_64/heimdall` | live | MIT | `heimdall 2.2.2-r0` | 200 |

## 3. Findings

**1. Rename is brand-only.** `channels.cfg` (pmaports `main`): `edge → pmaports=main / aports=master`,
`v26.06 → v26.06 / 3.24-stable`, `v25.12 → v25.12 / 3.23-stable` (older = "unsupported"); recommended
channel `edge`. Current stable OS release **Nura v26.06**, development on **edge**.

**2. pmaports is canonical at `gitlab.postmarketos.org/postMarketOS/pmaports`**, project id 226, branch
`main`, HEAD **`c7940da7b44e934c103261d1f41a5559f4c4be8f`** (2026-10-23T14:13:16Z,
"linux-clockworkpi-uconsole-rpi: upgrade to 6.18.58"), `last_activity_at` 2026-10-23. `pmaports.cfg`:
`version=7`, `pmbootstrap_min_version=3.11.0`, `supported_arches=aarch64,armv7,loongarch64,ppc64le,riscv64,x86_64`,
`supported_root_filesystems=btrfs,ext4,f2fs,xfs`, `supported_firewall=nftables`,
`install_user_groups=netdev,plugdev,wheel`, `systemd_linux_min_version=5.4`, plus a second repo
`[repo:systemd] pmaports_dir=systemd`.

**3. `device/downstream` (38 dirs) no longer contains the J1 mini.** Present: j4lte, m20lte, htc-golfu,
lg-vee3e, raspberry-pi3/4/5, xiaomi-ido/monet, `soc-sprd-audio`, …

**4. The 3G package was archived, not deleted.** `device/archived/device-samsung-j1mini3g/{APKBUILD,
deviceinfo,kernel-cmdline.conf}` and `device/archived/linux-samsung-j1mini3g/` (9 files) exist at `main`.
Archiving commit `cfbc1de3c7de56251800d53d20afcf92c313aa12` (Aelin, 2026-06-22, MR 8883), parent
`a1ceca35…`, where the path was `device/downstream/device-samsung-j1mini3g/`. `deviceinfo`/`APKBUILD`
bytes are identical at both pins (deviceinfo md5 `6ae4fcccb70db74e2ab1786fe1f5a64b`).

**5. Archived `deviceinfo`** (verbatim, key lines):

```
deviceinfo_codename="samsung-j1mini3g"   deviceinfo_arch="armv7"   deviceinfo_year="2016"
deviceinfo_screen_width="480"  deviceinfo_screen_height="800"  deviceinfo_dev_touchscreen="/dev/input/event2"
deviceinfo_flash_method="heimdall-bootimg"  deviceinfo_generate_bootimg="true"
deviceinfo_bootimg_qcdt="true"  deviceinfo_bootimg_append_seandroidenforce="true"
deviceinfo_flash_offset_base="0x00000000"  deviceinfo_flash_offset_kernel="0x00008000"
deviceinfo_flash_offset_ramdisk="0x01000000"  deviceinfo_flash_offset_second="0x00f00000"
deviceinfo_flash_offset_tags="0x00000100"  deviceinfo_flash_pagesize="2048"
deviceinfo_flash_sparse="true"  deviceinfo_flash_sparse_samsung_format="1"
```

`bootimg_qcdt_type` is deliberately **unset**; the header still cites `https://postmarketos.org/deviceinfo`.

**6. Device `APKBUILD`** (verbatim): `# Archived: unmaintained`, `pkgver=4`, `pkgrel=0`,
`license="MIT"`, `arch="armv7"`, `options="!check !archcheck"`,
`depends="postmarketos-base linux-samsung-j1mini3g mkbootimg msm-fb-refresher"`,
`makedepends="devicepkg-dev"`, `source="deviceinfo kernel-cmdline.conf"`. `kernel-cmdline.conf` = one
line `console=ttyS1,115200n8` (new cmdline system, commit `0648d45d762d`).

**7. Kernel `APKBUILD`**: `pkgver=3.10.106`, `pkgrel=8`, `_flavor="samsung-j1mini3g"`,
`license="GPL-2.0-only"`, `options="!strip !check !tracedeps pmb:cross-native"`, source pinned to
`github.com/IKGapirov/android_kernel_samsung_j1mini3g/archive/6a377f7c43a84b578df39300dcce9fb9cb387a21.tar.gz`,
config **`config-samsung-j1mini3g.armv7`** (3669 lines), **8 patches**: `gcc7-give-up-on-ilog2-const-optimizations`,
`gcc8-fix-put-user`, `gcc10-extern_YYLOC_global_declaration`,
`linux3.4-ARM-8933-1-replace-Sun-Solaris-style-flag-on-section`, `linux3.4-fix-piggy.gzip.S`,
`sprdfb-fix-swapped-colors`, `sprdfb-check-for-buffering`. It builds the master DTB itself:
`dtbTool-sprd -s 2048 -p "scripts/dtc/" -o arch/arm/boot/dt.img arch/arm/boot/dts/` → installed to
`/boot/dt.img`.

**8. Config anchors**: `CONFIG_MACH_J1MINI3G=y`, `CONFIG_MACH_SAMSUNG=y`,
`CONFIG_TOUCHSCREEN_MELFAS_MCS8040L=y`, `CONFIG_FB_SCX30G=y`, `CONFIG_SPRDFB_GEN_PANEL=y`,
`CONFIG_FB_TRIPLE_FRAMEBUFFER=y`, `CONFIG_SPRD_2331=y`, `CONFIG_SPRD_DOWNLOAD_IMG=y`.

**9. boot.img creation now lives in boot-deploy 0.25.0, not pmbootstrap.** `boot-deploy-functions.sh`:
if `bootimg_qcdt=true` **and** `bootimg_qcdt_type` empty → it *expects* `/boot/dt.img` from the kernel
APKBUILD (j1mini3g layout); if a type is set it requires `deviceinfo_dtb` and calls
`dtbtool-sprd`/`dtbTool`/`dtbTool-exynos`. `append_seandroidenforce=true` appends the literal
`SEANDROIDENFORCE` string.

**10. `install` sparse path** (`pmb/install/_install.py`): when `sparse is None`, it uses
`deviceinfo.flash_sparse`; sparse + non-split → `img2simg`, then `sm-sparse-image-tool` patching when
`flash_sparse_samsung_format` is set. Split is the default only for flashers with `split=True`
(`fastboot-bootpart`, `rkdeveloptool`) — **`heimdall-bootimg` is not**, so the J1 mini gets one
combined image, exactly what the Samsung patch needs.

**11. pmbootstrap current release: 3.12.1** (`7d23010a125c…`, 2026-10-13). Tag history shows the 2.x→3.x
break: `2.3.3` (2024-10-30) → **`3.0.0` (2024-11-10)** → `3.7.0` (2025-12-14) → `3.10.0` (2026-04-04)
→ `3.11.0`/`.1` (2026-07-13) → `3.12.0` (2026-10-09) → `3.12.1`. pmaports `main` needs `>= 3.11.0`, so
a 2023-era install refuses to run.

**12. Host requirements** (`pyproject.toml` + `README.md` @3.12.1): `requires-python = ">=3.10"`, Linux
`x86/x86_64/aarch64/armv7`, kernel ≥3.17, `/tmp` with `exec`, `openssl`, `git 2.46+`, `kpartx`,
`losetup --json`, `ps`, `tar`; **WSL unsupported**. Config path is now
`$XDG_CONFIG_HOME/pmbootstrap_v3.cfg` (`_v3` = why old configs are not silently reused).

**13. Install methods** (wiki `Pmbootstrap/Installation`): git clone + symlink of `pmbootstrap.py`;
clone + copy into `~/.pmbootstrap`; **uv**
(`uv tool install --python 3.11 git+https://gitlab.postmarketos.org/postMarketOS/pmbootstrap.git`);
`pip install .`; distro packages — Alpine/Nura `apk add pmbootstrap`, Arch `pacman -S pmbootstrap`,
Debian `apt install pmbootstrap`, Fedora `dnf install pmbootstrap`, Void `xbps-install -S pmbootstrap`,
Gentoo GURU `dev-util/pmbootstrap`, Nix `nix run nixpkgs#pmbootstrap`.

**14. armv7 remains first-class**: `Arch.armv7` in `pmb/core/arch.py` and in `Arch.supported()`;
`qemu_user()=="arm"`, `alpine_triple=="armv7-alpine-linux-musleabihf"`; armv7 chroots on x86_64 need
qemu (binfmt registered by `pmb/chroot/binfmt.py`).

**15. Downstream kernels still supported** — category `downstream` exists for them
(`allows_downstream_ports()` true only for `ARCHIVED`/`DOWNSTREAM`). But `systemd_linux_min_version=5.4`:
a 3.10 kernel port **cannot run systemd**; OpenRC only.

**16. `archived` is hidden from `pmbootstrap init`** (`DeviceCategory.shown()` = main, community, testing,
downstream; `list_codenames()` drops the rest). Docs (`device-categorization`) confirm the escape hatch:
"archived ports aren't listed in `pmbootstrap init` and binary packages are not built for them. However,
they can still be manually selected and built by entering the device codename" (a warning shows the
archive reason). Archived = "port replaced by a better alternative, no longer boots, or unmaintained";
downstream = "step towards mainline; may be moved to archived at any time".

**17. CLI at 3.12.1** (`pmb/parse/arguments.py`): global `-p/--aports <path>` (comma-separated multi-repo),
`--offline`, `--details-to-stdout`; actions `init`, `install`, `flasher {flash_rootfs,flash_kernel,boot,
flash_lk2nd,flash_vbmeta,flash_dtbo,sideload,list_flavors,list_devices}`, `export`, `sideload`, `initfs`,
`qemu`, `kconfig {check,edit,migrate,generate}`, `chroot`, `build`, `bootimg_analyze`, `deviceinfo_parse`,
`apkbuild_parse`, `status`, `zap`, `shutdown`, `pull`, `netboot`, `ci`, `config`. `flasher` adds
`--method` plus heimdall `--no-reboot`/`--resume` (heimdall reboots after every flash by default).

**18. `install` flags**: `--fde`, `--filesystem {ext4,f2fs,btrfs,xfs}`, `--single-partition`,
`--split/--no-split`, `--disk/--sdcard`, `--android-recovery-zip` (+`--recovery-install-partition`,
`--recovery-no-kernel`), `--sparse/--no-sparse`, `--password`, `--sector-size`, `--add`, `--no-base`,
`--no-recommends`, `--no-sshd`, `--no-firewall`, `--zap`.

**19. Heimdall plumbing**: `heimdall-bootimg` actions = `heimdall flash --wait --SYSTEM $IMAGE` (rootfs)
and `heimdall flash --wait --KERNEL $BOOT/boot.img$FLAVOR` (kernel); defaults `KERNEL`/`SYSTEM`
(overridable via `deviceinfo_flash_heimdall_partition_*` or `--partition`). Deps from `pmaports.cfg`:
`supported_heimdall_depends=heimdall,android-tools-mkbootimg`; Alpine v3.24/community ships
`heimdall 2.2.2-r0`.

**20. Wiki `j1mini3g`** (last edit 2026-06-23): `category = archived`, `packaged = yes`,
`pmoskernel = 3.10.106`, armv7, 4 GB / 768 MB, chipset SC8830; status `usbnet Y`, `flashing P`,
`touch Y`, `screen Y`, `xwayland Y`, `battery P`, `accel Y`, wifi blank. Maintainer **dolphinchips**.
Flash mode **Power+Home+Vol Down**, recovery **Power+Home+Vol Up**. Installation: `flasher flash_rootfs`
**fails at 17 %**, `flash_kernel` works → SD-card install (untested) or Android recovery zip. Links:
MR 533 (initial), kernel `github.com/IKGapirov/android_kernel_samsung_j1mini3g` (`cm-14.1`).

**21. Wiki `j1minilte`** (last edit 2026-07-24): `codename = j1minilte`, `model = SM-J105F/DS`,
`category = Downstream`, **`packaged = no`**, `pmoskernel = 3.10.65`, SC9830, "Quad-core 1,5 GHz
Cortex-A7", Mali-400 MP2, 1 GB / 8 GB, `booting = yes`, `status = flash, boot bug`, `usbnet Y`,
`flashing P`, `touch Y`, `screen Y`, `battery P`. Contributor `Latestofmymind`. Flash-mode section
**empty**; install = `pmbootstrap init` + `pmbootstrap install --fde`.

**22. No `j1minilte` port exists in pmaports** — raw probes for
`device/{main,community,testing,downstream,archived}/device-samsung-j1minilte/deviceinfo` at `main` all
return "redirected" (absent), and commits for `device/downstream/device-samsung-j1minilte` = `[]`.

**23. Downstream devices are edge-only.** Probes: `device/downstream/device-samsung-j1mini3g/deviceinfo`
→ 404 on `v25.06`, `v25.12`, `v26.06`; `device/downstream` category absent from those branches
(`device/` at `v26.06` = `.gitlab-ci`, `.shared-patches`, `archived`, `community`, `main`, `testing`).
Cross-checked: `device-lg-vee3e`, `device-samsung-j4lte`, `device-htc-golfu`, `device-xiaomi-ido` also
404 on `v26.06` in both `downstream` and `testing`.

**24. Alpine**: stable **v3.24** (branch 2026-06-09, minors to 3.24.3, main+community EOL 2028-06-01);
`edge` rolling; v3.23 main-only. `armv7` present in `v3.24/main/` and `edge/main/`, with
`alpine-minirootfs-3.24.1-armv7.tar.gz`.

**25. armv7 images are still built** by BPO: `images.nura.eco/bpo/edge/nvidia-tegra-armv7/{console,i3wm,
mate,sxmo-de-dwm,xfce4}/`. No `samsung-j1*` images; samsung entries are a3, a5, coreprimevelte, e7,
espresso7/10, grandmax, gt510, gt58, m0, starqltechn.

**26. Reusable, non-archived SC8830 support**: `main/soc-sprd-audio` (BSD-3-Clause) → subpackage
`soc-sprd-audio-sc8830` (UCM2 `sprdphone.conf`/`HiFi` + udev rule). Also alive: `main/dtbtool-sprd`,
`main/devicepkg-dev`, `main/postmarketos-mkinitfs` (2.12.0, Go) and `main/postmarketos-base`.

## 4. Reproduce (pinned)

Host: Linux, python ≥3.10, `git ≥2.46`, `kpartx`, `losetup --json`, `openssl`, `/tmp` with `exec` (not WSL).

```sh
# 1) pinned tool (tag 3.12.1)
uv tool install --python 3.12 \
  "git+https://gitlab.postmarketos.org/postMarketOS/pmbootstrap.git@3.12.1"
pmbootstrap --version          # 3.12.1
# alternative: git clone … && git checkout 3.12.1 && ln -sf "$PWD/pmbootstrap.py" ~/.local/bin/pmbootstrap

# 2) pinned pmaports
git clone https://gitlab.postmarketos.org/postMarketOS/pmaports.git ~/pmaports-j1
cd ~/pmaports-j1 && git checkout c7940da7b44e934c103261d1f41a5559f4c4be8f

# 3) port = copy of the archived 3G packages into a visible category
git mv device/archived/device-samsung-j1mini3g device/downstream/device-samsung-j1minilte
git mv device/archived/linux-samsung-j1mini3g device/downstream/linux-samsung-j1minilte
```

Edit (values are the verified `j1mini3g` ones; `j1minilte` deltas marked):

```sh
# deviceinfo
deviceinfo_name="Samsung Galaxy J1 mini 4G"     # wiki: SM-J105F/DS
deviceinfo_codename="samsung-j1minilte"
deviceinfo_arch="armv7"
deviceinfo_screen_width="480"; deviceinfo_screen_height="800"
deviceinfo_flash_method="heimdall-bootimg"
deviceinfo_generate_bootimg="true"
deviceinfo_bootimg_qcdt="true"                  # keep; do NOT set bootimg_qcdt_type
deviceinfo_bootimg_append_seandroidenforce="true"
deviceinfo_flash_offset_base="0x00000000"
deviceinfo_flash_offset_kernel="0x00008000"
deviceinfo_flash_offset_ramdisk="0x01000000"
deviceinfo_flash_offset_second="0x00f00000"
deviceinfo_flash_offset_tags="0x00000100"
deviceinfo_flash_pagesize="2048"
deviceinfo_flash_sparse="true"
deviceinfo_flash_sparse_samsung_format="1"
# deviceinfo_dev_touchscreen -> re-derive on device (3G used /dev/input/event2)
```

```diff
# device-samsung-j1minilte/APKBUILD
-pkgname=device-samsung-j1mini3g            +pkgname=device-samsung-j1minilte
-pkgdesc="Samsung Galaxy J1 mini"           +pkgdesc="Samsung Galaxy J1 mini 4G"
-maintainer=""                              +maintainer="<name> <<you@example.org>>"   # required, else re-archived
-depends="postmarketos-base linux-samsung-j1mini3g mkbootimg msm-fb-refresher"
+depends="postmarketos-base linux-samsung-j1minilte mkbootimg msm-fb-refresher soc-sprd-audio-sc8830"
# linux-samsung-j1minilte/APKBUILD
-pkgname=linux-samsung-j1mini3g  _flavor="samsung-j1mini3g"
+pkgname=linux-samsung-j1minilte _flavor="samsung-j1minilte"
-_commit="6a377f7c43a84b578df39300dcce9fb9cb387a21"   # 3G tree; replace with the j1minilte vendor kernel commit
```

Rename the config to `config-samsung-j1minilte.armv7`, fix `CONFIG_MACH_*`, refresh checksums:

```sh
pmbootstrap -p ~/pmaports-j1 checksum linux-samsung-j1minilte
pmbootstrap -p ~/pmaports-j1 checksum device-samsung-j1minilte
```

```sh
# 4) init / build / flash
pmbootstrap -p ~/pmaports-j1 init            # samsung → j1minilte → UI (xfce4/none) → downstream kernel
pmbootstrap -p ~/pmaports-j1 install         # combined image + Samsung sparse patching
pmbootstrap -p ~/pmaports-j1 export          # symlink .img / boot.img for inspection
pmbootstrap -p ~/pmaports-j1 flasher --method heimdall-bootimg list_devices
pmbootstrap -p ~/pmaports-j1 flasher flash_kernel
pmbootstrap -p ~/pmaports-j1 flasher flash_rootfs        # add --partition <name> if SYSTEM is wrong

# documented fallbacks for the 17 % rootfs failure
pmbootstrap -p ~/pmaports-j1 install --android-recovery-zip
pmbootstrap -p ~/pmaports-j1 flasher sideload
pmbootstrap -p ~/pmaports-j1 install --disk /dev/mmcblk0   # SD-card boot (untested upstream)

# static checks before hardware
pmbootstrap -p ~/pmaports-j1 deviceinfo_parse samsung-j1minilte
pmbootstrap -p ~/pmaports-j1 kconfig check linux-samsung-j1minilte   # expect failures on 3.10
```

## 5. Gaps / risks

1. **No `j1minilte` kernel pin.** `IKGapirov/…j1mini3g@6a377f7c` is the 3G/SC8830 tree; booting the LTE
   board with a `CONFIG_MACH_*`/DTB switch is unverified. [INFERENCE] a separate SC9830I vendor tree or
   defconfig will be needed.
2. **`deviceinfo_dev_touchscreen`** is undocumented for `j1minilte`; `event2` is only proven on 3G. Read
   `/proc/bus/input/devices` in a live session.
3. **Offsets/pagesize** are inherited. [INFERENCE] shared inside the Samsung SC9830 family, but re-derive
   with `pmbootstrap bootimg_analyze` against a stock `j1minilte` `boot.img`.
4. **`flash_rootfs` fails at 17 % on the sibling** (wiki); heimdall `SYSTEM` + Samsung-sparse is the main
   risk area → recovery zip or `--partition userdata` are the documented workarounds.
5. **Wi-Fi unresolved on 3G** (needs `download`/`wcnd` blobs from `/system/bin`; libhybris or Tizen-style
   reimplementation). Expect the same blocker on `j1minilte`.
6. **Downstream is edge-only** and archived on maintainer loss (already happened to `j1mini3g`): always
   pin pmaports; never promise release-branch support.
7. **No systemd** (`systemd_linux_min_version=5.4`) — OpenRC only.
8. **Docs/wiki are moving targets**; only the git pins above are reproducible. boot-deploy was pinned at
   `0.25.0` and md5-matched `main` on 2026-10-23 — re-verify after releases.
9. **Rebrand churn**: old domains redirect today (200), but package search/blog/CI all moved; even
   `pmaports.cfg` now references `https://nura.eco/pmaports.cfg`.

## 6. Recommendation

- Port against **edge, pinned**: pmbootstrap **3.12.1** (`7d23010a125ca7386fec4e390d14128b6c24d266`) +
  pmaports `c7940da7b44e934c103261d1f41a5559f4c4be8f`. Release branches contain no downstream devices
  at all, so they are not an option.
- **Fork, don't resurrect in place**: copy the archived `j1mini3g` device+kernel packages into
  `device/downstream/device-samsung-j1minilte` in your own pmaports fork and drive it with `-p`. This
  sidesteps the hidden-archived-codename path and keeps the pin explicit.
- **Keep the boot path byte-compatible with the 3G sibling** (`heimdall-bootimg`, `bootimg_qcdt=true`
  with no `_type`, `SEANDROIDENFORCE`, Samsung sparse format 1); change only kernel/config/touchscreen.
  Those values are Samsung quirks, and kernel-generated `/boot/dt.img` is what boot-deploy expects.
- **Scope the deliverable realistically**: SC8830-family 3.10.106 + sprdfb + Melfas touch can plausibly
  reach boot/display/touch/USB-networking — the exact statuses `j1mini3g` reached. Wi-Fi/camera/modem
  are research items; document the mainline dead end instead of claiming them.
- **Reuse `soc-sprd-audio-sc8830`** (maintained) and register a named maintainer so the port isn't swept
  into `archived` by the next unmaintained purge.

## Appendix — raw URLs used

```
https://nura.eco/  /install/  /source-code/  /mirrors/
https://nura.eco/blog/2026/09/27/nura-rename/   /blog/2024/12/09/pmOS-update-2024-11/   /blog/2026/06/21/v26.06-release/
https://gitlab.postmarketos.org/api/v4/projects/226/repository/{branches/main,commits/cfbc1de3c7de56251800d53d20afcf92c313aa12}
https://gitlab.postmarketos.org/api/v4/projects/226/repository/{tree?path=device/downstream&ref=main,tree?path=device/archived&ref=main&page=3}
https://gitlab.postmarketos.org/api/v4/projects/226/repository/commits?path=device/downstream/device-samsung-j1mini3g
https://gitlab.postmarketos.org/postmarketOS/pmaports/-/raw/main/{pmaports.cfg,channels.cfg,deviceinfo_schema.toml,LICENSE}
https://gitlab.postmarketos.org/postmarketOS/pmaports/-/raw/main/device/archived/device-samsung-j1mini3g/{deviceinfo,APKBUILD,kernel-cmdline.conf}
https://gitlab.postmarketos.org/postMarketOS/pmaports/-/raw/main/device/archived/linux-samsung-j1mini3g/{APKBUILD,config-samsung-j1mini3g.armv7}
https://gitlab.postmarketos.org/postmarketOS/pmaports/-/raw/a1ceca3530ecc009a74441da5d5fc4c0d84fef3c/device/downstream/device-samsung-j1mini3g/deviceinfo
https://gitlab.postmarketos.org/postMarketOS/pmaports/-/raw/main/main/{soc-sprd-audio,dtbtool-sprd,devicepkg-dev,postmarketos-mkinitfs,postmarketos-base}/APKBUILD
https://gitlab.postmarketos.org/api/v4/projects/235/repository/{tags?per_page=40,tags/3.12.1}
https://gitlab.postmarketos.org/postMarketOS/pmbootstrap/-/raw/3.12.1/{pyproject.toml,README.md,pmb/config/__init__.py,pmb/core/arch.py,pmb/helpers/devices.py,pmb/parse/arguments.py,pmb/flasher/init.py,pmb/flasher/variables.py,pmb/install/_install.py,pmb/chroot/binfmt.py}
https://gitlab.postmarketos.org/api/v4/projects/193/repository/tags?per_page=3
https://gitlab.postmarketos.org/postMarketOS/boot-deploy/-/raw/0.25.0/boot-deploy-functions.sh
https://docs.nura.eco/pmaports/main/packaging/{device-packages/deviceinfo-reference,device-categorization,kernel-packages/kernel-cmdline}.html
https://wiki.nura.eco/api.php?action=query&prop=revisions&titles={Samsung%20Galaxy%20J1%20mini%20(samsung-j1mini3g),Samsung%20Galaxy%20J1%20mini%20(samsung-j1minilte),Pmbootstrap%2FInstallation,Pmbootstrap%2FUsing%20pmbootstrap,Downstream%20kernel}
https://alpinelinux.org/releases/
https://dl-cdn.alpinelinux.org/alpine/v3.24/main/    /alpine/edge/main/    /alpine/v3.24/releases/armv7/
https://images.nura.eco/bpo/edge/    /bpo/edge/nvidia-tegra-armv7/
https://pkgs.alpinelinux.org/package/v3.24/community/x86_64/heimdall
https://gitlab.com/api/v4/projects/postmarketOS%2Fpmaports
```
