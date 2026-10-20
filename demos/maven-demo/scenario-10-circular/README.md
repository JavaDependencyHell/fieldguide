### Maven Scenario 10: Circular Dependencies

This scenario shows how Maven handles a cycle between two published artifacts.

#### What's happening:
1.  `install_deps.sh` publishes `com.demo:lib-circle-a:1.0.0`, which depends on `lib-circle-b:1.0.0`, which depends back on `lib-circle-a:1.0.0`.
2.  We depend on `lib-circle-a`.
3.  Maven's resolver skips nodes already on the current path, so the cycle terminates. No error and **no warning** is printed; the tree just stops where it would repeat.

#### Two different cases:
- **Published artifacts (this demo):** resolved silently.
- **Modules of the same reactor build:** fail immediately with `The projects in the reactor contain a cyclic reference`, because Maven must order the modules to build them.

#### How to verify:
```bash
mvn dependency:tree
```

#### Expected Output:
`lib-circle-a:jar:1.0.0` with `lib-circle-b:jar:1.0.0` beneath it, no second `lib-circle-a`, and BUILD SUCCESS.
