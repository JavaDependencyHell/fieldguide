# Rapid Dependency Failure Triage

Scan the symptoms below, find the one closest to yours, and jump to the scenario for your tool. JVM links give Maven, Gradle and sbt in that order.

## JVM (Maven, Gradle, sbt)

*   **Compilation failure** (`cannot find symbol`, `package does not exist`):
    *   Verify the dependency is declared and resolves. [MS1](../../demos/maven-demo/scenario-1-basic/guide.qmd) / [GS1](../../demos/gradle-demo/scenario-1-basic/guide.qmd) / [SB1](../../demos/sbt-demo/scenario-1-basic/guide.qmd)
    *   Check for over-aggressive exclusions. [MS5](../../demos/maven-demo/scenario-5-exclusions/guide.qmd) / [GS5](../../demos/gradle-demo/scenario-5-exclusions/guide.qmd) / [SB5](../../demos/sbt-demo/scenario-5-exclusions/guide.qmd)
    *   Verify scope or configuration (`test` vs `runtimeOnly`, `compileOnly` vs `implementation`). [MS7](../../demos/maven-demo/scenario-7-scopes/guide.qmd) / [GS7](../../demos/gradle-demo/scenario-7-scopes/guide.qmd) / [SB7](../../demos/sbt-demo/scenario-7-scopes/guide.qmd)

*   **Runtime failure** (`NoClassDefFoundError`, `NoSuchMethodError`, `ClassNotFoundException`):
    *   A version conflict selected an incompatible binary. [MS2](../../demos/maven-demo/scenario-2-conflict/guide.qmd) / [GS2](../../demos/gradle-demo/scenario-2-conflict/guide.qmd) / [SB2](../../demos/sbt-demo/scenario-2-conflict/guide.qmd)
    *   An excluded transitive is required at runtime. [MS5](../../demos/maven-demo/scenario-5-exclusions/guide.qmd) / [GS5](../../demos/gradle-demo/scenario-5-exclusions/guide.qmd) / [SB5](../../demos/sbt-demo/scenario-5-exclusions/guide.qmd)
    *   A `provided` / `compileOnly` dependency is missing from the environment. [MS7](../../demos/maven-demo/scenario-7-scopes/guide.qmd) / [GS7](../../demos/gradle-demo/scenario-7-scopes/guide.qmd) / [SB7](../../demos/sbt-demo/scenario-7-scopes/guide.qmd)
    *   A library's optional dependency never reached you. [MS8](../../demos/maven-demo/scenario-8-optional/guide.qmd) / [GS8](../../demos/gradle-demo/scenario-8-optional/guide.qmd) / [SB8](../../demos/sbt-demo/scenario-8-optional/guide.qmd)

*   **Unexpected version resolved**:
    *   Maven "nearest wins" vs Gradle and sbt "highest wins". [MS2](../../demos/maven-demo/scenario-2-conflict/guide.qmd) / [GS2](../../demos/gradle-demo/scenario-2-conflict/guide.qmd) / [SB2](../../demos/sbt-demo/scenario-2-conflict/guide.qmd)
    *   A direct declaration overrode the BOM or platform, or failed to. [MS4](../../demos/maven-demo/scenario-4-override/guide.qmd) / [GS4](../../demos/gradle-demo/scenario-4-override/guide.qmd) / [SB4](../../demos/sbt-demo/scenario-4-override/guide.qmd)
    *   A forced or managed version is in play. [MS6](../../demos/maven-demo/scenario-6-forcing/guide.qmd) / [GS6](../../demos/gradle-demo/scenario-6-forcing/guide.qmd) / [SB6](../../demos/sbt-demo/scenario-6-forcing/guide.qmd)
    *   A dynamic range resolved to something new. [MS9](../../demos/maven-demo/scenario-9-ranges/guide.qmd) / [GS9](../../demos/gradle-demo/scenario-9-ranges/guide.qmd) / [SB9](../../demos/sbt-demo/scenario-9-ranges/guide.qmd)
    *   The lockfile is stale or missing. [MS11](../../demos/maven-demo/scenario-11-locking/guide.qmd) / [GS11](../../demos/gradle-demo/scenario-11-locking/guide.qmd) / [SB11](../../demos/sbt-demo/scenario-11-locking/guide.qmd)

*   **Duplicate classes or `LinkageError`**:
    *   Two artifacts ship the same packages after a rename or relocation. [MS2](../../demos/maven-demo/scenario-2-conflict/guide.qmd) / [GS2](../../demos/gradle-demo/scenario-2-conflict/guide.qmd) / [SB2](../../demos/sbt-demo/scenario-2-conflict/guide.qmd), then [MS15](../../demos/maven-demo/scenario-15-substitution/guide.qmd) / [GS15](../../demos/gradle-demo/scenario-15-substitution/guide.qmd) / [SB15](../../demos/sbt-demo/scenario-15-substitution/guide.qmd)
    *   A circular dependency was silently broken. [MS10](../../demos/maven-demo/scenario-10-circular/guide.qmd) / [GS10](../../demos/gradle-demo/scenario-10-circular/guide.qmd) / [SB10](../../demos/sbt-demo/scenario-10-circular/guide.qmd)

*   **Exclusion failing to remove a dependency**:
    *   Apply the exclusion to the node that *brings in* the library, and check for other paths. [MS5](../../demos/maven-demo/scenario-5-exclusions/guide.qmd) / [GS5](../../demos/gradle-demo/scenario-5-exclusions/guide.qmd) / [SB5](../../demos/sbt-demo/scenario-5-exclusions/guide.qmd)
    *   To keep it out from *every* path, ban it instead. [MS18](../../demos/maven-demo/scenario-18-banning/guide.qmd) / [GS18](../../demos/gradle-demo/scenario-18-banning/guide.qmd) / [SB18](../../demos/sbt-demo/scenario-18-banning/guide.qmd)

*   **Build failed with no code changes**:
    *   A range resolved to a breaking version. [MS9](../../demos/maven-demo/scenario-9-ranges/guide.qmd) / [GS9](../../demos/gradle-demo/scenario-9-ranges/guide.qmd) / [SB9](../../demos/sbt-demo/scenario-9-ranges/guide.qmd)
    *   Unpinned versions with no lock. [MS11](../../demos/maven-demo/scenario-11-locking/guide.qmd) / [GS11](../../demos/gradle-demo/scenario-11-locking/guide.qmd) / [SB11](../../demos/sbt-demo/scenario-11-locking/guide.qmd)

*   **A known-bad version keeps coming back**:
    *   Reject it, or ban it outright. [MS14](../../demos/maven-demo/scenario-14-reject/guide.qmd) / [GS14](../../demos/gradle-demo/scenario-14-reject/guide.qmd) / [SB14](../../demos/sbt-demo/scenario-14-reject/guide.qmd), then [MS18](../../demos/maven-demo/scenario-18-banning/guide.qmd) / [GS18](../../demos/gradle-demo/scenario-18-banning/guide.qmd) / [SB18](../../demos/sbt-demo/scenario-18-banning/guide.qmd)
    *   Use a privately patched build instead. [MS16](../../demos/maven-demo/scenario-16-private-bom/guide.qmd) / [GS16](../../demos/gradle-demo/scenario-16-private-bom/guide.qmd) / [SB16](../../demos/sbt-demo/scenario-16-private-bom/guide.qmd) or [MS17](../../demos/maven-demo/scenario-17-private-patch/guide.qmd) / [GS17](../../demos/gradle-demo/scenario-17-private-patch/guide.qmd) / [SB17](../../demos/sbt-demo/scenario-17-private-patch/guide.qmd)

## Python (pip, Poetry, uv)

*   **`ResolutionImpossible` / "no solution found"**: two requirements cannot share one environment. [P2](../../demos/python-demo/scenario-2-conflict/guide.qmd), then [P3](../../demos/python-demo/scenario-3-resolver/guide.qmd) for why older pip used to "succeed".
*   **Older version than expected**: open ranges and resolver backtracking. [P4](../../demos/python-demo/scenario-4-specifiers/guide.qmd), [P3](../../demos/python-demo/scenario-3-resolver/guide.qmd)
*   **Works in dev, breaks in production**: a different environment, a missing lock, or a marker that evaluated differently. [P10](../../demos/python-demo/scenario-10-venv/guide.qmd), [P5](../../demos/python-demo/scenario-5-locks/guide.qmd), [P8](../../demos/python-demo/scenario-8-markers/guide.qmd)
*   **Resolves differently on my Mac**: environment markers. [P8](../../demos/python-demo/scenario-8-markers/guide.qmd)
*   **Unwanted transitive dependency**: you cannot exclude it with pip or Poetry; constrain or override it instead. [P9](../../demos/python-demo/scenario-9-exclusions-gap/guide.qmd), [P6](../../demos/python-demo/scenario-6-constraints/guide.qmd)
*   **Wrong package installed from a private index**: dependency confusion. [P11](../../demos/python-demo/scenario-11-private-index/guide.qmd)
*   **Inherited an environment and need to know what is in it**: [P12](../../demos/python-demo/scenario-12-audit/guide.qmd), [P1](../../demos/python-demo/scenario-1-basic/guide.qmd)

## Node (npm, pnpm, Yarn)

*   **Works locally, fails in CI** (`Cannot find module`): a phantom dependency that hoisting happened to provide. [N3](../../demos/node-demo/scenario-3-phantom/guide.qmd), [N9](../../demos/node-demo/scenario-9-tree-shape/guide.qmd)
*   **`ERESOLVE` peer dependency conflict**: the one place Node demands a single copy. [N8](../../demos/node-demo/scenario-8-peers/guide.qmd), [N2](../../demos/node-demo/scenario-2-diamond/guide.qmd)
*   **Different versions on different machines**: lock discipline and caret ranges. [N5](../../demos/node-demo/scenario-5-locks/guide.qmd), [N4](../../demos/node-demo/scenario-4-semver/guide.qmd)
*   **Two copies of the same package, `instanceof` fails across them**: duplication is the default. [N2](../../demos/node-demo/scenario-2-diamond/guide.qmd), [N6](../../demos/node-demo/scenario-6-overrides/guide.qmd), [N8](../../demos/node-demo/scenario-8-peers/guide.qmd)
*   **Unwanted or duplicate package in node_modules**: [N6](../../demos/node-demo/scenario-6-overrides/guide.qmd), [N9](../../demos/node-demo/scenario-9-tree-shape/guide.qmd)
*   **Dev tooling shipped to production**: [N7](../../demos/node-demo/scenario-7-dep-types/guide.qmd)
*   **Wrong package installed from a private registry**: dependency confusion. [N11](../../demos/node-demo/scenario-11-private-registry/guide.qmd)
*   **`npm audit` is red, or everyone ignores it**: [N12](../../demos/node-demo/scenario-12-audit/guide.qmd), then [N6](../../demos/node-demo/scenario-6-overrides/guide.qmd) to remediate.
