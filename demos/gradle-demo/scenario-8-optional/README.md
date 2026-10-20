### Gradle Scenario 8: Optional Dependencies

This scenario demonstrates how Gradle handles a Maven `<optional>` dependency as a consumer, and how a Gradle library expresses the same thing as a producer.

#### What's happening:
1.  `lib-d:1.0.0` (fixture, see `demo-dependencies/lib-d`) declares `lib-c:1.0.0` with `<optional>true</optional>`.
2.  We depend on `lib-d`. Gradle honours the flag: `lib-c` does not reach our classpaths.
3.  The producer side: `java { registerFeature('reporting') { ... } }` declares a feature variant with its own source set; `reportingImplementation 'com.demo:lib-c:1.0.0'` attaches `lib-c` to the feature only. Consumers opt in with `requireCapability`.

#### How to verify:
```bash
gradle dependencies --configuration runtimeClasspath
gradle dependencies --configuration reportingRuntimeClasspath
gradle printRuntimeJars
gradle outgoingVariants --variant reportingRuntimeElements
```

#### Expected Output:
- `runtimeClasspath`: `lib-d:1.0.0` and nothing beneath it.
- `reportingRuntimeClasspath`: `lib-c:1.0.0`.
- `printRuntimeJars`: `JAR lib-d-1.0.0.jar` only.
- `outgoingVariants`: capability `:gradle-scenario-8-optional-reporting`.
