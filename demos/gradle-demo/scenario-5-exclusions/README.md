### Gradle Scenario 5: Dependency Exclusions

This scenario demonstrates how to exclude a transitive dependency in Gradle.

#### What's happening:
1.  We declare a dependency on `com.demo:lib-a:1.0.0`.
2.  We use the `exclude` method within the dependency configuration block to remove `lib-c`.
3.  Gradle allows you to exclude by group, by module (artifact name), or both.

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
In the dependency tree, you will see `lib-a:1.0.0` and `lib-b:1.0.0`, but `lib-c` will be absent.
