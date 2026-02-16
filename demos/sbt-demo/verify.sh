#!/bin/bash

# verify.sh
# Automated verification for SBT dependency resolution scenarios

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[m' # No Color

# Determine the absolute path to the project root
# We assume this script is in demos/sbt-demo/
PROJECT_ROOT=$(cd ../.. && pwd)
SBT_DEMO_DIR="."

# Ensure local repo is populated
if [ ! -d "$PROJECT_ROOT/target/local-repo" ]; then
    echo "Populating local repository..."
    (cd "$PROJECT_ROOT" && bash install_deps.sh > /dev/null 2>&1)
fi

TOTAL=0
PASSED=0

function check_result() {
    TOTAL=$((TOTAL + 1))
    local scenario=$1
    local tool=$2
    local result=$3
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}[PASS]${NC} $tool - $scenario"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $tool - $scenario"
    fi
}

echo "Starting SBT verification..."

if ! command -v sbt &> /dev/null; then
    echo "sbt not found, skipping SBT scenarios."
    exit 0
else
    # Scenario 1: Basic
    echo "Running Scenario 1 (Basic)..."
    (cd $SBT_DEMO_DIR/scenario-1-basic && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-c/1.0.0")
    check_result "Scenario 1 (Basic)" "SBT" $?

    # Scenario 2: Conflict (Latest Wins)
    echo "Running Scenario 2 (Conflict)..."
    (cd $SBT_DEMO_DIR/scenario-2-conflict && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-b/2.0.0")
    check_result "Scenario 2 (Conflict)" "SBT" $?

    # Scenario 3: Overrides
    echo "Running Scenario 3 (Mgmt)..."
    (cd $SBT_DEMO_DIR/scenario-3-mgmt && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-b/1.0.0")
    check_result "Scenario 3 (Mgmt)" "SBT" $?

    # Scenario 4: Override
    echo "Running Scenario 4 (Override)..."
    (cd $SBT_DEMO_DIR/scenario-4-override && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-a/2.0.0")
    check_result "Scenario 4 (Override)" "SBT" $?

    # Scenario 5: Exclusions
    echo "Running Scenario 5 (Exclusions)..."
    (cd $SBT_DEMO_DIR/scenario-5-exclusions && sbt "show externalDependencyClasspath" | grep -v -q "com.demo/lib-c")
    check_result "Scenario 5 (Exclusions)" "SBT" $?

    # Scenario 6: Strict
    echo "Running Scenario 6 (Strict)..."
    (cd $SBT_DEMO_DIR/scenario-6-forcing && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-c/2.0.0")
    check_result "Scenario 6 (Strict)" "SBT" $?

    # Scenario 7: Scopes
    echo "Running Scenario 7 (Scopes)..."
    (cd $SBT_DEMO_DIR/scenario-7-scopes && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-a/1.0.0" && sbt "show test:externalDependencyClasspath" | grep -q "com.demo/lib-c/1.0.0")
    check_result "Scenario 7 (Scopes)" "SBT" $?

    # Scenario 8: Optional
    echo "Running Scenario 8 (Optional)..."
    (cd $SBT_DEMO_DIR/scenario-8-optional && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-a/1.0.0")
    check_result "Scenario 8 (Optional)" "SBT" $?

    # Scenario 9: Ranges
    echo "Running Scenario 9 (Ranges)..."
    # SBT output for ranges might just show the resolved version.
    (cd $SBT_DEMO_DIR/scenario-9-ranges && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-a/1.0.0")
    check_result "Scenario 9 (Ranges)" "SBT" $?

    # Scenario 10: Circular
    echo "Running Scenario 10 (Circular)..."
    (cd $SBT_DEMO_DIR/scenario-10-circular && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-circle-a/1.0.0" && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-circle-b/1.0.0")
    check_result "Scenario 10 (Circular)" "SBT" $?

    # Scenario 11: Locking
    echo "Running Scenario 11 (Locking)..."
    # Generate lock file first
    (cd $SBT_DEMO_DIR/scenario-11-locking && sbt dependencyLockWrite > /dev/null 2>&1)
    (cd $SBT_DEMO_DIR/scenario-11-locking && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-a/1.0.0")
    check_result "Scenario 11 (Locking)" "SBT" $?

    # Scenario 12: Metadata
    echo "Running Scenario 12 (Metadata)..."
    (cd $SBT_DEMO_DIR/scenario-12-metadata && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-a/1.0.0")
    check_result "Scenario 12 (Metadata)" "SBT" $?

    # Scenario 13: Variants
    echo "Running Scenario 13 (Variants)..."
    (cd $SBT_DEMO_DIR/scenario-13-variants && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-a/1.0.0")
    check_result "Scenario 13 (Variants)" "SBT" $?

    # Scenario 14: Reject
    echo "Running Scenario 14 (Reject)..."
    (cd $SBT_DEMO_DIR/scenario-14-reject && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-a/1.0.0")
    check_result "Scenario 14 (Reject)" "SBT" $?

    # Scenario 15: Substitution
    echo "Running Scenario 15 (Substitution)..."
    (cd $SBT_DEMO_DIR/scenario-15-substitution && sbt "show externalDependencyClasspath" | grep -q "com.demo/lib-a/1.0.0")
    check_result "Scenario 15 (Substitution)" "SBT" $?

    # Scenario 16: Private BOM
    echo "Running Scenario 16 (Private BOM)..."
    (cd $SBT_DEMO_DIR/scenario-16-private-bom && sbt "show externalDependencyClasspath" | grep -q "org.springframework.boot/spring-boot-starter/2.5.14.ACME")
    check_result "Scenario 16 (Private BOM)" "SBT" $?

    # Scenario 17: Private Patch
    echo "Running Scenario 17 (Private Patch)..."
    (cd $SBT_DEMO_DIR/scenario-17-private-patch && sbt "show externalDependencyClasspath" | grep -q "org.springframework.boot/spring-boot-starter/2.5.14.ACME")
    check_result "Scenario 17 (Private Patch)" "SBT" $?
fi

echo "-----------------------------------"
echo "SBT Verification Complete: $PASSED / $TOTAL scenarios passed."

if [ $PASSED -eq $TOTAL ]; then
    exit 0
else
    exit 1
fi
