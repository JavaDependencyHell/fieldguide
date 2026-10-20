### Maven Scenario 8: Optional Dependencies

This scenario demonstrates `<optional>true</optional>` from the consumer's side.

#### What's happening:
1.  `com.demo:lib-d:1.0.0` (a fixture published by `install_deps.sh`) declares `lib-c:1.0.0` in its own POM with `<optional>true</optional>`.
2.  We depend on `lib-d`. Because the optional flag is honoured for consumers, `lib-c` does **not** reach our classpath.
3.  The `with-feature` profile shows the opt-in: declare `lib-c` yourself if you use the feature that needs it.

#### How to verify:
```bash
mvn dependency:tree
mvn dependency:tree -Pwith-feature
```

#### Expected Output:
First run: `com.demo:lib-d:jar:1.0.0` alone, no `lib-c`.
Second run: `lib-d` and `lib-c:jar:1.0.0` as a direct dependency.
