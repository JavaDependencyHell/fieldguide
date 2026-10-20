### Maven Scenario 14: Rejecting a Version

This scenario demonstrates banning one specific version with the Enforcer Plugin (Maven has no native reject), and the managed-version fix that steers resolution away from it.

#### What's happening:
1.  We depend on `lib-a:2.0.0`, which transitively requires `lib-b:2.0.0`.
2.  The enforcer's `bannedDependencies` rule bans `com.demo:lib-b:2.0.0`.
3.  Resolution still picks `lib-b:2.0.0` (the ban does not influence version selection); the enforcer then fails the build at `validate`, printing the path.
4.  The `fixed` profile manages `lib-b` to `1.0.0`, so the banned version never resolves and the build passes.

#### How to verify:
```bash
mvn validate                 # BUILD FAILURE, lib-b:2.0.0 "banned via the exclude/include list"
mvn validate -Pfixed         # BUILD SUCCESS
mvn dependency:tree -Pfixed  # lib-b:1.0.0 under lib-a:2.0.0
```

#### Expected Output:
Failure naming `com.demo:lib-b:jar:2.0.0` and the path through `lib-a`; success with `lib-b:jar:1.0.0` once the version is managed.
