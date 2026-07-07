# Python Tool Version Reference

Key version breakpoints for the Python dependency tools covered by the book.
Each scenario guide carries a "Tool Versions" callout; this file is the source
those callouts draw from.

**Demo-tested versions (2026-07-06, verified by execution):**
pip **25.3** · Poetry **2.4** · uv **0.11** · Python **3.10**.

## pip

| Version | Date | Significance |
|---------|------|-------------|
| < 20.3  | pre Nov 2020 | **Legacy greedy resolver** is the default — "first found wins", no backtracking. Silently installs incompatible versions (see P3). |
| 20.2    | Jul 2020 | Backtracking resolver available as opt-in beta (`--use-feature=2020-resolver`). |
| 20.3    | Nov 2020 | Backtracking resolver becomes the **default** (Python 3); legacy opt-out via `--use-deprecated=legacy-resolver`. |
| 21.0    | Jan 2021 | Legacy resolver declared deprecated and **unsupported** (still present behind the opt-out flag as of 25.3). |
| 25.1    | Apr 2025 | Experimental **`pip lock`** writing PEP 751 `pylock.toml`; **`pip install --group`** (PEP 735 dependency groups). |
| 26.1    | Apr 2026 | Experimental `pip install -r pylock.toml`. |

**Key breakpoint:** pip 20.3 (the resolver change, P2/P3). pip has no
native lock file (experimental `pip lock` aside); `pip freeze` snapshots,
`pip-tools` compiles.

## Poetry

| Version | Date | Significance |
|---------|------|-------------|
| 1.0     | Dec 2019 | First stable; `poetry.lock` and backtracking from day one. |
| 1.2     | Aug 2022 | **Dependency groups** (`[tool.poetry.group.X]`), replacing `dev-dependencies`. |
| 2.0     | Jan 2025 | PEP 621 `[project]` table as primary metadata; the demos use this form. |
| 2.3     | Jan 2026 | `pylock.toml` **export** via poetry-plugin-export ≥ 1.10 (no native pylock lockfile). |

**Key breakpoint:** Poetry 1.2 (groups, P7). No constraints-file equivalent —
versions are centralised in `pyproject.toml`.

## uv

| Version | Date | Significance |
|---------|------|-------------|
| 0.1     | Feb 2024 | Initial release; Rust PubGrub resolver, pip-compatible interface. |
| 0.2     | May 2024 | Project mode, `uv lock` / `uv.lock` as `--preview` experiments. |
| 0.3.0   | Aug 2024 | Project management (lock/sync) and workspaces launch as stable. |
| 0.4.x   | late 2024 | `uv python` version management; `[dependency-groups]` (PEP 735) in 0.4.27 (Oct 2024). |
| 0.6.15  | Apr 2025 | `uv export --format pylock.toml` (PEP 751). |

**Key breakpoint:** uv moves fast — pin the tested version per demo run.
Notable behaviour: default `index-strategy = "first-index"` (P11, safe against
dependency confusion); `override-dependencies` forces a version graph-wide but
cannot remove a package (P9).

## PEP 751 (pylock.toml)

Accepted Mar 2025 as the cross-tool lock standard. pip (`pip lock`, 25.1+) and
uv (`uv export --format pylock.toml`, 0.6.15+) produce it; Poetry exports it via
poetry-plugin-export ≥ 1.10 (with Poetry ≥ 2.3, Jan 2026) but has no native
pylock lockfile. Adoption is real but partial — native formats (`poetry.lock`,
`uv.lock`) remain each tool's default. See P5.

## Scenarios where version matters most

| Scenario | Why version matters |
|----------|-------------------|
| P2 Conflict | pip < 20.3 installs the broken env silently; pip ≥ 20.3 fails cleanly. |
| P3 Resolver | The whole scenario is resolver history — greedy vs backtracking. |
| P5 Locks | pip has no native lock; poetry.lock (1.0+), uv.lock (0.2+), pylock.toml (PEP 751, 2025). |
| P7 Extras/Groups | Poetry groups need 1.2+; uv `[dependency-groups]` (PEP 735) needs 0.4.27+; `pip install --group` needs 25.1+. |
| P8 Markers | PEP 508 standard — consistent across all tools/versions. |
| P9 Exclusion gap | uv `override-dependencies` is the only override lever; pip/Poetry have none. |
| P11 Private index | uv `first-index` default is safe; pip `--extra-index-url` merge is the vulnerable path. |
