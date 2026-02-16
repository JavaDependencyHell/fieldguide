### Gradle Scenario 4: Hardcoded Version vs Platform

This scenario demonstrates how Gradle handles the interaction between a `platform()` (BOM) and an explicit version declaration.

#### What's happening:
1.  We import the `demo-bom:1.0.0` using `implementation platform(...)`.
2.  We declare `lib-a:2.0.0` with an explicit version.
3.  We declare `lib-b` without a version.

#### Gradle's Behavior:
In this specific setup:
- We specify `2.0.0` and the platform recommends `1.0.0`. Gradle will select **2.0.0** because it's newer.
- For `lib-b`, it will use **1.0.0** from the platform.
- This demonstrates "Newest Wins" logic combined with Platform recommendations.

#### How to verify:
Run the following command in this directory:
```bash
./gradlew dependencies --configuration compileClasspath
```

#### Expected Output:
You will see that `lib-a` is resolved to **2.0.0** and `lib-b` is resolved to **1.0.0**.
