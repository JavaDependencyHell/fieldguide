# Python Scenarios — Plan

**Track:** Dependency Management (book-bound) · **Status:** planning · **Date:** 2026-07-06

## Ground rules

- **Tools:** pip, Poetry, uv — every scenario gets a demo and a verify check for all three.
- **Hybrid guides:** where the three tools behave identically, one collapsed guide with a single "all three tools behave identically here" note. Where they diverge, full comparative treatment — the divergence *is* the content.
- **Numbering:** Python-native (P1–P12 core), not forced onto the JVM numbering. Each guide cross-references its JVM sibling(s) where one exists.
- **Harness:** one throwaway venv per scenario per tool, created and destroyed by verify.sh; local wheel repo (`target/python-repo`) with `com-demo` fixture packages (`lib-a`, `lib-b`, `lib-c`) mirroring the JVM fixtures; installs run `--no-index --find-links` for offline determinism. Salvage the quarantined harness mechanics; regenerate all wheels and expected outputs from real runs.
- **Verification discipline:** no guide ships until its claim is reproduced by execution against pinned tool versions (recorded in `python-demo/TOOL-VERSIONS.md`, which survives from the quarantined work — its version facts checked out).
- **Structural rule stated up front in the part intro:** one environment = one version of a package. No eviction, no classpath, no coexistence. Every scenario hangs off this.

## Core scenarios (wave 1)

| # | Working title | JVM sibling | Tool behaviour | The point |
|---|---------------|-------------|----------------|-----------|
| P1 | Basic Transitive Resolution | S1 | ~identical (collapsed) | Installing `lib-a` brings `lib-b` automatically; how to *see* the tree (`pipdeptree`, `poetry show --tree`, `uv tree`). |
| P2 | The Diamond: Conflicting Requirements | S2 | divergent errors | Two deps need different `lib-c` versions. There is no "winner" — Python must satisfy *all* specifiers in one env or fail. Backtracking vs `ResolutionImpossible`; how each tool reports it. The inversion of JVM eviction. |
| P3 | Resolver Strategies & History | — (Python-native) | divergent by definition | pip's greedy "last wins" (< 20.3) vs backtracking (21+) vs uv's PubGrub. Same requirements file, different resolver, different environment. The book's "resolution is mechanical" thesis, proven historically. |
| P4 | Specifiers & Ranges | S9 | ~identical (collapsed) | `>=`, `~=`, `==`, `!=` (PEP 440). Open ranges are the *default culture* here, unlike the JVM. Why "no upper bound" is normal and what it costs. Native `!=` covers most of JVM S14's ground — call that out. |
| P5 | Lock Files | S11 | maximum divergence | pip freeze vs pip-tools compile vs poetry.lock vs uv.lock vs the new standard pylock.toml (PEP 751, accepted 2025, adoption mixed). The flagship comparative scenario. |
| P6 | Constraints Files: Central Version Control | S3/S6 | divergent | `pip install -c constraints.txt` as the BOM-ish central pin; uv supports constraints and `override-dependencies`; Poetry has no direct equivalent (version catalog lives in pyproject). |
| P7 | Extras & Dependency Groups | S7 + S8 | divergent | Optional features via extras (`lib[feature]`), dev/test separation via requirements files (pip) vs Poetry groups vs uv groups / PEP 735. JVM scopes and optional deps, merged into one scenario because Python merges the concepts. |
| P8 | Environment Markers | — (Python-native) | ~identical (collapsed) | `; python_version < "3.11"`, `; sys_platform == "win32"` (PEP 508). Conditional dependencies as data — nothing like it in the JVM. Explains "resolves differently on my Mac". |
| P9 | Exclusions: The Gap | S5/S18 | divergent | You cannot exclude a transitive dependency in pip or Poetry — the gap is the scenario. Workarounds: constraint-pinning, forking. uv genuinely has `override-dependencies`; that asymmetry mirrors the Maven/Gradle S18 story. |
| P10 | Virtual Environment Isolation | — (Python-native) | divergent ergonomics | The env is the resolution result. System site-packages leakage, `--user` installs, tool-managed envs (Poetry/uv) vs manual venvs (pip). "Works in dev, breaks in prod" mechanics. |
| P11 | Private Index & Dependency Confusion | S16/S17 | divergent + security | `--index-url` vs `--extra-index-url` merge semantics — the exact behaviour behind the Birsan 2021 attack. uv's `index-strategy`, Poetry's source priorities as mitigations. Private patched packages (the `2.5.14.ACME` story, Python edition). Strongest HeroDevs tie-in in the book. |
| P12 | Auditing the Environment | — (Python-native) | divergent tooling | `pip-audit`, lockfile scanning, finding vulnerable/EOL packages in an env you inherited. Closes the part the way triage opens the JVM book: see reality first. |

Suggested collapsed/comparative split: P1, P4, P8 collapsed; the other nine comparative.

## Second wave (planned, not numbered-in yet)

Wheels, sdists & platform variants (JVM S13 sibling: manylinux tags, `--only-binary`, why an install works on x86 and fails on ARM) · Yanked releases & version rejection (PyPI yanking is a resolution behaviour with no JVM equivalent) · Substitution & forks (direct URL/VCS requirements, patched local wheels — JVM S15) · Workspaces & monorepos (uv workspaces, path dependencies) · Hash-checking & reproducibility (`--require-hashes`, the supply-chain hardening step past locking).

## Book integration

- New book part "Python Scenarios" after the SBT part; same `#### !` section template, same Tool Versions callout (cite `python-demo/TOOL-VERSIONS.md`), same Related-link convention (P↔S cross-references both ways).
- Comparison table gains a Python column *only* for rows where the comparison is meaningful; otherwise the part gets its own small pip/Poetry/uv table — decide when writing.
- index.qmd Python pathway already sketches trouble/control/learn groupings — renumber its links to this list when scenarios land; keep "coming soon" until each is verified.
- Cheat sheet gains a Python section (tree/lock/constrain/audit one-liners per tool).

## Pipeline notes (Substack-first)

Several scenarios are strong standalone Substack pieces before book assembly, each with derivatives: P3 (resolver history — "the day pip changed its mind"), P11 (dependency confusion — HeroDevs blog companion is obvious), P5 (the lockfile babel / PEP 751). Sequence: write scenario + demo first, verify, then lift the article from the verified material — the JVM review showed why prose written ahead of working demos drifts.

## Open questions

- Pin uv at a specific version per wave (it moves fast) — record in TOOL-VERSIONS.md at write time.
- Whether P12 (audit) demos against real CVE data (network, changes over time) or a fixture index with a planted "vulnerable" package (deterministic — recommended).
- Poetry 2.x vs 1.8 as the tested line — check current state when work starts.
