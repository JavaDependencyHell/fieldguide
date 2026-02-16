
### Maven Scenario 5: Dependency Exclusions

This scenario demonstrates how to manually exclude a transitive dependency in Maven.

#### What's happening:
1.  We declare a dependency on `com.demo:lib-a:1.0.0`.
2.  Normally, `lib-a` pulls in `lib-b` and `lib-c` as transitive dependencies.
3.  We use the `<exclusions>` block within the `<dependency>` declaration to tell Maven NOT to include `lib-c`.
4.  This is useful when a library pulls in an unwanted transitive dependency that conflicts with your project.

#### How to verify:
Run the following command in this directory:
```bash
mvn dependency:tree
```

To see the actual classpath:
```bash
mvn dependency:build-classpath
```

#### Expected Output:
In the `dependency:tree` output, you will see `lib-a` and `lib-b`, but `lib-c` will be missing from the tree.
