### Python Scenario 1: Basic Transitive Resolution

demo-lib-a → demo-lib-b → demo-lib-c. Installing the first pulls all three, in one environment (one version each).

Verify: `pip install -r pip/requirements.txt` (fresh venv), or `poetry install`, or `uv sync`. Expect demo-lib-c present.
