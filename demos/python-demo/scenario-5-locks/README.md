### Python Scenario 5: Lock Files

One loosely-pinned input; five ways to freeze it. pip has no native lock (pip freeze snapshots; pip-tools compiles); poetry.lock and uv.lock are native; PEP 751 pylock.toml is the emerging standard (pip lock, uv export).

Verify: each artifact records the transitive demo-lib-c.
