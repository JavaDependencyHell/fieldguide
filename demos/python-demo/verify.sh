#!/bin/bash
# ============================================================================
# verify.sh — Python scenario verification
# Equivalent to demos/maven-demo/verify.sh
#
# Runs each scenario with pip (and optionally poetry/uv) and checks that
# the resolved dependency versions match expectations.
#
# Usage: bash verify.sh
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../.."
REPO_DIR="$PROJECT_ROOT/target/python-repo"
VENV_BASE="/tmp/fieldguide-verify"

# Ensure local repo exists
if [ ! -d "$REPO_DIR" ] || [ -z "$(ls -A "$REPO_DIR"/*.whl 2>/dev/null)" ]; then
    echo "Local Python repo not found. Running install_python_deps.sh ..."
    bash "$PROJECT_ROOT/install_python_deps.sh"
fi

PASS=0
FAIL=0
TOTAL=0

# ---------------------------------------------------------------------------
# check_versions: verify installed packages match expected.txt
#   $1 = path to expected.txt
#   $2 = path to venv's pip
# ---------------------------------------------------------------------------
check_versions() {
    local expected_file="$1"
    local pip_cmd="$2"
    local ok=true

    while IFS= read -r line; do
        # Skip blank lines and comments
        [[ -z "$line" || "$line" == \#* ]] && continue

        pkg=$(echo "$line" | sed 's/==.*//' | tr '-' '_')
        expected_ver=$(echo "$line" | sed 's/.*==//')

        actual_ver=$($pip_cmd show "$(echo "$line" | sed 's/==.*//')" 2>/dev/null \
            | grep "^Version:" | awk '{print $2}') || actual_ver="NOT_INSTALLED"

        if [ "$actual_ver" = "$expected_ver" ]; then
            echo "    ✓ $pkg==$expected_ver"
        else
            echo "    ✗ $pkg expected $expected_ver, got $actual_ver"
            ok=false
        fi
    done < "$expected_file"

    $ok
}

# ---------------------------------------------------------------------------
# verify_pip: install via pip and check results
#   $1 = scenario directory
#   $2 = requirements file (default: requirements.txt)
#   $3 = expected file (default: expected.txt)
# ---------------------------------------------------------------------------
verify_pip() {
    local scenario_dir="$1"
    local req_file="${2:-requirements.txt}"
    local exp_file="${3:-expected.txt}"
    local scenario_name
    scenario_name=$(basename "$scenario_dir")
    local venv_dir="$VENV_BASE/$scenario_name"

    if [ ! -f "$scenario_dir/$exp_file" ]; then
        echo "  [SKIP] No $exp_file found"
        return 2
    fi

    # Create fresh venv
    rm -rf "$venv_dir"
    python3 -m venv "$venv_dir"
    local pip_cmd="$venv_dir/bin/pip"

    # Install from local repo only
    $pip_cmd install --find-links="$REPO_DIR" --no-index \
        -r "$scenario_dir/$req_file" --quiet 2>/dev/null || true

    # Check versions
    if check_versions "$scenario_dir/$exp_file" "$pip_cmd"; then
        return 0
    else
        return 1
    fi
}

# ---------------------------------------------------------------------------
# verify_conflict_pip: verify pip silently downgrades to resolve conflict
#   $1 = scenario directory
# ---------------------------------------------------------------------------
verify_conflict_pip() {
    local scenario_dir="$1"
    local scenario_name
    scenario_name=$(basename "$scenario_dir")
    local venv_dir="$VENV_BASE/$scenario_name"

    # Create fresh venv
    rm -rf "$venv_dir"
    python3 -m venv "$venv_dir"
    local pip_cmd="$venv_dir/bin/pip"

    # Install — pip will silently downgrade lib-a to avoid the conflict
    $pip_cmd install --find-links="$REPO_DIR" --no-index \
        -r "$scenario_dir/requirements-pip.txt" --quiet 2>/dev/null || true

    # Check that pip resolved by downgrading lib-a to 1.0.0
    if check_versions "$scenario_dir/expected-pip.txt" "$pip_cmd"; then
        echo "    (pip silently downgraded lib-a from 2.0.0 to 1.0.0 to resolve the conflict)"
        return 0
    else
        return 1
    fi
}

# ===========================
# Run scenarios
# ===========================

echo "=== Python Scenario Verification ==="
echo "    Using wheels from: $REPO_DIR"
echo ""

# --- Scenario 1: Basic Transitive Resolution ---
echo "--- scenario-1-basic (pip) ---"
TOTAL=$((TOTAL + 1))
if verify_pip "$SCRIPT_DIR/scenario-1-basic"; then
    PASS=$((PASS + 1))
    echo "  [PASS]"
else
    FAIL=$((FAIL + 1))
    echo "  [FAIL]"
fi
echo ""

# --- Scenario 2: Version Conflict ---
echo "--- scenario-2-conflict (pip — expected: silent downgrade) ---"
TOTAL=$((TOTAL + 1))
if verify_conflict_pip "$SCRIPT_DIR/scenario-2-conflict"; then
    PASS=$((PASS + 1))
    echo "  [PASS] pip silently downgraded as expected"
else
    FAIL=$((FAIL + 1))
    echo "  [FAIL]"
fi
echo ""

# ===========================
# Summary
# ===========================

rm -rf "$VENV_BASE"

echo "==========================================="
echo "Python Verification Complete: $PASS / $TOTAL scenarios passed."
if [ $FAIL -gt 0 ]; then
    echo "  ($FAIL failed)"
    exit 1
fi
