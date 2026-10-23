# docs/

| Path | What lives there |
|---|---|
| `adr/` | Architecture/decision records. Start with `0002-os-track.md` (Android vs Linux). |
| `device/identity.md` | Canonical verified hardware facts and partition map. |
| `delivery/ROADMAP.md` | The execution spine: task IDs, gates, hard rules. Read this before acting. |
| `delivery/execution-log.md` | One line per executed task: date, done/blocked, result, artifact. |
| `delivery/tasks.md`, `delivery/e1-flash-commands.md` | Historical task detail and the exact flash/rollback commands. |
| `plans/` | Per-track plans: TWRP build, Linux kernel foundation, Linux port, modem capture, device test checklist. |
| `research/` | Findings: model identification, ecosystem inventory, driver bring-up, OS landscape. |
| `build-reports/` | CI investigations and milestone evidence (kernel M3.x). |

Conventions: the ROADMAP wins over every other document when they disagree; historical commits/CI
runs keep their original SHAs (pre-consolidation repositories) and are not rewritten.
