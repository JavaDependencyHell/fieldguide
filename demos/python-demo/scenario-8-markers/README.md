### Python Scenario 8: Environment Markers (PEP 508)

Conditional dependencies: `demo-lib-c; python_version >= "3.8"` and `demo-lib-d; python_version < "3.8"`. The installed set depends on the interpreter.

Verify: on Python >= 3.8, demo-lib-c present and demo-lib-d absent.
