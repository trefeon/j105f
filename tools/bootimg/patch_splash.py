#!/usr/bin/env python3
"""D3: patch the custom J105F splash into a built recovery.img.

The TWRP 3.7.0_9 boot splash is a theme page: /twres/splash.xml plus
/twres/images/splashlogo.png (8-bit PNG, decoded by libpng at boot; the
GUI converts to the fb pixel format at blit time). Rather than replacing
the whole /twres theme (which would freeze ui.xml and all icons), this
surgical post-build step unpacks the built recovery.img, replaces exactly
those two files inside the ramdisk cpio, and repacks the boot image with
the same geometry (offsets, cmdline, dt.img, SEANDROIDENFORCE suffix if
the original carried one).

Usage:
  python3 tools/bootimg/patch_splash.py <recovery.img> <splash-dir> --out <img>
    <recovery.img>  built recovery image (unpacked in place if --out omitted)
    <splash-dir>    dir containing splash.xml + images/splashlogo.png
Exit 1 on any mismatch; prints VERIFY PASS lines on success.
"""

import argparse
import gzip
import os
import struct
import subprocess
import sys
import tempfile

PAGE = 2048
HEADER_FMT = "<8sIIIIIIIIII16s512s20s"
MAGIC = b"ANDROID!"


def align(n, page=PAGE):
    return ((n + page - 1) // page) * page


def unpack(path):
    data = open(path, "rb").read()
    assert data[0:8] == MAGIC, "not an Android boot image"
    (magic, ksz, kaddr, rsz, raddr, ssz, saddr, taddr, page, dtsz,
     unused, name, cmdline, img_id) = struct.unpack_from(HEADER_FMT, data, 0)
    off = page
    kernel = data[off:off + ksz]
    off += align(ksz, page)
    ramdisk = data[off:off + rsz]
    off += align(rsz, page)
    second = data[off:off + ssz]
    off += align(ssz, page)
    dt = data[off:off + dtsz]
    rest = data[off + dtsz:]
    seandroid = rest.startswith(b"SEANDROIDENFORCE")
    cmdline = cmdline.split(b"\0")[0].decode()
    return {
        "page": page, "kernel": kernel, "ramdisk": ramdisk,
        "second": second, "dt": dt, "cmdline": cmdline, "seandroid": seandroid,
    }


def read_cpio(data):
    """Parse a newc cpio into list of (name, mode, uid, gid, mtime, payload)."""
    entries = []
    off = 0
    while off + 110 <= len(data):
        if data[off:off + 6] != b"070701":
            break
        f = [int(data[off + 6 + i * 8: off + 14 + i * 8], 16) for i in range(13)]
        ino, mode, uid, gid, nlink, mtime = f[:6]
        filesize, namesize = f[6], f[11]
        name = data[off + 110: off + 110 + namesize].rstrip(b"\0").decode()
        payload_off = (off + 110 + namesize + 3) & ~3
        payload = data[payload_off: payload_off + filesize]
        entries.append((name, mode, uid, gid, mtime, payload))
        off = (payload_off + filesize + 3) & ~3
    return entries


def write_cpio(entries):
    out = bytearray()
    for ino, (name, mode, uid, gid, mtime, payload) in enumerate(entries, start=1):
        if name == "TRAILER!!!":
            continue
        name_b = name.encode()
        hdr = ("070701" + "".join(
            "%08X" % v for v in (ino, mode, uid, gid, 1, mtime, len(payload),
                                 0, 0, 0, 0, len(name_b) + 1, 0)
        )).encode()
        out += hdr + name_b + b"\0"
        while len(out) % 4:
            out += b"\0"
        out += payload
        while len(out) % 4:
            out += b"\0"
    trailer = ("070701" + "".join("%08X" % v for v in (0, 0, 0, 0, 1, 0, 0,
                                                      0, 0, 0, 0, 11, 0))).encode()
    out += trailer + b"TRAILER!!!\0"
    while len(out) % 4:
        out += b"\0"
    return bytes(out)


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("img", help="built recovery.img")
    ap.add_argument("splash_dir", help="dir with splash.xml + images/splashlogo.png")
    ap.add_argument("--out", default=None, help="output image (default: in-place)")
    args = ap.parse_args(argv)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    packer = os.path.join(script_dir, "pack_bootimg.py")

    splash_xml = os.path.join(args.splash_dir, "splash.xml")
    splash_png = os.path.join(args.splash_dir, "images", "splashlogo.png")
    for p in (splash_xml, splash_png):
        assert os.path.isfile(p), f"missing {p}"
    new_xml = open(splash_xml, "rb").read()
    new_png = open(splash_png, "rb").read()

    img = unpack(args.img)
    ramdisk = gzip.decompress(img["ramdisk"])
    entries = read_cpio(ramdisk)
    assert entries, "empty cpio"

    targets = {"twres/splash.xml": new_xml,
               "twres/images/splashlogo.png": new_png}
    patched = 0
    for i, (name, mode, uid, gid, mtime, payload) in enumerate(entries):
        if name in targets:
            entries[i] = (name, mode, uid, gid, mtime, targets.pop(name))
            patched += 1
    assert patched == 2, f"patched {patched}/2 splash files (ramdisk layout mismatch?)"
    assert not targets, f"unmatched: {list(targets)}"

    new_ramdisk = gzip.compress(write_cpio(entries), 9)

    out = args.out or args.img
    with tempfile.TemporaryDirectory() as td:
        kern = os.path.join(td, "kernel.zImage")
        ram = os.path.join(td, "ramdisk.cpio.gz")
        dt = os.path.join(td, "dt.img")
        open(kern, "wb").write(img["kernel"])
        open(ram, "wb").write(new_ramdisk)
        open(dt, "wb").write(img["dt"])
        cmd = [sys.executable, packer, "--kernel", kern, "--ramdisk", ram,
               "--dt", dt, "--out", out, "--cmdline", img["cmdline"]]
        if not img["seandroid"]:
            cmd.append("--no-seandroid")
        subprocess.run(cmd, check=True)

    # fail-closed verify: re-unpack the output and confirm both files + size
    re = unpack(out)
    assert re["cmdline"] == img["cmdline"], "cmdline changed"
    assert re["seandroid"] == img["seandroid"], "SEANDROID suffix changed"
    assert re["kernel"] == img["kernel"], "kernel changed"
    assert re["dt"] == img["dt"], "dt.img changed"
    entries2 = read_cpio(gzip.decompress(re["ramdisk"]))
    got = {n: p for n, _, _, _, _, p in entries2}
    assert got.get("twres/splash.xml") == new_xml, "splash.xml mismatch"
    assert got.get("twres/images/splashlogo.png") == new_png, "splashlogo.png mismatch"
    size = os.path.getsize(out)
    assert size < 16777216, f"recovery.img {size} B exceeds 16 MiB partition"
    print(f"VERIFY PASS: {out} ({size} B), splash.xml + splashlogo.png patched, "
          f"kernel/dt/cmdline/SEANDROID preserved")


if __name__ == "__main__":
    main(sys.argv[1:])
