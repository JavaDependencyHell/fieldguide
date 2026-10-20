### Gradle Scenario 6: Forcing a Version

This scenario demonstrates forcing a transitive dependency to a version nothing in the graph requested.

#### What's happening:
1.  We depend on `lib-a:1.0.0`, which transitively brings `lib-b:1.0.0` and `lib-c:1.0.0`.
2.  `configurations.all { resolutionStrategy { force 'com.demo:lib-c:2.0.0' } }` replaces every request for `lib-c` with `2.0.0`.
3.  The modern equivalent is a `strictly` constraint in a `constraints` block; it is scoped to the dependency and published with your module metadata.

#### How to verify:
```bash
gradle dependencies --configuration compileClasspath
gradle dependencyInsight --dependency lib-c --configuration compileClasspath
```

#### Expected Output:
The tree shows `com.demo:lib-c:1.0.0 -> 2.0.0` under `lib-b`. The insight report shows `com.demo:lib-c:2.0.0 (forced)`. Comment out the `force` line and `lib-c` returns to `1.0.0`.
