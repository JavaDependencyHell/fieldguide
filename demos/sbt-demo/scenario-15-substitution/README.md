### sbt Scenario 15: Dependency Substitution

This scenario demonstrates replacing one library with another in sbt, which has no substitution rules.

#### What's happening:
1.  `lib-a:1.0.0` brings `lib-b:1.0.0` (and through it `lib-c:1.0.0`).
2.  We want `lib-d` in place of `lib-b` (think of a maintained fork or a bridge artifact).
3.  `.exclude("com.demo", "lib-b")` removes `lib-b` from `lib-a`'s subtree; a direct declaration adds `lib-d`.
4.  `lib-c` disappears too, because it only arrived through `lib-b` (`lib-d` declares it optional, scenario 8). If the substitute needs it, declare it.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The classpath contains `lib-a/1.0.0` and `lib-d/1.0.0`; `lib-b` is absent.
