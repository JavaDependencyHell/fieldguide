### Gradle Scenario 11: Dependency Locking

This scenario demonstrates Gradle's built-in dependency locking turning a dynamic version into a reproducible one.

#### What's happening:
1.  We declare `lib-a:+` ("newest available"). The repository has `1.0.0` and `2.0.0`.
2.  `dependencyLocking { lockAllConfigurations() }` is enabled and a `gradle.lockfile` is committed that pins `lib-a` to `1.0.0`.
3.  Gradle adds every lock entry as a `strictly` constraint, so `+` resolves to `1.0.0` even though `2.0.0` exists.
4.  Updating the lock is explicit: `gradle dependencies --write-locks` (or `--update-locks com.demo:lib-a`). Do **not** run that here unless you mean to change the demo; it rewrites the committed file.

#### How to verify:
```bash
gradle dependencies --configuration compileClasspath
gradle dependencyInsight --dependency lib-a --configuration compileClasspath
```

#### Expected Output:
- Tree: `com.demo:lib-a:+ -> 1.0.0`.
- Insight: `By constraint: Dependency version enforced by Dependency Locking`, request shown as `{strictly 1.0.0}`.
- Copy the directory, delete `gradle.lockfile`, run `gradle dependencies --write-locks`: the copy resolves and locks `2.0.0`.
