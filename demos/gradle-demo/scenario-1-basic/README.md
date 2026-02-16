### Gradle Scenario 1: Basic Transitive Resolution

This scenario demonstrates how Gradle handles basic transitive dependencies.

#### What's happening:
1.  We declare an `implementation` dependency on `com.demo:lib-a:1.0.0`.
2.  `lib-a` has transitive dependencies on `lib-b` and `lib-c`.
3.  Gradle automatically resolves these and adds them to the runtime and compile classpaths.

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
Gradle will display a tree showing `lib-a` and its transitive dependencies nested beneath it.
