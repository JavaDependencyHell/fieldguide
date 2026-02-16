### Gradle Scenario 7: Dependency Configurations (Scopes)

This scenario demonstrates Gradle's dependency configurations, which are more flexible than Maven's scopes.

#### What's happening:
1.  `implementation`: Used for `lib-a`. This is the standard configuration for dependencies required to compile and run the project. It is transitive but encapsulates the API.
2.  `compileOnly`: Used for `lib-b`. This is equivalent to Maven's `provided` scope. It is available at compile time but not packaged or transitive.
3.  `testImplementation`: Used for `lib-c`. This is equivalent to Maven's `test` scope. It is only available for tests.

#### How to verify:
Run the following commands:

For compile classpath:
```bash
./gradlew dependencies --configuration compileClasspath
```

For compileOnly dependencies (note: they appear in compileClasspath but not runtimeClasspath):
```bash
./gradlew dependencies --configuration compileOnly
```

For test classpath:
```bash
./gradlew dependencies --configuration testCompileClasspath
```

#### Expected Output:
- `lib-a` will appear in `compileClasspath` and `runtimeClasspath`.
- `lib-b` will appear in `compileClasspath` but NOT `runtimeClasspath`.
- `lib-c` will appear only in `testCompileClasspath` and `testRuntimeClasspath`.
