### Maven Scenario 10: Circular Dependencies

This scenario discusses how Maven handles circular dependencies.

#### What's happening:
A circular dependency occurs when Project A depends on Project B, and Project B depends on Project A (A -> B -> A).

#### Behavior:
1.  **Build Time**: If you have a multi-module project with a cycle (Module A depends on Module B, Module B depends on Module A), Maven will fail the build immediately with a "The projects in the reactor contain a cyclic reference" error.
2.  **Runtime/Resolution**: If the cycle is via binary dependencies (jars in a repo), Maven can sometimes tolerate it by stopping the recursion when it encounters a project it has already visited. However, this is considered bad practice and can lead to `StackOverflowError` or unpredictable classpath ordering.

#### How to verify:
This scenario is primarily for documentation, as creating a real cycle requires modifying the deployed artifacts in the local repo to point back to this project, which is complex to set up in this static demo environment.

#### Expected Output:
If you were to introduce a cycle in a multi-module build, you would see:
`[ERROR] The projects in the reactor contain a cyclic reference: ...`
