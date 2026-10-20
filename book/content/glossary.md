# Glossary of Terms {.unnumbered}

Key dependency management terms used in this book, grouped by where they apply.

## Across ecosystems

| Term | Definition |
|:--|:--|
| Dependency Graph | The directed (usually acyclic) graph of all dependencies, direct and transitive. Each node is an artifact or package; each edge is a declaration. |
| Direct Dependency | A dependency you declare yourself in the build or project file. |
| Transitive Dependency | A dependency you did not declare, required by one of your direct dependencies (or by their dependencies, recursively). |
| Diamond Dependency | Two paths in the graph require the same library at different versions. The JVM tools pick one, Python fails, Node installs both. The most common source of version surprises. |
| Resolution | The process of turning declarations into a concrete set of versions. Mechanical, rule-driven, and unaware of binary compatibility. |
| Lock File | A record of the exact versions (and often hashes and placement) resolution produced, committed so that future installs reproduce it. `gradle.lockfile`, `build.sbt.lock`, `poetry.lock`, `uv.lock`, `pylock.toml`, `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`. |
| Version Range | A declaration that accepts any version within an interval: `[1.0,2.0)`, `1.+`, `>=1.4,<2`, `^1.4.0`. Convenient; non-deterministic without a lock. |
| Semantic Versioning (semver) | The `MAJOR.MINOR.PATCH` convention: patch for fixes, minor for compatible additions, major for breaking changes. A social contract that tools assume and libraries sometimes break. |
| Dependency Confusion | An attack in which a public package with the same name as a private one is published at a higher version, and a tool that merges public and private sources installs the attacker's copy. Documented against npm, PyPI and others in 2021. |
| Audit | Checking the resolved set against vulnerability databases (`npm audit`, `pip-audit`, `uv audit`) and for abandoned or end-of-life packages. |
| Phantom Dependency | A package your code imports but never declares, available only because of how the tree happened to be laid out. Breaks when the layout changes. |

## JVM (Maven, Gradle, sbt)

| Term | Definition |
|:--|:--|
| BOM (Bill of Materials) | A POM that defines a set of dependency versions without declaring the dependencies themselves. Imported to centralise versions across projects. Maven: `<scope>import</scope>`; Gradle: `platform()`; sbt 2: native; sbt 1: emulated. |
| Dependency Management | Maven's mechanism for pre-defining the version to use when a dependency is encountered transitively. Applies to transitives; a direct declaration's own version still wins. |
| Platform | Gradle's name for an imported BOM. A plain `platform()` adds constraints that join ordinary conflict resolution; `enforcedPlatform()` makes the BOM's versions win. |
| Version Catalog | Gradle's `libs.versions.toml`: a single file of named coordinates and versions shared across modules. |
| Nearest Wins | Maven's conflict resolution strategy. The version closest to the root (fewest edges away) is selected; at equal depth the first declared wins. |
| Highest Wins | Gradle's and sbt's default strategy. The highest version number requested anywhere in the graph is selected, assuming backward-compatible semver. |
| Eviction | sbt's term for the version that lost a conflict. `sbt evicted` lists them; since sbt 1.5 an eviction that is incompatible under the declared `versionScheme` can be made an error. |
| Coursier | The dependency resolver sbt has used by default since 1.3 (replacing Ivy). Ivy-only settings such as `conflictManager` are ignored under it. sbt 2 removes the Ivy option entirely. |
| Scope / Configuration | A label that controls when a dependency is visible (compile, test, runtime, provided) and whether consumers inherit it. Maven calls these scopes; Gradle and sbt call them configurations. |
| Optional Dependency | A dependency a library declares for an optional feature. Consumers of the library do not receive it transitively and must declare it themselves to use the feature. |
| Classifier | A suffix (`jdk11`, `sources`, `tests`) that selects an alternative artifact published under the same coordinates. |
| Feature Variant | A Gradle concept in which a library publishes optional features as separate variants with their own dependencies. Consumers opt in by requiring a capability. |
| Capability | A Gradle attribute that names what a module provides, so two modules providing the same capability (for example `javax.servlet-api` and `jakarta.servlet-api`) are detected as a conflict instead of both landing on the classpath. |
| Strict Constraint | A Gradle rich version using `strictly`: forces a specific version even if it means downgrading, and fails if another strict constraint disagrees. The strongest version signal in Gradle. |
| Dependency Overrides | sbt's `dependencyOverrides`: forces a version for direct and transitive declarations alike (under Coursier). |
| Exclusion | Removing a transitive dependency from one path (`<exclusions>`, `exclude`, `exclude(...)`). Other paths can still bring it in; banning covers every path. |
| Dependency Locking | Recording the exact resolved versions into a lock file so later builds resolve identically even with dynamic versions. Built into Gradle; plugins for Maven and sbt. |
| Classpath | The flat, ordered list of jars the JVM loads from. Resolution produces a graph; the runtime only sees this list, and order decides which of two duplicate classes wins. |

## Python (pip, Poetry, uv)

| Term | Definition |
|:--|:--|
| Virtual Environment | An isolated interpreter plus `site-packages`. The environment *is* the resolution result: one version of each package, nothing shared with the system interpreter. |
| Specifier | A PEP 440 version expression: `==1.2`, `>=1.4,<2`, `~=1.4` (compatible release), `!=1.5` (rejection). |
| Constraints File | A requirements-style file applied with `pip install -c` that pins versions without adding dependencies. Python's closest thing to a BOM. |
| Extras | Optional feature sets a package publishes: `requests[socks]`. Installing the extra adds the feature's dependencies. |
| Dependency Group | A named set of development-time dependencies (test, docs, lint) that is not part of the package's own requirements. PEP 735 `[dependency-groups]` is the standard table; Poetry also has its own syntax. |
| Environment Marker | A PEP 508 condition on a requirement (`; python_version < "3.11"`, `; sys_platform == "win32"`) evaluated at install time, so the same file resolves differently on different machines. |
| Backtracking Resolver | pip's resolver since 20.3: it searches for a version set that satisfies every requirement and fails with `ResolutionImpossible` if none exists. The earlier greedy resolver silently installed conflicting versions. |
| PubGrub | The resolution algorithm uv (and Dart's pub) use; produces the same "satisfy everything or fail" outcome with clearer error explanations. |
| Index | A package source (PyPI, or a private server). `--index-url` replaces PyPI; `--extra-index-url` merges another index into it, which is the dependency-confusion hazard. |
| pylock.toml | The PEP 751 cross-tool lock file format (2025). Produced by `pip lock`, `uv export`, and Poetry's export plugin; not yet any tool's native format. |

## Node (npm, pnpm, Yarn)

| Term | Definition |
|:--|:--|
| Nested Resolution | Node's model: each package can carry its own `node_modules`, so several versions of one package coexist and `require` finds the nearest copy walking up the directory tree. |
| Hoisting | Lifting a dependency to the top-level `node_modules` so it is shared instead of nested (npm 3+). Reduces duplication; creates phantom dependencies. |
| Deduplication | Converging the tree so one copy satisfies several consumers. `npm dedupe` attempts it but is not a reliable re-hoist; deleting `node_modules` and the lock and reinstalling is. |
| Peer Dependency | A declaration that the *host* project must provide one shared copy of a package (plugins, React). The one place Node refuses duplication; npm 7+ fails the install (`ERESOLVE`) when peers cannot agree. |
| Overrides / Resolutions | npm `overrides`, pnpm `overrides`, Yarn `resolutions`: force one version tree-wide or on one path, regardless of what dependents declare. |
| Caret Range | `^1.2.3`: any version with the same leading non-zero component. The default npm writes, so most trees are open ranges until locked. |
| Plug'n'Play (PnP) | Yarn's install mode with no `node_modules`: a generated map tells Node where every package lives, and an undeclared import fails immediately. |
| Content-Addressed Store | pnpm's global cache of package files, linked into each project. Every copy of a version on disk is one set of files; the tree is a pure function of the lockfile. |
| Workspace | A monorepo of several packages managed by one install (`workspaces` in npm and Yarn, `pnpm-workspace.yaml`). The `workspace:` protocol links to a local package instead of the registry. |
| Scope | The `@org/` prefix on a package name. A scope can be routed to one registry in `.npmrc`, which is the structural defence against dependency confusion. |
| Release-Age Cooldown | A tool setting that refuses versions published less than N days ago (`minimumReleaseAge`, `npmMinimalAgeGate`, `min-release-age`), buying time for malicious releases to be noticed and pulled. On by default in pnpm 11 and Yarn 4.15+. |
| Corepack | The shim that fetches the package manager pinned in `package.json`'s `packageManager` field. Bundled with Node 14.19 through 24; installed separately from Node 25. |
