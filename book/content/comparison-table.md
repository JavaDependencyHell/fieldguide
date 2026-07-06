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
| **Conflict Resolution** | Backtracking (21.0+); unsatisfiable graph *fails* | Backtracking; fails on conflict | PubGrub; fails on conflict |
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
