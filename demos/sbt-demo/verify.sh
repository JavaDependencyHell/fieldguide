#!/bin/bash

# verify.sh
# Automated verification for sbt dependency resolution scenarios.
# Every check asserts the behaviour the guide claims, and where feasible the
# negative too (the thing that must NOT be on the classpath).

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[m' # No Color

# Resolve paths from the script location, not the caller's cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SBT_DEMO_DIR="$SCRIPT_DIR"

# Ensure local repo is populated
if [ ! -d "$PROJECT_ROOT/target/local-repo" ]; then
    echo "Populating local repository..."
    (cd "$PROJECT_ROOT" && bash install_deps.sh > /dev/null 2>&1)
fi
if [ ! -d "$PROJECT_ROOT/demo-dependencies/private-repo" ]; then
    echo "Populating private repository (scenarios 16/17)..."
    (cd "$PROJECT_ROOT" && bash install_private_repo.sh > /dev/null 2>&1)
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

# Print a configuration's external classpath (one line per entry).
showcp() { sbt -batch "show $1" 2>/dev/null; }

echo "Starting sbt verification..."

if ! command -v sbt &> /dev/null; then
    echo "[FAIL] sbt not found — 0 sbt scenarios verified. Install sbt to run these checks."
    exit 1
fi
sbt --version 2>/dev/null | head -2

# Scenario 1: Basic — the whole chain arrives
echo "Running Scenario 1 (Basic)..."
(cd "$SBT_DEMO_DIR/scenario-1-basic" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-a/1.0.0" \
    && echo "$out" | grep -q "com/demo/lib-b/1.0.0" \
    && echo "$out" | grep -q "com/demo/lib-c/1.0.0")
check_result "Scenario 1 (Basic)" "sbt" $?

# Scenario 2: Conflict — highest wins, direct 1.0.0 evicted
echo "Running Scenario 2 (Conflict)..."
(cd "$SBT_DEMO_DIR/scenario-2-conflict" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-b/2.0.0" \
    && ! echo "$out" | grep -q "com/demo/lib-b/1.0.0")
check_result "Scenario 2 (Conflict)" "sbt" $?

# Scenario 3: Central versions — everything at the shared val's version
echo "Running Scenario 3 (Mgmt)..."
(cd "$SBT_DEMO_DIR/scenario-3-mgmt" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-a/1.0.0" \
    && echo "$out" | grep -q "com/demo/lib-b/1.0.0" \
    && ! echo "$out" | grep -q "com/demo/lib-b/2.0.0")
check_result "Scenario 3 (Mgmt)" "sbt" $?

# Scenario 4: Override — direct lib-b:1.0.0 loses to transitive 2.0.0
echo "Running Scenario 4 (Override)..."
(cd "$SBT_DEMO_DIR/scenario-4-override" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-a/2.0.0" \
    && echo "$out" | grep -q "com/demo/lib-b/2.0.0" \
    && ! echo "$out" | grep -q "com/demo/lib-b/1.0.0")
check_result "Scenario 4 (Override)" "sbt" $?

# Scenario 5: Exclusions — lib-c gone, lib-b still there
echo "Running Scenario 5 (Exclusions)..."
(cd "$SBT_DEMO_DIR/scenario-5-exclusions" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-b/1.0.0" \
    && ! echo "$out" | grep -q "com/demo/lib-c")
check_result "Scenario 5 (Exclusions)" "sbt" $?

# Scenario 6: Forcing — override wins although nothing requests 2.0.0
echo "Running Scenario 6 (Forcing)..."
(cd "$SBT_DEMO_DIR/scenario-6-forcing" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-c/2.0.0" \
    && ! echo "$out" | grep -q "com/demo/lib-c/1.0.0")
check_result "Scenario 6 (Forcing)" "sbt" $?

# Scenario 7: Configurations — Provided/Test narrow their own declaration; a
# Provided declaration does NOT demote a transitive Compile edge (lib-b via lib-a)
echo "Running Scenario 7 (Scopes)..."
(cd "$SBT_DEMO_DIR/scenario-7-scopes" \
    && c=$(showcp "Compile / externalDependencyClasspath") \
    && r=$(showcp "Runtime / externalDependencyClasspath") \
    && t=$(showcp "Test / externalDependencyClasspath") \
    && echo "$c" | grep -q "com/demo/lib-a/1.0.0" \
    && echo "$c" | grep -q "com/demo/lib-d/1.0.0" \
    && ! echo "$c" | grep -q "com/demo/lib-circle-a" \
    && echo "$r" | grep -q "com/demo/lib-a/1.0.0" \
    && echo "$r" | grep -q "com/demo/lib-b/1.0.0" \
    && ! echo "$r" | grep -q "com/demo/lib-d" \
    && ! echo "$r" | grep -q "com/demo/lib-circle-a" \
    && echo "$t" | grep -q "com/demo/lib-d/1.0.0" \
    && echo "$t" | grep -q "com/demo/lib-circle-a/1.0.0")
check_result "Scenario 7 (Scopes)" "sbt" $?

# Scenario 8: Optional — lib-d present, its optional lib-c absent
echo "Running Scenario 8 (Optional)..."
(cd "$SBT_DEMO_DIR/scenario-8-optional" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-d/1.0.0" \
    && ! echo "$out" | grep -q "com/demo/lib-c")
check_result "Scenario 8 (Optional)" "sbt" $?

# Scenario 9: Ranges — [1.0.0,2.0.0) picks 1.0.0, not 2.0.0
echo "Running Scenario 9 (Ranges)..."
(cd "$SBT_DEMO_DIR/scenario-9-ranges" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-a/1.0.0" \
    && ! echo "$out" | grep -q "com/demo/lib-a/2.0.0")
check_result "Scenario 9 (Ranges)" "sbt" $?

# Scenario 10: Circular — both resolve, build succeeds
echo "Running Scenario 10 (Circular)..."
(cd "$SBT_DEMO_DIR/scenario-10-circular" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-circle-a/1.0.0" \
    && echo "$out" | grep -q "com/demo/lib-circle-b/1.0.0")
check_result "Scenario 10 (Circular)" "sbt" $?

# Scenario 11: Locking — write a lock, check passes; restore the committed lock afterwards
echo "Running Scenario 11 (Locking)..."
(cd "$SBT_DEMO_DIR/scenario-11-locking" \
    && cp -f build.sbt.lock /tmp/sb11-committed.lock \
    && sbt -batch dependencyLockWrite > /dev/null 2>&1 \
    && [ -s build.sbt.lock ] \
    && grep -q '"name" : "lib-a"' build.sbt.lock \
    && sbt -batch dependencyLockCheck 2>&1 | grep -q "Dependency lock check passed"; \
    rc=$?; cp -f /tmp/sb11-committed.lock build.sbt.lock; rm -f /tmp/sb11-committed.lock; exit $rc)
check_result "Scenario 11 (Locking)" "sbt" $?

# Scenario 12: Metadata — exclude+add moves lib-b (and lib-c) to 2.0.0
echo "Running Scenario 12 (Metadata)..."
(cd "$SBT_DEMO_DIR/scenario-12-metadata" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-a/1.0.0" \
    && echo "$out" | grep -q "com/demo/lib-b/2.0.0" \
    && ! echo "$out" | grep -q "com/demo/lib-b/1.0.0" \
    && echo "$out" | grep -q "com/demo/lib-c/2.0.0")
check_result "Scenario 12 (Metadata)" "sbt" $?

# Scenario 13: Variants — the jdk11 classifier jar replaces the default jar
echo "Running Scenario 13 (Variants)..."
(cd "$SBT_DEMO_DIR/scenario-13-variants" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "lib-a-1.0.0-jdk11.jar" \
    && ! echo "$out" | grep -q "lib-a-1.0.0.jar" \
    && echo "$out" | grep -q "com/demo/lib-b/1.0.0")
check_result "Scenario 13 (Variants)" "sbt" $?

# Scenario 14: Reject — incompatible eviction fails update; allowed, it resolves 2.0.0
echo "Running Scenario 14 (Reject)..."
(cd "$SBT_DEMO_DIR/scenario-14-reject" \
    && sbt -batch update 2>&1 | grep -qi "binary incompatible" \
    && out=$(sbt -batch -Dsb14.allow=true "show externalDependencyClasspath" 2>/dev/null) \
    && echo "$out" | grep -q "com/demo/lib-b/2.0.0" \
    && ! echo "$out" | grep -q "com/demo/lib-b/1.0.0")
check_result "Scenario 14 (Reject)" "sbt" $?

# Scenario 15: Substitution — lib-b gone, lib-d in its place
echo "Running Scenario 15 (Substitution)..."
(cd "$SBT_DEMO_DIR/scenario-15-substitution" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-a/1.0.0" \
    && echo "$out" | grep -q "com/demo/lib-d/1.0.0" \
    && ! echo "$out" | grep -q "com/demo/lib-b")
check_result "Scenario 15 (Substitution)" "sbt" $?

# Scenario 16: Private BOM (emulated) — override forces the patched version
echo "Running Scenario 16 (Private BOM)..."
(cd "$SBT_DEMO_DIR/scenario-16-private-bom" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "org/springframework/boot/spring-boot-starter/2.5.14.ACME" \
    && ! echo "$out" | grep -q "spring-boot-starter/2.5.14/")
check_result "Scenario 16 (Private BOM)" "sbt" $?

# Scenario 17: Private Patch — direct declaration of the patched version
echo "Running Scenario 17 (Private Patch)..."
(cd "$SBT_DEMO_DIR/scenario-17-private-patch" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "org/springframework/boot/spring-boot-starter/2.5.14.ACME")
check_result "Scenario 17 (Private Patch)" "sbt" $?

# Scenario 18: Banning — lib-c gone from every path, lib-b still present
echo "Running Scenario 18 (Banning)..."
(cd "$SBT_DEMO_DIR/scenario-18-banning" && out=$(showcp externalDependencyClasspath) \
    && echo "$out" | grep -q "com/demo/lib-b" \
    && ! echo "$out" | grep -q "com/demo/lib-c")
check_result "Scenario 18 (Banning)" "sbt" $?

echo "-----------------------------------"
echo "sbt Verification Complete: $PASSED / $TOTAL scenarios passed."

if [ $PASSED -eq $TOTAL ]; then
    exit 0
else
    exit 1
fi
