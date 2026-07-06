### Maven Scenario 15: Version Substitution

This scenario demonstrates replacing one library with another: exclusion + explicit replacement (Maven has no substitution mechanism).

#### What's happening:
1.  `log4j:log4j` is excluded from `lib-a`.
2.  `org.slf4j:log4j-over-slf4j` is declared as the drop-in replacement (fetched from Maven Central — first run needs network).

#### How to verify:
1.  Run `mvn dependency:tree`.
2.  `log4j-over-slf4j` is present; `log4j:log4j` is absent.

#### Expected Output:
`org.slf4j:log4j-over-slf4j` in the tree, no `log4j:log4j`.
