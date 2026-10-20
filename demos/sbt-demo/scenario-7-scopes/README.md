### sbt Scenario 7: Dependency Configurations (Scopes)

This scenario demonstrates how sbt's dependency configurations control which classpath a dependency reaches.

#### What's happening:
1.  `lib-a` is declared without a configuration, so it is `Compile`: on the compile, runtime and test classpaths, and transitive to consumers. It brings `lib-b` and `lib-c`.
2.  `lib-d` is declared `% Provided`: on the compile and test classpaths, but not the runtime classpath.
3.  `lib-circle-a` is declared `% Test`: on the test classpath only (with its own transitive `lib-circle-b`).
4.  The trap: `lib-b` is *also* declared `% Provided`, but `lib-a` needs it at `Compile`, so Coursier keeps `lib-b` on the runtime classpath anyway. A narrower direct configuration does not demote a transitive edge (Maven's nearest-wins scope mediation would).

#### How to verify:
```bash
sbt "show Compile / externalDependencyClasspath"
sbt "show Runtime / externalDependencyClasspath"
sbt "show Test / externalDependencyClasspath"
```

#### Expected Output:
- Compile: `lib-a`, `lib-b`, `lib-c`, `lib-d`.
- Runtime: `lib-a`, `lib-b`, `lib-c` (no `lib-d`; `lib-b` is still there).
- Test: all of the above plus `lib-circle-a` and `lib-circle-b`.
