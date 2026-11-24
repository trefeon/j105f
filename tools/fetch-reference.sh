#!/usr/bin/env bash
# Fetch the pinned reference corpus into reference/ (gitignored).
#
# Usage:  bash tools/fetch-reference.sh [--check]
#   --check   verify local corpus against the pins below; download nothing
#
# Design notes:
# - Every entry is pinned to a commit SHA or a branch+HEAD recorded on 2026-10-23;
#   LTE-model-only additions (see docs/research/lte-models.md) were verified 2026-11-24.
# - 3G/SCX30G material is deliberately EXCLUDED (quarantined in .reference_delete/,
#   gitignored). Do not add j1mini3g sources here — see lte-models.md §6 hard rule.
# - Branch tips move; a mismatch is reported, never silently accepted.
# - Large trees use partial clone (--filter=blob:none) + sparse-checkout.
# - Windows: `core.protectNTFS=false` is required for aux.c; the stock dump has one
#   NTFS-invalid path (bootimg/01_dtbdump_@0<`.dtb) that is excluded from checkout.
# - Nothing here is committed: reference/ and tools/platform-tools/ are gitignored.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REF="${REF:-$ROOT/reference}"
CHECK=0
[[ "${1:-}" == "--check" ]] && CHECK=1

say()  { printf '%s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

need_git() { command -v git >/dev/null || fail "git not found"; }

# head_of <dir>
head_of() { git -C "$1" rev-parse HEAD 2>/dev/null || true; }

# checkout_safe <dir>
# Windows cannot materialize NTFS-reserved paths; the corpus only needs the
# tracked exclusion applied at clone time, never a silent partial tree.
checkout_safe() {
  local dir="$1" pin="$2"
  local have; have="$(head_of "$dir")"
  if [[ "$have" == "$pin" ]]; then
    say "  ok  $(basename "$dir") @ ${pin:0:12}"
    return 0
  fi
  if (( CHECK )); then
    fail "$(basename "$dir"): have ${have:0:12} want ${pin:0:12}"
  fi
  if ! git -C "$dir" rev-parse -q --verify FETCH_HEAD >/dev/null; then
    git -C "$dir" fetch -q --depth 1 origin "$pin"
  fi
  git -C "$dir" -c core.protectNTFS=false checkout -q FETCH_HEAD
  have="$(head_of "$dir")"
  [[ "$have" == "$pin" ]] || fail "$(basename "$dir"): checked out ${have:0:12}, expected ${pin:0:12}"
  say "  ok  $(basename "$dir") @ ${pin:0:12}"
}

# fetch_commit <url> <dir> <sha> [sparse-path...]
fetch_commit() {
  local url="$1" dir="$2" sha="$3"; shift 3
  if [[ -d "$dir" ]] && [[ "$(head_of "$dir")" == "$sha" ]]; then
    say "  ok  ${dir#$REF/} @ ${sha:0:12} (present)"; return 0
  fi
  (( CHECK )) && fail "${dir#$REF/} missing (want ${sha:0:12})"
  mkdir -p "$dir"
  if [[ ! -d "$dir/.git" ]]; then
    git -C "$dir" init -q
    git -C "$dir" remote add origin "$url"
  fi
  say "  ..  fetching ${dir#$REF/} @ ${sha:0:12}"
  git -C "$dir" fetch -q --depth 1 origin "$sha"
  if (($#)); then
    git -C "$dir" sparse-checkout init --cone
    git -C "$dir" sparse-checkout set "$@"
  fi
  checkout_safe "$dir" "$sha"
}

# fetch_sparse <url> <dir> <branch> <sha> <sparse-path...>
# Partial clone by branch, then sparse-checkout. Pin is the branch HEAD at
# capture time; a moved tip is reported by checkout_safe.
fetch_sparse() {
  local url="$1" dir="$2" branch="$3" sha="$4"; shift 4
  if [[ -d "$dir" ]] && [[ "$(head_of "$dir")" == "$sha" ]]; then
    say "  ok  ${dir#$REF/} @ ${sha:0:12} (present)"; return 0
  fi
  (( CHECK )) && fail "${dir#$REF/} missing (want ${sha:0:12})"
  say "  ..  cloning ${dir#$REF/} (${branch})"
  git clone -q --filter=blob:none --no-checkout --depth 1 \
    --branch "$branch" "$url" "$dir"
  git -C "$dir" sparse-checkout init --cone
  git -C "$dir" sparse-checkout set "$@"
  checkout_safe "$dir" "$sha"
}

# fetch_shallow <url> <dir> <branch> <sha>
fetch_shallow() {
  local url="$1" dir="$2" branch="$3" sha="$4"
  if [[ -d "$dir" ]] && [[ "$(head_of "$dir")" == "$sha" ]]; then
    say "  ok  ${dir#$REF/} @ ${sha:0:12} (present)"; return 0
  fi
  (( CHECK )) && fail "${dir#$REF/} missing (want ${sha:0:12})"
  say "  ..  cloning ${dir#$REF/} (${branch})"
  git -c core.protectNTFS=false clone -q --depth 1 --no-checkout \
    --branch "$branch" "$url" "$dir"
  checkout_safe "$dir" "$sha"
}

need_git
mkdir -p "$REF"

say "== postmarketOS/Nura recipes (sparse, pinned main HEAD 2026-10-23)"
fetch_sparse "https://gitlab.postmarketos.org/postMarketOS/pmaports.git" \
  "$REF/pmaports" main c7940da7b44e934c103261d1f41a5559f4c4be8f \
  main/dtbtool-sprd main/boot-deploy main/devicepkg-dev \
  main/mkbootimg-osm0sis main/msm-fb-refresher main/postmarketos-base \
  main/postmarketos-base-downstream main/postmarketos-mkinitfs \
  main/postmarketos-zram main/sm-sparse-image-tool \
  device/.shared-patches/linux

say "== stock device dump (system + boot/recovery + TWRP tree; sparse)"
fetch_sparse "https://github.com/Galaxy-J105F-Resources/samsung_j1minilte_dump.git" \
  "$REF/j1minilte-dump" \
  "j1miniltexx-user-5.1.1-LMY47V-J105FXXS0ARD2-release-keys" \
  aceed8396fa345b17434ca2980b5f34abf021c5c \
  boot bootRE bootdts ikconfig twrp-device-tree system

say "== device trees and vendor blobs (shallow, pinned branch HEADs)"
fetch_shallow "https://github.com/NotNoelChannel/android_device_samsung_j1minilte.git" \
  "$REF/android/device_j1minilte_cm13" cm-13.0 52b80ac79c9edfd3e1a55bf42fb3b328f0a2082b
fetch_shallow "https://github.com/NotNoelChannel/twrp_device_samsung_j1minilte.git" \
  "$REF/android/twrp_device_j1minilte" twrp-5.1 f5b96747e059e501e5e81b79a319561a692e1e9a
fetch_shallow "https://github.com/NotNoelChannel/proprietary_vendor_samsung_j1minilte.git" \
  "$REF/android/vendor_j1minilte_cm13" cm-13.0 f674dd4157bfab6cbc740a3908284de620e48505
fetch_shallow "https://github.com/djeman/android_device_samsung_sharkls-common.git" \
  "$REF/android/device_sharkls-common_cm141" cm-14.1 d0b1da8f14117f88d9e9a1b9b00d2c868afce063

say "== kernels (shallow, pinned)"
fetch_shallow "https://github.com/djeman/android_kernel_samsung_sharkls.git" \
  "$REF/kernels/sharkls_cm141" cm-14.1 0502c3a5bb4de36a399ad075fe945761428a5a2c
fetch_shallow "https://github.com/MayuriLabs/android_kernel_samsung_j1minilte.git" \
  "$REF/kernels/j1minilte_mayuri" master 5f4f03bd4899c988d33302b0d7543ff8a0694996
# The only tree that pairs a native j1minilte_defconfig with the cm-14.1 kernel layout.
fetch_shallow "https://github.com/Galaxy-J105F-Resources/kernel_samsung_sharkls.git" \
  "$REF/kernels/sharkls_g105f" cm-14.1 1df22d20250a335561f5f2bebd2fe95f62c2f4ee

say "== LTE-model kernel mirrors (j1minilte only; verified 2026-11-24)"
fetch_shallow "https://github.com/TeamWin/android_kernel_samsung_j1minilte.git" \
  "$REF/kernels/j1minilte_teamwin" android-5.1 7641d1bbd0f8ed29595fd4d1fab55741f36bcd9a
fetch_shallow "https://github.com/napoleonlijun/android_kernel_samsung_j1minilte.git" \
  "$REF/kernels/j1minilte_napoleonlijun" master 9b41876e97c1b034a45a7d65efc24790af2b54fe
fetch_shallow "https://github.com/NotNoelChannel/android_kernel_samsung_j1minilte.git" \
  "$REF/kernels/j1minilte_notnoel" cm-14.1 3127397b465d223da75a51095e21d447a8d2d995

say "== Android vendor trees (shallow, pinned; blob sources)"
fetch_shallow "https://github.com/Galaxy-J105F-Resources/android_vendor_sprd.git" \
  "$REF/android/vendor_sprd_cm141" cm-14.1 087a5490809fd8ce29d65013e9895c3f4bb2f16c
fetch_shallow "https://github.com/djeman/android_vendor_samsung_common.git" \
  "$REF/android/vendor_samsung_common_cm141" cm-14.1 8cae5ca14cad355d523ed4b4db3f59ae7ddc157f

say "== build tools"
fetch_shallow "https://gitlab.postmarketos.org/postMarketOS/pmbootstrap.git" \
  "$REF/tools/pmbootstrap" 3.12.1 7d23010a125ca7386fec4e390d14128b6c24d266
fetch_shallow "https://github.com/Benjamin-Dobell/Heimdall.git" \
  "$REF/tools/heimdall" master 3997d5cc607e6c603c6e7c0d07e42e9868c62af2

say "== Alpine armv7 minirootfs (for custom-userspace work)"
ALP="$REF/alpine/alpine-minirootfs-3.24.3-armv7.tar.gz"
ALP_SHA="dc1ddfaf03ede4be79ad7475490f6b7859dbcbbbbb85150aa1ee013b4bc2f0c1"
if [[ -f "$ALP" ]]; then
  say "  ok  alpine-minirootfs-3.24.3-armv7.tar.gz (present)"
elif (( CHECK )); then
  fail "alpine minirootfs missing"
else
  mkdir -p "$REF/alpine"
  curl -fLoS "$ALP" "https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/armv7/alpine-minirootfs-3.24.3-armv7.tar.gz"
fi
if command -v sha256sum >/dev/null; then
  echo "$ALP_SHA  $ALP" | sha256sum -c - >/dev/null || fail "alpine checksum mismatch"
  say "  ok  alpine checksum ${ALP_SHA:0:12}"
fi

# 3G/SCX30G material must never be part of the live corpus: it is the wrong
# platform for SM-J105F (see docs/research/lte-models.md section 6).
for bad in "$REF/kernels/j1mini3g_ikgapirov" \
           "$REF/pmaports/device/archived/device-samsung-j1mini3g" \
           "$REF/pmaports/device/archived/linux-samsung-j1mini3g"; do
  if [[ -e "$bad" ]]; then
    if (( CHECK )); then fail "3G material present in the live corpus: ${bad#$REF/} (quarantined, see lte-models.md)"; fi
    say "WARN 3G material present in live corpus: ${bad#$REF/} — move it to .reference_delete/"
  fi
done
say "  ok  no 3G/SCX30G sources in the live corpus"

say ""
say "corpus: $(du -sh "$REF" 2>/dev/null | cut -f1) at $REF"
say "run 'bash tools/fetch-reference.sh --check' to verify pins without network writes"
