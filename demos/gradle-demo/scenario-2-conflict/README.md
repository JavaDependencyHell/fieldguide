### Gradle Scenario 2: Version Conflict Resolution (Newest Wins)

This scenario demonstrates Gradle's "Newest Wins" strategy for resolving version conflicts.

#### What's happening:
1.  We have a direct dependency on `com.demo:lib-a:2.0.0`.
2.  `lib-a:2.0.0` transitively depends on `com.demo:lib-b:2.0.0`.
3.  We also have a direct dependency on `com.demo:lib-b:1.0.0`.
4.  Unlike Maven (which would pick 1.0.0 because it's "nearer"), **Gradle chooses version 2.0.0** because it is the highest version found in the entire dependency graph.

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
In the dependency tree, you will see `com.demo:lib-b:1.0.0 -> 2.0.0`. This indicates that version 1.0.0 was requested but was upgraded to 2.0.0.
