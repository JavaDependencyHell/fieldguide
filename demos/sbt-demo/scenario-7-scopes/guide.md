# Scenario 7: Dependency Configurations

## What This Scenario Demonstrates
This scenario demonstrates SBT configurations (`Compile`, `Test`, `Provided`).

## Dependency Graph
Standard scopes.

### SBT (build.sbt)

```{.scala include="/demos/sbt-demo/scenario-7-scopes/build.sbt" snippet="s7-deps"}
```

## Expected Intuition
Provided not in runtime.

## Actual Resolution Results
*   **SBT**: Respects configurations.

## Classpath Reality
Correct separation.

## Why This Happens
Ivy configurations.

## How Developers Commonly "Fix" This
N/A

## Safer Ways to Take Control
N/A

## Signals to Watch For
N/A

## How This Scales in Real Systems
N/A

## Key Takeaway
Configurations control visibility.

## Related Scenarios
*   [Scenario 8: Optional](../scenario-8-optional/guide.md)
