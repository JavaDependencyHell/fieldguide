### Maven Scenario 3: Dependency Management (BOM)

This scenario demonstrates how Maven uses `<dependencyManagement>` and Bill of Materials (BOM) to centralize dependency versions.

#### What's happening:
1.  We import the `demo-bom` in the `<dependencyManagement>` section. This defines a curated list of library versions.
2.  In the `<dependencies>` section, we declare `lib-a` and `lib-b` **without** specifying a version.
3.  Maven looks up the correct version to use from the imported BOM.

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
You will see that `lib-a` and `lib-b` are resolved to the versions specified in the `demo-bom` (1.0.0), even though we didn't explicitly define them in our direct dependencies.
