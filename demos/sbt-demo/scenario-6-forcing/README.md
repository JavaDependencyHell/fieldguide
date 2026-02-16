### SBT Scenario 6: Strict Constraints / Forced Versions

This scenario demonstrates how to use `dependencyOverrides` in SBT to force a specific version of a transitive dependency.

#### What's happening:
1.  We depend on `lib-a:1.0.0`.
2.  `lib-a` pulls in `lib-b`, which pulls in `lib-c:1.0.0`.
3.  We add `com.demo:lib-c:2.0.0` to the `dependencyOverrides` setting.
4.  SBT will now use this version for `lib-c`, regardless of what other libraries in the dependency graph request.

#### How to verify:
Run the following command in this directory:
```bash
sbt "show externalDependencyClasspath"
```

#### Expected Output:
The output will show that version **2.0.0** of `lib-c` is used in the classpath. You can also run `sbt evicted` to see the details.
