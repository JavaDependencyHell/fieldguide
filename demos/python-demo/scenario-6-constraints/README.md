### Python Scenario 6: Constraints Files (Central Version Control)

`demo-lib-c>=1.0.0` alone → 2.0.0; with `-c constraints.txt` pinning ==1.0.0 → 1.0.0. A constraints file caps resolution without adding a dependency (pip's BOM). uv: constraint-dependencies.

Verify: 1.0.0 with the constraint, 2.0.0 without.
