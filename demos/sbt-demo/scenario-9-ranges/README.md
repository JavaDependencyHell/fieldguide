### SBT Scenario 9: Version Ranges

This scenario demonstrates SBT's support for version ranges.

#### What's happening:
1.  We declare a dependency on `lib-a` with the range `[1.0.0,2.0.0)`.
2.  SBT passes this range to Ivy, which resolves it against the repository.
3.  It should pick the highest version that satisfies the range.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
SBT will resolve to `1.0.0` (since 2.0.0 is excluded).
