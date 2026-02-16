### Maven Scenario 6: Strict Constraints / Forced Versions

This scenario demonstrates how to use `<dependencyManagement>` to force a specific version of a deep transitive dependency.

#### What's happening:
1.  We depend on `lib-a:1.0.0`, which transitively depends on `lib-b:1.0.0`, which in turn depends on `lib-c:1.0.0`.
2.  We want to ensure that version **2.0.0** of `lib-c` is used throughout the project instead of the transitively requested `1.0.0`.
3.  By placing `lib-c:2.0.0` in the `<dependencyManagement>` section, we tell Maven: "Whenever you encounter `lib-c` as a transitive dependency, use this version."
4.  This is a common pattern for "patching" transitive dependencies without having to declare them as direct dependencies.

#### How to verify:
Run the following command in this directory:
```bash
mvn dependency:tree
```

#### Expected Output:
In the output, search for `lib-c`. You will see it resolved to `2.0.0`. If you look at where it's pulled in from `lib-b`, you'll see `(version managed from 2.0.0)`, indicating the override is active.
