# ADR-0001 — One repository, three former repositories

- **Status:** accepted (2026-10-23)
- **Supersedes:** the two-repository layout documented in `docs/delivery/ROADMAP.md` §0 and Task 0.1.

## Context

The project grew as three repositories:

| Repository | Contents | Size |
|---|---|---|
| `trefeon/Project_J105F` | docs, device evidence, host scripts | 226 KB |
| `trefeon/twrp_j1minilte` | TWRP device tree **and a full copy of the kernel** + recovery CI | 132 MB |
| `trefeon/linux-samsung-j1minilte` | the same kernel tree + Linux CI | 132 MB |

Consequences observed before consolidation:

- the 3.10 kernel source was duplicated bit-for-bit in two repositories, so every kernel change had to
  be made twice or silently diverged;
- a workflow change required a commit in a *different* repository than the docs describing it, and the
  parent `.gitignore` hid both nested repos, so `git status` at the top level was always empty;
- docs referenced `twrp/…` and `kernel/…` paths that do not exist in either published repository —
  only in one workstation's checkout;
- rollback/recovery artifacts, evidence and build logic lived in three places with three CI histories.

## Decision

Consolidate into a single repository with the layout in `README.md`:

- **one kernel tree** at `kernel/`, consumed by both the recovery build (`j1minilte_defconfig`) and the
  Linux build (`j1minilte_linux_defconfig`);
- AOSP-relative paths under `android/` so CI copies one directory into an AOSP checkout;
- one `.github/workflows/` with two path-filtered workflows instead of two repositories' workflows;
- history: a fresh commit history starting at the consolidation. Before deletion the three former
  repositories were archived as local git bundles (`_archive/Project_J105F-20261023.bundle`,
  `_archive/Project_J105F-twrp-20261023.bundle`,
  `_archive/Project_J105F-os-kernel-20261023.bundle` — outside Git, on the workstation). Commit SHAs and
  CI run numbers quoted in `docs/` are historical evidence, not resolvable links.

## Alternatives rejected

- **Submodules.** Would keep three repositories, three permission surfaces and three CI histories; the
  kernel duplication problem returns with a submodule pointer that must be bumped in lockstep.
- **Keep two component repos, drop only the parent.** Loses the single place where evidence, plans and
  build inputs are reviewed together; the docs would still describe paths that do not exist.
- **Rewrite history to merge the three trees.** The trees overlap (kernel, `tools/pack_bootimg.py`,
  ROADMAP copies), the merge would need `filter-repo` path surgery, and the result is no more useful
  than a fresh commit plus archived bundles.

## Consequences

- A single `git clone` yields everything needed to build both images; checkout is ~660 MB (kernel
  dominated).
- Path filters mean a recovery push does not rebuild the Linux image and vice versa.
- `device/evidence/stock-backup/*.img`, `device/dumps/`, `reference/` and `out/` stay untracked; the
  repository contains no proprietary blobs, no EFS data and no device images.
- Existing docs keep their historical SHAs and run IDs verbatim; the ROADMAP records that those refer
  to the former repositories.
