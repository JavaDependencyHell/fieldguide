### Gradle Scenario 15: Dependency Substitution

This scenario demonstrates how to swap one dependency for another.

#### What's happening:
1.  We depend on `lib-a:1.0.0`.
2.  We use `resolutionStrategy.dependencySubstitution` to tell Gradle: "Whenever you see `lib-a:1.0.0`, replace it with `lib-a:2.0.0`".
3.  This is powerful for replacing a library with a fork, or upgrading a transitive dependency globally.

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
You will see `lib-a:1.0.0 -> 2.0.0` in the tree, indicating the substitution happened.
