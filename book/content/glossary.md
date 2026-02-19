# Glossary of Terms {.unnumbered}

Key dependency management terms used

| Term                      | Definition                                                                                                                                                                         |
|:--------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| BOM (Bill of Materials)   | A POM (or equivalent) that defines a set of dependency versions without declaring actual dependencies. Imported to centralise version management across projects.                  |
| Dependency Graph          | The directed acyclic graph (usually) of all dependencies, both direct and transitive. Each node is an artifact; each edge is a dependency declaration.                             |
| Dependency Management     | A mechanism for pre-defining versions that will be used when a dependency is encountered, regardless of what version the transitive graph would otherwise resolve.                 |
| Diamond Dependency        | When two direct dependencies each transitively require the same library but at different versions. The build tool must pick one. The most common source of version conflicts.      |
| Eviction                  | When a build tool replaces one version of a library with another during resolution. SBT/Ivy explicitly warn about evictions; Maven and Gradle do so silently.                      |
| Nearest Wins              | Maven’s conflict resolution strategy. When the same artifact appears at multiple depths in the graph, the version closest to the root (fewest edges away) is selected.             |
| Newest Wins / Latest Wins | Gradle and SBT’s default strategy. When conflicting versions exist, the highest version number is selected, assuming backward-compatible semver.                                   |
| Scope / Configuration     | A label that controls when a dependency is visible (compile, test, runtime) and whether it is transitive to consumers. Maven calls these scopes; Gradle calls them configurations. |
| Transitive Dependency     | A dependency you did not directly declare, but which is required by one of your direct dependencies (or by their dependencies, recursively).                                       |
| Version Range             | A dependency declaration that accepts any version within a defined interval, e.g. [1.0,2.0). Convenient but makes builds non-deterministic without locking.                        |
| Dependency Locking        | "Recording the exact resolved versions into a lock file so that future builds resolve identically, even when dynamic versions or ranges are used.                                  |
| Feature Variant           | A Gradle concept where a library publishes multiple variants (e.g. with different optional capabilities). Consumers select which variant they want via attributes.                 |
| Strict Constraint         | A Gradle constraint (using strictly) that forces a specific version, even if it means downgrading. The strongest version override in Gradle.                                       |
| DependencyOverrides       | SBT’s mechanism for forcing a specific version of any dependency in the graph. Overrides all other resolution, including direct declarations.                                      |                              
