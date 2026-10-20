### Python Scenario 9: Exclusions — The Gap

demo-lib-a -> demo-lib-b -> demo-lib-c. pip and Poetry have NO way to exclude a
transitive: demo-lib-c is always installed. uv has two levers:
`override-dependencies` changes demo-lib-c's version (to 2.0.0, `uv/`) and
`exclude-dependencies` (uv 0.9.8+) removes it from the graph entirely
(`uv-exclude/`).

Verify: demo-lib-c present under pip and Poetry; 2.0.0 under the uv override;
absent (and demo-lib-b still installed) under the uv exclusion.
