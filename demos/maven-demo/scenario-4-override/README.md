### Maven Scenario 4: Hardcoded Version vs Dependency Management

This scenario demonstrates how a direct version declaration in the `<dependencies>` section overrides the version defined in `<dependencyManagement>` (or an imported BOM).

#### What's happening:
1.  We import the `demo-bom:1.0.0` in the `<dependencyManagement>` section.
2.  We declare `lib-a` but explicitly set the version to **2.0.0**.
3.  We declare `lib-b` **without** a version, letting it be managed by the BOM.
4.  In Maven, a version specified in the direct dependency block takes precedence over the version suggested by `<dependencyManagement>`.

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
- `lib-a` will be resolved to version **2.0.0**.
- `lib-b` will be resolved to version **1.0.0** (from the BOM).
- This shows that you can "break out" of the managed versions by explicitly specifying a version.
