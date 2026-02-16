### SBT Scenario 5: Dependency Exclusions

This scenario demonstrates how to exclude a transitive dependency in SBT.

#### What's happening:
1.  We declare a dependency on `com.demo % lib-a % 1.0.0`.
2.  We append the `exclude("com.demo", "lib-c")` method to the dependency definition.
3.  This tells SBT/Ivy to ignore that specific transitive dependency when resolving `lib-a`.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The output will show `lib-a` and `lib-b`, but `lib-c` will not be in the classpath.
