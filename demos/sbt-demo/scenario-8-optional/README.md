### SBT Scenario 8: Optional Dependencies

This scenario discusses optional dependencies in SBT.

#### What's happening:
1.  SBT (via Ivy) respects the `<optional>true</optional>` flag in Maven POMs.
2.  If we depend on a library that has an optional dependency, SBT will NOT include that optional dependency transitively.
3.  In this demo, we depend on `lib-a`. If `lib-a` were published with an optional dependency, it would be excluded. Since we are just declaring `lib-a` here, this scenario mainly serves to show that `lib-a` itself is included normally.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
`lib-a` is present.
