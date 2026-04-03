# Rapid Dependency Failure Triage

Scan symptoms below to identify the path.

*   **Compilation failure** (`cannot find symbol`, `package missing`):
    *   Verify build file definition. See [MS1](../../demos/maven-demo/scenario-1-basic/guide.qmd).
    *   Check for over-aggressive exclusions. See [MS5](../../demos/maven-demo/scenario-5-exclusions/guide.qmd).
    *   Verify scope/configuration (e.g., `test` vs `runtimeOnly`). See [MS7](../../demos/maven-demo/scenario-7-scopes/guide.qmd).

*   **Runtime failure** (`NoClassDefFoundError`, `NoSuchMethodError`):
    *   Version conflict bringing incompatible binary. See [MS2](../../demos/maven-demo/scenario-2-conflict/guide.qmd).
    *   Excluded transitive required at runtime. See [MS5](../../demos/maven-demo/scenario-5-exclusions/guide.qmd).
    *   Missing `provided`/`compileOnly` dependency in environment. See [MS7](../../demos/maven-demo/scenario-7-scopes/guide.qmd).

*   **Unexpected version resolved**:
    *   Maven "nearest wins" vs Gradle/SBT "newest wins". See [MS2](../../demos/maven-demo/scenario-2-conflict/guide.qmd).
    *   Direct declaration overriding BOM/Management. See [MS4](../../demos/maven-demo/scenario-4-override/guide.qmd).
    *   Dynamic range resolution. See [MS9](../../demos/maven-demo/scenario-9-ranges/guide.qmd).
    *   Stale or missing lockfile. See [MS11](../../demos/maven-demo/scenario-11-locking/guide.qmd).

*   **Duplicate classes or `LinkageError`**:
    *   Address version conflicts. See [MS2](../../demos/maven-demo/scenario-2-conflict/guide.qmd).
    *   Investigate circular dependencies. See [MS10](../../demos/maven-demo/scenario-10-circular/guide.qmd).

*   **Exclusion failing to remove dependency**:
    *   Apply exclusion to the specific node *bringing in* the library.
    *   Check for multiple paths in the graph.
    *   Verify via `dependency:tree` or `dependencyInsight`.

*   **Build failed with no code changes**:
    *   Dynamic range resolution of breaking version. See [MS9](../../demos/maven-demo/scenario-9-ranges/guide.qmd).
    *   Unpinned version or lack of locking. See [MS11](../../demos/maven-demo/scenario-11-locking/guide.qmd).
