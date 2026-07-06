### SBT Scenario 18: Banning a Dependency (Global Exclusion)

This scenario demonstrates keeping an artifact out of the entire build.

#### What's happening:
1.  `lib-a` transitively pulls in `lib-c` (via `lib-b`).
2.  `excludeDependencies += ExclusionRule("com.demo", "lib-c")` removes `lib-c` from every dependency's subtree — including dependencies added in the future.
3.  Like Gradle's global exclude (and unlike Maven's enforcer), the removal is silent.

#### How to verify:
1.  Run `sbt dependencyTree`.
2.  `lib-c` is absent from the tree (with no marker of the removal).
3.  Comment out the `excludeDependencies` line and re-run — `lib-c` reappears under `lib-b`.

#### Expected Output:
The dependency tree shows `lib-a` and `lib-b` but no `lib-c`.
