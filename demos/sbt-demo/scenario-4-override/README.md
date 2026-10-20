### sbt Scenario 4: Hardcoded Version vs Managed Default

This scenario demonstrates what a hardcoded version in `libraryDependencies` does and does not override.

#### What's happening:
1.  A `val defaultVersion = "1.0.0"` plays the role of a managed default.
2.  `lib-a` is hardcoded to **2.0.0**, breaking away from the default; `lib-b` uses the default **1.0.0**.
3.  `lib-a:2.0.0` transitively requires `lib-b:2.0.0`. The direct `lib-b:1.0.0` and the transitive `lib-b:2.0.0` enter Coursier's conflict resolution, and the highest version wins.
4.  Result: `lib-a:2.0.0` and `lib-b:2.0.0`. The hardcoded version beat the *default*, but the direct `lib-b` declaration did not beat *resolution*. Only `dependencyOverrides` can do that (scenario 6).

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
- The classpath contains `lib-a/2.0.0` and `lib-b/2.0.0`; `lib-b/1.0.0` is absent.
- `sbt evicted` reports `lib-b:1.0.0` evicted by `2.0.0`.
