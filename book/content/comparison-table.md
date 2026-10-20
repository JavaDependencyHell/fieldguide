# Cross-Tool Comparison Table {.unnumbered}

## JVM (Maven / Gradle / sbt)

| Feature | Maven | Gradle | sbt |
| :--- | :--- | :--- | :--- |
| **Default Conflict Resolution** | Nearest definition wins (declaration order breaks ties) | Highest version wins | Highest version wins (Coursier, sbt 1.3+; Ivy "latest revision" before that) |
| **Transitive Dependencies** | Yes (compile/runtime scopes) | Yes (implementation/api/runtimeOnly) | Yes (Compile/Test/Runtime configurations) |
| **Excluding a Dependency (one path)** | `<exclusions>` in `<dependency>` | `exclude group: ..., module: ...` on the dependency | `exclude("group", "artifact")` on the dependency |
| **Banning a Dependency (every path)** | No silent prune: Enforcer `bannedDependencies` fails the build | `configurations.all { exclude ... }` (silent) | `excludeDependencies += ExclusionRule(...)` (silent) |
| **Forcing a Version** | `<dependencyManagement>` (applies to transitives; direct declarations still win) | `strictly` constraint, `enforcedPlatform`, or `resolutionStrategy.force` | `dependencyOverrides` (forces direct and transitive under Coursier) |
| **BOM Support** | Native (`<scope>import</scope>` in `<dependencyManagement>`) | `platform(...)` (joins conflict resolution) or `enforcedPlatform(...)` (wins) | sbt 1.x: none native; emulate with `dependencyOverrides` or the `here-sbt-bom` plugin. sbt 2.0+: native (`.pomOnly()` BOM dependencies) |
| **Optional Dependencies** | `<optional>true</optional>`; consumers never receive it | Honours POM `optional`; producers use feature variants (`registerFeature`, 5.3+) | Honours POM `optional`; producers mark `% Optional` |
| **Version Ranges** | Supported (`[1.0,2.0)`); a hard range overrides soft versions elsewhere | Supported (`1.+`, `[1.0, 2.0)`, `latest.release`) | Supported (Ivy syntax `1.+`, `[1.0,2.0)`) |
| **Rejecting a Version** | Enforcer `bannedDependencies` with a version pattern | Rich version `reject '2.0.0'` (5.0+) | No reject; nearest is `evictionErrorLevel := Level.Error` with `versionScheme` / `libraryDependencySchemes` (1.5+) |
| **Substitution** | Exclusion plus a direct declaration of the replacement | `resolutionStrategy.dependencySubstitution { substitute ... using ... }` (6.6+) | Exclusion plus a direct declaration; no substitution rule |
| **Dependency Locking** | No native support (`maven-lockfile`, `dependency-lock-maven-plugin`) | Native (`dependencyLocking`, 4.8+; single `gradle.lockfile` 7.0+) | No native support (`sbt-dependency-lock` plugin) |
| **Rich Metadata / Rules** | No (POM is static); enforcer rules check the result | Gradle Module Metadata; component metadata rules rewrite a module's declared dependencies | No (relies on POM/Ivy) |
| **Variant Selection** | Classifiers (`jdk11`, `sources`, `javadoc`) | Attributes, capabilities and variants; classifiers still work | Classifiers / configurations |
| **Private / Patched Artifacts** | Private repository first in `<repositories>`; vendor BOM import or direct version | Private `maven { url }` first; `platform()` the vendor BOM or declare the patched version | Private resolver first; `dependencyOverrides` to the patched version |
| **Circular Dependencies** | Between *projects* (reactor): build fails. Between *artifacts*: the cycle is broken silently, no warning | Between *projects*: build fails. Between *artifacts*: broken silently, no warning | Between *projects*: build fails. Between *artifacts*: broken silently, no warning |

## Python (pip / Poetry / uv)

Python resolves into a single environment that holds **one version of each package**, no eviction, no classpath, no coexistence, so several rows above behave fundamentally differently. This table stands on its own rather than as a fourth JVM column.

| Feature | pip | Poetry | uv |
| :--- | :--- | :--- | :--- |
| **Conflict Resolution** | Backtracking (default since 20.3); unsatisfiable graph *fails* | Backtracking; fails on conflict | PubGrub; fails on conflict |
| **Version Conflict Outcome** | Hard error, no version can be evicted | Hard error | Hard error |
| **Excluding a Transitive** | Not possible | Not possible | `exclude-dependencies` (0.9.8+), tree-wide or scoped to one package's edge |
| **Forcing / Overriding a Version** | Constraints file (`-c`) | Pin in `pyproject.toml` | `override-dependencies` / `constraint-dependencies` |
| **Central Version Control (BOM-like)** | Constraints file | `pyproject.toml` | `constraint-dependencies` |
| **Version Ranges** | PEP 440 (`>=`, `~=`, `!=`); open ranges are the *default culture* | PEP 440 | PEP 440 |
| **Native Version Rejection** | `!=` operator (no plugin needed) | `!=` | `!=` |
| **Lock File** | None native (`pip freeze` snapshot; `pip-tools` compile; `pip lock` → pylock.toml, 25.1+ experimental) | `poetry.lock` (native); pylock export via plugin (2.3+) | `uv.lock` (native) + `uv export --format pylock.toml` |
| **Optional Dependencies** | Extras (`pkg[extra]`); `--group` installs PEP 735 groups (25.1+) | Extras + groups (own syntax 1.2+, PEP 735 table 2.2+) | Extras + `[dependency-groups]` |
| **Conditional Dependencies** | Environment markers (PEP 508) | Markers | Markers |
| **Environment Isolation** | Manual `venv` | Managed `.venv` | Managed `.venv` |
| **Dependency Confusion Guard** | Unsafe: `--extra-index-url` merges, highest version wins | Source priority | `index-strategy = first-index` (default) |
| **Built-in Audit** | None (`pip-audit`, separate PyPA tool) | None (use `pip-audit` on the export) | `uv audit` (preview, OSV-backed) |

## Node (npm / pnpm / Yarn 4)

Node resolves into a **tree** that can hold *multiple versions of the same package*: the JVM picks a winner, Python demands agreement, Node duplicates. Conflicts mostly dissolve; the costs move to tree size, phantom imports, and singletons (peers). This table stands on its own for the same reason Python's does.

| Feature | npm | pnpm | Yarn 4 |
| :--- | :--- | :--- | :--- |
| **Conflict Resolution** | Duplicate and nest: both versions install | Duplicate (content-addressed store) | Duplicate (PnP map or node_modules) |
| **Version Conflict Outcome** | No conflict, per-consumer copies | Same | Same |
| **Where Conflict Returns** | Peer dependencies: hard `ERESOLVE` failure (npm 7+) | Peers: installs + warning (`strictPeerDependencies` to fail) | Peers: installs + `YN0060` warning |
| **Layout / Hoisting** | Hoisted, history-dependent (phantoms possible) | Strict symlinks: no hoisting, no phantoms | PnP (default): no node_modules, phantoms impossible; `nodeLinker: node-modules` hoists like npm |
| **Forcing / Overriding a Version** | `overrides` (npm 8.3+), nested object form for one path | `overrides` in `pnpm-workspace.yaml` (11+), `"parent>child"` for one path | `resolutions`, `"parent/child"` for one path |
| **Version Ranges** | Semver; `^` written by default | Same | Same |
| **Lock File** | `package-lock.json` by default (npm 5+); `npm ci` obeys it; records tree *placement*, not only versions | `pnpm-lock.yaml`; `--frozen-lockfile` | `yarn.lock`; `--immutable` (CI default) |
| **Dev / Prod Separation** | `devDependencies` + `--omit=dev` | `--prod` | `yarn workspaces focus --production` |
| **Workspaces** | Native (npm 7+), by-name matching | `pnpm-workspace.yaml` + `workspace:` protocol | Native + `workspace:` protocol |
| **Dependency Confusion Guard** | Scopes: `@org:registry=` routing (one registry per name, no version merge) | Same `.npmrc` scope routing | `npmScopes` (age gate is per scope) |
| **Release-Age Cooldown** | `min-release-age` (11.10+, off by default); `--before=<date>` since npm 6 | `minimumReleaseAge` (10.16+; on by default from 11.0) | `npmMinimalAgeGate` (4.10+; on by default from 4.15; per-scope from 4.17) |
| **Built-in Audit** | `npm audit` (npm 6+) | `pnpm audit` | `yarn npm audit` |
