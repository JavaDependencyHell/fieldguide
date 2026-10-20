### sbt Scenario 5: Dependency Exclusions

This scenario demonstrates how to exclude a transitive dependency in sbt.

#### What's happening:
1.  We declare a dependency on `com.demo % lib-a % 1.0.0`.
2.  `lib-a` depends on `lib-b`, which depends on `lib-c`.
3.  We append `.exclude("com.demo", "lib-c")` to the declaration. Coursier prunes `lib-c` from the whole subtree under `lib-a`, however deep it sits.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The classpath contains `lib-a` and `lib-b`, but not `lib-c`. `sbt dependencyTree` shows `lib-b` with no child.
