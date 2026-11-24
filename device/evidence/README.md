# Device evidence — capture rules

Raw, read-only captures pulled from the unit (`adb`/`getprop`, `dmesg`, `/proc`). They are the
source for the claims in `docs/device/identity.md` and the research dossiers. Treat them as
immutable except for the redaction rule below.

## Redaction rule

Device-unique identifiers are replaced with a literal marker before the capture is committed:

| Value | Marker |
|---|---|
| `ro.serialno`, `ro.boot.serialno`, `ril.serialnumber` | `<REDACTED>` |
| SoC `chip.uid`, Samsung `connie`/`cordon` hashes in the kernel cmdline | `<REDACTED>` |
| LAN address / gateway from `dhcp.wlan0.*` | `<LAN-IP>` / `<LAN-GATEWAY>` |

Everything the build depends on — model, PDA, bootloader, partition table, SoC revision, memory,
panel ID — is kept verbatim. `cmdline.txt` and the kernel-cmdline line in `dmesg.txt` carry the same
values and are redacted the same way.

The images under `stock-backup/` (`efs.img` = IMEI/NV, `boot_stock.img`, `recovery_stock.img`,
`prodnv.img`) and the `TWRP/` userdata backup are **never committed** (`.gitignore`); only their
SHA-256 list is.
