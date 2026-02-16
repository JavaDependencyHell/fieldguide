### Gradle Scenario 8: Optional Dependencies

This scenario demonstrates how to handle optional dependencies in Gradle.

#### What's happening:
1.  Gradle does not have a direct `optional` keyword like Maven.
2.  The most common way to simulate this is using `compileOnly`.
3.  Alternatively, Gradle offers "Feature Variants" (capabilities) for more advanced optionality, but `compileOnly` is the direct analog for "I need this to compile, but consumers don't need it."

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
`lib-a` will be present on the compile classpath. If you were to publish this project and consume it, `lib-a` would not be transitive.
