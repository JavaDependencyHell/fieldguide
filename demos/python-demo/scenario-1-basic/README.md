# Scenario P1: Basic Transitive Resolution

Demonstrates that pip/poetry/uv resolve transitive dependencies automatically.

## Setup
- Direct dependency: `lib-a==1.0.0`
- lib-a 1.0.0 depends on `lib-b>=1.0.0,<2.0.0`
- lib-b 1.0.0 depends on `lib-c>=1.0.0,<2.0.0`

## Expected Result
All three packages installed: lib-a 1.0.0, lib-b 1.0.0, lib-c 1.0.0

## Tool Versions
This behavior is consistent across **all pip versions**, **poetry ≥ 1.0**, and **uv ≥ 0.1**.
Transitive resolution is fundamental — no version-specific differences here.

## Java Developer Surprise Factor: LOW
This works the same way as Maven and Gradle. The happy path is universal.

## Run manually

### pip
```bash
python -m venv .venv && source .venv/bin/activate
pip install --find-links=../../target/python-repo --no-index lib-a==1.0.0
pip list
```

### poetry
```bash
poetry install
poetry show
```

### uv
```bash
uv sync
uv pip list
```
