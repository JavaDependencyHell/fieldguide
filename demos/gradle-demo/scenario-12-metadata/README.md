### Gradle Scenario 12: Component Metadata Rules

This scenario demonstrates how to fix incorrect metadata in third-party libraries on the fly.

#### What's happening:
1.  We pretend `lib-a:1.0.0` has a "bug" in its metadata (e.g., it declares a dependency on `lib-b:1.0.0` but actually needs `2.0.0`).
2.  Instead of waiting for the library author to fix it, we use a `ComponentMetadataRule`.
3.  In `build.gradle`, we define a rule that modifies the dependencies of `lib-a` *before* resolution completes.

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
You will see `lib-a` depending on `lib-b:2.0.0` (the patched version), even though the original POM said `1.0.0`.
