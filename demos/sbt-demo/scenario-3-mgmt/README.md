### SBT Scenario 3: Dependency Overrides

This scenario demonstrates how to force specific versions of transitive dependencies in SBT using `dependencyOverrides`.

#### What's happening:
1.  We have a dependency on `lib-a:2.0.0`, which normally pulls in `lib-b:2.0.0`.
2.  We want to force the project to use `lib-b:1.0.0` despite what other libraries might want.
3.  We use `dependencyOverrides += "com.demo" % "lib-b" % "1.0.0"` to achieve this.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
Even though `lib-a` wants version 2.0.0, the override will ensure that version **1.0.0** is used in the final classpath. You can also run `sbt evicted` to see the eviction details.
