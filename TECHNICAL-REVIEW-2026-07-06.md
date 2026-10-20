# Technical Review — Dependency Hell Field Guide
**Date:** 2026-07-06 · **Scope:** core chapters + all 51 scenario guides (static review; demos not executed; suspect claims verified against official docs)

## Verdict

Maven and Gradle content is largely accurate; the SBT track is the weak leg. Three systemic problems dominate: (1) the book repeatedly claims SBT has native dependency locking / BOM import — it doesn't; (2) scenarios 16/17 depend on a `demo-dependencies/private-repo` fixture that doesn't exist in the repo, so those demos (and their verify.sh checks) can't work in any tool track; (3) template drift in later scenarios (missing frontmatter, wrong heading levels, missing Check/Risk sections). Everything else is polish.

---

## HIGH — factually wrong or broken; fix before publication

### Repo-wide
1. **Missing `demo-dependencies/private-repo` fixture (all three tracks, scenarios 16/17).** Build files point at `../../../demo-dependencies/private-repo`; nothing creates it, and nothing publishes `com.thirdparty.springboot:patched-bom:1.0.0` or `spring-boot-starter:2.5.14.ACME`. `verify.sh` tests 16/17 and must fail. Fix: seed the fixture via `install_deps.sh`, or mark 16/17 illustrative and drop from verify.sh.
2. **SBT locking is fiction.** `comparison-table.md` says SBT locking is "Native (`csrLock`)" — no such key exists. `conclusion.md` theme 5 says "Gradle and SBT have built-in locking." SBT scenario 11 claims "SBT (1.4.x+) freezes the resolved graph into a lock file" and its README references `project/dependency-locks` / `dependencyLockRead` — that's Gradle's feature transplanted. Reality: only Gradle has built-in locking; SBT needs `sbt-dependency-lock` (task `dependencyLockWrite`, file `build.sbt.lock`) — and the scenario has no `project/plugins.sbt`, so even verify.sh's `dependencyLockWrite` can't run. Also: SBT scenario 9's Wild claims a built-in `dependencyLock`.
3. **`mavenBomImport` doesn't exist.** Used in `cheat-sheet.md` (SBT "Import BOM") and `sbt-demo/scenario-16` build.sbt. Real option is the here-sbt-bom plugin (`Bom.dependencies(...)` → `dependencyOverrides`). S16's build.sbt is also a type error (`"org...boot" % "spring-boot-starter"` with no version) and has no plugins.sbt.

### Core chapters
4. **index.qmd Python pathway: 9 broken links** (scenario-3-resolver, 5-lock, 6-constraints, 11-exclusions, 13-venv, 14-reject, 15-substitution, 16-private, 18-audit don't exist — only 1 and 2 do). Node links are correctly `#`/"coming soon"; Python's are live hrefs. Mark coming-soon or build them.

### Gradle track
5. **GS11: `./gradlew dependencies --lock-state` is not a real flag** (only `--write-locks` / `--update-locks` exist). Command fails as written.
6. **GS3: `dependencies --configuration implementation` can't show resolved versions** — `implementation` isn't resolvable; use `compileClasspath` (verify.sh already does).
7. **GS4 (echoed in GS3/16/17): wrong resolution model.** "A direct version declaration is stronger than a platform recommendation" — false. Plain `platform()` constraints join normal highest-version conflict resolution; the demo works only because 2.0.0 > 1.0.0. A direct *lower* version would NOT win. Downgrading past a BOM needs `strictly` (or `enforcedPlatform`). This is the most important conceptual fix — it fails exactly when readers try to downgrade.

### SBT track
8. **SB6: guide describes the wrong artifact.** build.sbt/README/verify.sh override **lib-c** to 2.0.0; the guide's diagram and Check say **lib-b**.
9. **SB8: fixture has no optional dependency.** No `<optional>` anywhere under `demo-dependencies/`; the demo shows lib-b present, contradicting the guide's "will be absent". README admits it; guide doesn't. Also MEDIUM: "SBT lacks a native optional keyword" is wrong — `% Optional` exists (with known POM-emission quirks, sbt/sbt#162).
10. **SB4: Expect contradicted by its own fixture.** lib-a:2.0.0 transitively requires lib-b:2.0.0, so the direct lib-b:1.0.0 is evicted — the "explicit versions win" claim is false for this exact demo (and the diagram hides the conflicting edge).

### Maven track
(No HIGH factual errors in guides themselves beyond the shared 16/17 fixture problem.)

---

## MEDIUM — misleading, inconsistent, or incomplete

### Core chapters
- **Coursier never mentioned.** comparison-table says SBT default resolution is "Latest Revision (Ivy default)" — Coursier has been the default since sbt 1.3 (2019). Stale "via Ivy"/`latest-revision` phrasing also appears in SB2. Update and add Coursier to the glossary.
- **comparison-table "Circular Dependencies: Allowed (warns)"** — project/reactor cycles hard-fail in Maven and Gradle; external artifact cycles are broken *silently*, not with warnings. (Same false "prints a warning" claim in MS10 Check and SB10.) Distinguish the two cases.
- **comparison-table coverage gap:** no rows for optional deps (S8), rejection (S14), substitution (S15), private repo/patch (S16/17).
- **cheat-sheet gaps:** no locking, rejection, or substitution commands despite S11/S14/S15 headlining the "Taking control" path. Gradle `dependencyInsight` example should add `--configuration runtimeClasspath`.
- **triage.md links are Maven-only** even where the prose is cross-tool. Add GS/SB links.
- **classpath-reality-check** conflates two failure mechanisms (winner lacks a class vs. duplicate classes + classpath ordering). Name both.
- **Scenario 12 is orphaned** — in scenarios.md but reachable from no pathway/triage/start-here page.
- **Naming drift:** same scenarios have different display names across scenarios.md / index.qmd / start-here pages (S2, S3, S6, S7, S14, S15, S16). index.qmd also uses bare "S1…" where the book convention is MS/GS/SB.
- **glossary "DependencyOverrides"** overstates ("overrides all other resolution, including direct declarations") — soften; behavior differs between Ivy/Coursier backends.

### Maven track
- **MS12: `requireUpperBoundDeps` described backwards** — it fails when the *resolved* version is *lower* than the highest transitively required, not "transitive older than direct".
- **Demos that don't demonstrate:** MS13 requests a `jdk11` classifier nothing publishes (resolution fails); MS14's enforcer pom has no dependencies so the ban can never trip; MS15's exclusion targets log4j which lib-a doesn't have (no-op).
- **Structure erosion in MS11–15:** `### !` instead of `#### !` headings, missing frontmatter (MS12–15), MS16/17 skeletal (no Fix/Risk/Check/Scales). MS3 has `#### !Check` (missing space) and `#### Related Scenarios`.
- **Parent-pom repo path bug:** root pom's `file://${project.basedir}/../../target/local-repo` resolves wrongly for inheriting scenarios (1, 11–15); works only via verify.sh's `-Dmaven.repo.local` override.
- **verify.sh bugs:** scenario-5 check is a tautology (`grep -v -q` always passes; should be `! grep -q`) — same bug in sbt verify.sh; scenario-10 check greps `lib-a` but the pom uses `lib-circle-a`; 11–15 have no coverage. README-6's `(version managed from 2.0.0)` example is wrong twice (shows the replaced version, needs `-Dverbose`).
- **MS10 README stale** ("primarily for documentation") — install_deps.sh now installs a real lib-circle-a↔b cycle.

### Gradle track
- **GS8:** feature variants shipped in Gradle **5.3**, not "Gradle 6"; and Spring Boot starters are *not* feature variants (plain POM modules) — pick a real example.
- **GS9:** diagram/Expect say `1.+` but build.gradle uses `[1.0.0, 2.0.0)`. (Same notation mismatch in SB9.)
- **GS10:** diagram shows lib-a/lib-b cycling; the demo actually uses lib-circle-a/b. Maven contrast conflates reactor vs external cycles.
- **GS6:** title "Strict Constraints"/tagline promise a resolution failure; demo is `force` and succeeds.
- **GS16/17:** "ensures"/"prioritizes" overstate plain `platform()`/direct-require semantics (see HIGH #7); a newer transitive would out-vote 2.5.14.ACME.
- **Structure:** `#### Related Scenarios` (no `!`) in GS7/9/11/14/15; GS1 has `#### ! Dot Reader Expectation` (template artifact) and a `Diagram` heading; GS12–15 lack Check sections; GS16/17 skeletal, no READMEs, duplicated Example headings.
- **GS14:** the reject is a no-op (nothing ever proposes 2.0.0).

### SBT track
- **SB5/SB6: no frontmatter**; SB5 Takeaway is "Exclusions work." with Related "N/A"; SB5 never mentions build-wide `excludeDependencies += ExclusionRule(...)` (relevant to the planned new scenario).
- **SB11 Check:** "fast check `dependencyTree`, look for a lockfile (`build.sbt.lock` or `gradle.lockfile`)" — incoherent + Gradle leftover.
- **SB12:** build.sbt omits the exclude+add fix the guide narrates; demo resolves lib-b:1.0.0, not the promised 2.0.0.
- **SB13:** snippet is a plain dependency, demonstrates nothing variant-related; no diagram.
- **SB16/17:** skeletal structure, no READMEs.
- Later scenarios progressively shed Risk/Check/Wild; several use nonstandard `Look` instead of `Check`.

## LOW (selected)
- start_here_control.qmd: "**f** your build is stable" (missing I); start_here_trouble.qmd: "Has something … **has** started".
- scenarios.md "Scenario make up" section reads unfinished ("and.", double spaces).
- glossary: stray quote in "Dependency Locking"; missing terms: Capability, Platform, Version Catalog, Classifier, Coursier; Eviction entry predates sbt 1.5 behaviour change.
- Cross-cutting boilerplate: "…is why the same graph behaves differently across tools" pasted into ~20 Why sections where it's a non-sequitur (all three tracks). Gradle guides have "Gradle"-eating find/replace artifacts ("demonstrates its default…").
- Link style split: some files link `guide.qmd`, others `guide.html` — standardise on `.qmd`.
- MS5/SB fixtures: mermaid shows lib-a→lib-c direct; the real chain is via lib-b.
- SB7: `runtime:dependencyClasspath` legacy syntax → `Runtime/dependencyClasspath`.
- SB15 build.sbt comment claims `updateOptions` enables substitution — it doesn't.

## Verified clean
All snippet markers (`tag::`/`end::`) referenced by guides exist; all Related cross-links resolve; all 17 scenario directories exist per tool and match scenarios.md numbering; sbt 1.12.2 is real and `dependencyTree` is built-in at that version; Maven plugin goals cited (versions:resolve-ranges, dependency-lock-maven-plugin, maven-lockfile, enforcer 3.5.0) are all real.

## Suggested fix order
1. SBT locking rewrite (S11 + comparison table + conclusion + cheat sheet + S9 Wild)
2. private-repo fixture for 16/17 (or mark illustrative) — all tracks
3. GS4 platform-precedence rewrite (+ GS3/16/17 echoes) and SB4 Expect rewrite
4. SB6 lib-b/lib-c, SB8 optional fixture, cheat-sheet `mavenBomImport`, GS11 `--lock-state`, GS3 configuration, index.qmd Python links
5. MS12 requireUpperBoundDeps, MS10/SB10/table circular-deps wording, Coursier updates
6. Structural pass: heading normalisation, frontmatter, missing Check/Risk sections, naming alignment, verify.sh fixes
7. Copy-edit pass: boilerplate sentence, typos, glossary additions
