### SBT Scenario 13: Variants and Configurations

This scenario discusses SBT's configuration-based variant selection.

#### What's happening:
1.  SBT maps Maven scopes to Ivy configurations (Compile, Runtime, Test, Provided, Optional).
2.  You can also define custom configurations (e.g., `IntegrationTest`).
3.  While it doesn't have Gradle's attribute-based matching, it offers powerful control over which artifacts are fetched via `classpathTypes` and `updateOptions`.

#### How to verify:
This is a placeholder scenario to acknowledge the capability.
