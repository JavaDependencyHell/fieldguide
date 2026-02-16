### Maven Scenario 2: Version Conflict Resolution (Nearest Wins)

This scenario demonstrates Maven's "Nearest Wins" strategy for resolving version conflicts.

#### What's happening:
1.  We have a direct dependency on `com.demo:lib-a:2.0.0`.
2.  `lib-a:2.0.0` transitively depends on `com.demo:lib-b:2.0.0` (Distance 2).
3.  We also have a direct dependency on `com.demo:lib-b:1.0.0` (Distance 1).
4.  Because `lib-b:1.0.0` is closer to the project root (Distance 1 vs Distance 2), Maven chooses version **1.0.0**, even though it's older than the transitive version **2.0.0**.

#### How to verify:
Run the following command in this directory:
```bash
mvn dependency:tree
```

To see the actual classpath that will be used:
```bash
mvn dependency:build-classpath
```

#### Expected Output:
Look for `lib-b`. You will see version `1.0.0` selected. Under `lib-a`, you will see that `lib-b:2.0.0` was omitted for conflict.
