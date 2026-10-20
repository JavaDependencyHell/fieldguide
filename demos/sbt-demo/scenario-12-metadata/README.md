### sbt Scenario 12: Customizing Metadata

This scenario demonstrates how to work around incorrect upstream metadata in sbt.

#### What's happening:
1.  `lib-a:1.0.0`'s POM declares `lib-b:1.0.0`. We are treating that declaration as wrong: `lib-a` should have declared `lib-b:2.0.0`.
2.  sbt has no equivalent of Gradle's component metadata rules, so the patch is applied in the build: exclude `lib-b` from `lib-a`, then declare `lib-b:2.0.0` directly.
3.  `lib-b:2.0.0` brings `lib-c:2.0.0`, so the whole subtree moves to the corrected version.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The classpath contains `lib-a/1.0.0`, `lib-b/2.0.0` and `lib-c/2.0.0`; `lib-b/1.0.0` is absent.
