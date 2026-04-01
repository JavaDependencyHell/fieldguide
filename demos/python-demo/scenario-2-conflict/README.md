# Scenario P2: Version Conflict — The Diamond Problem

Demonstrates what happens when dependency paths request incompatible versions.

## Setup
- Direct dependencies: `lib-a` (unpinned) and `lib-b==1.0.0`
- Available: lib-a 2.0.0 (depends on `lib-b>=2.0.0`) and lib-a 1.0.0 (depends on `lib-b>=1.0.0,<2.0.0`)
- lib-b 1.0.0 depends on `lib-c>=1.0.0,<2.0.0`

## Expected Results

### pip (SILENT DOWNGRADE)
pip's backtracking resolver tries lib-a 2.0.0 first, discovers it needs lib-b>=2.0
(conflicting with the pinned lib-b==1.0.0), and silently falls back to lib-a 1.0.0.
The build succeeds, but you get an **older version of lib-a than you expected**
with no warning that a conflict caused the downgrade.

Result: lib-a 1.0.0, lib-b 1.0.0, lib-c 1.0.0

### Comparison with Maven
In Maven's "Nearest Wins" strategy (Scenario S2), the tool silently picks the
version closest to the root of the graph — potentially using an **incompatible**
version. pip's backtracking is actually safer (it finds a compatible solution),
but the silent downgrade can be equally surprising.

## Tool Versions — THIS SCENARIO IS VERSION-SENSITIVE

| Tool | Version | Behavior |
|------|---------|----------|
| pip < 20.3 | Legacy greedy resolver | **Silently installs incompatible versions.** Both lib-a 2.0.0 and lib-b 1.0.0 installed despite conflict. Environment is broken — lib-a fails at runtime. |
| pip ≥ 21.0 | Backtracking resolver | **Silent downgrade.** Tries lib-a 2.0.0, detects conflict, falls back to lib-a 1.0.0. Environment works but you got an older version without being told why. |
| pip ≥ 21.0 (hard conflict) | Backtracking resolver | If both versions are pinned (`lib-a==2.0.0` + `lib-b==1.0.0`), pip **refuses to install** with a clear error. |
| poetry ≥ 1.0 | Backtracking resolver | Reports conflict clearly during `poetry lock`. |
| uv ≥ 0.1 | Backtracking resolver | Reports conflict clearly during `uv lock`. |

The pip version breakpoint (20.3 / 21.0) is one of the most significant changes
in Python dependency management history. The same `requirements.txt` produces
fundamentally different (and incompatible) environments depending on your pip version.

## Java Developer Surprise Factor: HIGH
Maven silently picks the wrong version. pip silently picks an older version.
Both resolve without error. Both can produce unexpected behavior at runtime.
The failure mode is different, but the underlying problem is the same: **the
resolver made a decision you didn't ask for, and didn't tell you about it.**

## Run manually

### pip
```bash
python -m venv .venv && source .venv/bin/activate
pip install --find-links=../../target/python-repo --no-index lib-a lib-b==1.0.0
pip list
# Notice: lib-a is 1.0.0, not 2.0.0
```
