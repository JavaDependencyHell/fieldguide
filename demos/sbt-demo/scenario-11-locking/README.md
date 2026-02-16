### SBT Scenario 11: Dependency Locking

This scenario demonstrates SBT's dependency locking feature.

#### What's happening:
1.  SBT 1.4+ supports dependency locking to ensure reproducible builds.
2.  You can generate a lock file that pins every dependency (including transitives) to a specific version/checksum.
3.  This prevents "it works on my machine" issues when a dynamic version or a SNAPSHOT changes.

#### How to verify:
1.  Run `sbt dependencyLockWrite` to generate the lock file.
2.  Inspect the `project/dependency-locks` directory.
3.  Run `sbt dependencyLockRead` (or just a normal build) to use the locks.

#### Expected Output:
The build uses the locked versions.
