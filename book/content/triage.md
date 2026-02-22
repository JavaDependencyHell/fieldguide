# Rapid Dependency Failure Triage

This page is designed to help you quickly identify the root cause of a dependency-related problem. When you are facing an unexpected build failure or runtime error, start here. Find the symptom that matches your situation and jump to the relevant scenarios.

*   **Build fails at compile time with `cannot find symbol` or `package does not exist`**:
    *   Is the dependency correctly defined in your build file? See [Scenario 1: Basic Resolution](demos/maven-demo/scenario-1-basic/guide.qmd).
    *   Did you exclude a required transitive dependency? See [Scenario 5: Exclusions](demos/maven-demo/scenario-5-exclusions/guide.qmd).
    *   Is the dependency in a `test` or `runtimeOnly` scope, making it unavailable at compile time? See [Scenario 7: Scopes](demos/maven-demo/scenario-7-scopes/guide.qmd).

*   **Build succeeds, but fails at runtime with `NoClassDefFoundError` or `NoSuchMethodError`**:
    *   Is there a version conflict, causing an older, incompatible version of a library to be on the classpath? See [Scenario 2: Version Conflict](demos/maven-demo/scenario-2-conflict/guide.qmd).
    *   Did you exclude a necessary transitive dependency that is only used at runtime? See [Scenario 5: Exclusions](demos/maven-demo/scenario-5-exclusions/guide.qmd).
    *   Is a `compileOnly` dependency missing from the final application? See [Scenario 7: Scopes](demos/maven-demo/scenario-7-scopes/guide.qmd).

*   **The version of a dependency is not what you expected**:
    *   Are you seeing an older version because of a "nearest wins" conflict (Maven)? See [Scenario 2: Version Conflict](demos/maven-demo/scenario-2-conflict/guide.qmd).
    *   Is a hardcoded version in your build file overriding a version from a BOM or dependency management? See [Scenario 4: Hardcoded vs Management](demos/maven-demo/scenario-4-override/guide.qmd).
    *   Is a version range causing an unexpected upgrade or downgrade? See [Scenario 9: Version Ranges](demos/maven-demo/scenario-9-ranges/guide.qmd).
    *   Are you using a dependency lockfile that is out of date? See [Scenario 11: Dependency Locking](demos/maven-demo/scenario-11-locking/guide.qmd).

*   **You have duplicate classes on the classpath, or `LinkageError` at runtime**:
    *   This is almost always a version conflict. See [Scenario 2: Version Conflict](demos/maven-demo/scenario-2-conflict/guide.qmd).
    *   In rare cases, it could be a circular dependency. See [Scenario 10: Circular Dependencies](demos/maven-demo/scenario-10-circular/guide.qmd).

*   **You excluded a dependency, but it keeps reappearing in the resolved tree**:
    *   The exclusion might be in the wrong place. The exclusion must be on the dependency that *brings in* the unwanted library.
    *   The dependency might be included from multiple places. You may need to add multiple exclusions.
    *   Are you sure you're looking at the right dependency? Check the full `dependency:tree` or `dependencyInsight` report.

*   **The build worked yesterday, but is failing today with no code changes**:
    *   The most likely culprit is a version range that has resolved to a new, breaking version of a dependency. See [Scenario 9: Version Ranges](demos/maven-demo/scenario-9-ranges/guide.qmd).
    *   Someone may have published a new version of a library you depend on, and your build tool is picking it up. See [Scenario 11: Dependency Locking](demos/maven-demo/scenario-11-locking/guide.qmd) for how to prevent this.
