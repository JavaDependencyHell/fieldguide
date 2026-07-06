### Maven Scenario 13: Feature Variants (Classifiers)

This scenario demonstrates Maven's only variant mechanism: classifiers.

#### What's happening:
1.  The POM requests `lib-a:1.0.0` with the `jdk11` classifier.
2.  Classifiers are opaque strings — no attribute matching, no automatic selection (unlike Gradle variants).
3.  `install_deps.sh` publishes a `lib-a-1.0.0-jdk11.jar` alongside the main jar so the demo resolves.

#### How to verify:
1.  Run `mvn dependency:tree`.
2.  The tree shows the classified artifact: `com.demo:lib-a:jar:jdk11:1.0.0`.

#### Expected Output:
`com.demo:lib-a:jar:jdk11:1.0.0` in the tree.
