### Gradle Scenario 7: Dependency Configurations (Scopes)

This scenario demonstrates which classpaths each declarable configuration feeds.

#### What's happening:
1.  `implementation 'com.demo:lib-c:1.0.0'`: compile and runtime (Maven `compile`).
2.  `compileOnly 'com.demo:lib-d:1.0.0'`: compile classpath only (Maven `provided`).
3.  `testImplementation 'com.demo:lib-a:1.0.0'`: test classpaths only (Maven `test`); it brings `lib-b` and `lib-c` with it.
4.  A configuration governs the *declaration*, not the module: if an `implementation` dependency transitively needed `lib-d`, `lib-d` would still reach the runtime classpath.

#### How to verify:
```bash
gradle dependencies --configuration compileClasspath
gradle dependencies --configuration runtimeClasspath
gradle dependencies --configuration testRuntimeClasspath
```
(`compileOnly` itself is not resolvable; asking for it only lists what was declared.)

#### Expected Output:
- `compileClasspath`: `lib-c` and `lib-d`.
- `runtimeClasspath`: `lib-c` only.
- `testRuntimeClasspath`: `lib-c`, and `lib-a` with `lib-b` and `lib-c` beneath it.
