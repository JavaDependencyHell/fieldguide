# How to Use This Book {.unnumbered}

This book is structured as a series of scenarios, each demonstrating a specific dependency management challenge. Most scenarios are implemented for Maven, Gradle, and SBT to allow for a direct comparison of how each tool handles the same problem.

The following table provides a summary of all scenarios and a cross-reference to the chapter where you can find the detailed implementation for each build tool. This allows you to either focus on a specific tool or compare and contrast their different approaches to dependency resolution.

| # | Scenario | Summary | Maven | Gradle | SBT |
|:---:|:---|:---|:---:|:---:|:---:|
| 1 | Basic Dependency | Resolving a simple transitive dependency. | 3.1 | 4.1 | 5.1 |
| 2 | Version Conflict | Handling a "diamond dependency" conflict. | 3.2 | 4.2 | 5.2 |
| 3 | Central Management (BOM) | Using a Bill of Materials to control versions. | 3.3 | 4.3 | 5.3 |
| 4 | Direct Override | Overriding a managed version with a direct declaration. | 3.4 | 4.4 | 5.4 |
| 5 | Exclusions | Excluding a specific transitive dependency. | 3.5 | 4.5 | 5.5 |
| 6 | Forcing a Version | Forcing a specific version throughout the graph. | 3.6 | 4.6 | 5.6 |
| 7 | Scopes | Using `compile`, `test`, and `provided` scopes. | 3.7 | 4.7 | 5.7 |
| 8 | Optional Dependencies | Handling optional dependencies that are not transitive by default. | 3.8 | 4.8 | 5.8 |
| 9 | Version Ranges | Using version ranges and their effect on reproducibility. | 3.9 | 4.9 | 5.9 |
| 10 | Circular Dependencies | How circular dependencies are handled. | 3.10 | 4.10 | 5.10 |
| 11 | Dependency Locking | Using lock files to ensure reproducible builds. | N/A | 4.11 | 5.11 |
| 12 | Rich Version Metadata | Using rich metadata for more advanced resolution. | N/A | 4.12 | 5.12 |
| 13 | Feature Variants | Consuming different variants of the same library. | N/A | 4.13 | 5.13 |
| 14 | Rejecting a Version | Explicitly rejecting a specific version from being used. | N/A | 4.14 | 5.14 |
| 15 | Version Substitution | Programmatically substituting one version for another. | N/A | 4.15 | 5.15 |
| 16 | Private Repo (BOM) | Overriding public versions using a private repo and a vendor BOM. | 3.11 | 4.16 | 5.16 |
| 17 | Private Repo (Patch) | Overriding public versions using a private repo and a direct patch. | 3.12 | 4.17 | 5.17 |

: Scenario Overview {tbl-colwidths="[5, 20, 45, 10, 10, 10]"}

*Chapter numbers are based on the structure of this book and may vary if chapters are added or removed.*
