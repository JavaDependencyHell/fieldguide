### Maven Scenario 12: Rich Version Metadata

This scenario demonstrates a limitation: the POM cannot express rich constraints like "prefer 1.5, accept [1.0,2.0)" or "strictly 1.3.0".

#### What's happening:
1.  The POM declares a plain pinned `lib-a:1.0.0` — that is all the POM format lets you say.
2.  Gradle's rich versions (`prefer`/`strictly`/`reject`) have no Maven equivalent; the enforcer plugin approximates some checks post-resolution.

#### How to verify:
1.  Run `mvn dependency:tree`.
2.  `lib-a:1.0.0` and its transitive `lib-b:1.0.0` resolve — with no way to attach preference or rejection metadata.

#### Expected Output:
`com.demo:lib-a:jar:1.0.0` and `com.demo:lib-b:jar:1.0.0` in the tree.
