### Gradle Scenario 9: Version Ranges

This scenario demonstrates Gradle's support for dynamic versions and ranges.

#### What's happening:
1.  We declare a dependency on `lib-a` with the range `[1.0.0, 2.0.0)`.
2.  This syntax is standard Maven-style range syntax, which Gradle supports.
3.  Gradle also supports `1.+` (latest 1.x) or `latest.release`.

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
Gradle will resolve to `1.0.0` (since 2.0.0 is excluded by the range).
