### Gradle Scenario 14: Rejecting Versions

This scenario demonstrates removing a known-bad version from the candidate pool without pinning.

#### What's happening:
1.  We require `lib-a` in the range `[1.0.0, 3.0.0)`. The repository has `1.0.0` and `2.0.0`, so the range alone resolves to `2.0.0`.
2.  `reject '2.0.0'` removes that version from the candidates. Highest-wins then selects `1.0.0`.
3.  Unlike `force '1.0.0'`, the rejection still allows a future `2.0.1` or `2.1.0`.

#### How to verify:
```bash
gradle dependencies --configuration compileClasspath
gradle dependencyInsight --dependency lib-a --configuration compileClasspath
```

#### Expected Output:
- Tree: `com.demo:lib-a:{require [1.0.0, 3.0.0); reject 2.0.0} -> 1.0.0`.
- Insight: selection reason `Was requested: rejected version 2.0.0`.
- Comment out the `reject` line and the same build resolves `2.0.0`.
