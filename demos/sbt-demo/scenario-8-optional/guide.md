# Scenario 8: Optional Dependencies

## What This Scenario Demonstrates
This scenario demonstrates optional dependencies in SBT.

## Dependency Graph
Optional dep.

### SBT (build.sbt)

```{.scala include="/demos/sbt-demo/scenario-8-optional/build.sbt" snippet="s8-deps"}
```

## Expected Intuition
Not transitive.

## Actual Resolution Results
*   **SBT**: Respects optional.

## Classpath Reality
Not transitive.

## Why This Happens
Ivy metadata.

## How Developers Commonly "Fix" This
N/A

## Safer Ways to Take Control
N/A

## Signals to Watch For
N/A

## How This Scales in Real Systems
N/A

## Key Takeaway
Optional works.

## Related Scenarios
N/A
