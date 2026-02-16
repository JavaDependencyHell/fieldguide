### Gradle Scenario 11: Dependency Locking

This scenario demonstrates Gradle's Dependency Locking feature, which allows for reproducible builds even when using dynamic versions.

#### What's happening:
1.  We declare a dynamic dependency on `lib-a:1.+`.
2.  We enable dependency locking with `dependencyLocking { lockAllConfigurations() }`.
3.  When we run with `--write-locks`, Gradle generates a `gradle.lockfile`.
4.  Subsequent builds will respect the versions in the lockfile, ignoring newer versions that might match `1.+` until the lock is updated.

#### How to verify:
1.  Generate the lock file:
    ```bash
    ./gradlew dependencies --write-locks
    ```
2.  Inspect the generated `gradle.lockfile`.
3.  Run dependencies again to see it uses the locked version.

#### Expected Output:
The build uses the specific version captured in the lockfile.
