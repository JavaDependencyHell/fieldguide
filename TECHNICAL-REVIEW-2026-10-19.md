# Technical Review — Dependency Hell: A Field Guide
**Date:** 2026-10-19 · **Scope:** all core chapters, both appendices, README, Quarto config, and all 90 scenario guides (18 Maven, 18 Gradle, 18 sbt, 12 Python, 12 Node) with their build files, READMEs and verify scripts · **Method:** static review against the repo; the July 2026 HTML build in `build/book` used to confirm rendering claims; suspect tool claims checked against official docs and release pages today. Demos were not executed.

Previous reviews: `TECHNICAL-REVIEW-2026-07-06.md` (JVM; no resolution record), `PYTHON-REVIEW-2026-07-06.md` (resolved 2026-07-07).

## Verdict

The book has grown from a three-tool JVM guide into a five-ecosystem one, and the two newest parts (Python, Node) are now the best-built: uniform template, every demo backed by a verify check, cross-links in both directions. The JVM parts have not kept pace. The conceptual errors flagged in July (Gradle platform precedence, sbt native locking and BOM import, the missing private-repo fixture) are fixed, but most of July's structural and demo-fidelity items were not, and the framing chapters still describe a JVM-only book of "17 scenarios and three build tools".

Four things need attention before the next release, in this order:

1. **Tool currency.** Every version the book pins is now at least one major behind: Maven's current release is 3.10.0 (book: "3.9 current line"); Gradle 9.0 shipped 31 Jul 2025 and the demos were verified on 8.14.3 a year later (book: "8.x current line"); sbt 2.0.0 shipped 29 Jun 2026, ten days before the July verification, with native BOM support and no `useCoursier` opt-out (book: "2.x upcoming"); Corepack no longer ships with Node 25+ (book: "Node ≥ 22, run `corepack enable`"). None of this changes the resolution behaviour the scenarios teach, but a reader on current tools will hit the callouts first and trust the rest less.
2. **A rendering bug** in five Maven chapters: `### !` headings make the filter swallow every later section into one box. Confirmed in the July HTML build (MS15 renders five boxes, not twelve).
3. **Fourteen demos that cannot demonstrate their scenario** (bare `lib-a:1.0.0` with a tautological verify check, or a reject/exclusion that nothing in the graph ever triggers). Listed in section C.
4. **Book-level framing is stale and JVM-only**: index pathway still stamps Node "(coming soon)", `scenarios.md`, triage, both Start Here pages, the conclusion, glossary, README and acknowledgements do not know Python and Node exist.

Everything else is polish, though there is a lot of it.

---

## A. HIGH — cross-cutting

### A1. Tool versions are stale (verified online today)
| Tool | Book says | Reality |
|---|---|---|
| Maven | `TOOL-VERSIONS.md`: "3.9 — current 3.x line; tested 3.9.9"; 4.0 "RC series 2024–25" | maven.apache.org: **3.10.0** is the current release; 4.x is still a preview at 4.0.0-rc-7 ("NOT safe for production") |
| Gradle | "8.x 2023+ current line; tested 8.14.3"; every GS callout "tested with Gradle 8.14" | **Gradle 9.0.0 GA 31 Jul 2025** (JDK 17 minimum, Kotlin 2, Groovy 4, configuration cache preferred); 9.x current throughout 2026. 8.14.3 was already superseded when the July verification ran. |
| sbt | "2.x upcoming — native BOM support lands in sbt 2"; SB callouts offer `useCoursier := false` as an escape hatch | **sbt 2.0.0 GA 29 Jun 2026** (JDK 17 min). The 2.0 change summary: "sbt 2.0 adds Maven BOM usage support" (`.pomOnly()` + `"*"` versions passed to Coursier); "Dropped `useCoursier` setting so Coursier cannot be opted out"; "sbt 2.x enforces eviction error in `Test` configuration". |
| Node | `node-demo/README.md:16-18`, `TOOL-VERSIONS.md:42,51`, `verify.sh:36-42`: "Node ≥ 22 … `corepack enable`" | Corepack README: "distributed with Node.js from version 14.19.0 up to (but not including) 25.0.0." On Node 25/26 the prerequisite gate in verify.sh fails. |
| Yarn | `TOOL-VERSIONS.md:43`, `comparison-table.md:52`: `npmMinimalAgeGate` "on by default" in 4.17 | Default-on arrived in **4.15.0** (May 2026); 4.17 added the per-scope form. [verified by Node reviewer against release pages] |
| npm | `comparison-table.md:52` release-age cooldown "—" | npm 11.10 added `min-release-age` (default off); `--before=<date>` has existed since npm 6. |
| uv | `TOOL-VERSIONS.md` uv table stops at 0.6.15; P9 and P12 | uv 0.9.8+ has `exclude-dependencies` (see D1); uv 0.10.10+ has a preview `uv audit`. |

**Fix:** decide a version policy (re-verify on a current major, or state explicitly that the book targets Maven 3.x / Gradle 8–9 / sbt 1.x and say what changes in sbt 2 and Gradle 9). Update the three TOOL-VERSIONS files and the sbt callouts in one pass; add a sbt 2 row (native BOM, no Ivy, Test eviction errors) to the sbt table, comparison table and cheat sheet.

### A2. Heading-level drift breaks box rendering (Maven)
`filters/scenario-boxes.lua:284-289` captures blocks until the next heading of level ≤ the box's level. A `### !` box therefore swallows every following `#### !` section.
- `demos/maven-demo/scenario-15-substitution/guide.qmd:27` `### ! Fix` swallows Risk, Control, Look, Scales, Takeaway, Related and Wild. **Confirmed:** the July build of this page contains only five `scn-` boxes.
- `scenario-11-locking/guide.qmd:29,35,49,53,57` (`###  ! Fix` with two spaces, `### ! Control` swallows `#### ! Check`), `scenario-12-metadata:28-42`, `scenario-13-variants:28-52`, `scenario-14-reject:29-54`.
**Fix:** normalise every section heading in the 90 guides to `#### !`. A one-line grep (`grep -n '^### ' demos/*/scenario-*/guide.qmd`) finds them all. Consider making the filter warn on a `### !` heading.

### A3. Index pathway still marks Node "coming soon"
`index.qmd:731-755`: `updateNodeState()` is a dead stub and `var comingSoon = isNode ? '(coming soon)' : ''` stamps every Node results header and link, although all 12 Node hrefs are live. The HTML edition tells readers the Node part does not exist. Delete the stub and the two `comingSoon` branches.

### A4. Fourteen demos cannot demonstrate their scenario
Each ships a build file whose resolution is identical with the feature removed, and a verify check that would pass either way.
| Scenario | What the build does | What the guide claims |
|---|---|---|
| MS8 | `<optional>` on this project's own dependency; no consumer exists | "the optional dependency will be absent" from a consumer |
| MS12 | plain pin, no enforcer plugin (guide:14 and TOOL-VERSIONS say enforcer is used) | rich metadata / upper-bound rule |
| MS14 | enforcer bans `lib-a:2.0.0` but the POM declares no dependencies | ban fails the build |
| MS15 | excludes `log4j:log4j`, which no fixture declares | substitution changes the tree |
| GS8 | single project, `compileOnly` | optional dep not seen by consumer |
| GS13 | config block only; the `jdk11` classifier published by `install_deps.sh:33` is never requested | variant selection |
| GS14 | requires `lib-a:1.0.0`, rejects `2.0.0`; nothing proposes 2.0.0 | reject knocks out a candidate |
| SB8 | fixture has no `<optional>` anywhere | lib-b absent |
| SB12 | bare `lib-a:1.0.0` (guide narrates exclude+add lib-b:2.0.0) | resolves lib-b:2.0.0 |
| SB13 | bare `lib-a:1.0.0`; could request the `jdk11` classifier | variant selection |
| SB14 | bare `lib-a:1.0.0`; Fix overrides to the version already declared | version rejected |
| SB15 | bare `lib-a:1.0.0`; Fix excludes `com.original:old-lib` which exists nowhere | substitution |
| GS11 | `1.+` always resolves 1.0.0; verify accepts 1.0.0 or 2.0.0 | lock prevents drift |
| N12 | npm only | pnpm/Yarn "query the same advisory endpoint" |
**Fix:** the fixture graph already supports most of these (lib-a v2 → lib-b v2 → lib-c v2, the jdk11 classifier, lib-circle-a/b). For optional (MS8/GS8/SB8) add one fixture with `<optional>true</optional>` shared by all three tracks. Each verify check should also prove the negative (feature removed → different result), as MS18 and the Node checks already do.

### A5. The Gradle and sbt parts are islands
`grep -l 'maven-demo\|sbt-demo\|python-demo\|node-demo' demos/gradle-demo/*/guide.qmd demos/sbt-demo/*/guide.qmd` returns nothing. No Gradle or sbt guide links to any sibling in any other track, while Maven links 12 Python and 10 Node siblings and Python/Node link both ways. A Gradle or sbt reader never discovers the other 42 scenarios. Add MS/SB/P/N siblings to every Related section; the Python plan's rule ("reverse links at write time") should become a repo check in `scripts/audit_scenarios.py`.

---

## B. Core chapters

### B1. Framing still describes a JVM-only book (MEDIUM, many places)
- `book/content/conclusion.md:7` "Across 17 scenarios and three build tools" — it is 18 JVM + 12 Python + 12 Node across five ecosystems. The "Trust but Verify" tool list (`dependency:tree`, `dependencies`, `dependencyTree`) is JVM-only. Theme 5 ("Reproducibility requires active effort … only Gradle has built-in locking") is contradicted by the Node part, where all three tools lock by default; worth one sentence. Item 7 is a sign-off, not a theme.
- `book/content/scenarios.md:6` "All are implemented for Maven, Gradle, and SBT". There is a Python paragraph (line 10) but **no Node paragraph**, and both the HTML and PDF tables list only the 18 JVM scenarios. The "Scenario make up" section (lines 59-66) is unfinished ("and. configuration examples", "So  we've tried") and never names the Expect/Actual/Why/Fix/Risk/Control/Check/Scales/Takeaway/Related/Wild sections, which is exactly what a reader needs here.
- `book/content/triage.md`: Maven-only links (prior MEDIUM, unfixed) and JVM-only symptoms. No `ResolutionImpossible`, `ERESOLVE`, phantom-import or "works in dev, breaks in prod" rows, all of which the Python/Node parts cover. The "Exclusion failing to remove dependency" bullet links nowhere.
- `book/content/start_here_trouble.qmd:3` "Has something in your build has started"; `start_here_control.qmd:3` "f your build is stable" — both typos survive from July. Both pages route only to MS/GS/SB.
- `book/content/classpath-reality-check.md`: a chapter consisting of one callout, titled by an H2 inside it. JVM-only, though the Node part has the exact mirror (two live copies of one package) and Python the inverse (one environment, one version). Prior MEDIUM (two failure mechanisms conflated) unfixed.
- `book/content/acknowledgements.md:18` "built and tested against real Maven, Gradle, and SBT projects".
- `README.md`: "Java-based ecosystems (Maven, Gradle, and SBT)", prerequisites omit Python/Node, targets omit `init-python`, `init-node`, `verify-python`, `verify-node`, `audit`; "© 2024" (site footer says 2026); structure list omits `scripts/`, `filters/`, the build profiles.

### B2. index.qmd (MEDIUM)
- No format-conditional content: PDF readers get "use the pathway chooser above" and "pick 'Understanding the system' above" with nothing above them. Wrap the About block in `::: {.content-visible when-format="html"}` and give PDF readers a short pointer to the two Start Here chapters.
- Pathway data uses bare `S1…S18` ids; the book convention (scenarios.md:8) is MS/GS/SB.
- Python "Unwanted transitive dependency" routes to P9 then P1; P6 (constraints) is the practical answer and is missing.

### B3. Appendices (MEDIUM)
- `comparison-table.md:15` "Circular Dependencies | Allowed (warns)" ×3 — prior MEDIUM, unfixed. Project/reactor cycles hard-fail in all three; external cycles are broken silently, with no warning.
- JVM table has no rows for Optional (S8), Rejection (S14), Substitution (S15), Private repo/patch (S16/17), Metadata rules (S12) — prior MEDIUM, unfixed. BOM row needs the sbt 2 note. Python and Node tables are good and should be the model.
- `cheat-sheet.md`: Gradle has no locking (`--write-locks`), reject or substitution one-liners; Maven has no locking-plugin or enforcer-reject example — prior MEDIUM, unfixed. Line 128 "Reset a history-shaped tree: `rm -rf node_modules && npm ci`" is wrong (see F1). "`sbt dependencyTree` (requires plugin in older versions)" → "< 1.4".
- `glossary.md`: stray opening quote in "Dependency Locking"; trailing-whitespace row. Entirely JVM: nothing for lock file, constraints file, extras, dependency group, environment marker, virtual environment, dependency confusion, phantom dependency, hoisting, peer dependency, semver/caret, workspace, Plug'n'Play; still no Coursier, Platform, Version Catalog, Classifier, Capability (prior LOW).

### B4. Front and back matter (LOW)
- `authors.md:14` "user group keader ,"; the parenthesis is never closed; "Occasional Mad scientist". Hervé's "Life changed even more when growing from OSS user…" is clunky.
- `sponsors.md` and `back_page.qmd` are in no profile's chapter list.
- Authors and Acknowledgements sit between the Start Here pages and the scenario parts; they read as back matter.
- `.gitignore` lists `build/` twice; `NODE-SCENARIOS-PLAN.md`, both July reviews and `PYTHON-SCENARIOS-PLAN.md` are untracked at the root. Commit them under `docs/reviews/` or ignore them; the July technical review should get a resolution record like the Python one has.

---

## C. Maven track (MS1–MS18)
Core content (MS1–9, MS18) is sound on nearest-wins, dependencyManagement precedence, BOM import, exclusions, scopes and the enforcer. July's structural items were mostly not applied.

**HIGH**
- C1. `### !` nesting bug — see A2.
- C2. `scenario-12-metadata/guide.qmd:32` `requireUpperBoundDeps` is still described backwards ("fails if a transitive dependency is older than a direct one"). It fails when the *resolved* version is *lower* than the highest version any path requested.
- C3. `demos/maven-demo/pom.xml:14` `file://${project.basedir}/../../target/local-repo` is inherited by scenarios 1, 11–17; `${project.basedir}` interpolates against the child, so it resolves to `demos/target/local-repo`, which does not exist. verify.sh masks it with `-Dmaven.repo.local`; a reader following any README's "run `mvn dependency:tree` here" gets an unresolvable `com.demo:lib-a`. Scenarios 2–10 and 18 use `../../../target/local-repo` correctly.
- C4. MS14, MS15, MS8, MS12 demos demonstrate nothing — see A4.
- C5. `scenario-7-scopes/guide.qmd:18-24,41-44`: the diagram shows three independent direct deps, but the fixture chain is lib-a → lib-b → lib-c. The direct `provided`/`test` declarations are nearer and demote the compile-scope transitives lib-a needs at runtime; the Reality box ("Runtime: A") is what Maven produces, and lib-a will `NoClassDefFoundError` without lib-b. That is the tagline's own failure and the guide never mentions it.

**MEDIUM**
- C6. Boilerplate "…is why the same graph behaves differently across tools" in 11 of 18 Why sections (2, 3, 4, 5, 7, 9, 11, 12, 13, 14, 15). In MS7 it is half the Why.
- C7. `scenario-9-ranges:35`, `scenario-12-metadata:31`: "`[1.0.0]` … causes build failure if any other version is selected". A hard range overrides soft versions; the build fails only when two hard constraints have no intersection.
- C8. `scenario-6-forcing/README.md:18` "`(version managed from 2.0.0)`" still wrong (tree prints the replaced version, and only with `-Dverbose`). `scenario-6-forcing/guide.qmd:42` "evaluates `<dependencyManagement>` after building the complete graph" — Aether applies managed versions during collection.
- C9. `scenario-10-circular/README.md:10,13` still says the scenario is "primarily for documentation" and that external cycles "can lead to `StackOverflowError`"; install_deps.sh publishes a real cycle and the guide (line 51) correctly says it is broken silently.
- C10. Skeletal: MS12 (no Check/Risk/Scales/diagram), MS13 (no Check, `### ! LOOK`, no diagram), MS16/17 (Scenario/Example/Expect/Why/Takeaway/Related only). MS11, MS14, MS15 have no diagram.
- C11. `scenario-3-mgmt/guide.qmd:3,10` tagline "When Your BOM Isn't Actually in Control" belongs to MS4; MS3's demo shows a BOM that *is* in control. MS3 Fix (line 42) is a risk statement; MS4 Fix (line 39) "They might try… Or they use exclusions" is still vague; MS9 Fix argues for banning ranges. MS4 Conclusion "always overrides" vs Takeaway "generally trump".
- C12. `scenario-2-conflict/guide.qmd:46,49` two back-to-back Why boxes; the LOW/MEDIUM/HIGH list at 57-59 is three Fix options filed under Risk.
- C13. `scenario-14-reject/guide.qmd:31-32` calls `[2.0.0,2.1.0)` a "wildcard" and invents versions 1.9.0/2.0.1 the fixtures lack.
- C14. No MS guide links its Gradle/sbt sibling; MS4, MS10, MS12, MS13, MS15 link no P/N; MS5, MS14, MS18 lack Node; MS6 lacks Python.

**LOW** `scenario-3-mgmt:48` `#### !Check`, `:66` `#### Related Scenarios` (the only unboxed Related in the track); `LOOK`/`Look` in 13/14/15; `scenario-9:34` `#####` inside Why; `scenario-10:21-22` mermaid labels use single quotes (`['…']`), which mermaid does not treat as quoting [unverified]; `scenario-16:10` "third-paty"; MS4 heading trailing colon; MS6/MS18 put the tagline on an italic line, every other MS guide in the heading; Related-link names for MS3/MS4/MS6/MS16 differ from their titles; `scenario-13:46` multi-release JARs are what *avoid* variants; `scenario-6:71` "OpenSSL >= 3.0" is not a Maven example; `verify.sh:12` derives root from cwd and scenario-15 writes to `/tmp/s15tree.txt`.

**July scorecard** — FIXED: MS13 jdk11 classifier, frontmatter MS12–15, verify.sh scenario-5 tautology and scenario-10 grep, verify coverage 11–15 (though 12/14/15 are tautological), MS10 "prints a warning", private-repo fixture. STILL PRESENT: MS12 upper-bound, MS14 ban, MS15 log4j, MS3 headings, MS11–15 `### !` (now a render bug), MS16/17 skeletal, root pom path, README-6 example, MS10 README, MS5 diagram (lib-a → lib-c direct), boilerplate.

---

## D. Gradle track (GS1–GS18)
The July conceptual fixes held: GS3/4/16/17/18 are now correct on platform precedence, `compileClasspath`, `--write-locks`, and read well.

**HIGH**
- D1. `scenario-6-forcing/README.md:6-8,17` describes a demo that does not exist: lib-a:2.0.0, `strictly` downgrade of lib-c to 1.0.0, expected output `lib-c:2.0.0 -> 1.0.0` "forcing a downgrade". `build.gradle:14,21` declares lib-a:1.0.0 and `force 'com.demo:lib-c:2.0.0'`. Every expected line in the README is wrong.
- D2. GS14 reject is a no-op, GS13 cannot show variant selection, GS8 cannot show non-transitivity — see A4. GS13 `guide.qmd:41` "`sourceCompatibility = JavaVersion.VERSION_11`" — the `org.gradle.jvm.version` attribute derives from `targetCompatibility`/toolchain, not `sourceCompatibility`.
- D3. `scenario-8-optional/guide.qmd:41` "Feature Variants, introduced in Gradle 6" contradicts the callout at line 15 (5.3); line 44 still calls `spring-boot-starter-data-jpa` "essentially a feature variant" (it is a plain POM module).

**MEDIUM**
- D4. `scenario-9-ranges/guide.qmd:22,31` `1.+` vs `build.gradle:14` `[1.0.0, 2.0.0)` — July item, unfixed.
- D5. `scenario-10-circular/guide.qmd:22-24` diagram draws lib-a/lib-b; build uses lib-circle-a/b. Line 42 compares Maven's *reactor* failure with Gradle's *external* tolerance; both tools behave the same in each case. `README.md:6` "Gradle is generally smarter than Maven at handling this" is false. Related "N/A".
- D6. `scenario-6-forcing/guide.qmd:2-3` title "Strict Constraints" / "When Constraints Stop Resolution Completely" for a `force` demo that succeeds; GS14:55 echoes it. Line 33 "Forced versions override all other constraints" overstates (a `force` against a `strictly` fails resolution). `verify.sh:75` grep matches with the force removed.
- D7. `verify.sh:82` asserts on `dependencies --configuration compileOnly`, a declarable (not resolvable) configuration; proves nothing about classpaths. The claim needs lib-b in `compileClasspath` and absent from `runtimeClasspath`. README:21 repeats it.
- D8. GS12–15 have no Check (`! Look`, `! Reality` instead). GS16/17 each have two `#### ! Example` boxes and no Fix/Risk/Control/Check/Scales/Wild; GS16 has no Related.
- D9. GS1 is off-template and thin: `#### ! Diagram`, `#### ! Dot Reader Expectation` (renders as a "DOT" box), `#### ! Scales How This Scales`; no Fix/Risk/Control/Wild; line 35 "depth-first traversal" is unsupported; line 49 "`omitted` nodes" is Maven vocabulary (Gradle prints `(*)`/`->`).
- D10. `verify.sh:103-125` is twenty lines of think-aloud comments; GS11 `guide.qmd:35` "uses these versions instead of performing dynamic resolution" — Gradle still resolves, adds the lock as strict constraints, and fails on mismatch.
- D11. Boilerplate in GS5:36, GS9:34, GS13:35, GS14:36. "Gradle"-eating find/replace artifacts: GS1:10,55 ("It shows how it automatically", "It resolves"), GS2:10,56 ("demonstrates its default", "It upgrades you"), GS7:11.
- D12. No GS guide links any other track (A5).

**LOW** `#### Related Scenarios` (no `!`) in GS7:53, GS9:54, GS14:54, GS15:61; `! Reality` in GS8/10/12 duplicating Actual; taglines inside the heading in GS1/GS2 only; GS5 diagram draws lib-a → lib-c direct; empty Takeaways ("Exclusions work as expected.", "Ranges work but are dynamic.", "`compileOnly` simulates optionality."); GS14 "Blacklist"; GS13 tagline promises a rejection that never happens; no `settings.gradle` in any scenario and no `gradlew` though every Check says `./gradlew`.

**July scorecard** — FIXED: `--lock-state`, `--configuration implementation`, platform precedence (GS3/4/16/17), GS11 Related heading, GS16/17 READMEs, GS8 callout. STILL PRESENT: GS8 Why/Scales, GS9, GS10, GS6 title, GS14 no-op, GS7/9/14/15 Related headings, GS1 artifacts, GS12–15 Check, GS16/17 duplicated Example and skeletal bodies.

---

## E. sbt track (SB1–SB18)
Every feature now claimed exists. Locking is correctly the `sbt-dependency-lock` plugin with a `project/plugins.sbt`; `mavenBomImport` is gone; SB4/SB6/SB8 no longer contradict their fixtures; SB18 is a genuinely good chapter.

**HIGH**
- E1. `scenario-2-conflict/guide.qmd:37,40,49` "Resolves `lib-b:2.0.0` (via `latest-revision` conflict manager)… employs the `latest-revision` conflict manager by default". That is an Ivy conflict manager; under Coursier (which the callout three lines above says was tested) `conflictManager` is ignored. `build.sbt:10` "Ivy (SBT's underlying engine)". Right answer, wrong mechanism, contradicting its own callout.
- E2. SB12, SB13, SB14, SB15 all ship the identical bare `lib-a:1.0.0` — see A4. `verify.sh:103-118` assert the trivially true `lib-a/1.0.0`.
- E3. `scenario-16-private-bom/guide.qmd:21-35,59-60` diagram still shows `Root -- imports --> VendorBOM` and "version from BOM", and the Takeaway speaks of "an imported BOM"; `build.sbt:14-22` never references `patched-bom` and hard-pins `2.5.14.ACME` in `dependencyOverrides`. The prose (line 38) is honest about the emulation; the picture and Takeaway are not. With sbt 2 now shipping native BOM support, this chapter needs a version split.

**MEDIUM**
- E4. `scenario-3-mgmt/README.md` and `scenario-4-override/README.md` each describe a different build from the `build.sbt` beside them (SB3 README: lib-a:2.0.0 + override; build: both 1.0.0 via a `libVersion` val. SB4 README: override to 2.0.0; build: no `dependencyOverrides`).
- E5. `verify.sh:60` SB4 asserts `lib-a/2.0.0` (the direct declaration) instead of the eviction the scenario is about (`lib-b/2.0.0` present, `lib-b/1.0.0` absent). `verify.sh:97-98` SB11 never runs `dependencyLockCheck`, which the guide's Check promises, and `dependencyLockWrite` rewrites the committed `build.sbt.lock` on every run.
- E6. `scenario-9-ranges/guide.qmd:22,31` `1.+` vs `build.sbt:13` `[1.0.0,2.0.0)` — July item, unfixed.
- E7. `scenario-14-reject/guide.qmd:28,44` "SBT lacks a first-class reject mechanism" ignores `evictionErrorLevel := Level.Error` + `versionScheme`/`libraryDependencySchemes` (1.5+), which every callout mentions and the reject chapter never uses. `README.md:8` "custom eviction rules in `evictionWarningOptions`" is wrong (deprecated; tunes warnings only).
- E8. `scenario-10-circular/guide.qmd:54` "SBT may print a warning" — Coursier breaks artifact cycles silently.
- E9. `scenario-8-optional/build.sbt:10` comment "SBT/Ivy doesn't have a direct 'optional' flag" contradicts the guide's correct `% Optional`.
- E10. `scenario-5-exclusions/guide.qmd:59,62` Takeaway "Exclusions work.", Related "N/A" (SB18 and SB15 exist); diagram hides lib-b. `scenario-6-forcing:66,69` "Overrides force versions." / Related "N/A".
- E11. `scenario-7-scopes/guide.qmd:49`, `verify.sh:75`, `README.md:20` legacy `runtime:dependencyClasspath` / `test:externalDependencyClasspath` (deprecated 1.5, removed in sbt 2). Actual (37) "lib-b: Compile only" contradicts Wild (66), which is correct (Provided is on compile and test classpaths).
- E12. `scenario-15-substitution/build.sbt:15` "True module substitution… via custom updateOptions" still present; `guide.qmd:30-31` "Reality: Depends on the implementation." is content-free.
- E13. Template drift: `#### Related Scenarios` (unboxed) in SB1:64, SB2:64, SB3:64, SB4:65, SB7:61, SB8:60, SB9:51, SB12:65, SB14:46, SB15:55; `! Look` in SB12–15; `! Reality` in SB10/12/15; duplicated `#### ! Example` in 14 of 18 guides; stray literal `N/A` paragraph after Scenario in SB13/14/15:13; SB16 Related before Takeaway.
- E14. Coverage: Risk missing in 11 guides, Wild in 12, Fix in 6, Scales in 3, Check in SB17. SB17 is six sections.
- E15. No SB guide links any other track (A5).

**LOW** Stale "via Ivy" in SB1:36, SB5:38, SB9:34, SB10:37, SB12:42,53, SB13:28 and five READMEs; SB1:53 "`omitted` nodes"; SB3:39 "sbt-bom" vs "here-sbt-bom" elsewhere; SB16/17 `scalaVersion 2.13.8` vs 2.13.12 everywhere else and a redundant `"central"` resolver; SB5/SB6 lack the italic tagline; callout "`conflictManager` behave differently" understates "ignored".

**July scorecard** — FIXED: SB11 locking, SB9 Wild, SB16 `mavenBomImport`/type error, SB6 lib-b/lib-c, SB8 guide text, SB4 Expect, SB5/SB6 frontmatter, SB11 `gradle.lockfile`, verify scenario-5 tautology. STILL PRESENT: SB2 Ivy mechanism, SB5 Takeaway/Related, SB12 build, SB13 snippet, SB10 warning (softened, still wrong), SB7 syntax, SB15 `updateOptions`, Risk/Check/Wild erosion, `Look`.

---

## F. Node track (N1–N12)
Structurally the strongest part: uniform headings, every link/include/snippet resolves, reverse links in every cited Maven and Python guide, and the big tool claims (npm 3 hoisting, npm 5 lock, npm 7 ERESOLVE, npm 8.3 overrides, pnpm 11 reading overrides from `pnpm-workspace.yaml`, YN0060, PnP default, per-scope `npmMinimalAgeGate`) check out.

**HIGH**
- F1. `scenario-9-tree-shape/guide.qmd:43` "Reinstall clean when the tree matters: `rm -rf node_modules && npm ci`". npm's lockfile (v2/v3) keys entries by *path*, so after the detour the lock records the nested shape and `npm ci` reproduces it exactly. The guide's own Check (line 61) and `verify.sh:250` delete `package-lock.json` as well, because they had to. Same error in the Wild (line 78, "a pure function of the lockfile"), in N5 Related (`scenario-5-locks/guide.qmd:66` "What the lockfile does *not* fully pin: the shape of the tree"), and in `cheat-sheet.md:128`. Fix: the lock records placement; resetting needs `npm dedupe`, or deleting node_modules *and* the lock.
- F2. Corepack prerequisite — see A1.

**MEDIUM**
- F3. Yarn cooldown default attributed to 4.17 (really 4.15); npm cooldown "—" (see A1).
- F4. `scenario-6-overrides/guide.qmd:47` "the lever Python's pip/Poetry simply don't have (P9 — only uv does)" contradicts line 11 ("pip does it with constraints (P6)") and P6's title. Line 51 "npm and Yarn support nested forms" — nested objects are npm-only; Yarn uses `"demo-lib-b/demo-lib-c"`, pnpm `"demo-lib-b>demo-lib-c"` (omitted).
- F5. `scenario-12-audit/guide.qmd:61` and `python-demo/scenario-12-audit/guide.qmd:62`: "a decade" between npm audit (2018) and pip-audit (2021). Three years.
- F6. N12 is npm-only (A4); N9 has no Yarn leg; `verify.sh:176-182` N5 never exercises `--frozen-lockfile`/`--immutable`, the scenario's point.
- F7. The plan's "three-model triangle" diagram and Node part intro never landed; the thesis survives as prose in `comparison-table.md:38` and `node-demo/README.md`. Either add the intro + diagram (it would be the single best figure in the book) or strike the promise.

**LOW** N2:11 "resolves by eviction (MS2)" (Maven is nearest-wins) and "demo-lib-a 2.0.0 needs demo-lib-c 2.0.0" (via b); N8:14 unsourced superlative; N12:29 GitHub advisory DB anachronism (2018 was npm's own database); N3/N4/N11 successive `cd npm && …; cd pnpm && …` lines are relative to the previous `cd`; N10:73 Related cites MS1 for multi-module (it is not); N10:14 Yarn also matches workspaces by name; duplicate snippet tag `n11-scoped` in `pnpm/.npmrc`; `verify.sh:193` label says `pnpm.overrides` for a scenario whose point is that pnpm 11 ignores it; P9 lacks a reverse link to N6; MS2 lacks one to N8.

---

## G. Python track (P1–P12)
All eight July fixes are present with no regression; links, includes, fixtures and verify legs agree with the guides. Two factual problems survived.

**HIGH**
- G1. `scenario-9-exclusions-gap/guide.qmd:33` "**Nothing in the Python ecosystem removes a required transitive.**" (also lines 11, 14, 36, 65; `uv/pyproject.toml` comment; README; `TOOL-VERSIONS.md` uv section and P9 row; P12 lines 11, 29, 56). uv has had `[tool.uv] exclude-dependencies` since 0.9.8, with scoped exclusions equivalent to Maven's per-edge `<exclusion>` — verified today at docs.astral.sh/uv/concepts/resolution ("Dependency exclusions remove packages from the dependency graph"). The track was tested on uv 0.11, so this was wrong in July. The chapter's thesis survives for pip and Poetry; reframe as "pip and Poetry have no exclusion; uv has override (version) and exclusion (removal)", add the snippet and a verify leg asserting `demo_lib_c` absent.
- G2. `scenario-7-extras-groups/guide.qmd:35` "**Poetry** — absent by default; needs `--with dev` to include it." Poetry installs every non-optional group by default; `dev` is not special and the demo's group is not `optional = true`, so `--with dev` is a no-op. verify.sh's `--without`/`--with` pair passes either way, which is why execution did not catch it. Also soften line 47 and the Check comment at 63.

**MEDIUM**
- G3. `scenario-7:14,24,46,73` and the TOOL-VERSIONS Poetry table say Poetry uses "its own syntax" for groups; Poetry 2.2 (Sep 2025) added PEP 735 `[dependency-groups]` support, so the tested 2.4 reads the standard table and one snippet could serve all three tools.
- G4. P12 and the uv table never mention `uv audit` (preview since 0.10.10; OSV-backed, JSON/SARIF). The uv table stops at 0.6.15.
- G5. `scenario-12-audit/guide.qmd:46-48` Check installs `pip-audit` and `urllib3==1.26.4` into one venv and runs bare `pip-audit`; verify.sh deliberately abandoned that path (comment explains the crash) and audits `-r requirements.txt` from a clean venv. The book shows the path the harness rejected.
- G6. `verify.sh:293-296` claims S12 is the only online check, but the S7 third pip leg runs `pip install --upgrade "pip>=25.1"` from PyPI ungated, so an offline run fails S7.
- G7. `verify.sh:75-79` `new_venv` never upgrades pip, so the "Tested with pip 25.3" callouts are not what the harness exercises (July run used venv-bundled 22.0.2). Pin or print the version.
- G8. `scenario-4-specifiers/guide.qmd:11,39` "The JVM has no native equivalent [to `!=`]; Maven reaches for the enforcer plugin" — Gradle's `reject` is native (the book's own GS14). Say Maven, link GS14.

**LOW** `scenario-6-constraints/README.md:5` promises an unconstrained run verify.sh never does; P4/P6/P8 Checks show pip only though verify runs three tools; P11 never includes the tagged `p11-poetry-sources` snippet; 8 of 12 guides have no diagram (P9 and P11 would benefit most); `scenario-7/README.md:3` stale "separate requirements files"; P5:44 `pip freeze` cannot emit hashes at all; P8:38 `poetry.lock` is also platform-independent; P12:33 pylock auditing is `pip-audit --locked`, not `-r`.

---

## H. Writing quality

The strongest writing in the book is in the Python and Node parts and in the JVM chapters rewritten in July (GS4, SB11, SB18, MS18): one claim per section, Expect/Actual framed as a bet the reader loses, concrete commands, Wild sections with named incidents. The weakest is the older JVM material, where the same faults recur:

- **Pasted boilerplate.** "This … is why the same graph behaves differently across tools" closes 18 Why sections (11 Maven, 4 Gradle, 3 sbt) as a non-sequitur. Delete it everywhere; where a cross-tool contrast is wanted, write the actual contrast and link the sibling.
- **Find/replace scars.** Gradle guides lost the word "Gradle" ("demonstrates its default", "It shows how it automatically", "It upgrades you").
- **Empty Takeaways.** "Exclusions work." "Overrides force versions." "Ranges work but are dynamic." A Takeaway should be the sentence the reader repeats to a colleague; the Node ones ("The JVM picks a winner, Python refuses to play, Node lets everyone win") show the standard.
- **Fix sections that aren't fixes.** MS3 (a risk), MS4 ("They might try…"), MS9 (an argument), SB15 ("Depends on the implementation").
- **Taglines.** All 90 read "Or what to Do When…" (lower-case what, capital Do). Several are attached to the wrong scenario (MS3, GS13, GS6).
- **Diagrams that lie.** MS5, GS5, SB5 draw lib-a → lib-c directly; GS10 draws the wrong libraries; SB16 draws a BOM import that does not happen; GS9/SB9 draw `1.+` for a range build.
- **Vocabulary drift.** "SBT" (79) vs "sbt" (248); "eviction" used for Maven; "`omitted` nodes" used for Gradle and sbt; "wildcard" for a range; "Ivy" as sbt's engine; MS/GS/SB in the book, bare S in the index, "Scenario 9: Ranges" in sbt Related lists.
- **Scenario framing.** `scenarios.md` promises a description of the section template and never gives one. The Python and Node parts have no intro page; the one-paragraph thesis each part hangs off lives only in a README and a comparison-table caption.

---

## I. Suggested fix order

1. **Render bug + heading normalisation** (A2, E13, D8) — mechanical, one pass over 90 files; make `audit_scenarios.py` reject `### !`.
2. **Tool currency pass** (A1): three TOOL-VERSIONS files, every callout, sbt 2 rows, Corepack prerequisite, Gradle 9 note. Decide whether to re-verify on Gradle 9 / sbt 2.
3. **Factual corrections**: C2, C5, C7, E1, E7, E8, E11, F1 (+ cheat sheet + N5), G1, G2, G3, D3, D6, F4, F5, G8.
4. **Demos that demonstrate** (A4): shared `<optional>` fixture; real reject candidates for GS14/SB14; jdk11 classifier for GS13/SB13; exclude+add for SB12/SB15; MS14 dependency; MS15 fixture; two-project builds for MS8/GS8; negative assertions in every verify.sh.
5. **Framing chapters** (B1–B3, A3): index coming-soon, PDF-safe About, scenarios.md Node paragraph + P/N tables + section template, triage and Start Here rows for Python/Node, conclusion count and themes, comparison-table rows, cheat-sheet Gradle/Maven gaps, glossary across five ecosystems, README, acknowledgements.
6. **Cross-links** (A5): MS↔GS↔SB on every scenario; GS/SB → P/N; audit script enforces both directions.
7. **Template completeness**: Risk/Wild/Check/Fix in the JVM guides that lack them (MS12/13/16/17, GS1/12–17, SB12–17 first); Node part intro + triangle diagram.
8. **Copy-edit pass**: boilerplate, Takeaways, taglines, typos (authors, Start Here), diagrams, vocabulary.

## Verified clean

All 90 guides have frontmatter and a Tool Versions callout; every `include=`/`snippet=` resolves to an existing file and matching `tag::`/`end::` pair; every relative Related link resolves on disk; all 90 chapters are listed in `_quarto.yml`; `scripts/audit_scenarios.py` passes its structural checks (its only failures are missing fixtures after `make clean`); the private-repo fixture (`install_private_repo.sh`) publishes `patched-bom:1.0.0` and `spring-boot-starter:2.5.14.ACME` so S16/S17 are coherent in all three JVM tracks; the fixture graph (lib-a → lib-b → lib-c at v1/v2, demo-bom pinning 1.0.0, lib-circle-a ↔ b, jdk11 classifier) matches MS1/2/3/4/6/18, GS2/3/4/5/12/15/16/17/18, SB1/2/4/6/16/17/18 and every Python and Node diagram; Python fixture metadata and PEP 503 indexes are correct; Node `.yarnrc.yml`/pnpm settings zero the cooldowns everywhere and N3 alone runs PnP; the July Python fixes (resolver timeline, `--group`, Poetry pylock export, uv dates, PEP 668, CWE, survey claim, reverse links) are all present; Maven enforcer 3.5.0 / 3.6.3 minimum, `versions:resolve-ranges`, `maven-lockfile`, Gradle 4.8/5.0/5.3/6.6/7.0 dates, sbt 1.3/1.4/1.5 dates, `sbt-dependency-lock` coordinates and tasks, Birsan 2021, left-pad 2016 and Log4Shell details check out.

## Confidence notes

Verified online today: Maven 3.10.0 current / 4.0.0-rc-7 preview; Gradle 9.0.0 (31 Jul 2025); sbt 2.0.0 (29 Jun 2026) and its change summary (BOM support, `useCoursier` dropped, Test eviction errors); Corepack not shipped from Node 25.0.0; uv `exclude-dependencies` docs. Verified against the July HTML build: the MS15 box-swallowing bug. Reported by the track reviewers from release pages: Yarn 4.15 cooldown default, pnpm 11.0.0 details, npm 11.10 `min-release-age`, uv 0.9.8 exclusion changelog, Poetry 2.2 PEP 735. From tool knowledge, not re-verified: Maven range/hard-constraint semantics (C7), Aether managed-version timing (C8), Gradle `compileOnly` resolvability (D7), sbt `evictionErrorLevel` behaviour (E7), npm lockfile path-keyed layout (F1 — corroborated by the demo's own need to delete the lock), Poetry default-group behaviour (G2). The mermaid single-quote claim (Maven LOW) was not rendered.

---

## Resolution — 2026-10-19

All findings above were applied the same day, by five parallel per-track passes (Maven, Gradle, sbt, Python, Node) plus a core-chapter pass, and every track was then **re-verified by execution** on the local toolchain. Nothing is committed; `git status` shows the full change set.

### Execution results

| Track | verify.sh | Toolchain |
|---|---|---|
| Maven | 18/18 | Apache Maven 3.9.16, JDK 25 |
| Gradle | 18/18 | Gradle 9.3.0 (first run on 9.x; "re-verified on 9.3" sentence added to every callout) |
| sbt | 18/18 | sbt 1.12.2 (Coursier) |
| Python | 35/35 (+1 new uv-exclusion check) | Python 3.14.6, venv pip 26.1.2, Poetry 2.4.1, uv 0.11.27 |
| Node | 39/39 (+3: N5 frozen negatives, N9 Yarn leg, N12 pnpm/Yarn legs) | Node 26.4.0, npm 12.0.1, pnpm 11.10.0, Yarn 4.17.0, Corepack 0.35 (separate install), Verdaccio 6.10.6 |

`scripts/audit_scenarios.py`: 0 failures, 0 warnings. The audit now also enforces section-heading level and names, rejects `#### Related Scenarios`, duplicated Example boxes and the pasted boilerplate sentence, and warns when a JVM guide does not link both sibling JVM tracks. All core chapters and the full book render to HTML without errors.

### What was done

- **A1 tool currency:** `demos/TOOL-VERSIONS.md` rewritten (Maven 3.10/4.0-rc-7, Gradle 9.0 row, sbt 2.0 row with native BOM / no Ivy / Test eviction errors, lib-d fixture, two verified-behaviour notes); Gradle and sbt callouts updated in all 36 guides; Node Corepack prerequisite corrected in README, TOOL-VERSIONS, verify.sh gate and install script; Yarn 4.15 / pnpm 11 / npm 11.10 cooldown attributions corrected; Python TOOL-VERSIONS gains Poetry 2.2 (PEP 735), uv 0.9.8 (exclusions) and 0.10.10 (`uv audit` preview) rows.
- **A2 render bug:** every section heading in all 90 guides is `#### !` with a template name; no `### !`, `Look`, `Reality`, `Diagram`, `Dot Reader Expectation` or duplicated Example remain.
- **A3:** index.qmd "coming soon" machinery removed; pathway ids are MS/GS/SB; an HTML-only About block and a PDF-safe one; P6 and N12 added to the pathways.
- **A4 demos that demonstrate:** new shared fixture `com.demo:lib-d:1.0.0` (optional `lib-c`) used by MS8/GS8/SB8; MS12 (managed downgrade trips `requireUpperBoundDeps`), MS14 (ban trips, `-Pfixed` passes), MS15 (exclude + stand-in on the real graph), GS11 (`+` locked to 1.0.0, "enforced by Dependency Locking"), GS13/SB13 (`jdk11` classifier), GS14 (range admits 2.0.0, reject knocks it out), SB12 (exclude+add inside the snippet), SB14 (`libraryDependencySchemes` + `evictionErrorLevel` fails `update`), SB15 (exclude + lib-d), N12 (pnpm and Yarn legs). Every verify check now also proves the negative where a POM edit is not required.
- **A5 cross-links:** every JVM guide links both sibling JVM tracks and its P/N siblings; Gradle and sbt are no longer islands; P9→N6 and MS2→N8 reverse links added.
- **Core chapters:** scenarios.md (five ecosystems, P and N tables, section template described), triage.md (JVM links for all three tools, Python and Node sections), both Start Here pages (typos fixed, Python/Node routes), classpath-reality-check.md (two JVM mechanisms, Python and Node mirrors), conclusion.md (42 scenarios, three-answers theme, locking nuance, cross-ecosystem tool list), comparison-table.md (circular row corrected; optional/reject/substitution/private/metadata rows; sbt 2 BOM; uv exclusions and `uv audit`; Node cooldown row), cheat-sheet.md (Maven/Gradle/sbt locking, reject, substitution; uv exclusion; corrected Node reset line), glossary.md (grouped, ~45 terms across all three ecosystems), authors.md, acknowledgements.md, README.md (five-ecosystem, all make targets, structure, how to write a scenario).
- **New part introductions:** `book/content/part-jvm.qmd` (shared fixture graph and the three resolution rules side by side), `part-python.qmd`, `part-node.qmd` (the three-answers triangle diagram). Authors and Acknowledgements moved to back matter; "SBT Scenarios" part renamed "sbt Scenarios".
- **Copy-edit:** boilerplate sentence gone from all 18 guides; "Gradle"-eating artifacts repaired; empty Takeaways and non-fix Fix sections rewritten; taglines "Or what to do when …" everywhere; "sbt" lowercase in prose; Ivy-era phrasing purged from the sbt track; every JVM guide now has Risk and Wild sections with real incidents.

### Corrections to the review itself, found by execution

- **C5 / E11 (scope demotion):** true for Maven (nearest-wins mediation demotes the transitive to the direct declaration's scope) and **false for sbt**: under Coursier a direct `% Provided` on lib-b does not remove lib-b from Runtime when lib-a needs it at Compile. SB7 was rebuilt around lib-d/lib-circle-a and now teaches the sbt behaviour and the trap; recorded in `demos/TOOL-VERSIONS.md`. GS7 was likewise reshaped because its old `compileOnly lib-b` was on `runtimeClasspath` anyway via lib-a.
- **F1 (npm tree reset):** confirmed that `npm ci` reproduces the nested shape from the lock. Additionally found that `npm dedupe` does **not** re-hoist on npm 12; only deleting `node_modules` and `package-lock.json` and reinstalling does. N9, the cheat sheet and the glossary say so. Yarn's node-modules linker re-hoists on its own.
- **GS4:** the tree actually shows `lib-b -> 2.0.0` as well (lib-a:2.0.0's transitive also beats the platform); the old README claimed 1.0.0.

### Still open

- Python's pinned pip 25.3 was not re-exercised (the venv pip was 26.1.2); TOOL-VERSIONS states the July pins as the documented baseline and today's versions as the re-verification.
- GS13 demonstrates classifier-based selection; a true Gradle-Module-Metadata variant fixture was not published.
- MS15/MS18 negative cases are described in their Check sections but not run by verify.sh (they would require editing the POM).
- `sponsors.md` and `back_page.qmd` are still in no profile; the Makefile's sample/brochure page ranges were not re-tuned after moving Authors and Acknowledgements to the back.
- The July plan and review files at the repo root (`NODE-SCENARIOS-PLAN.md`, `PYTHON-SCENARIOS-PLAN.md`, `*-REVIEW-2026-07-06.md`) are still untracked; commit them under `docs/reviews/` or ignore them.
- PDF output was not rendered in this pass (HTML only); run `make book` before publishing.
