### Gradle Scenario 14: Rejecting Versions

This scenario demonstrates how to explicitly reject a specific version of a dependency.

#### What's happening:
1.  We depend on `lib-a`.
2.  We explicitly tell Gradle to **reject** version `2.0.0` of `lib-a`.
3.  This is useful if a specific version is known to be broken (e.g., "bad release").
4.  If the dependency graph tries to resolve to `2.0.0`, Gradle will fail or look for another candidate.

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
Since we requested `1.0.0` and rejected `2.0.0`, it will resolve to `1.0.0`. If we had requested `2.0.0`, the build would fail with a rejection error.
