### Python Scenario 10: Virtual Environment Isolation

demo-lib-a 1.0.0 in one venv, 2.0.0 in another; the global interpreter has neither. The environment is the unit of truth — most "works in dev, breaks in prod" bugs live here.

Verify: two versions coexist in separate venvs; `import demo_lib_a` fails in global Python.
