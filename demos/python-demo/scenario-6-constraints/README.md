### Python Scenario 6: Constraints Files (Central Version Control)

`demo-lib-c>=1.0.0` alone → 2.0.0; with `-c constraints.txt` pinning ==1.0.0 → 1.0.0. A constraints file caps resolution without adding a dependency (pip's BOM). uv: constraint-dependencies. Poetry: no constraints file — the pin lives in pyproject.toml.

Verify: pip 1.0.0 with the constraint and 2.0.0 without it (two fresh venvs); uv and Poetry lock 1.0.0.
