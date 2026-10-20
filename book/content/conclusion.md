# Conclusion {.unnumbered}

Dependency management is not a solved problem. It is a continuous trade-off between stability, security, and velocity.

## What the scenarios teach us

Across 42 scenarios, nine tools and three ecosystems, a handful of recurring themes emerge. These are the ideas worth keeping in your head long after the specific syntax has faded.

1. **Resolution is mechanical, not semantic.** Build tools do not understand your code, your intent, or whether two library versions are compatible. They follow structural rules: depth, version numbers, declaration order, constraint strength, directory position. Every surprise in this book traces back to a mismatch between what developers expect (semantic reasoning) and what the tool does (mechanical processing).

2. **There are three answers to the diamond, and each buys a different hell.** The JVM tools pick a winner: Maven by proximity (nearest wins), Gradle and sbt by version number (highest wins), and the loser is evicted whether or not anything still needs it. Python refuses to pick: one environment holds one version of each package, so a graph that cannot agree fails to install at all. Node lets everyone win: each consumer gets the version it asked for, nested in its own `node_modules`, and the cost moves to tree size, phantom imports and the singletons that must not be duplicated. None of these is the correct strategy; each is a different trade-off between stability, freshness, and developer control, and the scenarios are much easier to reason about once you know which answer your ecosystem gave.

3. **Within the JVM, the tools optimise for different things.** Maven optimises for structural proximity, which gives developers direct control but can silently downgrade transitive dependencies. Gradle optimises for freshness, which reduces compatibility gaps but can silently upgrade you to untested versions. sbt follows Gradle's rule under Coursier and adds eviction reporting and a blunt override mechanism.

4. **Today's fix is tomorrow's mystery.** Exclusions, overrides, forced versions, constraints files, resolutions blocks and dependency management entries all solve immediate problems. They also create invisible constraints that future developers (including your future self) must understand to modify safely. Every intervention in the dependency graph deserves a comment explaining why it exists.

5. **Centralised version management is not optional at scale.** Whether you use Maven's dependencyManagement with BOMs, Gradle's platforms and version catalogs, sbt's dependencyOverrides collected into a shared plugin, a pip constraints file, or npm overrides at the workspace root, centralising version decisions is the single most effective way to prevent dependency drift across modules, services, and teams.

6. **Reproducibility is a decision, and the ecosystems made it differently.** Without a lock, any build that uses dynamic versions, ranges, or a live repository is non-deterministic: the same source can produce different binaries on different days. Node made locking the default a decade ago; Python's tools (Poetry, uv) lock by default while pip still needs a separate step; on the JVM only Gradle has locking built in, and Maven and sbt need plugins. Whatever your ecosystem, lock files belong in version control and CI should install from the lock, not around it.

7. **The graph is the system.** Dependency management is not a build concern that can be delegated to a tool and forgotten. The dependency graph is a first-class architectural artifact. It determines what runs in production, what security vulnerabilities you're exposed to, and how fast your builds execute. Treating it with the same attention you give to your source code is not excessive, it is proportionate.

We hope this field guide has given you the mental models to understand why your build tool behaves the way it does. Whether you are fighting a diamond in Maven, debugging a strict constraint in Gradle, wrestling with evictions in sbt, staring at `ResolutionImpossible` from pip, or wondering why `instanceof` just failed between two copies of the same npm package, the underlying principles are the same.

Remember:

*   **Trust but verify.** Don't assume a dependency is doing what you expect. Look at the tree: `mvn dependency:tree`, `gradle dependencies`, `sbt dependencyTree`, `pipdeptree`, `poetry show --tree`, `uv tree`, `npm ls`, `pnpm why`, `yarn why`.
*   **Be explicit.** When in doubt, explicit versions and constraints are better than implicit defaults.
*   **Keep it clean.** Regularly prune unused dependencies and update old ones. A smaller graph is a safer graph.

Good luck, and may your builds be ever green.
