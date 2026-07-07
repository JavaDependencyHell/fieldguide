# Cross-Tool Comparison Table {.unnumbered}

| Feature | Maven | Gradle | SBT |
| :--- | :--- | :--- | :--- |
| **Default Conflict Resolution** | Nearest Definition Wins | Newest Version Wins | Highest Version Wins (Coursier, sbt 1.3+; Ivy "latest revision" before that) |
| **Transitive Dependencies** | Yes (compile/runtime scopes) | Yes (implementation/api/runtimeOnly) | Yes (compile/test/runtime) |
| **Excluding Dependencies** | `<exclusions>` in `<dependency>` | `exclude group: ..., module: ...` | `exclude("group", "artifact")` |
| **Banning a Dependency (everywhere)** | No silent prune — Enforcer `bannedDependencies` fails the build | `configurations.all { exclude ... }` (silent) | `excludeDependencies += ExclusionRule(...)` (silent) |
| **Forcing a Version** | `<dependencyManagement>` (closest definition) | `strictly` constraint or `resolutionStrategy.force` | `dependencyOverrides` |
| **BOM Support** | Native (`<scope>import</scope>` in `<dependencyManagement>`) | `platform(...)` or `enforcedPlatform(...)` | via plugins (e.g. `sbt-bom`) |
| **Version Ranges** | Supported (e.g. `[1.0,2.0)`) | Supported (e.g. `1.+`, `[1.0, 2.0)`) | Supported (Ivy syntax) |
| **Dependency Locking** | No native support (plugins exist) | Native (`dependencyLocking`) | No native support (plugins, e.g. `sbt-dependency-lock`) |
| **Rich Metadata** | No (POM is static) | Yes (Gradle Module Metadata) | No (relies on POM/Ivy) |
| **Variant Selection** | Classifiers (sources, javadoc) | Attributes (variants, capabilities) | Classifiers / Configurations |
| **Circular Dependencies** | Allowed (warns) | Allowed (warns) | Allowed (warns) |

## Python (pip / Poetry / uv)

Python resolves into a single environment that holds **one version of each package** — no eviction, no classpath, no coexistence — so several rows above behave fundamentally differently. This table stands on its own rather than as a fourth JVM column.

| Feature | pip | Poetry | uv |
| :--- | :--- | :--- | :--- |
| **Conflict Resolution** | Backtracking (default since 20.3); unsatisfiable graph *fails* | Backtracking; fails on conflict | PubGrub; fails on conflict |
| **Version Conflict Outcome** | Hard error — no version can be evicted | Hard error | Hard error |
| **Excluding a Transitive** | Not possible | Not possible | Not possible (only `override-dependencies`, which *replaces* a version) |
| **Forcing / Overriding a Version** | Constraints file (`-c`) | Pin in `pyproject.toml` | `override-dependencies` / `constraint-dependencies` |
| **Central Version Control (BOM-like)** | Constraints file | `pyproject.toml` | `constraint-dependencies` |
| **Version Ranges** | PEP 440 (`>=`, `~=`, `!=`); open ranges are the *default culture* | PEP 440 | PEP 440 |
| **Native Version Rejection** | `!=` operator (no plugin needed) | `!=` | `!=` |
| **Lock File** | None native (`pip freeze` snapshot; `pip-tools` compile; `pip lock`→pylock.toml, 25.1+ exp.) | `poetry.lock` (native) | `uv.lock` (native) + PEP 751 export |
| **Optional Dependencies** | Extras (`pkg[extra]`) | Extras + groups | Extras + `[dependency-groups]` |
| **Conditional Dependencies** | Environment markers (PEP 508) | Markers | Markers |
| **Environment Isolation** | Manual `venv` | Managed `.venv` | Managed `.venv` |
| **Dependency Confusion Guard** | Unsafe: `--extra-index-url` merges, highest version wins | Source priority | `index-strategy = first-index` (default) |

## Node (npm / pnpm / Yarn 4)

Node resolves into a **tree** that can hold *multiple versions of the same package* — the JVM picks a winner, Python demands agreement, Node duplicates. Conflicts mostly dissolve; the costs move to tree size, phantom imports, and singletons (peers). This table stands on its own for the same reason Python's does.

| Feature | npm | pnpm | Yarn 4 |
| :--- | :--- | :--- | :--- |
| **Conflict Resolution** | Duplicate & nest — both versions install | Duplicate (content-addressed store) | Duplicate (PnP map or node_modules) |
| **Version Conflict Outcome** | No conflict — per-consumer copies | Same | Same |
| **Where Conflict Returns** | Peer dependencies: hard `ERESOLVE` failure (npm 7+) | Peers: installs + warning (`strictPeerDependencies` to fail) | Peers: installs + `YN0060` warning |
| **Layout / Hoisting** | Hoisted, history-dependent (phantoms possible) | Strict symlinks — no hoisting, no phantoms | PnP (default): no node_modules, phantoms impossible; `nodeLinker: node-modules` hoists like npm |
| **Forcing / Overriding a Version** | `overrides` (npm 8.3+) | `overrides` in `pnpm-workspace.yaml` (11+) | `resolutions` |
| **Version Ranges** | Semver; `^` written by default | Same | Same |
| **Lock File** | `package-lock.json` by default (npm 5+); `npm ci` obeys it | `pnpm-lock.yaml`; `--frozen-lockfile` | `yarn.lock`; `--immutable` (CI default) |
| **Dev / Prod Separation** | `devDependencies` + `--omit=dev` | `--prod` | `yarn workspaces focus --production` |
| **Workspaces** | Native (npm 7+), by-name matching | `pnpm-workspace.yaml` + `workspace:` protocol | Native + `workspace:` protocol |
| **Dependency Confusion Guard** | Scopes: `@org:registry=` routing (one registry per name — no version merge) | Same `.npmrc` scope routing | `npmScopes` (age-gate is per-scope) |
| **Release-Age Cooldown** | — | `minimumReleaseAge` (default on, 11+) | `npmMinimalAgeGate` (default on, 4.17) |
| **Built-in Audit** | `npm audit` (npm 6+) | `pnpm audit` | `yarn npm audit` |
