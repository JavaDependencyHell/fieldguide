### SBT Scenario 4: Hardcoded Version vs Dependency Overrides

This scenario demonstrates how `dependencyOverrides` in SBT interacts with hardcoded versions in `libraryDependencies`.

#### What's happening:
1.  We declare `lib-a` with version **1.0.0** in `libraryDependencies`.
2.  We also declare a `dependencyOverrides` for `lib-a` with version **2.0.0**.
3.  In SBT, `dependencyOverrides` is a way to force a version for a dependency, even if it is explicitly declared differently elsewhere in the build file or pulled in transitively.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
- Even though **1.0.0** is hardcoded in `libraryDependencies`, SBT will use **2.0.0** because it is specified in `dependencyOverrides`.
- The output will show `lib-a/2.0.0` in the classpath. You can also run `sbt evicted` to see the details.
