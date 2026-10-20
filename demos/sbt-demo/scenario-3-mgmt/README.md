### sbt Scenario 3: Dependency Management (Central Versions)

This scenario demonstrates how to manage dependency versions centrally in sbt, the role Maven's `<dependencyManagement>` plays.

#### What's happening:
1.  A single `val libVersion = "1.0.0"` holds the version.
2.  `lib-a` and `lib-b` are both declared against that `val`, so one edit moves both.
3.  `lib-a:1.0.0` also pulls in `lib-b:1.0.0` transitively, so the graph agrees and nothing is evicted.
4.  sbt 1.x cannot import a Maven BOM natively; the `here-sbt-bom` plugin can, and sbt 2.0 adds native BOM support. See scenario 16 for the `dependencyOverrides` emulation.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The classpath contains `lib-a/1.0.0`, `lib-b/1.0.0` and `lib-c/1.0.0`.
