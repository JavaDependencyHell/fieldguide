### Maven Scenario 15: Version Substitution

This scenario demonstrates replacing one library with another. Maven has no substitution rule; the pattern is exclusion + explicit replacement + an enforcer guard.

#### What's happening:
1.  `lib-a:1.0.0` normally pulls in `lib-b` (and through it `lib-c`). We treat `lib-b` as abandoned.
2.  `lib-b` is excluded from the `lib-a` declaration.
3.  `lib-d:1.0.0` is declared directly as the stand-in replacement.
4.  A `bannedDependencies` rule for `com.demo:lib-b` fails the build if any other path ever brings `lib-b` back.

All artifacts come from the local demo repository; no network is needed.

#### How to verify:
```bash
mvn validate          # BUILD SUCCESS (ban finds nothing)
mvn dependency:tree   # lib-a with no children, lib-d beside it
```

#### Expected Output:
`com.demo:lib-a:jar:1.0.0` and `com.demo:lib-d:jar:1.0.0`; no `lib-b` or `lib-c` anywhere. Remove the `<exclusion>` and `mvn validate` fails naming `lib-b`.
