### Gradle Scenario 10: Circular Dependencies

This scenario demonstrates Gradle's handling of circular dependencies.

#### What's happening:
1.  We depend on `lib-circle-a`, which depends on `lib-circle-b`, which depends back on `lib-circle-a`.
2.  Gradle is generally smarter than Maven at handling this at resolution time. It detects the cycle and stops recursing, effectively resolving the graph without crashing.

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
You will see the dependency tree, and where the cycle occurs, Gradle will likely print `(*)` or omit the repeated dependency, indicating it has already been visited. It will NOT fail the build.
