### Maven Scenario 18: Banning a Dependency (Global Exclusion)

This scenario demonstrates keeping an artifact out of the entire build.

#### What's happening:
1.  `lib-a` transitively pulls in `lib-c` (via `lib-b`).
2.  Maven has no global exclude, so `lib-c` is excluded at the `lib-a` declaration.
3.  The Maven Enforcer Plugin's `bannedDependencies` rule guarantees `lib-c` can never reappear through any path — if it does, the build fails at `validate`.

#### How to verify:
1.  Run `mvn validate` — it succeeds (the ban finds nothing).
2.  Run `mvn dependency:tree` — `lib-c` is absent.
3.  Remove the `<exclusion>` block and run `mvn validate` again — the build fails, naming `com.demo:lib-c` and the path that pulled it in.

#### Expected Output:
Build success with `lib-c` absent; build failure when the exclusion is removed.
