#!/usr/bin/env bash
# Fetch and verify the Windows flashing toolchain into reference/tools/flash/ (gitignored).
#
# Usage:  bash tools/fetch-flash-tools.sh [--check]
#   --check   verify the staged files against the pins below; download nothing
#
# Pins verified 2026-11-24 (see docs/research/flash-and-firmware.md):
#   Odin 3.13.1       3,517,718 B   sha256 056aeb87…4933   (samsungodin.com; matches the 2026-10-23 fetch)
#   Odin 3.14.4       4,510,482 B   sha256 a8822952…d515   (odindownload.com repack; no independent copy)
#   Samsung USB drv  37,216,544 B   sha256 0ecc9e47…4a20   (v1.9.5.0 NSIS, signed .inf/.cat dated 2026-04-23)
#   Heimdall pkg        270,792 B   sha256 e3baf9fd…ff0b   (MSYS2 r180.3997d5c-3)
#     -> heimdall.exe   497,805 B   sha256 cef77a0e…8dff   (PE32+ x86-64, libusb-1.0.30 linked in)
#   Zadig 2.9         5,334,088 B   sha256 4ecaa95d…039b   (libwdi v1.5.1; Heimdall/WinUSB path only)
#
# samsungodin.com's zip is served through this workstation's Kaspersky filter as an
# HTML block page (~197 KB). On such a host, fetch the file elsewhere and copy it in:
#   ssh <unfiltered-host> 'curl -sSLo /tmp/o.zip https://samsungodin.com/download/Odin3_v3.13.1.zip'
#   scp <unfiltered-host>:/tmp/o.zip reference/tools/flash/odin/Odin3_v3.13.1_samsungodin.zip
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${DEST:-$ROOT/reference/tools/flash}"
CHECK=0
[[ "${1:-}" == "--check" ]] && CHECK=1

say()  { printf '%s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

# Some Windows coreutils emit "\<hash>" (backslash escape); strip it.
sha256_of() {
  local h; h="$(sha256sum "$1")"; h="${h%% *}"
  printf '%s' "${h#\\}"
}

# verify <file> <sha256> <label>
verify() {
  local f="$1" want="$2" label="$3"
  [[ -f "$f" ]] || return 1
  local have; have="$(sha256_of "$f")"
  if [[ "$have" == "$want" ]]; then
    say "  ok  $label (${want:0:12})"
    return 0
  fi
  say "  !!  $label: have ${have:0:12} want ${want:0:12}"
  return 1
}

# fetch <url> <out> <sha256> <label>
fetch() {
  local url="$1" out="$2" want="$3" label="$4"
  if verify "$out" "$want" "$label"; then return 0; fi
  (( CHECK )) && fail "$label missing or wrong (want ${want:0:12})"
  mkdir -p "$(dirname "$out")"
  say "  ..  downloading $label"
  curl -fsSL --max-time 300 -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' -o "$out" "$url" \
    || fail "$label: download failed"
  if head -c 15 "$out" | grep -qi '<!doctype html'; then
    rm -f "$out"
    fail "$label: server/filter returned HTML, not the binary — see the header comment"
  fi
  verify "$out" "$want" "$label" || { rm -f "$out"; fail "$label: checksum mismatch"; }
}

mkdir -p "$DEST"/{odin,heimdall,samsung-usb-driver,zadig}

say "== Odin"
fetch "https://samsungodin.com/download/Odin3_v3.13.1.zip" \
  "$DEST/odin/Odin3_v3.13.1_samsungodin.zip" \
  056aeb87bfc5b7b05abbe4b287c6b494e1c5a660866f14068f8afaffb1ad4933 "Odin 3.13.1"
fetch "https://odindownload.com/download/Odin3_v3.14.4.zip" \
  "$DEST/odin/Odin3_v3.14.4.zip" \
  a8822952a9e43b7ffb500ced342b3fa298c2bb4204a31bfc733b51e67739d515 "Odin 3.14.4 (repack)"

say "== Samsung USB driver"
fetch "https://developer.samsung.com/SDP/file/a2fcaf64-7aa3-49f7-b06f-9e646590d528" \
  "$DEST/samsung-usb-driver/Samsung_USB_Driver_v1.9.5.0.zip" \
  0ecc9e47d836a7cff7215ec9cdf33dc7f3e416a7d5ededad522b978b2eb84a20 "Samsung USB driver 1.9.5.0"

say "== Heimdall"
PKG="$DEST/heimdall/heimdall-msys2-r180.3997d5c-3.pkg.tar.zst"
fetch "https://mirror.msys2.org/mingw/ucrt64/mingw-w64-ucrt-x86_64-heimdall-r180.3997d5c-3-any.pkg.tar.zst" \
  "$PKG" e3baf9fd2f16a42fb1608f58590e704189abf290ea8a7d59166bda66acdbff0b "heimdall pkg"
if [[ ! -f "$DEST/heimdall/heimdall.exe" ]]; then
  (( CHECK )) && fail "heimdall.exe not extracted"
  say "  ..  extracting heimdall.exe"
  TMP="$DEST/heimdall/.pkg"
  rm -rf "$TMP"; mkdir -p "$TMP"
  if command -v 7z >/dev/null; then
    7z x -y -o"$TMP/a" "$PKG" >/dev/null
    7z x -y -o"$TMP/b" "$TMP/a/heimdall-msys2-r180.3997d5c-3.pkg.tar" >/dev/null
  elif command -v tar >/dev/null && tar --zstd -tf "$PKG" >/dev/null 2>&1; then
    tar --zstd -xf "$PKG" -C "$TMP/a"
  else
    fail "need 7z or tar with zstd to unpack the MSYS2 package"
  fi
  cp "$TMP/b/ucrt64/bin/heimdall.exe" "$TMP/b/ucrt64/bin/heimdall-frontend.exe" "$DEST/heimdall/" 2>/dev/null \
    || cp "$TMP/a/ucrt64/bin/"*.exe "$DEST/heimdall/"
  rm -rf "$TMP"
fi
verify "$DEST/heimdall/heimdall.exe" \
  cef77a0e147b1a7083927bf9d07211ce97aa82525593e29a39d9216c45e98dff "heimdall.exe"

say "== Zadig (Heimdall/WinUSB path only)"
fetch "https://github.com/pbatard/libwdi/releases/download/v1.5.1/zadig-2.9.exe" \
  "$DEST/zadig/zadig-2.9.exe" \
  4ecaa95df3da3621486a043aef8b3050b8bafe7c901402871e816229ef82039b "Zadig 2.9"

say "== checksum manifest"
( cd "$DEST" && sha256sum odin/*.zip samsung-usb-driver/*.zip heimdall/*.exe zadig/*.exe > SHA256SUMS )
say "  ok  $DEST/SHA256SUMS"

say ""
say "firmware is not fetched here: SamFrew's free path is browser/captcha-gated,"
say "stock J105FXXS0ARD2 is 1,003,482,272 B with no published checksum."
say "toolchain: $(du -sh "$DEST" 2>/dev/null | cut -f1) at $DEST"
