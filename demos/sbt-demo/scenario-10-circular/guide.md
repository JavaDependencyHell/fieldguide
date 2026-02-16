# Scenario 10: Circular Dependencies

## What This Scenario Demonstrates
This scenario demonstrates SBT cycles.

## Dependency Graph
Cycle.

### SBT (build.sbt)

```{.scala include="/demos/sbt-demo/scenario-10-circular/build.sbt" snippet="s10-deps"}
```

## Expected Intuition
Works.

## Actual Resolution Results
*   **SBT**: Tolerates.

## Classpath Reality
Both present.

## Why This Happens
Visited set.

## How Developers Commonly "Fix" This
N/A

## Safer Ways to Take Control
N/A

## Signals to Watch For
N/A

## How This Scales in Real Systems
N/A

## Key Takeaway
Cycles tolerated.

## Related Scenarios
N/A
