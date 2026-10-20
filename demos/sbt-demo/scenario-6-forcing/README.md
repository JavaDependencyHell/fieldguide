### sbt Scenario 6: Forcing a Version

This scenario demonstrates how to use `dependencyOverrides` to force a specific version of a transitive dependency.

#### What's happening:
1.  We depend on `lib-a:1.0.0`.
2.  `lib-a` pulls in `lib-b`, which pulls in `lib-c:1.0.0`.
3.  We add `com.demo % lib-c % 2.0.0` to `dependencyOverrides`.
4.  Coursier uses `2.0.0` for `lib-c` regardless of what the graph requests. Under Coursier, overrides apply to direct declarations as well as transitives.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The classpath contains `lib-c/2.0.0` and not `lib-c/1.0.0`. `sbt dependencyTree` shows `lib-c:1.0.0 (evicted by: 2.0.0)` under `lib-b`.
