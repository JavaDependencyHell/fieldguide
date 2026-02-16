### Gradle Scenario 6: Strict Constraints / Forced Versions

This scenario demonstrates Gradle's rich version constraints, specifically the `strictly` keyword.

#### What's happening:
1.  We depend on `lib-a:2.0.0`, which transitively depends on `lib-c:2.0.0`.
2.  We want to force the project to use version **1.0.0** of `lib-c` regardless of what other libraries request.
3.  We use a `constraints` block with the `strictly` keyword.
4.  The `strictly` constraint is one of Gradle's "Rich Version" features. It tells Gradle: "Use this version exactly. Do not upgrade even if another dependency requests a higher version."

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
In the dependency tree, you will see `com.demo:lib-c:2.0.0 -> 1.0.0`. This shows that the transitive version 2.0.0 was downgraded to 1.0.0 because of the strict constraint. You will also see the reason: `forcing a downgrade to a known stable version`.
