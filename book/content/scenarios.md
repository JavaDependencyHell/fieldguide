---
title: Scenarios
---

This guide explores dependency management through targeted scenarios.
All are implemented for Maven, Gradle, and SBT, enabling direct comparison of how each tool resolves the same problem.

Scenarios will often be referred to by the shorthand. Sxx. so S10 or S9 etc

::: {.content-visible when-format="html"}

|  #  | Scenario | Maven | Gradle | SBT |
|:---:|:---|:---:|:---:|:---:|
| S1  | Basic Dependency | [Maven](../demos/maven-demo/scenario-1-basic/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-1-basic/guide.qmd) | [SBT](../demos/sbt-demo/scenario-1-basic/guide.qmd) |
| S2  | Version Conflict | [Maven](../demos/maven-demo/scenario-2-conflict/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-2-conflict/guide.qmd) | [SBT](../demos/sbt-demo/scenario-2-conflict/guide.qmd) |
| S3  | Central Management (BOM) | [Maven](../demos/maven-demo/scenario-3-mgmt/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-3-mgmt/guide.qmd) | [SBT](../demos/sbt-demo/scenario-3-mgmt/guide.qmd) |
| S4  | Direct Override | [Maven](../demos/maven-demo/scenario-4-override/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-4-override/guide.qmd) | [SBT](../demos/sbt-demo/scenario-4-override/guide.qmd) |
| S5  | Exclusions | [Maven](../demos/maven-demo/scenario-5-exclusions/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-5-exclusions/guide.qmd) | [SBT](../demos/sbt-demo/scenario-5-exclusions/guide.qmd) |
| S6  | Forcing a Version | [Maven](../demos/maven-demo/scenario-6-forcing/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-6-forcing/guide.qmd) | [SBT](../demos/sbt-demo/scenario-6-forcing/guide.qmd) |
| S7  | Scopes | [Maven](../demos/maven-demo/scenario-7-scopes/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-7-scopes/guide.qmd) | [SBT](../demos/sbt-demo/scenario-7-scopes/guide.qmd) |
| S8  | Optional Dependencies | [Maven](../demos/maven-demo/scenario-8-optional/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-8-optional/guide.qmd) | [SBT](../demos/sbt-demo/scenario-8-optional/guide.qmd) |
| S9  | Version Ranges | [Maven](../demos/maven-demo/scenario-9-ranges/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-9-ranges/guide.qmd) | [SBT](../demos/sbt-demo/scenario-9-ranges/guide.qmd) |
| S10 | Circular Dependencies | [Maven](../demos/maven-demo/scenario-10-circular/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-10-circular/guide.qmd) | [SBT](../demos/sbt-demo/scenario-10-circular/guide.qmd) |
| S11 | Dependency Locking | [Maven](../demos/maven-demo/scenario-11-locking/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-11-locking/guide.qmd) | [SBT](../demos/sbt-demo/scenario-11-locking/guide.qmd) |
| S12 | Rich Version Metadata | [Maven](../demos/maven-demo/scenario-12-metadata/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-12-metadata/guide.qmd) | [SBT](../demos/sbt-demo/scenario-12-metadata/guide.qmd) |
| S13 | Feature Variants | [Maven](../demos/maven-demo/scenario-13-variants/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-13-variants/guide.qmd) | [SBT](../demos/sbt-demo/scenario-13-variants/guide.qmd) |
| S14 | Rejecting a Version | [Maven](../demos/maven-demo/scenario-14-reject/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-14-reject/guide.qmd) | [SBT](../demos/sbt-demo/scenario-14-reject/guide.qmd) |
| S15 | Version Substitution | [Maven](../demos/maven-demo/scenario-15-substitution/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-15-substitution/guide.qmd) | [SBT](../demos/sbt-demo/scenario-15-substitution/guide.qmd) |
| S16 | Private Repo (BOM) | [Maven](../demos/maven-demo/scenario-16-private-bom/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-16-private-bom/guide.qmd) | [SBT](../demos/sbt-demo/scenario-16-private-bom/guide.qmd) |
| S17 | Private Repo (Patch) | [Maven](../demos/maven-demo/scenario-17-private-patch/guide.qmd) | [Gradle](../demos/gradle-demo/scenario-17-private-patch/guide.qmd) | [SBT](../demos/sbt-demo/scenario-17-private-patch/guide.qmd) |

: Scenario Overview {tbl-colwidths="[5, 28, 22, 22, 22]"}

:::

::: {.content-visible when-format="pdf"}

|  #  | Scenario | Summary |
|:---:|:---|:---|
| S1  | Basic Dependency | Resolving a simple transitive dependency. |
| S2  | Version Conflict | Handling a "diamond dependency" conflict. |
| S3  | Central Management (BOM) | Using a Bill of Materials to control versions. |
| S4  | Direct Override | Overriding a managed version with a direct declaration. |
| S5  | Exclusions | Excluding a specific transitive dependency. |
| S6  | Forcing a Version | Forcing a specific version throughout the graph. |
| S7  | Scopes | Using `compile`, `test`, and `provided` scopes. |
| S8  | Optional Dependencies | Handling optional dependencies (non-transitive by default). |
| S9  | Version Ranges | Using ranges and their effect on reproducibility. |
| S10 | Circular Dependencies | How circular dependencies are handled. |
| S11 | Dependency Locking | Using lock files for reproducible builds. |
| S12 | Rich Version Metadata | Using rich metadata for advanced resolution. |
| S13 | Feature Variants | Consuming different variants of the same library. |
| S14 | Rejecting a Version | Explicitly rejecting a specific version. |
| S15 | Version Substitution | Programmatically substituting one version for another. |
| S16 | Private Repo (BOM) | Overriding public versions via private repo and vendor BOM. |
| S17 | Private Repo (Patch) | Overriding public versions via private repo and direct patch. |

: Scenario Overview {tbl-colwidths="[5, 30, 65]"}

:::

---

### Scenario make up

Most scenarios follow the same pattern

A title, a scenario description, a graphical representation of the dependency graph, and. configuration examples to match.

So  we've tried to structure each one to help you quickly navigate around.

