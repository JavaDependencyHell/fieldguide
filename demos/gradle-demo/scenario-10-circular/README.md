### Gradle Scenario 10: Circular Dependencies

This scenario demonstrates how Gradle resolves a cycle between two external artifacts.

#### What's happening:
1.  We depend on `lib-circle-a:1.0.0`, which depends on `lib-circle-b:1.0.0`, which depends back on `lib-circle-a:1.0.0` (both published by `install_deps.sh`).
2.  Gradle tracks visited modules and stops following the branch when it meets `lib-circle-a` again. Resolution succeeds; both jars are on the classpath; there is no warning.
3.  The case that *does* fail is a cycle between **projects** in a multi-project build (a circular task graph). Maven draws the same line: external cycles resolve silently, reactor cycles fail.

#### How to verify:
```bash
gradle dependencies --configuration compileClasspath
```

#### Expected Output:
```
\--- com.demo:lib-circle-a:1.0.0
     \--- com.demo:lib-circle-b:1.0.0
          \--- com.demo:lib-circle-a:1.0.0 (*)
```
The `(*)` marks a repeated subtree. The build does not fail.
