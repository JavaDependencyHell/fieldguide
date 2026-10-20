### sbt Scenario 10: Circular Dependencies

This scenario demonstrates sbt's handling of a cycle between external libraries.

#### What's happening:
1.  We depend on `lib-circle-a`, which depends on `lib-circle-b`, which depends back on `lib-circle-a`.
2.  Coursier detects that it has already visited `lib-circle-a` and stops. Both artifacts land on the classpath; nothing is reported.
3.  A cycle between *sub-projects* of the same build is a different matter: sbt refuses to load the build ("cyclic reference").

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The build succeeds, and the classpath contains both `lib-circle-a` and `lib-circle-b`. No warning is printed.
