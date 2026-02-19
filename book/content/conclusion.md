# Conclusion {.unnumbered}

Dependency management is not a solved problem. It is a continuous trade-off between stability, security, and velocity.

#### What the Scenarios Teach Us

Across 17 scenarios and three build tools, a handful of recurring themes emerge. These are the ideas worth keeping in your head long after the specific syntax has faded.

1. Resolution is mechanical, not semantic. Build tools do not understand your code, your intent, or whether two library versions are compatible. They follow structural rules: depth, version numbers, declaration order, constraint strength. Every surprise in this book traces back to a mismatch between what developers expect (semantic reasoning) and what the tool does (mechanical processing).

2. The three tools optimise for different things. Maven optimises for structural proximity (nearest wins), which gives developers direct control but can silently downgrade transitive dependencies. Gradle optimises for freshness (newest wins), which reduces compatibility gaps but can silently upgrade you to untested versions. SBT follows Gradle’s approach but adds eviction warnings and a strong override mechanism. None of these strategies is universally correct; each makes a different trade-off between stability, freshness, and developer control.

3. Today’s fix is tomorrow’s mystery. Exclusions, overrides, forced versions, and dependency management entries all solve immediate problems. They also create invisible constraints that future developers (including your future self) must understand to modify safely. Every intervention in the dependency graph deserves a comment explaining why it exists.

4. Centralised version management is not optional at scale. Whether you use Maven’s dependencyManagement with BOMs, Gradle’s platforms and version catalogs, or SBT’s dependencyOverrides collected into a shared plugin, centralising version decisions is the single most effective way to prevent dependency drift across modules, services, and teams.

5. Reproducibility requires active effort. Without dependency locking, any build that uses dynamic versions, version ranges, or resolves from a live repository is non-deterministic. The same source code can produce different binaries on different days. Gradle and SBT have built-in locking; Maven requires plugins or discipline. In all cases, lock files belong in version control.

6. The graph is the system. Dependency management is not a build concern that can be delegated to a tool and forgotten. The dependency graph is a first-class architectural artifact. It determines what runs in production, what security vulnerabilities you’re exposed to, and how fast your builds execute. Treating it with the same attention you give to your source code is not excessive — it’s proportionate.

7. We hope this field guide has given you the mental models to understand why your build tool behaves the way it does. Whether you are fighting a diamond dependency in Maven, debugging a strict constraint in Gradle, or wrestling with eviction warnings in SBT, the underlying principles are often the same.

Remember:
*   **Trust but Verify:** Don't assume a dependency is doing what you expect. Use the tools (`dependency:tree`, `dependencies`, `dependencyTree`) to see the reality.
*   **Be Explicit:** When in doubt, explicit versions and constraints are better than implicit defaults.
*   **Keep It Clean:** Regularly prune unused dependencies and update old ones. A smaller graph is a safer graph.

Good luck, and may your builds be ever green.
