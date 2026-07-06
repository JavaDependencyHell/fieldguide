### SBT Scenario 11: Dependency Locking

This scenario demonstrates dependency locking in sbt using the third-party
`sbt-dependency-lock` plugin (sbt has no built-in locking).

#### What's happening:
1.  The `sbt-dependency-lock` plugin (declared in `project/plugins.sbt`) adds locking tasks to the build.
2.  `sbt dependencyLockWrite` generates a lock file (`build.sbt.lock`) that pins every dependency (including transitives) to a specific version.
3.  This prevents "it works on my machine" issues when a dynamic version (here `1.+`) or a SNAPSHOT changes.

#### How to verify:
1.  Run `sbt dependencyLockWrite` to generate `build.sbt.lock`.
2.  Inspect `build.sbt.lock` — it records the exact resolved versions.
3.  Run `sbt dependencyLockCheck` to verify current resolution still matches the lock file.

#### Expected Output:
`dependencyLockCheck` prints "Dependency lock check passed".
