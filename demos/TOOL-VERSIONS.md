# JVM Tool Version Reference

This file tracks the key version breakpoints for the three JVM dependency
management tools covered by the book. Each scenario guide carries a
"Tool Versions" callout naming the tested version and the nearest
behavioural cliff; this file is the single source those callouts draw from.

**Demo-tested versions:** Maven **3.9.9** · Gradle **8.14.3** · sbt **1.12.2**
(July 2026). **Re-verified October 2026:** Maven **3.9.16** · Gradle **9.3.0** ·
sbt **1.12.2** (pinned in each sbt scenario's `project/build.properties`).

**Currency check (19 October 2026):** Maven's current release is 3.10.0 and
Maven 4 is still a preview (4.0.0-rc-7, "not safe for production");
Gradle 9.x has been the current line since July 2025; sbt 2.0.0 shipped in
June 2026. None of these change the resolution rules the scenarios teach;
the rows below say what each one does change.

## Maven

| Version | Date | Significance |
|---------|------|-------------|
| 2.0.9   | 2008 | **Declaration order breaks depth ties** in nearest-wins mediation. Before this, equal-depth conflicts were effectively unordered. |
| 3.0     | 2010 | Aether (now Maven Resolver) replaces the Maven 2 resolution internals. `RELEASE`/`LATEST` metaversions deprecated for plugin versions. |
| 3.6.3   | 2019 | Minimum Maven for maven-enforcer-plugin 3.5.0 (used by scenarios 12/14/15/18). |
| 3.9     | 2023 | Demos tested against 3.9.9 (July 2026) and 3.9.16 (October 2026). |
| 3.10.0  | 2026 | Current 3.x release at the time of writing. Resolution behaviour unchanged from 3.9. |
| 4.0     | preview (rc-7, 2026) | New POM model version (4.1.0 for build POMs), consumer/build POM split, the same Maven Resolver underneath. Still a preview; the book targets Maven 3.x and will revisit scenarios when 4.x is GA and common. |

**Key breakpoint for this book:** effectively none within 3.x. Maven's
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
| 8.x     | 2023–25 | Demos first tested against 8.14.3 (July 2026). Only `--write-locks` / `--update-locks` exist for locking (there is no `--lock-state` flag). |
| 9.0     | Jul 2025 | **Current major.** Runtime floor raised to **JDK 17**, Kotlin 2 / Groovy 4 for build scripts, configuration cache becomes the preferred execution mode, semantic versioning adopted. Dependency resolution rules (highest wins, constraints, platforms, locking) are unchanged; demos re-verified on 9.3.0 (October 2026). |

**Key breakpoint for this book:** Gradle 5.0. Everything the platform,
constraint, and rejection scenarios demonstrate assumes ≥ 5.0; locking
output assumes the ≥ 7.0 single-lockfile format. Gradle 9 is a toolchain
breakpoint (JDK 17), not a resolution breakpoint.

## sbt

| Version | Date | Significance |
|---------|------|-------------|
| 1.3     | 2019 | **Coursier replaces Ivy** as the default resolver. `conflictManager` and other Ivy-only settings are ignored under Coursier (`ThisBuild / useCoursier := false` restores Ivy on 1.x only). Highest-version-wins semantics retained, edge cases differ. |
| 1.4     | 2020 | **`dependencyTree` built in** (previously required the sbt-dependency-graph plugin). |
| 1.5     | 2021 | **Eviction reporting changed:** the blanket eviction warning was replaced by the `evicted` task plus `versionScheme`-aware eviction errors (`evictionErrorLevel`, `libraryDependencySchemes`). Slash syntax (`Runtime / dependencyClasspath`) replaces `runtime:dependencyClasspath`. |
| 1.12    | 2025 | Demo-pinned version (1.12.2). |
| 2.0.0   | Jun 2026 | **Current major** (JDK 17 minimum, Scala 3 build definitions). **Native Maven BOM support** (`.pomOnly()` BOM dependencies with `"*"` versions filled in by Coursier); the `useCoursier` setting is **removed**, so Ivy can no longer be opted into; **eviction errors are enforced in the `Test` configuration**; the legacy `config:key` syntax is gone. The demos target sbt 1.x; the BOM emulation in scenario 16 is the 1.x technique. |

**Not built in (any sbt 1.x or 2.x):** dependency locking. The book uses the
third-party `sbt-dependency-lock` plugin
(`addSbtPlugin("software.purpledragon" % "sbt-dependency-lock" % "1.5.1")`,
tasks `dependencyLockWrite` / `dependencyLockCheck`, file `build.sbt.lock`).

**No native BOM import in sbt 1.x:** the book emulates it with
`dependencyOverrides` (scenario 16), or use the `here-sbt-bom` plugin. sbt 2
adds native support.

**Key breakpoint for this book:** sbt 1.3 (Coursier). Every sbt guide's
callout names it, because pre-1.3 advice found online (conflict managers,
Ivy resolution quirks) silently does nothing on a modern build. sbt 2 is the
next cliff: the Ivy escape hatch disappears and Test-scope evictions become
build failures.

**Verified behaviour note (2026-07-06):** under Coursier, `dependencyOverrides`
forces the version of *direct* declarations as well as transitives —
confirmed by execution against sbt 1.12.2.

**Verified behaviour note (2026-10-19):** under Coursier a direct declaration
in a narrower configuration does **not** demote a transitive edge in a wider
one. Declaring `lib-b % Provided` while `lib-a` (Compile) depends on `lib-b`
leaves `lib-b` on the Runtime classpath; Maven's nearest-wins mediation would
demote it to `provided`. Scenario 7 demonstrates both the sbt behaviour and
the trap. Scenario 14 relies on the sbt 1.5 eviction-error machinery
(`evictionErrorLevel`, `libraryDependencySchemes`), which is sbt's nearest
equivalent to a version reject.

## Fixtures

`install_deps.sh` publishes to `target/local-repo`: `com.demo:lib-a`,
`lib-b`, `lib-c` at 1.0.0 and 2.0.0 (chain a → b → c at matching versions),
`demo-bom:1.0.0` (manages all three at 1.0.0), `lib-circle-a` ↔
`lib-circle-b` (a real cycle), `lib-a:1.0.0:jdk11` (a classifier, scenario
13), and `lib-d:1.0.0`, which declares `lib-c` as `<optional>true</optional>`
(scenario 8). `install_private_repo.sh` publishes the scenario 16/17
"vendor" artifacts to `demo-dependencies/private-repo`.

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
| S3/S4/S16 (Platforms/BOMs) | `platform()`/`enforcedPlatform()` require Gradle 5.0+; sbt 1.x has no BOM import (2.0 adds it). |
| S8 (Optional) | Gradle feature variants shipped in 5.3 (not 6). All three tools honour a POM's `<optional>` when consuming. |
| S11 (Locking) | Gradle: built in since 4.8, single lockfile since 7.0. Maven and sbt: plugins only. |
| S14 (Reject) | Gradle rich versions require 5.0+; Maven needs enforcer (3.6.3+ for plugin 3.5.0); sbt's nearest equivalent is `evictionErrorLevel` + `versionScheme` (1.5+). |
| S15 (Substitution) | Gradle `using` syntax requires 6.6+. |
| S2/S4/S5 (Evictions, sbt) | Eviction *reporting* changed at sbt 1.5; the resolution result did not. sbt 2 turns Test-scope eviction warnings into errors. |
