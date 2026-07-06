### Python Scenario 9: Exclusions — The Gap

demo-lib-a -> demo-lib-b -> demo-lib-c. pip and Poetry have NO way to exclude a transitive. uv's override-dependencies can change demo-lib-c's version (to 2.0.0) but not remove it.

Verify: demo-lib-c always present; 2.0.0 under uv's override.
