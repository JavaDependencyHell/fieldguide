### Maven Scenario 14: Rejecting a Version

This scenario demonstrates banning a specific version via the Enforcer Plugin (Maven has no native reject).

#### What's happening:
1.  The enforcer's `bannedDependencies` rule bans `com.demo:lib-a:2.0.0`.
2.  The POM has no dependency on the banned version, so the rule passes.

#### How to verify:
1.  Run `mvn validate` — the enforcer runs and the build succeeds.
2.  Add `lib-a:2.0.0` as a dependency and re-run — the build fails naming the banned artifact.

#### Expected Output:
BUILD SUCCESS from `mvn validate`; BUILD FAILURE when the banned version is introduced.
