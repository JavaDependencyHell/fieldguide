# Scenario 9: Version Ranges

## What This Scenario Demonstrates
This scenario demonstrates SBT ranges.

## Dependency Graph
Range.

### SBT (build.sbt)

```{.scala include="/demos/sbt-demo/scenario-9-ranges/build.sbt" snippet="s9-deps"}
```

## Expected Intuition
Highest match.

## Actual Resolution Results
*   **SBT**: Resolves highest.

## Classpath Reality
Highest.

## Why This Happens
Ivy ranges.

## How Developers Commonly "Fix" This
N/A

## Safer Ways to Take Control
Locking.

## Signals to Watch For
N/A

## How This Scales in Real Systems
N/A

## Key Takeaway
Ranges work.

## Related Scenarios
*   [Scenario 11: Locking](../scenario-11-locking/guide.md)
