---
title: Scenarios
---

This guide teaches dependency management through targeted scenarios: one mechanism, one surprise, one fix at a time. There are three sequences, one per ecosystem, because the ecosystems do not agree on what a "conflict" even is.

- **JVM (Maven, Gradle, sbt):** 18 scenarios, each implemented for all three tools so you can see the same graph resolved three ways. References use a tool prefix: **MS** (Maven), **GS** (Gradle), **SB** (sbt). MS2 is the Maven version of scenario 2, GS2 is Gradle, SB2 is sbt.
- **Python (pip, Poetry, uv):** 12 scenarios, prefix **P**. Numbered on their own because Python's model, one environment holding one version of each package, reshapes which scenarios matter and adds several (resolver history, environment markers, venv isolation, dependency confusion, auditing) that have no JVM equivalent.
- **Node (npm, pnpm, Yarn):** 12 scenarios, prefix **N**. Node's model is the third answer to the same problem: the tree can hold several versions of one package at once, so the classic conflict dissolves and the trouble moves to tree shape, phantom imports and the singletons (peer dependencies) that must not be duplicated.

Every scenario links to its siblings in the other ecosystems, so you can read the same problem three times and watch the answer change.

## JVM scenarios

::: {.content-visible when-format="html"}

|  #  | Scenario | Maven | Gradle | sbt |
|:---:|:---|:---:|:---:|:---:|
| 1  | Basic Transitive Resolution | [MS1](../../demos/maven-demo/scenario-1-basic/guide.qmd) | [GS1](../../demos/gradle-demo/scenario-1-basic/guide.qmd) | [SB1](../../demos/sbt-demo/scenario-1-basic/guide.qmd) |
| 2  | Version Conflict | [MS2](../../demos/maven-demo/scenario-2-conflict/guide.qmd) | [GS2](../../demos/gradle-demo/scenario-2-conflict/guide.qmd) | [SB2](../../demos/sbt-demo/scenario-2-conflict/guide.qmd) |
| 3  | Dependency Management (BOM / Platform) | [MS3](../../demos/maven-demo/scenario-3-mgmt/guide.qmd) | [GS3](../../demos/gradle-demo/scenario-3-mgmt/guide.qmd) | [SB3](../../demos/sbt-demo/scenario-3-mgmt/guide.qmd) |
| 4  | Hardcoded Version vs Managed Version | [MS4](../../demos/maven-demo/scenario-4-override/guide.qmd) | [GS4](../../demos/gradle-demo/scenario-4-override/guide.qmd) | [SB4](../../demos/sbt-demo/scenario-4-override/guide.qmd) |
| 5  | Exclusions | [MS5](../../demos/maven-demo/scenario-5-exclusions/guide.qmd) | [GS5](../../demos/gradle-demo/scenario-5-exclusions/guide.qmd) | [SB5](../../demos/sbt-demo/scenario-5-exclusions/guide.qmd) |
| 6  | Forcing a Version | [MS6](../../demos/maven-demo/scenario-6-forcing/guide.qmd) | [GS6](../../demos/gradle-demo/scenario-6-forcing/guide.qmd) | [SB6](../../demos/sbt-demo/scenario-6-forcing/guide.qmd) |
| 7  | Scopes and Configurations | [MS7](../../demos/maven-demo/scenario-7-scopes/guide.qmd) | [GS7](../../demos/gradle-demo/scenario-7-scopes/guide.qmd) | [SB7](../../demos/sbt-demo/scenario-7-scopes/guide.qmd) |
| 8  | Optional Dependencies | [MS8](../../demos/maven-demo/scenario-8-optional/guide.qmd) | [GS8](../../demos/gradle-demo/scenario-8-optional/guide.qmd) | [SB8](../../demos/sbt-demo/scenario-8-optional/guide.qmd) |
| 9  | Version Ranges | [MS9](../../demos/maven-demo/scenario-9-ranges/guide.qmd) | [GS9](../../demos/gradle-demo/scenario-9-ranges/guide.qmd) | [SB9](../../demos/sbt-demo/scenario-9-ranges/guide.qmd) |
| 10 | Circular Dependencies | [MS10](../../demos/maven-demo/scenario-10-circular/guide.qmd) | [GS10](../../demos/gradle-demo/scenario-10-circular/guide.qmd) | [SB10](../../demos/sbt-demo/scenario-10-circular/guide.qmd) |
| 11 | Dependency Locking | [MS11](../../demos/maven-demo/scenario-11-locking/guide.qmd) | [GS11](../../demos/gradle-demo/scenario-11-locking/guide.qmd) | [SB11](../../demos/sbt-demo/scenario-11-locking/guide.qmd) |
| 12 | Rich Version Metadata | [MS12](../../demos/maven-demo/scenario-12-metadata/guide.qmd) | [GS12](../../demos/gradle-demo/scenario-12-metadata/guide.qmd) | [SB12](../../demos/sbt-demo/scenario-12-metadata/guide.qmd) |
| 13 | Variants and Classifiers | [MS13](../../demos/maven-demo/scenario-13-variants/guide.qmd) | [GS13](../../demos/gradle-demo/scenario-13-variants/guide.qmd) | [SB13](../../demos/sbt-demo/scenario-13-variants/guide.qmd) |
| 14 | Rejecting a Version | [MS14](../../demos/maven-demo/scenario-14-reject/guide.qmd) | [GS14](../../demos/gradle-demo/scenario-14-reject/guide.qmd) | [SB14](../../demos/sbt-demo/scenario-14-reject/guide.qmd) |
| 15 | Substitution | [MS15](../../demos/maven-demo/scenario-15-substitution/guide.qmd) | [GS15](../../demos/gradle-demo/scenario-15-substitution/guide.qmd) | [SB15](../../demos/sbt-demo/scenario-15-substitution/guide.qmd) |
| 16 | Private Repository (BOM) | [MS16](../../demos/maven-demo/scenario-16-private-bom/guide.qmd) | [GS16](../../demos/gradle-demo/scenario-16-private-bom/guide.qmd) | [SB16](../../demos/sbt-demo/scenario-16-private-bom/guide.qmd) |
| 17 | Private Repository (Patch) | [MS17](../../demos/maven-demo/scenario-17-private-patch/guide.qmd) | [GS17](../../demos/gradle-demo/scenario-17-private-patch/guide.qmd) | [SB17](../../demos/sbt-demo/scenario-17-private-patch/guide.qmd) |
| 18 | Banning a Dependency | [MS18](../../demos/maven-demo/scenario-18-banning/guide.qmd) | [GS18](../../demos/gradle-demo/scenario-18-banning/guide.qmd) | [SB18](../../demos/sbt-demo/scenario-18-banning/guide.qmd) |

: JVM scenarios {tbl-colwidths="[5, 40, 18, 18, 19]"}

:::

::: {.content-visible when-format="pdf"}

|  #  | Scenario | Summary |
|:---:|:---|:---|
| 1  | Basic Transitive Resolution | Resolving a simple transitive dependency. |
| 2  | Version Conflict | The "diamond": two paths want different versions. Nearest wins (Maven) vs highest wins (Gradle, sbt). |
| 3  | Dependency Management (BOM / Platform) | Centralising versions with a Bill of Materials. |
| 4  | Hardcoded Version vs Managed Version | What happens when a direct declaration disagrees with the BOM. |
| 5  | Exclusions | Removing one transitive dependency from one path. |
| 6  | Forcing a Version | Pinning one version throughout the graph. |
| 7  | Scopes and Configurations | `compile`, `test`, `provided`, `runtime` and their Gradle and sbt equivalents. |
| 8  | Optional Dependencies | A library's optional dependency does not reach its consumers. |
| 9  | Version Ranges | Dynamic versions and what they cost in reproducibility. |
| 10 | Circular Dependencies | Cycles between artifacts, and why the tools stay silent. |
| 11 | Dependency Locking | Lock files for reproducible builds, built in or by plugin. |
| 12 | Rich Version Metadata | Rules and metadata that reshape resolution. |
| 13 | Variants and Classifiers | Consuming a different flavour of the same library. |
| 14 | Rejecting a Version | Keeping a specific version out of the graph. |
| 15 | Substitution | Swapping one module or version for another at resolution time. |
| 16 | Private Repository (BOM) | Overriding public versions through a private repository and a vendor BOM. |
| 17 | Private Repository (Patch) | Overriding public versions through a private repository and a direct patch. |
| 18 | Banning a Dependency | Keeping an artifact out of the entire build, from any path. |

: JVM scenarios {tbl-colwidths="[5, 30, 65]"}

:::

## Python scenarios

|  #  | Scenario | Summary |
|:---:|:---|:---|
| [P1](../../demos/python-demo/scenario-1-basic/guide.qmd)  | Basic Transitive Resolution | One install pulls the chain; seeing the tree with `pipdeptree`, `poetry show --tree`, `uv tree`. |
| [P2](../../demos/python-demo/scenario-2-conflict/guide.qmd)  | The Diamond: Conflicting Requirements | There is no winner: the install fails. |
| [P3](../../demos/python-demo/scenario-3-resolver/guide.qmd)  | Resolver Strategies and History | pip's greedy past, backtracking present, and uv's PubGrub. |
| [P4](../../demos/python-demo/scenario-4-specifiers/guide.qmd)  | Specifiers and Ranges | PEP 440 operators and the open-range culture. |
| [P5](../../demos/python-demo/scenario-5-locks/guide.qmd)  | Lock Files | `pip freeze`, pip-tools, `poetry.lock`, `uv.lock`, `pylock.toml`. |
| [P6](../../demos/python-demo/scenario-6-constraints/guide.qmd)  | Constraints Files | Central version control, BOM-style. |
| [P7](../../demos/python-demo/scenario-7-extras-groups/guide.qmd)  | Extras and Dependency Groups | Optional features and dev/test separation. |
| [P8](../../demos/python-demo/scenario-8-markers/guide.qmd)  | Environment Markers | Conditional dependencies by platform and interpreter. |
| [P9](../../demos/python-demo/scenario-9-exclusions-gap/guide.qmd)  | Exclusions: The Gap | pip and Poetry cannot remove a transitive; uv can. |
| [P10](../../demos/python-demo/scenario-10-venv/guide.qmd) | Virtual Environment Isolation | The environment is the resolution result. |
| [P11](../../demos/python-demo/scenario-11-private-index/guide.qmd) | Private Index and Dependency Confusion | `--extra-index-url` and the 2021 attack. |
| [P12](../../demos/python-demo/scenario-12-audit/guide.qmd) | Auditing the Environment | Finding vulnerable and abandoned packages. |

: Python scenarios {tbl-colwidths="[8, 32, 60]"}

## Node scenarios

|  #  | Scenario | Summary |
|:---:|:---|:---|
| [N1](../../demos/node-demo/scenario-1-basic/guide.qmd)  | Basic Transitive Resolution | One install pulls the chain; `npm ls`, `pnpm why`, `yarn why`. |
| [N2](../../demos/node-demo/scenario-2-diamond/guide.qmd)  | The Diamond: Everyone Wins | Both versions install; nobody is evicted or refused. |
| [N3](../../demos/node-demo/scenario-3-phantom/guide.qmd)  | Hoisting and Phantom Dependencies | Importing a package you never declared, and the tools that refuse. |
| [N4](../../demos/node-demo/scenario-4-semver/guide.qmd)  | Semver and the `^` Culture | Caret ranges by default, and release-age cooldowns. |
| [N5](../../demos/node-demo/scenario-5-locks/guide.qmd)  | Lock Files | Everyone locks by default; `npm ci`, `--frozen-lockfile`, `--immutable`. |
| [N6](../../demos/node-demo/scenario-6-overrides/guide.qmd)  | Overrides and Resolutions | Forcing one version tree-wide. |
| [N7](../../demos/node-demo/scenario-7-dep-types/guide.qmd)  | Dependency Types | dependencies, devDependencies, optionalDependencies. |
| [N8](../../demos/node-demo/scenario-8-peers/guide.qmd)  | Peer Dependencies: Where Flat Returns | The one place Node demands a single copy. |
| [N9](../../demos/node-demo/scenario-9-tree-shape/guide.qmd)  | Tree Shape and Deduplication | Why two clones of the same lockfile can differ on disk. |
| [N10](../../demos/node-demo/scenario-10-workspaces/guide.qmd) | Workspaces and Monorepos | Three tools, three flavours, and the `workspace:` protocol. |
| [N11](../../demos/node-demo/scenario-11-private-registry/guide.qmd) | Private Registry and Dependency Confusion | Scoped packages as the structural defence. |
| [N12](../../demos/node-demo/scenario-12-audit/guide.qmd) | Auditing the Tree | `npm audit`, its noise, and remediation through overrides. |

: Node scenarios {tbl-colwidths="[8, 32, 60]"}

## How each scenario is built

Every scenario follows the same shape, so once you have read one you can skim the rest. The sections appear as labelled boxes:

- **Scenario.** The situation in one or two sentences, and a *Tool Versions* note naming the version the demo was verified against and the nearest version where behaviour changes.
- **Example.** A diagram of the dependency graph and the build-file snippet that produces it. The snippet is included from the real demo project, so what you read is what was run.
- **Expect.** What most developers assume will happen.
- **Actual.** What the tool does. When Expect and Actual agree the section is omitted.
- **Why.** The mechanical rule behind the result.
- **Fix.** The change that resolves the problem, with alternatives where they exist.
- **Risk.** What can go wrong with the fix, graded LOW, MEDIUM, HIGH.
- **Control.** How to keep the problem from recurring (JVM scenarios).
- **Check.** A fast command, what to look for in its output, and the conclusion to draw.
- **Scales.** How the behaviour plays out across many modules, teams or services (JVM scenarios).
- **Takeaway.** The one sentence to remember.
- **Related.** The same scenario in the other tools and ecosystems, and the scenarios that usually come next.
- **Wild.** A real incident or pattern from production where this mechanism mattered.

Each demo lives in the repository under `demos/<tool>-demo/scenario-N-*/`, with a `README.md` that says how to run it by hand and a `verify.sh` per track that proves every claim by execution.
