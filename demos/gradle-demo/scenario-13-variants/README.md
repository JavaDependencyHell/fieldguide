### Gradle Scenario 13: Variant Selection (Classifiers vs Attributes)

This scenario demonstrates selecting a published flavour of a library, and the difference between a Maven classifier and a Gradle variant.

#### What's happening:
1.  `lib-a:1.0.0` is published twice by `install_deps.sh`: `lib-a-1.0.0.jar` and `lib-a-1.0.0-jdk11.jar` (classifier `jdk11`). There is no Gradle Module Metadata, so there are no attribute-matched variants.
2.  We request `com.demo:lib-a:1.0.0:jdk11`. Gradle selects that *file*; the dependency graph is unchanged and the tree does not mention the classifier.
3.  With Gradle Module Metadata, the producer would publish variants with attributes (e.g. `org.gradle.jvm.version`) and Gradle would match them automatically. `dependencyInsight` shows the attributes the consumer requests.

#### How to verify:
```bash
gradle printRuntimeJars
gradle dependencies --configuration compileClasspath
```

#### Expected Output:
- `printRuntimeJars`: `JAR lib-a-1.0.0-jdk11.jar` (plus `lib-b-1.0.0.jar`, `lib-c-1.0.0.jar`).
- Tree: `com.demo:lib-a:1.0.0` with no classifier shown. Remove `:jdk11` from the build and `printRuntimeJars` shows `lib-a-1.0.0.jar` instead.
