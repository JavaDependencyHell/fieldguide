### Maven Scenario 11: Dependency Locking

This scenario demonstrates that Maven has no native lockfile — reproducibility requires plugins or discipline.

#### What's happening:
1.  The POM declares `lib-a` with the range `[1.0.0,2.0.0)` — resolution can drift as new 1.x versions appear.
2.  Maven has no built-in lock file. Options: `versions:resolve-ranges` (rewrite ranges to pins), `dependency-lock-maven-plugin`, or `maven-lockfile`.

#### How to verify:
1.  Run `mvn dependency:tree` — the range resolves to the highest available 1.x (`1.0.0` in the demo repo).
2.  Run `mvn versions:resolve-ranges` to see the range replaced with a pinned version in the POM.

#### Expected Output:
`com.demo:lib-a:jar:1.0.0` in the tree.
