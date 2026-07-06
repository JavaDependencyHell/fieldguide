### Gradle Scenario 18: Banning a Dependency (Global Exclusion)

This scenario demonstrates keeping an artifact out of the entire build.

#### What's happening:
1.  `lib-a` transitively pulls in `lib-c` (via `lib-b`).
2.  `configurations.all { exclude group: 'com.demo', module: 'lib-c' }` removes `lib-c` from every configuration and every path — including dependencies added in the future.
3.  Unlike Maven's enforcer (which fails the build), the removal is silent.

#### How to verify:
1.  Run `gradle dependencies --configuration runtimeClasspath`.
2.  `lib-c` is absent from the tree (with no marker of the removal).
3.  Comment out the `configurations.all` block and re-run — `lib-c` reappears under `lib-b`.

#### Expected Output:
The dependency tree shows `lib-a` and `lib-b` but no `lib-c`.
