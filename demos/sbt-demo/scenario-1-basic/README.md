### SBT Scenario 1: Basic Transitive Resolution

This scenario demonstrates how SBT handles basic transitive dependencies.

#### What's happening:
1.  We declare a dependency on `com.demo % lib-a % 1.0.0`.
2.  `lib-a` depends on `lib-b`, and `lib-b` depends on `lib-c`.
3.  SBT (using Ivy or its own engine) fetches the metadata for `lib-a` and automatically identifies and downloads the transitive dependencies: `lib-b` and `lib-c`.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The output will list the JAR files in the classpath, including `lib-a`, `lib-b`, and `lib-c` from the local repository.
