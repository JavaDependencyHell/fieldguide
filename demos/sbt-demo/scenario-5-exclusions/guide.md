# Scenario 5: Dependency Exclusions

## What This Scenario Demonstrates
This scenario demonstrates exclusions in SBT.

## Dependency Graph
Exclude `lib-c`.

### SBT (build.sbt)

```{.scala include="/demos/sbt-demo/scenario-5-exclusions/build.sbt" snippet="s5-deps"}
```

## Expected Intuition
`lib-c` gone.

## Actual Resolution Results
*   **SBT**: Excluded.

## Classpath Reality
Missing.

## Why This Happens
Exclusion metadata.

## How Developers Commonly "Fix" This
N/A

## Safer Ways to Take Control
N/A

## Signals to Watch For
N/A

## How This Scales in Real Systems
N/A

## Key Takeaway
Exclusions work.

## Related Scenarios
N/A
