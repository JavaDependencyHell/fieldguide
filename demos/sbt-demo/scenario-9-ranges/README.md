### sbt Scenario 9: Version Ranges

This scenario demonstrates sbt's support for version ranges.

#### What's happening:
1.  We declare a dependency on `lib-a` with the range `[1.0.0,2.0.0)`.
2.  Coursier reads the repository's `maven-metadata.xml`, finds the versions `1.0.0` and `2.0.0`, and picks the highest inside the range.
3.  The result depends on what the repository contains today. Publish `1.1.0` tomorrow and the same build file resolves differently.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
`lib-a/1.0.0` (because `2.0.0` is outside the range).
