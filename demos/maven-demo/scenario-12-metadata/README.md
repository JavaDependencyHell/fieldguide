### Maven Scenario 12: Rich Version Metadata

This scenario demonstrates a limit of the POM: it cannot say "prefer", "strictly", or "at least what my dependencies need". A stale managed version silently downgrades a transitive, and only the Enforcer Plugin notices.

#### What's happening:
1.  `<dependencyManagement>` pins `lib-b` to `1.0.0` (a pin made "months ago").
2.  We depend on `lib-a:2.0.0`, which requires `lib-b:2.0.0`.
3.  The managed version wins: `lib-b` is downgraded to `1.0.0` with no warning (`-Dverbose` shows `version managed from 2.0.0`).
4.  The Enforcer Plugin's `requireUpperBoundDeps` rule fails the build because the resolved `1.0.0` is lower than the `2.0.0` that a path in the graph requested.
5.  The `fixed` profile raises the managed version to `2.0.0`; the rule passes.

#### How to verify:
```bash
mvn validate                      # BUILD FAILURE: RequireUpperBoundDeps
mvn dependency:tree -Dverbose     # lib-b:1.0.0 (version managed from 2.0.0)
mvn validate -Pfixed              # BUILD SUCCESS
mvn dependency:tree -Pfixed       # lib-b:2.0.0
```

#### Expected Output:
The first command fails naming `com.demo:lib-b:1.0.0` and the path through `lib-a:2.0.0`; after `-Pfixed` the build succeeds and the tree shows `lib-b:jar:2.0.0`.
