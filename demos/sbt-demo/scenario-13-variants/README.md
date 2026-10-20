### sbt Scenario 13: Variants and Classifiers

This scenario demonstrates how sbt selects a specific flavour of a library using a classifier.

#### What's happening:
1.  `lib-a:1.0.0` is published with two artifacts: the default JAR and a `jdk11`-classified JAR (installed by `install_deps.sh`).
2.  `classifier "jdk11"` asks for `lib-a-1.0.0-jdk11.jar` instead of the default artifact.
3.  The POM is shared, so `lib-b` and `lib-c` still arrive transitively.
4.  sbt has no attribute-based variant matching like Gradle; classifiers are opaque strings, and the `%%` operator handles the one variant dimension the Scala ecosystem cares about most, the Scala binary version.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The classpath contains `lib-a-1.0.0-jdk11.jar` (not `lib-a-1.0.0.jar`), plus `lib-b` and `lib-c`.
