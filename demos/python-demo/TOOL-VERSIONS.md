# Python Tool Version Reference

This file tracks the key version breakpoints for Python dependency management
tools. Each scenario's guide should include a version callout noting which
versions the demonstrated behavior applies to.

## pip

| Version  | Date     | Significance |
|----------|----------|-------------|
| < 20.3   | Pre Oct 2020 | **Legacy greedy resolver.** "Last wins" — silently installs incompatible versions. No backtracking. Produces broken environments without warning. |
| 20.3     | Oct 2020 | **New backtracking resolver introduced** (opt-in via `--use-feature=2020-resolver`). Hard conflicts detected; soft conflicts resolved by silent downgrade. |
| 21.0     | Jan 2021 | Backtracking resolver becomes **default**. Legacy resolver still available via `--use-deprecated=legacy-resolver`. |
| 22.2     | Aug 2022 | Legacy resolver **removed entirely**. All pip installs use backtracking. |
| 23.1     | Apr 2023 | Improved error messages for resolution failures. |
| 24.0     | Jan 2024 | `--dry-run` flag added — useful for testing resolution without installing. |

**Key breakpoint for this book:** pip 20.3 / 21.0. Most scenarios assume the modern
backtracking resolver. Where behavior differs between old and new pip, the scenario
guide notes this explicitly.

## poetry

| Version  | Date     | Significance |
|----------|----------|-------------|
| 1.0      | Dec 2019 | First stable release. Backtracking resolver from day one. |
| 1.2      | Aug 2022 | **Dependency groups** introduced (`[tool.poetry.group.X]`). Replaces the older `[tool.poetry.dev-dependencies]` pattern. |
| 1.4      | Mar 2023 | Lock file format v2. Faster resolution. |
| 1.5      | May 2023 | Source priority ordering for repositories. |
| 1.7+     | 2024     | PEP 735 alignment, improved workspace support. |

**Key breakpoint for this book:** poetry 1.2 (dependency groups). Most scenarios
assume ≥ 1.2. The resolver itself has been stable since 1.0.

## uv

| Version  | Date     | Significance |
|----------|----------|-------------|
| 0.1      | Feb 2024 | Initial release. pip-compatible interface with Rust-based resolver. |
| 0.2      | Jun 2024 | `uv lock` and `uv.lock` file introduced. Project management mode. |
| 0.3      | Aug 2024 | Workspace support. Dependency groups. |
| 0.4+     | Late 2024 | Python version management (`uv python`). Stabilising API. |

**Key breakpoint for this book:** uv is evolving rapidly. Demos are tested against
a pinned version (noted in each scenario). Core resolver behavior has been stable
since 0.1, but project management features (lock files, workspaces, groups) are
newer and may change.

**Pinned version for demos:** _TBD — set when writing guide.qmd files._

## Version callout template

Each scenario's `guide.qmd` should include a callout block like this:

```markdown
::: {.callout-note title="Tool Versions"}
This behavior applies to **pip ≥ 21.0**, **poetry ≥ 1.2**, and **uv ≥ 0.2**.

Older pip (< 20.3) uses a greedy resolver that would [describe different behavior].
:::
```

## Scenarios where version matters most

| Scenario | Why version matters |
|----------|-------------------|
| P2: Conflict resolution | pip < 20.3 silently installs broken deps. pip ≥ 21.0 backtracks and silently downgrades. Fundamentally different outcomes. |
| P3: Resolver strategies | The entire scenario is about comparing resolvers — version is the story. |
| P5: Lock files | pip has no native lock file; pip-tools required. poetry.lock stable since 1.0. uv.lock since 0.2. |
| P9: Dependency groups | Only available in poetry ≥ 1.2 and uv ≥ 0.3. pip has no equivalent (multiple requirements files instead). |
| P10: Environment markers | Consistent across all tools and versions (PEP 508 is a standard, not a tool feature). |
