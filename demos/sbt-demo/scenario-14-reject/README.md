### SBT Scenario 14: Rejecting Versions

This scenario discusses how to reject versions in SBT.

#### What's happening:
1.  SBT does not have a direct "reject" syntax in `libraryDependencies`.
2.  To achieve rejection, you typically use `dependencyOverrides` to force a safe version, or use `exclude` to remove the bad version if it's coming transitively.
3.  You can also write custom eviction rules in `evictionWarningOptions`.

#### How to verify:
This is a placeholder scenario to acknowledge the capability.
