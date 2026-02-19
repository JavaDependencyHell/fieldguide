# Scenarios {.unnumbered}

This book is structured as a series of scenarios, each demonstrating a specific dependency management challenge. 

Most scenarios are implemented for Maven, Gradle, and SBT to allow for a direct comparison of how each tool handles the same problem.

The following table provides a summary of all scenarios. Where unique to a particular build tool this is indicated in the table.

| # | Scenario | Summary |
|:---:|:---|:---|
| 1 | Basic Dependency | Resolving a simple transitive dependency. |
| 2 | Version Conflict | Handling a "diamond dependency" conflict. |
| 3 | Central Management (BOM) | Using a Bill of Materials to control versions. |
| 4 | Direct Override | Overriding a managed version with a direct declaration. |
| 5 | Exclusions | Excluding a specific transitive dependency. |
| 6 | Forcing a Version | Forcing a specific version throughout the graph. |
| 7 | Scopes | Using `compile`, `test`, and `provided` scopes. |
| 8 | Optional Dependencies | Handling optional dependencies that are not transitive by default. |
| 9 | Version Ranges | Using version ranges and their effect on reproducibility. |
| 10 | Circular Dependencies | How circular dependencies are handled. |
| 11 | Dependency Locking | Using lock files to ensure reproducible builds. |
| 12 | Rich Version Metadata | Using rich metadata for more advanced resolution. |
| 13 | Feature Variants | Consuming different variants of the same library. |
| 14 | Rejecting a Version | Explicitly rejecting a specific version from being used. |
| 15 | Version Substitution | Programmatically substituting one version for another. |
| 16 | Private Repo (BOM) | Overriding public versions using a private repo and a vendor BOM. |
| 17 | Private Repo (Patch) | Overriding public versions using a private repo and a direct patch. |

: Scenario Overview {tbl-colwidths="[10, 30, 60]"}
