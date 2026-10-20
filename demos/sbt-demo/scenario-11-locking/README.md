### sbt Scenario 11: Dependency Locking

This scenario demonstrates dependency locking in sbt using the third-party
`sbt-dependency-lock` plugin. sbt has no built-in locking.

#### What's happening:
1.  The `sbt-dependency-lock` plugin (declared in `project/plugins.sbt`) adds locking tasks to the build.
2.  `sbt dependencyLockWrite` generates `build.sbt.lock`, which pins every dependency (including transitives) to the exact resolved version and artifact hash.
3.  `sbt dependencyLockCheck` fails if current resolution differs from the lock file, so a dynamic version (here `1.+`) cannot drift unnoticed.

#### How to verify:
1.  Run `sbt dependencyLockWrite` to generate `build.sbt.lock`.
2.  Inspect `build.sbt.lock`; it records the exact resolved versions.
3.  Run `sbt dependencyLockCheck` to verify current resolution still matches the lock file.

#### Expected Output:
`dependencyLockCheck` prints "Dependency lock check passed".
