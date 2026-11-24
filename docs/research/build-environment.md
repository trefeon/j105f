# Build environment dossier — Project J105F

**Measured 2026-10-23** on the three hosts this project has (Windows workstation, local Linux build host, small cloud VPS)
plus the GitHub Actions state of `trefeon/j105f`; every capability below was produced by running the command
on the host with the key output pasted. Documentation-only facts are marked `[DOC]`, derived `[INFERENCE]`.

## 1. Scope

Which host can build what for `j1minilte` (SM-J105F, SC9830I, kernel 3.10.65) today: kernel `zImage` + SPRD
`dt.img` + `boot.img`, TWRP recovery (AOSP 6.0), Android 5.1.1 ROM, postmarketOS armv7 rootfs. Not in scope:
flash procedure (`docs/delivery/e1-flash-commands.md`), OS choice (`docs/adr/0002-os-track.md`).

## 2. Measured hosts

### 2.1 Windows workstation — control plane only

```
OS Windows 10.0.26300 x64 · 8C/16T · 32 GB RAM · PowerShell 5.1 · OpenSSH 10.5p1 · tar 1.35
python 3.14.7 · node v24.22.0 · npm 11.19.0 · git 2.55.0.windows.5 · gh 2.102.0 · java 21.0.12.1 Temurin
7-Zip 26.02 · curl · dos2unix present · rsync MISSING       disk: ~1.8 TB free across fixed volumes
absent (command -v empty): adb(PATH) docker make gcc g++ heimdall odin repo pmbootstrap
wsl --status → "The Windows Subsystem for Linux is not installed."
```

Android tooling is vendored in-repo, so no PATH install is needed:
```
$ ./tools/platform-tools/adb.exe version → Android Debug Bridge version 1.0.41 / Version 37.0.1-15733141
$ ./tools/platform-tools/fastboot.exe --version → fastboot version 37.0.1-15733141
$ ./tools/platform-tools/adb.exe devices → List of devices attached        (no phone connected)
source.properties: Pkg.Revision=37.0.1
```

No Odin/Heimdall/Samsung driver: `ls "/c/Program Files" | grep -i 'odin|samsung|heimdall'` → `NONE_FOUND`,
`C:\Windows\INF` samsung match count `0`.

**Two blockers for building here (measured):**

1. NTFS cannot materialise the kernel tree. `git archive HEAD kernel` →
   `error: invalid path 'kernel/drivers/gpu/drm/nouveau/core/subdev/i2c/aux.c'`. `git ls-files -v kernel`
   lists **13** `skip-worktree` paths: that `aux.c` plus the case-colliding `xt_*.h`/`xt_*.c` netfilter pairs.
2. The worktree is CRLF against an LF index: `git ls-files --eol kernel/lib/Kconfig` → `i/lf  w/crlf  attr/`,
   and there is **no `.gitattributes`**. A tree copied from here dies in kconfig (reproduced in §5):
   `scripts/kconfig/check.sh: ... $'\r'` / `arch/arm/Kconfig:99: unknown option "With"`.

### 2.2 Linux build host — primary build box

```
Ubuntu 24.04 LTS · Linux 6.8 · 2C/4T
16 GiB RAM · ~300 GB free · groups include sudo docker kvm · sudo -n true → OK · /dev/kvm
docker 29.9.2 (driver=overlay2 cgroup=2 images=48; docker system df: 12.46GB images, 5.02GB reclaimable)
gcc 13.3.0 · make 4.3 · python3 3.12.3 (pip 26.1.2) · java openjdk 21.0.12.1 · git 2.43.0 · gh 2.45.0
repo launcher 2.36 · simg2img 34.0.4 · dtc 1.7.0 · lz4 1.9.4 · zstd 1.5.5 · cpio 2.15 · zip 3.0
e2fsck 1.47.0 + mkfs.ext4 · ccache 4.9.1 · 12 /dev/loop* devices · unzip
MISSING: flex · bison · python2 · pmbootstrap · mkbootimg · dtbtool-sprd · heimdall · qemu-arm-static (before install)
apt candidates measured: gcc-arm-linux-gnueabihf 4:13.2.0-7ubuntu1 · gcc-arm-none-eabi 15:13.2.rel1-2
  openjdk-8-jdk 8u504-ga-1ubuntu1~24.04.3 · openjdk-11-jdk 11.0.32.1 · heimdall-flash 2.0.2-2build2
  android-sdk-libsparse-utils 1:34.0.4-1build3 · lz4 1.9.4 · repo 2.36.1 · device-tree-compiler 1.7.0
```

**armv7 execution — the gate for pmbootstrap / armhf work — needed a fix:**

```
before: /proc/sys/fs/binfmt_misc/qemu-arm → flags: PO   (qemu-user + qemu-user-binfmt)
        docker run --rm --platform linux/arm/v7 alpine:3.21 uname -m
        → exec /bin/uname: no such file or directory        (no "F" flag → interpreter looked up
                                                             inside the container root)
after:  apt-get install -y qemu-user-static → flags: POF, arm-binfmt-P -> ../../bin/qemu-arm-static
        docker run … uname -m → armv7l
```

Native chroot (what pmbootstrap does), alpine 3.21 armhf minirootfs:

```
$ sudo chroot /tmp/armv7root /bin/sh -c "uname -m; cat /etc/alpine-release; apk --version"
armv7l / 3.21.0 / apk-tools 2.14.6, compiled for armhf.
```

**pmbootstrap is not on PyPI** (`pip install pmbootstrap` → `from versions: none`); source install works:

```
git clone --depth 1 https://gitlab.postmarketos.org/postMarketOS/pmbootstrap.git
HEAD ff954a63c7a5ead5045150f5a79f035259512df2 (2026-10-21) · pyproject requires-python = ">=3.10"
$ pmbootstrap --version → 3.12.1
```

`docker run --rm ubuntu:22.04` → `Ubuntu 22.04.5 LTS` (CI-parity container available).

### 2.3 Cloud VPS — not a build host

```
Linux 7.0-azure x86_64 · 2 vCPU · 887 MB RAM + 4 GB swap
/ 29G, 14G free · docker 29.9.2 · gcc · make · python3 · git · losetup · sudo OK · zstd · cpio
absent: any arm cross compiler, qemu-arm-static, ccache
apt-get install gcc-arm-linux-gnueabihf → arm-linux-gnueabihf-gcc -O2 → ELF 32-bit LSB pie ARM EABI5
```

Verdict: cross-compiling a standalone file works, but 887 MB RAM + 14 GB disk rule out a kernel build
(the Linux build host needs a 2.0 GB clone + 110 MB toolchain + 1.9 GB objects with 4 concurrent gcc
processes — on 887 MB that is swap-bound `[INFERENCE]`), a `repo sync` (20–40 GB class) or any image work.

### 2.4 GitHub Actions — `trefeon/j105f`

```
gh repo view → trefeon/j105f PUBLIC, size 132789 KB
gh api /repos/trefeon/j105f/actions/runners --jq .total_count → 0            (hosted only)
gh api .../actions/permissions → {"enabled":true,"allowed_actions":"all","sha_pinning_required":false}
gh api .../actions/permissions/artifact-and-log-retention → {"days":90,"maximum_allowed_days":90}
gh api /users/trefeon/settings/billing/actions → 404, "needs the \"user\" scope"  (token: read:org,repo,…)
```

Workflows: `kernel.yml` (boot.img) and `recovery.yml` (TWRP) — both `on: workflow_dispatch` only, both
`runs-on: ubuntu-22.04`. Last two runs (2026-10-23T13:57Z, push) were **cancelled**: the kernel job passed
`Install build dependencies`, `Toolchain (arm-eabi-4.8 …)`, `Configure kernel (j1minilte_linux_defconfig)`
and was cancelled inside `Build zImage`. The toolchain step really fetched and ran:

```
Cloning into '/opt/toolchains/arm-eabi-4.8'...
warning: refs/tags/android-5.1.1_r38 f2b904ee... is not a commit!      (annotated tag)
arm-eabi-gcc (GCC) 4.8
Runner image: ubuntu22/20261012.322  (from the job log)
```

`ubuntu-22.04` = 4 CPU / 16 GB RAM / 14 GB SSD and standard runners are "free and unlimited on public
repositories"; default job timeout 6 h `[DOC]` — the 14 GB SSD, not minutes, is the real constraint.

## 3. Capability matrix

**Y** measured working · **N** measured impossible/absent · **Y\*** works after the listed install

| Capability | Windows | Linux build host | cloud VPS | GH `ubuntu-22.04` |
|---|---|---|---|---|
| kernel 3.10 `zImage` cross-build | **N** (NTFS `aux.c`, CRLF) | **Y** — 856 s `-j4` (§5) | **N** (887 MB, 14 GB) | **Y** (green run 2026-08-11) |
| `dt.img` / `boot.img` packing | Y (python `tools/bootimg/`) | Y | Y | Y |
| initramfs (cpio + static busybox) | N (no make/cpio) | **Y\*** (`cpio 2.15`) | Y\* | Y |
| TWRP recovery (repo + py2.7 + JDK8) | **N** (no Linux, no JDK 8) | **Y\*** (`openjdk-8-jdk` 8u504 + python2 from source) | **N** | Y (`recovery.yml`) |
| Android 5.1.1 ROM | **N** | **Y\*** same prereqs, ~100 GB `[INFERENCE]` | **N** | Y `[INFERENCE]` |
| pmOS rootfs (pmbootstrap, armv7) | **N** | **Y** (3.12.1 + measured armv7 chroot) | **N** | untested `[INFERENCE]` |
| armv7 user space (binfmt `POF`) | N | **Y** (`armv7l`) | N | Y `[INFERENCE]` |
| sparse images / ext4 (`simg2img`, `mkfs.ext4`) | N (only `mke2fs.exe`) | **Y\*** | N | Y |
| flash device (Odin / heimdall) | **N** (neither installed) | **N** (apt candidate only) | N | N (no USB) |
| `adb` / `fastboot` to phone | **Y** (37.0.1 vendored) | N | N | N |

## 4. Toolchain matrix (source + pin)

| Tool | Source | Pin | Verified |
|---|---|---|---|
| `arm-eabi-4.8` (kernel) | `android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8` | tag `android-5.1.1_r38` (annotated `f2b904ee…` → commit `26e93f6af47f…`), 110 MB | cloned on the build host, `GCC 4.8`; same in CI log |
| LineageOS fallback (in both workflows) | `github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-eabi-4.8` | — | **dead**: `Repository not found` |
| `arm-linux-gnueabihf-gcc` | Ubuntu 24.04 `gcc-arm-linux-gnueabihf` / Alpine armv7 gcc | 4:13.2.0-7ubuntu1 (host gcc 13.3.0) | installed on the VPS, produced ARM EABI5 ELF |
| `dtbtool-sprd` | pmaports `main/dtbtool-sprd` → `gitlab.com/Grimler/dtbtool-sprd` | pkgver **1.1.2**, MIT, `depends=dtc` | APKBUILD fetched from pmaports API |
| `dt.img` packer (used instead) | `tools/bootimg/pack_dtimg.py` (repo) | — | byte-identical to device `prebuilt/dtb` (329 728 B) |
| `mkbootimg` (used) | `tools/bootimg/pack_bootimg.py` (repo, v0 format) | — | `--help` on py3.14; CI verifies header |
| `mkbootimg` (alt) | pmaports `mkbootimg-osm0sis` → `github.com/osm0sis/mkbootimg` | **2021.08.06** | APKBUILD fetched |
| `simg2img` | `android-sdk-libsparse-utils` / AOSP `system/core/libsparse` | 1:34.0.4-1build3 | usage line printed |
| AOSP mkbootimg source | `android.googlesource.com/platform/system/tools/mkbootimg/` | HTTP 200 | fetched |
| e2fsprogs · cpio · lz4 · zstd · dtc | Ubuntu 24.04 | 1.47.0 · 2.15 · 1.9.4 · 1.5.5 · 1.7.0 | version commands |
| `heimdall` | apt `heimdall-flash` | **2.0.2-2build2**; upstream newest tag `v1.4.2` | apt candidate + `gh api .../tags` |
| `Odin3` | proprietary, Windows-only | absent | `ls "C:\Program Files"` → `NONE_FOUND` |
| `pmbootstrap` | `gitlab.postmarketos.org/postMarketOS/pmbootstrap` (not on PyPI) | **ff954a63** (2026-10-21) → 3.12.1 | installed from source |
| `pmaports` | `gitlab.postmarketos.org/postMarketOS/pmaports` | default branch **`main`** @ `c7940da7…` (activity 2026-10-23T14:11Z) | GitLab API + `ls-remote` |
| pmaports old home | `gitlab.com/postmarketOS/pmaports` | `master` @ `817ed870…` (read-only mirror, behind) | `ls-remote`, HTTP 200 |
| `repo` launcher | apt `repo` / `storage.googleapis.com/git-repo-downloads/repo` | 2.36 (apt 2.36.1-1ubuntu0.1) | installed + launcher runs |

## 5. Kernel build on the Linux build host — measured end to end

The tree must arrive as LF with `aux.c` present, so it is **cloned on the Linux host**:

```
git clone --depth 1 https://github.com/trefeon/j105f.git ~/j105f-build/src
cd src/kernel && make ARCH=arm CROSS_COMPILE=~/toolchains/arm-eabi-4.8/bin/arm-eabi- \
   j1minilte_linux_defconfig && … olddefconfig && time make … -j4 zImage
```

```
CLONE_SECONDS=27 · .git 136M · kernel/ 615M · DEFCONFIG_OK · OLDDEFCONFIG_OK
CONFIG_MACH_J1MINILTE=y CONFIG_DEVTMPFS=y CONFIG_DEVTMPFS_MOUNT=y CONFIG_FRAMEBUFFER_CONSOLE=y CONFIG_VT=y
BUILD_OK · BUILD_SECONDS=856   (14 min 16 s, make -j4, load average 5.77/8.07 — box shared)
-rwxrwxr-x 5208936 arch/arm/boot/zImage
9e671935ef581d4812407cd84acc80f1267aa6f9ad3c358b41807d5df1b615bf  arch/arm/boot/zImage
```

- Footprint: `kernel/` with objects **1.9 GB**, whole clone 2.0 GB, toolchain 110 MB; free disk 302 → 300 GB.
- RAM during build: 7.1 GiB used of 16 GiB with 8.8 GiB page cache — `-j4` is comfortable here.
- The first attempt, from a **copy of the Windows worktree**, failed before compiling —
  `scripts/kconfig/check.sh: syntax error near unexpected token '$'\r''`, `arch/arm/Kconfig:99: unknown
  option "With"` — reproducing §2.1 on Linux.
- vs the 2026-08-11 CI artifact (5 209 144 B, same toolchain): 208 B smaller — embedded `UTS_VERSION` metadata, not a config delta `[INFERENCE]`.

## 6. Setup commands (Linux build host, pinned; every line executed above except as noted)

```bash
# 1. Android packaging + armv7 execution. qemu-user-static is REQUIRED (stock qemu-user-binfmt = flags PO
#    → every armv7 exec fails with ENOENT).
sudo apt-get update && sudo apt-get install -y lz4 android-sdk-libsparse-utils device-tree-compiler \
     ccache repo cpio zstd qemu-user-static
docker run --rm --platform linux/arm/v7 alpine:3.21 uname -m        # expect armv7l

# 2. AOSP-5.1 kernel toolchain (110 MB, 8 s warm)
git clone --depth 1 --branch android-5.1.1_r38 --single-branch \
  https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8 ~/toolchains/arm-eabi-4.8
~/toolchains/arm-eabi-4.8/bin/arm-eabi-gcc --version | head -1       # GCC 4.8

# 3. Source tree with LF endings — never from the Windows worktree
git clone --depth 1 https://github.com/trefeon/j105f.git ~/j105f-build/src

# 4. postmarketOS tooling (not on PyPI)
git clone --depth 1 https://gitlab.postmarketos.org/postMarketOS/pmbootstrap.git ~/pmbootstrap
python3 -m venv ~/.venvs/pmb && ~/.venvs/pmb/bin/pip install -e ~/pmbootstrap
~/.venvs/pmb/bin/pmbootstrap --version                               # 3.12.1

# 5. Only for TWRP / ROM work (not installed during this survey)
sudo apt-get install -y openjdk-8-jdk flex bison gperf libncurses5 libtinfo5 \
     lib32ncurses5-dev gcc-multilib g++-multilib
# python2.7 is not packaged for 24.04: build python.org 2.7.18 from source (as recovery.yml does)

docker pull ubuntu:22.04        # 6. CI-parity container
```

## 7. Recommended topology

| Artifact | Host | Why (measured) |
|---|---|---|
| `zImage` + `dt.img` + initramfs + `boot.img` | **GH Actions 22.04** for releases, **local Linux build host** for iteration | CI: 4 vCPU/16 GB, toolchain clone in seconds; build host: 14 min per full kernel build on a 2011-era 2C/4T CPU |
| TWRP recovery | **GH Actions only** | needs `repo sync` + python2.7 + JDK 8; the build host has ~300 GB free but no py2 and would serialize with other work |
| Android 5.1.1 ROM | **GH Actions only** | same tree, bigger artifact; the cloud VPS excluded (887 MB) |
| pmOS rootfs / device packages | **local Linux build host** | only host with a working armv7 chroot + pmbootstrap 3.12.1 |
| packing/verification (`tools/bootimg/*.py`) | anywhere incl. Windows | pure python, no deps |
| flashing | Windows + Odin (or `heimdall` once installed) | only host with the phone's USB; both tools absent today |

Disk/time: kernel = 2.0 GB clone + 110 MB toolchain + 1.9 GB objects, 14 min at `-j4` (measured); TWRP/ROM =
20–40 GB tree + 12 GB swap, tens of minutes on a hosted runner `[INFERENCE from recovery.yml]`; pmOS = 2–4 GB
chroot `[INFERENCE]`. Windows headroom (~1.8 TB across fixed volumes) is staging space only.

## 8. Gaps and defects found

1. **Dead fallback URL** in both workflows: the LineageOS `…arm_eabi-4.8` repo does not exist (`Repository
   not found`); the googlesource primary works, so the fallback is decoration.
2. **No `.gitattributes`** → Windows worktree `w/crlf` against `i/lf`; any tree shipped from Windows fails
   in kconfig. Fix: `kernel/** text eol=lf` (+ `*.sh`) then re-checkout.
3. **13 `skip-worktree` kernel paths** make the Windows worktree an incomplete 3.10 tree; `git archive` from
   it fails outright. Never use it as build input.
4. **`qemu-user-static` is mandatory** on the build host: stock `qemu-user-binfmt` registers `PO` (no `F` flag) → armv7 exec ENOENT.
5. **`pmbootstrap` is not installable from PyPI** — any doc saying `pip install pmbootstrap` is wrong.
6. **No flasher anywhere**: Heimdall absent on both Linux hosts, Odin + Samsung USB driver absent on Windows;
   `adb devices` was empty, so nothing phone-side is measured.
7. **Billing not queryable** with the current token (no `user` scope → 404). Moot on a public repo (free
   standard runners `[DOC]`), but there is no cost guardrail if the repo goes private.
8. **The build host lacks `flex`/`bison`** — harmless for this 3.10 kernel (ships `zconf.*_shipped`), fatal for
   most AOSP host tools; install with the §6 step 5 block. The cloud VPS stays excluded from all build work (§2.3).
