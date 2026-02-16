### SBT Scenario 7: Dependency Configurations (Scopes)

This scenario demonstrates how SBT handles different dependency configurations (scopes).

#### What's happening:
1.  `lib-a` is declared without a specific configuration, so it defaults to `Compile` (available in compile, runtime, and test).
2.  `lib-b` is declared with `% Provided`. This means it is needed for compilation but is not transitive and not included in the runtime classpath (unless explicitly added).
3.  `lib-c` is declared with `% Test`. This means it is only available in the test classpath.

#### How to verify:
Run the following commands:

For compile/runtime classpath:
```bash
sbt "show externalDependencyClasspath"
```

For test classpath:
```bash
sbt "show test:externalDependencyClasspath"
```

#### Expected Output:
- `lib-a` will appear in both classpaths.
- `lib-b` will appear in the compile classpath (and test classpath) but is marked as provided.
- `lib-c` will only appear in the test classpath.
