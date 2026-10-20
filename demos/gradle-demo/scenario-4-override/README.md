### Gradle Scenario 4: Hardcoded Version vs Platform

This scenario demonstrates how a `platform()` constraint and an explicit version declaration compete.

#### What's happening:
1.  We import `demo-bom:1.0.0` with `implementation platform(...)`; it constrains `lib-a`, `lib-b` and `lib-c` to `1.0.0`.
2.  We declare `lib-a:2.0.0` explicitly and `lib-b` without a version.
3.  The platform's `1.0.0` and the direct `2.0.0` both enter conflict resolution; the **highest** wins, so `lib-a` is `2.0.0`. A direct `0.9.0` would lose to the platform (downgrading needs `strictly`).
4.  `lib-a:2.0.0` transitively requests `lib-b:2.0.0`, which also beats the platform's `1.0.0`, so the versionless `lib-b` resolves to `2.0.0` too.

#### How to verify:
```bash
gradle dependencies --configuration compileClasspath
gradle dependencyInsight --dependency lib-a --configuration compileClasspath
```

#### Expected Output:
- Tree: the platform's entries show `com.demo:lib-a:1.0.0 -> 2.0.0 (c)` (and the same for `lib-b`, `lib-c`); `com.demo:lib-a:2.0.0` with `lib-b:2.0.0` beneath it; `com.demo:lib-b -> 2.0.0 (*)`.
- Insight: `by conflict resolution: between versions 2.0.0 and 1.0.0`.
