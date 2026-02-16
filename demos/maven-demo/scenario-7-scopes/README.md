### Maven Scenario 7: Dependency Scopes

This scenario demonstrates how different dependency scopes affect the classpath and transitivity.

#### What's happening:
1.  `lib-a` is declared with default (compile) scope. It will be available on all classpaths and transitive to dependents.
2.  `lib-b` is declared with `provided` scope. It is available for compilation but is not transitive and not packaged (the runtime environment is expected to provide it).
3.  `lib-c` is declared with `test` scope. It is only available during compilation and execution of tests.

#### How to verify:
Run the following command in this directory:
```bash
mvn dependency:tree
```

To see the compile classpath:
```bash
mvn dependency:build-classpath -Dmdep.outputFile=cp-compile.txt
cat cp-compile.txt
```

To see the test classpath:
```bash
mvn dependency:build-classpath -DincludeScope=test -Dmdep.outputFile=cp-test.txt
cat cp-test.txt
```

#### Expected Output:
- `dependency:tree` will show the scopes next to the artifacts (e.g., `:provided`, `:test`).
- `lib-b` will appear in the compile classpath but would not be transitive if another project depended on this one.
- `lib-c` will only appear in the test classpath.
