#!/bin/bash

# verify.sh — Python scenario verification (pip / Poetry / uv)
#
# Every scenario is verified in a FRESH throwaway virtualenv per tool —
# in Python the environment IS the resolution result, so shared state
# would corrupt the checks (see scenario 10).
#
# Fixtures come from two local PEP 503 indexes built by install_python_deps.sh:
#   public  : target/python-repo         served on http://127.0.0.1:8765/
#   private : target/python-private-repo served on http://127.0.0.1:8766/
#
# Usage: ./verify.sh [scenario-number]   (no arg = run all)

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[m'

PROJECT_ROOT=$(cd ../.. && pwd)
PUB_REPO="$PROJECT_ROOT/target/python-repo"
PRIV_REPO="$PROJECT_ROOT/target/python-private-repo"
ONLY="${1:-}"

# ---------- prerequisites: fail loudly, never vacuously ----------
# The book documents pip, Poetry AND uv, so verifying the book requires all
# three. A missing tool is a hard failure (consistent with the Maven/Gradle/SBT
# verify scripts) — never a silent or skipped column.
MISSING=""
command -v python3 > /dev/null 2>&1 || MISSING="$MISSING python3"
command -v poetry  > /dev/null 2>&1 || MISSING="$MISSING poetry"
command -v uv      > /dev/null 2>&1 || MISSING="$MISSING uv"
if [ -n "$MISSING" ]; then
    echo -e "${RED}[FAIL]${NC} missing toolchain:$MISSING — 0 Python scenarios verified."
    echo "This book covers pip, Poetry and uv; verifying it needs all three. Install:"
    echo "  uv     : curl -LsSf https://astral.sh/uv/install.sh | sh"
    echo "  poetry : uv tool install poetry   (or: pipx install poetry)"
    exit 1
fi

if [ ! -d "$PUB_REPO/simple" ] || [ ! -d "$PRIV_REPO/simple" ]; then
    echo "Local Python indexes not found. Running install_python_deps.sh ..."
    (cd "$PROJECT_ROOT" && bash install_python_deps.sh > /dev/null)
fi

# ---------- index servers + workspace ----------
WORK=$(mktemp -d)
python3 -m http.server 8765 --directory "$PUB_REPO"  > /dev/null 2>&1 &
SRV_PUB=$!
python3 -m http.server 8766 --directory "$PRIV_REPO" > /dev/null 2>&1 &
SRV_PRIV=$!
cleanup() { kill $SRV_PUB $SRV_PRIV 2>/dev/null; rm -rf "$WORK"; }
trap cleanup EXIT
sleep 1

export POETRY_VIRTUALENVS_IN_PROJECT=true
export PIP_DISABLE_PIP_VERSION_CHECK=1

TOTAL=0
PASSED=0

check_result() {  # check_result <scenario> <tool> <exit-code>
    TOTAL=$((TOTAL + 1))
    if [ "$3" -eq 0 ]; then
        echo -e "${GREEN}[PASS]${NC} $2 - $1"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $2 - $1"
    fi
}

new_venv() {  # new_venv <name> -> prints venv dir
    local d="$WORK/$1"
    python3 -m venv "$d" > /dev/null
    echo "$d"
}

# Copy a tool project dir into the workspace so lockfiles/.venv never
# pollute the repo. Prints the copy's path.
work_copy() {  # work_copy <scenario-dir>/<tool>
    local d="$WORK/$(echo "$1" | tr '/' '-')"
    rm -rf "$d"; mkdir -p "$d"
    cp "$1"/* "$d"/
    echo "$d"
}

run_scenario() {
    [ -n "$ONLY" ] && [ "$ONLY" != "$1" ] && return 1
    echo "Running Scenario $1 ($2)..."
    return 0
}

# ---------- Scenario 1: Basic transitive resolution ----------
if run_scenario 1 "Basic"; then
    V=$(new_venv s1-pip)
    "$V/bin/pip" install -q -r scenario-1-basic/pip/requirements.txt \
        && "$V/bin/pip" show -q demo-lib-c > /dev/null 2>&1
    check_result "Scenario 1 (Basic)" "pip" $?

    W=$(work_copy scenario-1-basic/poetry)
    (cd "$W" && poetry lock -q && poetry sync -q --no-root \
        && .venv/bin/pip show -q demo-lib-c > /dev/null 2>&1)
    check_result "Scenario 1 (Basic)" "poetry" $?

    W=$(work_copy scenario-1-basic/uv)
    (cd "$W" && uv sync -q && .venv/bin/python -c "import demo_lib_c" 2>/dev/null)
    check_result "Scenario 1 (Basic)" "uv" $?
fi

# ---------- Scenario 2: The diamond — conflicting requirements ----------
if run_scenario 2 "Conflict"; then
    V=$(new_venv s2-pip)
    "$V/bin/pip" install -q -r scenario-2-conflict/pip/requirements.txt > "$WORK/s2.log" 2>&1
    [ $? -ne 0 ] && grep -qi "cannot install\|ResolutionImpossible\|conflict" "$WORK/s2.log"
    check_result "Scenario 2 (Conflict fails)" "pip" $?

    W=$(work_copy scenario-2-conflict/poetry)
    (cd "$W" && ! poetry lock -q > /dev/null 2>&1)
    check_result "Scenario 2 (Conflict fails)" "poetry" $?

    W=$(work_copy scenario-2-conflict/uv)
    (cd "$W" && ! uv lock -q > /dev/null 2>&1)
    check_result "Scenario 2 (Conflict fails)" "uv" $?
fi

# ---------- Scenario 3: Resolver strategies — backtracking ----------
if run_scenario 3 "Resolver"; then
    V=$(new_venv s3-pip)
    "$V/bin/pip" install -q -r scenario-3-resolver/pip/requirements.txt \
        && "$V/bin/pip" show demo-lib-a 2>/dev/null | grep -q "Version: 1.0.0"
    check_result "Scenario 3 (Backtracks to 1.0.0)" "pip" $?

    W=$(work_copy scenario-3-resolver/poetry)
    (cd "$W" && poetry lock -q && grep -A1 'name = "demo-lib-a"' poetry.lock | grep -q '1.0.0')
    check_result "Scenario 3 (Backtracks to 1.0.0)" "poetry" $?

    W=$(work_copy scenario-3-resolver/uv)
    (cd "$W" && uv lock -q && grep -A1 'name = "demo-lib-a"' uv.lock | grep -q '1.0.0')
    check_result "Scenario 3 (Backtracks to 1.0.0)" "uv" $?
fi

# ---------- Scenario 4: Specifiers and ranges ----------
if run_scenario 4 "Specifiers"; then
    V=$(new_venv s4-pip)
    "$V/bin/pip" install -q -r scenario-4-specifiers/pip/requirements.txt \
        && "$V/bin/pip" show demo-lib-c 2>/dev/null | grep -q "Version: 2.0.0"
    R1=$?
    V=$(new_venv s4-pip2)
    "$V/bin/pip" install -q -r scenario-4-specifiers/pip/requirements-compatible.txt \
        && "$V/bin/pip" show demo-lib-c 2>/dev/null | grep -q "Version: 1.0.0"
    R2=$?
    V=$(new_venv s4-pip3)
    "$V/bin/pip" install -q -r scenario-4-specifiers/pip/requirements-reject.txt \
        && "$V/bin/pip" show demo-lib-c 2>/dev/null | grep -q "Version: 1.0.0"
    R3=$?
    [ $R1 -eq 0 ] && [ $R2 -eq 0 ] && [ $R3 -eq 0 ]
    check_result "Scenario 4 (>=,~=,!= behave)" "pip" $?

    W=$(work_copy scenario-4-specifiers/poetry)
    (cd "$W" && poetry lock -q && grep -A1 'name = "demo-lib-c"' poetry.lock | grep -q '1.0.0')
    check_result "Scenario 4 (~=1.0 -> 1.0.0)" "poetry" $?

    W=$(work_copy scenario-4-specifiers/uv)
    (cd "$W" && uv lock -q && grep -A1 'name = "demo-lib-c"' uv.lock | grep -q '1.0.0')
    check_result "Scenario 4 (!=2.0.0 -> 1.0.0)" "uv" $?
fi

# ---------- Scenario 5: Lock files ----------
if run_scenario 5 "Locks"; then
    V=$(new_venv s5-pip)
    "$V/bin/pip" install -q -r scenario-5-locks/pip/requirements.txt \
        && "$V/bin/pip" freeze | grep -q "demo-lib-c==1.0.0"
    check_result "Scenario 5 (pip freeze snapshots transitives)" "pip" $?

    W=$(work_copy scenario-5-locks/poetry)
    (cd "$W" && poetry lock -q && grep -q 'name = "demo-lib-c"' poetry.lock)
    check_result "Scenario 5 (poetry.lock records transitives)" "poetry" $?

    W=$(work_copy scenario-5-locks/uv)
    (cd "$W" && uv lock -q && grep -q 'name = "demo-lib-c"' uv.lock \
        && uv export -q --format pylock.toml -o pylock.toml 2>/dev/null \
        && grep -q 'demo-lib-c' pylock.toml)
    check_result "Scenario 5 (uv.lock + PEP 751 export)" "uv" $?
fi

# ---------- Scenario 6: Constraints files ----------
if run_scenario 6 "Constraints"; then
    V=$(new_venv s6-pip)
    "$V/bin/pip" install -q -r scenario-6-constraints/pip/requirements.txt \
        -c scenario-6-constraints/pip/constraints.txt \
        && "$V/bin/pip" show demo-lib-c 2>/dev/null | grep -q "Version: 1.0.0"
    check_result "Scenario 6 (constraint pins 1.0.0)" "pip" $?

    W=$(work_copy scenario-6-constraints/poetry)
    (cd "$W" && poetry lock -q && grep -A1 'name = "demo-lib-c"' poetry.lock | grep -q '1.0.0')
    check_result "Scenario 6 (central pin)" "poetry" $?

    W=$(work_copy scenario-6-constraints/uv)
    (cd "$W" && uv lock -q && grep -A1 'name = "demo-lib-c"' uv.lock | grep -q '1.0.0')
    check_result "Scenario 6 (constraint-dependencies)" "uv" $?
fi

# ---------- Scenario 7: Extras and dependency groups ----------
if run_scenario 7 "Extras/Groups"; then
    V=$(new_venv s7-pip)
    "$V/bin/pip" install -q -r scenario-7-extras-groups/pip/requirements.txt \
        && ! "$V/bin/pip" show -q demo-lib-d > /dev/null 2>&1
    R1=$?
    V=$(new_venv s7-pip2)
    "$V/bin/pip" install -q -r scenario-7-extras-groups/pip/requirements-extras.txt \
        && "$V/bin/pip" show -q demo-lib-d > /dev/null 2>&1
    R2=$?
    [ $R1 -eq 0 ] && [ $R2 -eq 0 ]
    check_result "Scenario 7 (extra opt-in)" "pip" $?

    # pip 25.1+ reads the standard PEP 735 [dependency-groups] table directly.
    # The venv's bundled pip may predate --group, so upgrade it first
    # (needs PyPI, like scenario 12; an offline run fails loudly here).
    V=$(new_venv s7-pip3)
    "$V/bin/pip" install -q --upgrade "pip>=25.1" \
        && (cd scenario-7-extras-groups/pip \
            && "$V/bin/pip" install -q --group dev -i http://127.0.0.1:8765/simple/) \
        && "$V/bin/pip" show -q demo-lib-d > /dev/null 2>&1
    check_result "Scenario 7 (pip install --group, 25.1+)" "pip" $?

    W=$(work_copy scenario-7-extras-groups/poetry)
    (cd "$W" && poetry lock -q \
        && poetry sync -q --no-root --without dev && ! .venv/bin/pip show -q demo-lib-d > /dev/null 2>&1 \
        && poetry sync -q --no-root --with dev && .venv/bin/pip show -q demo-lib-d > /dev/null 2>&1)
    check_result "Scenario 7 (dev group with/without)" "poetry" $?

    W=$(work_copy scenario-7-extras-groups/uv)
    (cd "$W" && uv sync -q --no-dev && ! .venv/bin/python -c "import demo_lib_d" 2>/dev/null \
        && uv sync -q && .venv/bin/python -c "import demo_lib_d" 2>/dev/null)
    check_result "Scenario 7 (dev group with/without)" "uv" $?
fi

# ---------- Scenario 8: Environment markers ----------
if run_scenario 8 "Markers"; then
    V=$(new_venv s8-pip)
    "$V/bin/pip" install -q -r scenario-8-markers/pip/requirements.txt \
        && "$V/bin/pip" show -q demo-lib-c > /dev/null 2>&1 \
        && ! "$V/bin/pip" show -q demo-lib-d > /dev/null 2>&1
    check_result "Scenario 8 (markers filter deps)" "pip" $?

    W=$(work_copy scenario-8-markers/poetry)
    (cd "$W" && poetry lock -q && poetry sync -q --no-root \
        && .venv/bin/pip show -q demo-lib-c > /dev/null 2>&1 \
        && ! .venv/bin/pip show -q demo-lib-d > /dev/null 2>&1)
    check_result "Scenario 8 (markers filter deps)" "poetry" $?

    W=$(work_copy scenario-8-markers/uv)
    (cd "$W" && uv sync -q && .venv/bin/python -c "import demo_lib_c" 2>/dev/null \
        && ! .venv/bin/python -c "import demo_lib_d" 2>/dev/null)
    check_result "Scenario 8 (markers filter deps)" "uv" $?
fi

# ---------- Scenario 9: Exclusions — the gap ----------
if run_scenario 9 "Exclusions gap"; then
    V=$(new_venv s9-pip)
    # The point: demo-lib-c CANNOT be excluded; it is always present.
    "$V/bin/pip" install -q -r scenario-9-exclusions-gap/pip/requirements.txt \
        && "$V/bin/pip" show -q demo-lib-c > /dev/null 2>&1
    check_result "Scenario 9 (no exclusion exists; lib-c present)" "pip" $?

    W=$(work_copy scenario-9-exclusions-gap/poetry)
    (cd "$W" && poetry lock -q && grep -q 'name = "demo-lib-c"' poetry.lock)
    check_result "Scenario 9 (no exclusion exists; lib-c present)" "poetry" $?

    W=$(work_copy scenario-9-exclusions-gap/uv)
    (cd "$W" && uv sync -q \
        && .venv/bin/python -c "import demo_lib_c, sys; sys.exit(0 if demo_lib_c.__version__ == '2.0.0' else 1)" 2>/dev/null)
    check_result "Scenario 9 (uv override forces 2.0.0)" "uv" $?
fi

# ---------- Scenario 10: Virtual environment isolation ----------
if run_scenario 10 "Venv isolation"; then
    V1=$(new_venv s10-a)
    V2=$(new_venv s10-b)
    "$V1/bin/pip" install -q -r scenario-10-venv/pip/requirements-v1.txt \
        && "$V2/bin/pip" install -q -r scenario-10-venv/pip/requirements-v2.txt \
        && "$V1/bin/pip" show demo-lib-a 2>/dev/null | grep -q "Version: 1.0.0" \
        && "$V2/bin/pip" show demo-lib-a 2>/dev/null | grep -q "Version: 2.0.0" \
        && ! python3 -c "import demo_lib_a" 2>/dev/null
    check_result "Scenario 10 (two envs, two truths)" "pip" $?
fi

# ---------- Scenario 11: Private index & dependency confusion ----------
if run_scenario 11 "Private index"; then
    V=$(new_venv s11-pip-vuln)
    "$V/bin/pip" install -q -r scenario-11-private-index/pip/requirements-vulnerable.txt \
        && "$V/bin/pip" show acme-internal-tool 2>/dev/null | grep -q "Version: 9.9.9"
    check_result "Scenario 11 (--extra-index-url is confused: 9.9.9)" "pip" $?

    V=$(new_venv s11-pip-safe)
    "$V/bin/pip" install -q -r scenario-11-private-index/pip/requirements-safe.txt \
        && "$V/bin/pip" show acme-internal-tool 2>/dev/null | grep -q "Version: 1.0.0"
    check_result "Scenario 11 (single index is safe: 1.0.0)" "pip" $?

    W=$(work_copy scenario-11-private-index/poetry)
    (cd "$W" && poetry lock -q && grep -B1 'version = "1.0.0"' poetry.lock | grep -q 'acme-internal-tool')
    check_result "Scenario 11 (source priority is safe: 1.0.0)" "poetry" $?

    W=$(work_copy scenario-11-private-index/uv)
    (cd "$W" && uv lock -q && grep -A1 'name = "acme-internal-tool"' uv.lock | grep -q '1.0.0')
    check_result "Scenario 11 (first-index strategy is safe: 1.0.0)" "uv" $?
fi

# ---------- Scenario 12: Auditing the environment ----------
if run_scenario 12 "Audit"; then
    # S12 is the ONLY scenario that needs the public internet (real PyPI + the
    # OSV/PyPI advisory database). Everything else resolves offline against the
    # local index. Because that makes S12 non-deterministic, it is network-gated:
    # run and hard-check it WHEN online; report it as not-run (not pass, not fail)
    # when offline, so an offline box neither lies green nor falsely goes red.
    if python3 - <<'PY' 2>/dev/null
import socket, sys
try:
    socket.create_connection(("pypi.org", 443), timeout=5).close()
except OSError:
    sys.exit(1)
PY
    then
        # pip-audit must NOT share a venv with the package it's auditing:
        # installing urllib3==1.26.4 alongside pip-audit makes pip-audit's own
        # `import requests -> import urllib3` pick up that ancient pin, whose
        # vendored `six` shim can crash on newer Pythons (e.g. 3.14) before the
        # audit ever runs. Keep pip-audit's own env clean and point it at the
        # requirements file instead — it only needs to read name+version pins.
        V=$(new_venv s12)
        "$V/bin/pip" install -q pip-audit 2>/dev/null
        "$V/bin/pip-audit" -r scenario-12-audit/pip/requirements.txt 2>/dev/null | grep -qi "urllib3"
        check_result "Scenario 12 (pip-audit flags urllib3 1.26.4)" "pip" $?
    else
        echo -e "${RED}[----]${NC} pip - Scenario 12 NOT RUN: pypi.org unreachable (needs network)."
        S12_SKIPPED=1
    fi
fi

echo "-----------------------------------"
echo "Python Verification Complete: $PASSED / $TOTAL offline checks passed."
[ "${S12_SKIPPED:-0}" -eq 1 ] && echo "Scenario 12 (network-only) was NOT run — no internet. Re-run online to verify it."

# Gate only on the deterministic offline checks. S12's network prerequisite,
# when absent, is reported above but does not turn the suite red.
if [ $PASSED -eq $TOTAL ] && [ $TOTAL -gt 0 ]; then
    exit 0
else
    exit 1
fi
