### Gradle Scenario 3: Dependency Management (BOM via Platform)

This scenario demonstrates how Gradle uses `platform()` to import Maven BOMs for dependency management.

#### What's happening:
1.  We use `implementation platform(...)` to import our `demo-bom`.
2.  The `platform` keyword tells Gradle to use the versions defined in that BOM as recommendations/constraints for the project.
3.  We then declare `lib-a` and `lib-b` without versions.
4.  Gradle resolves these to the versions specified in the imported BOM (1.0.0).

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
The output will show `lib-a` and `lib-b` resolved to version 1.0.0.
