---
title: Scenarios
---

This guide explores dependency management through targeted scenarios.
All are implemented for Maven, Gradle, and SBT, enabling direct comparison of how each tool resolves the same problem.

Each scenario is implemented for all three tools. References use a tool prefix: MS (Maven), GS (Gradle), SB (SBT) --- so MS2 is the Maven version of scenario 2, GS2 is Gradle, and SB2 is SBT.

::: {.content-visible when-format="html"}

|  #  | Scenario | Maven | Gradle | SBT |
|:---:|:---|:---:|:---:|:---:|
| 1  | Basic Dependency | [MS1](../../demos/maven-demo/scenario-1-basic/guide.html) | [GS1](../../demos/gradle-demo/scenario-1-basic/guide.html) | [SB1](../../demos/sbt-demo/scenario-1-basic/guide.html) |
| 2  | Version Conflict | [MS2](../../demos/maven-demo/scenario-2-conflict/guide.html) | [GS2](../../demos/gradle-demo/scenario-2-conflict/guide.html) | [SB2](../../demos/sbt-demo/scenario-2-conflict/guide.html) |
| 3  | Central Management (BOM) | [MS3](../../demos/maven-demo/scenario-3-mgmt/guide.html) | [GS3](../../demos/gradle-demo/scenario-3-mgmt/guide.html) | [SB3](../../demos/sbt-demo/scenario-3-mgmt/guide.html) |
| 4  | Direct Override | [MS4](../../demos/maven-demo/scenario-4-override/guide.html) | [GS4](../../demos/gradle-demo/scenario-4-override/guide.html) | [SB4](../../demos/sbt-demo/scenario-4-override/guide.html) |
| 5  | Exclusions | [MS5](../../demos/maven-demo/scenario-5-exclusions/guide.html) | [GS5](../../demos/gradle-demo/scenario-5-exclusions/guide.html) | [SB5](../../demos/sbt-demo/scenario-5-exclusions/guide.html) |
| 6  | Forcing a Version | [MS6](../../demos/maven-demo/scenario-6-forcing/guide.html) | [GS6](../../demos/gradle-demo/scenario-6-forcing/guide.html) | [SB6](../../demos/sbt-demo/scenario-6-forcing/guide.html) |
| 7  | Scopes | [MS7](../../demos/maven-demo/scenario-7-scopes/guide.html) | [GS7](../../demos/gradle-demo/scenario-7-scopes/guide.html) | [SB7](../../demos/sbt-demo/scenario-7-scopes/guide.html) |
| 8  | Optional Dependencies | [MS8](../../demos/maven-demo/scenario-8-optional/guide.html) | [GS8](../../demos/gradle-demo/scenario-8-optional/guide.html) | [SB8](../../demos/sbt-demo/scenario-8-optional/guide.html) |
| 9  | Version Ranges | [MS9](../../demos/maven-demo/scenario-9-ranges/guide.html) | [GS9](../../demos/gradle-demo/scenario-9-ranges/guide.html) | [SB9](../../demos/sbt-demo/scenario-9-ranges/guide.html) |
| 10 | Circular Dependencies | [MS10](../../demos/maven-demo/scenario-10-circular/guide.html) | [GS10](../../demos/gradle-demo/scenario-10-circular/guide.html) | [SB10](../../demos/sbt-demo/scenario-10-circular/guide.html) |
| 11 | Dependency Locking | [MS11](../../demos/maven-demo/scenario-11-locking/guide.html) | [GS11](../../demos/gradle-demo/scenario-11-locking/guide.html) | [SB11](../../demos/sbt-demo/scenario-11-locking/guide.html) |
| 12 | Rich Version Metadata | [MS12](../../demos/maven-demo/scenario-12-metadata/guide.html) | [GS12](../../demos/gradle-demo/scenario-12-metadata/guide.html) | [SB12](../../demos/sbt-demo/scenario-12-metadata/guide.html) |
| 13 | Feature Variants | [MS13](../../demos/maven-demo/scenario-13-variants/guide.html) | [GS13](../../demos/gradle-demo/scenario-13-variants/guide.html) | [SB13](../../demos/sbt-demo/scenario-13-variants/guide.html) |
| 14 | Rejecting a Version | [MS14](../../demos/maven-demo/scenario-14-reject/guide.html) | [GS14](../../demos/gradle-demo/scenario-14-reject/guide.html) | [SB14](../../demos/sbt-demo/scenario-14-reject/guide.html) |
| 15 | Version Substitution | [MS15](../../demos/maven-demo/scenario-15-substitution/guide.html) | [GS15](../../demos/gradle-demo/scenario-15-substitution/guide.html) | [SB15](../../demos/sbt-demo/scenario-15-substitution/guide.html) |
| 16 | Private Repo (BOM) | [MS16](../../demos/maven-demo/scenario-16-private-bom/guide.html) | [GS16](../../demos/gradle-demo/scenario-16-private-bom/guide.html) | [SB16](../../demos/sbt-demo/scenario-16-private-bom/guide.html) |
| 17 | Private Repo (Patch) | [MS17](../../demos/maven-demo/scenario-17-private-patch/guide.html) | [GS17](../../demos/gradle-demo/scenario-17-private-patch/guide.html) | [SB17](../../demos/sbt-demo/scenario-17-private-patch/guide.html) |

: Scenario Overview {tbl-colwidths="[5, 28, 22, 22, 22]"}

:::

::: {.content-visible when-format="pdf"}

|  #  | Scenario | Summary |
|:---:|:---|:---|
| 1  | Basic Dependency | Resolving a simple transitive dependency. |
| 2  | Version Conflict | Handling a "diamond dependency" conflict. |
| 3  | Central Management (BOM) | Using a Bill of Materials to control versions. |
| 4  | Direct Override | Overriding a managed version with a direct declaration. |
| 5  | Exclusions | Excluding a specific transitive dependency. |
| 6  | Forcing a Version | Forcing a specific version throughout the graph. |
| 7  | Scopes | Using `compile`, `test`, and `provided` scopes. |
| 8  | Optional Dependencies | Handling optional dependencies (non-transitive by default). |
| 9  | Version Ranges | Using ranges and their effect on reproducibility. |
| 10 | Circular Dependencies | How circular dependencies are handled. |
| 11 | Dependency Locking | Using lock files for reproducible builds. |
| 12 | Rich Version Metadata | Using rich metadata for advanced resolution. |
| 13 | Feature Variants | Consuming different variants of the same library. |
| 14 | Rejecting a Version | Explicitly rejecting a specific version. |
| 15 | Version Substitution | Programmatically substituting one version for another. |
| 16 | Private Repo (BOM) | Overriding public versions via private repo and vendor BOM. |
| 17 | Private Repo (Patch) | Overriding public versions via private repo and direct patch. |

: Scenario Overview {tbl-colwidths="[5, 30, 65]"}

:::

---

### Scenario make up

Most scenarios follow the same pattern

A title, a scenario description, a graphical representation of the dependency graph, and. configuration examples to match.

So  we've tried to structure each one to help you quickly navigate around.

