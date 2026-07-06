### Python Scenario 2: The Diamond (Conflicting Requirements)

demo-lib-a 2.0.0 needs demo-lib-c 2.0.0; we also pin demo-lib-c 1.0.0. One environment cannot hold both, so the install FAILS (no eviction, unlike the JVM).

Verify: install/lock exits non-zero with a conflict message; nothing is installed.
