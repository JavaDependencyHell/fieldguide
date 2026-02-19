# Glossary {.unnumbered}

*   **BOM (Bill of Materials):** A special POM file that lists dependencies and their versions, used to manage versions across a project.
*   **Diamond Dependency:** A situation where two dependencies rely on different versions of the same transitive dependency.
*   **Eviction:** The process of removing a dependency version from the graph in favor of another (usually newer) version.
*   **Nearest Wins:** Maven's default conflict resolution strategy, where the version defined closest to the root of the dependency tree is selected.
*   **Newest Wins:** Gradle's default conflict resolution strategy, where the highest version number is selected regardless of depth.
*   **Transitive Dependency:** A dependency of a dependency.
*   **Direct Dependency:** A dependency explicitly declared in the project's build file.
*   **Scope:** Defines the visibility and lifecycle of a dependency (e.g., compile, runtime, test).
*   **Classifier:** An optional identifier appended to the artifact name to distinguish variants (e.g., sources, javadoc).
*   **Repository:** A storage location for artifacts (e.g., Maven Central, JCenter, private Nexus/Artifactory).
*   **Snapshot:** A version of a dependency that is under development and may change over time.
*   **Release:** A stable, immutable version of a dependency.
*   **Module:** A unit of software that can be versioned and deployed (e.g., a JAR file).
*   **Artifact:** A specific file produced by a build (e.g., a JAR, WAR, or POM file).
*   **Group ID:** A unique identifier for the organization or project that produces the artifact.
*   **Artifact ID:** A unique identifier for the artifact within the group.
*   **Version:** A string that identifies a specific release of an artifact.
