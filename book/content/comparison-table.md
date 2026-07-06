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
