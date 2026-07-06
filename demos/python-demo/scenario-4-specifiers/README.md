### Python Scenario 4: Specifiers & Ranges (PEP 440)

Same package, three operators, three results: `>=1.0.0` → 2.0.0; `~=1.0` → 1.0.0; `!=2.0.0` → 1.0.0. `!=` is a native rejection operator (the JVM needs the enforcer plugin).

Verify: three fresh venvs, three resolved versions as above.
