# Scenarios

This guide explores dependency management through targeted scenarios. 
All are implemented for Maven, Gradle, and SBT, enabling direct comparison of how each tool resolves the same problem.

Scenarios will often be referred to by the shorthand. Sxx. so S10 or S9 etc 


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

: Scenario Overview {tbl-colwidths="[10, 30, 60]"}
