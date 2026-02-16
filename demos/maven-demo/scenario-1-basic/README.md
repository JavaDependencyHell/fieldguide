### Maven Scenario 1: Basic Transitive Resolution

This scenario demonstrates how Maven handles basic transitive dependencies.

#### What's happening:
1.  We declare a direct dependency on `com.demo:lib-a:1.0.0`.
2.  `lib-a` depends on `lib-b`, and `lib-b` depends on `lib-c`.
3.  Maven automatically resolves and includes these transitive dependencies (`lib-b` and `lib-c`) in the project's classpath.

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
You will see `lib-a` at the top level, with `lib-b` and `lib-c` branched underneath it, indicating they are transitive dependencies.
