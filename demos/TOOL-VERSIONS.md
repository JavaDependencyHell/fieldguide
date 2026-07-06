# JVM Tool Version Reference

This file tracks the key version breakpoints for the three JVM dependency
management tools covered by the book. Each scenario guide carries a
"Tool Versions" callout naming the tested version and the nearest
behavioural cliff; this file is the single source those callouts draw from.

**Demo-tested versions:** Maven **3.9.9** · Gradle **8.14.3** · sbt **1.12.2**
(pinned in each sbt scenario's `project/build.properties`).

## Maven

| Version | Date | Significance |
|---------|------|-------------|
| 2.0.9   | 2008 | **Declaration order breaks depth ties** in nearest-wins mediation. Before this, equal-depth conflicts were effectively unordered. |
| 3.0     | 2010 | Aether resolver replaces the Maven 2 resolution internals. `RELEASE`/`LATEST` metaversions deprecated for plugin versions. |
| 3.6.3   | 2019 | Minimum Maven for maven-enforcer-plugin 3.5.0 (used by scenarios 12/14/18). |
| 3.9     | 2023 | Current 3.x line; demos tested against 3.9.9. |
| 4.0     | RC series 2024–25 | New POM model version (4.1.0 for build POMs), consumer/build POM split. The book's content targets Maven 3.x; revisit scenarios when 4.x GA becomes the common baseline. |

**Key breakpoint for this book:** effectively none within 3.x — Maven's
resolution behaviour has been stable for over a decade, which is itself a
point the book makes. The enforcer plugin's minimum (3.6.3) is the only
version constraint a reader is likely to hit.

## Gradle

| Version | Date | Significance |
|---------|------|-------------|
| 4.8     | 2018 | **Dependency locking** introduced (`dependencyLocking { lockAllConfigurations() }`). |
| 5.0     | 2018 | **`platform()` / `enforcedPlatform()`** BOM import and **rich version constraints** (`require`/`prefer`/`strictly`/`reject`). Gradle Module Metadata production. |
| 5.3     | 2019 | **Feature variants** (the optional-dependencies mechanism, scenario 8). |
| 6.6     | 2020 | `substitute ... using ...` substitution syntax (replaces `with`, scenario 15). |
| 7.0     | 2021 | Single per-project **`gradle.lockfile`** becomes the default lock format (replacing the per-configuration `dependency-locks/` directory). |
| 8.x     | 2023+ | Current line; demos tested against 8.14.3. Only `--write-locks` / `--update-locks` exist for locking (there is no `--lock-state` flag). |

**Key breakpoint for this book:** Gradle 5.0. Everything the platform,
constraint, and rejection scenarios demonstrate assumes ≥ 5.0; locking
output assumes the ≥ 7.0 single-lockfile format.

## sbt

| Version | Date | Significance |
|---------|------|-------------|
| 1.3     | 2019 | **Coursier replaces Ivy** as the default resolver. `conflictManager` and other Ivy-only settings are ignored under Coursier (`ThisBuild / useCoursier := false` restores Ivy). Highest-version-wins semantics retained, edge cases differ. |
| 1.4     | 2020 | **`dependencyTree` built in** (previously required the sbt-dependency-graph plugin). |
| 1.5     | 2021 | **Eviction reporting changed:** the blanket eviction warning was replaced by the `evicted` task plus `versionScheme`-aware eviction errors. |
| 1.12    | 2025 | Demo-pinned version (1.12.2). |
| 2.x     | upcoming | **Native BOM support** lands in sbt 2. sbt 1.x has no BOM import — the book emulates it with `dependencyOverrides` (scenario 16), or use the `here-sbt-bom` plugin. |

**Not built in (any sbt 1.x):** dependency locking. The book uses the
third-party `sbt-dependency-lock` plugin
(`addSbtPlugin("software.purpledragon" % "sbt-dependency-lock" % "1.5.1")`,
tasks `dependencyLockWrite` / `dependencyLockCheck`, file `build.sbt.lock`).

**Key breakpoint for this book:** sbt 1.3 (Coursier). Every SBT guide's
callout names it, because pre-1.3 advice found online (conflict managers,
Ivy resolution quirks) silently does nothing on a modern build.

**Verified behaviour note (2026-07-06):** under Coursier, `dependencyOverrides`
forces the version of *direct* declarations as well as transitives —
confirmed by execution against sbt 1.12.2.

## Version callout template

Each scenario's `guide.qmd` includes a callout between the Scenario and
Example sections:

```markdown
::: {.callout-note title="Tool Versions"}
This scenario was tested with **<tool> <version>**.
<Nearest behavioural cliff, if any — cite this file.>
:::
```

## Scenarios where version matters most

| Scenario | Why version matters |
|----------|-------------------|
| S2 (Conflict) | Maven's declaration-order tie-break dates to 2.0.9; sbt's mechanism is Coursier (1.3+), not Ivy's `latest-revision`. |
| S3/S4/S16 (Platforms/BOMs) | `platform()`/`enforcedPlatform()` require Gradle 5.0+; sbt 1.x has no BOM import at all (2.x adds it). |
| S8 (Optional) | Gradle feature variants shipped in 5.3 (not 6). |
| S11 (Locking) | Gradle: built in since 4.8, single lockfile since 7.0. Maven and sbt: plugins only. |
| S14 (Reject) | Gradle rich versions require 5.0+; Maven needs enforcer (3.6.3+ for plugin 3.5.0). |
| S15 (Substitution) | Gradle `using` syntax requires 6.6+. |
| S2/S4/S5 (Evictions, sbt) | Eviction *reporting* changed at sbt 1.5; the resolution result did not. |
