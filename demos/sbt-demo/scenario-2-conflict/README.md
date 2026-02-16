### SBT Scenario 2: Version Conflict Resolution (Latest Wins)

This scenario demonstrates SBT's default conflict resolution strategy.

#### What's happening:
1.  We have a direct dependency on `com.demo % lib-a % 2.0.0`.
2.  `lib-a:2.0.0` transitively depends on `lib-b:2.0.0`.
3.  We also have a direct dependency on `lib-b:1.0.0`.
4.  By default, SBT uses a "Latest Wins" strategy (similar to Gradle), so it will evict version 1.0.0 and use version **2.0.0**.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The output will show that version **2.0.0** of `lib-b` is selected for the classpath, and version 1.0.0 is absent. You can also run `sbt evicted` to see the eviction details.
