# Guides

One guide is written; the two implementation tracks it points at are still dossiers. They become
their own guides only after the device work in them is executed.

| Guide | Use it when |
|---|---|
| [`01-porting-an-os-to-a-phone.md`](01-porting-an-os-to-a-phone.md) | you are starting from a stock phone and need the full stage-gated method: evidence, safety net, boot chain, recovery, kernel, userspace, bring-up, debugging, release |

## Implementation tracks (dossier material, not yet guides)

| Track | Read |
|---|---|
| Alpine/Nura userspace on this kernel | [`../research/pmos-ecosystem.md`](../research/pmos-ecosystem.md) §4 (reproduce), §5 (gaps) |
| LineageOS 14.1 | [`../research/source-landscape.md`](../research/source-landscape.md) §5.2, [`../research/porting-methodology.md`](../research/porting-methodology.md) S8 |

## Ground rules

- A compile is not a boot; a boot is not a working device. Every claim needs an on-device log.
- Nothing is flashed without an explicit human "yes" in the session.
- Images are size-gated against the **real** partition table (16 MiB boot/recovery here), not the
  device-tree numbers.
- `reference/` is input material, never a flash source. Flash only checksummed build artifacts.
- Where a step is unverified it is marked `[INFERENCE]` or "unproven" rather than presented as fact.

## What already exists in this repo

| Piece | Path |
|---|---|
| Device evidence | `device/evidence/` |
| Stock rollback set | `device/evidence/stock-backup/` |
| Boot image tools | `tools/bootimg/` |
| Pinned reference corpus | `tools/fetch-reference.sh` → `reference/` |
| Research dossiers | `docs/research/` |
| Execution roadmap | `docs/delivery/ROADMAP.md` |
