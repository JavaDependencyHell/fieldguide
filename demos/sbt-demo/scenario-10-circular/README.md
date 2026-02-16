### SBT Scenario 10: Circular Dependencies

This scenario demonstrates SBT's handling of circular dependencies.

#### What's happening:
1.  We depend on `lib-circle-a`, which depends on `lib-circle-b`, which depends back on `lib-circle-a`.
2.  SBT/Ivy generally handles this by detecting the cycle and stopping recursion.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The build should succeed, and the classpath should contain both `lib-circle-a` and `lib-circle-b`.
