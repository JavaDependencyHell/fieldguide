### sbt Scenario 2: Version Conflict Resolution (Highest Wins)

This scenario demonstrates sbt's default conflict resolution strategy under Coursier.

#### What's happening:
1.  We have a direct dependency on `com.demo % lib-a % 2.0.0`.
2.  `lib-a:2.0.0` transitively depends on `lib-b:2.0.0`.
3.  We also have a direct dependency on `lib-b:1.0.0`.
4.  Coursier selects the highest version requested anywhere in the graph, so it evicts `1.0.0` and uses `lib-b:2.0.0`. Maven would pick the nearer `1.0.0`.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The classpath contains `lib-b/2.0.0` and not `lib-b/1.0.0`. `sbt evicted` lists the eviction.
