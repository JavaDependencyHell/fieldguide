### Maven Scenario 6: Forcing a Transitive Version

This scenario demonstrates how to use `<dependencyManagement>` to force a specific version of a deep transitive dependency.

#### What's happening:
1.  We depend on `lib-a:1.0.0`, which transitively depends on `lib-b:1.0.0`, which in turn depends on `lib-c:1.0.0`.
2.  We want version **2.0.0** of `lib-c` used throughout the project instead of the transitively requested `1.0.0`.
3.  Placing `lib-c:2.0.0` in `<dependencyManagement>` tells Maven: "Whenever you encounter `lib-c` as a transitive dependency, use this version."
4.  This is the standard pattern for patching transitive dependencies without declaring them directly.

#### How to verify:
Run the following command in this directory:
```bash
mvn dependency:tree -Dverbose
```

#### Expected Output:
`lib-c` resolves to `2.0.0`. With `-Dverbose`, the line under `lib-b` reads:
```
com.demo:lib-c:jar:2.0.0:compile (version managed from 1.0.0)
```
Without `-Dverbose` you see only the winning `2.0.0`.
