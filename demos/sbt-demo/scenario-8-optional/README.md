### sbt Scenario 8: Optional Dependencies

This scenario demonstrates how sbt treats a dependency that a library marked optional in its POM.

#### What's happening:
1.  We depend on `lib-d:1.0.0`.
2.  `lib-d`'s POM declares `lib-c:1.0.0` with `<optional>true</optional>`.
3.  Coursier honours the flag: `lib-c` is not resolved for consumers of `lib-d`. If we need `lib-d`'s optional feature, we declare `lib-c` ourselves.
4.  To mark a dependency optional in a library you publish, declare it `% Optional`; sbt writes `<optional>true</optional>` into the generated POM.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The classpath contains `lib-d/1.0.0` and does not contain `lib-c`.
