#!/bin/bash

# verify.sh
# Automated verification for Maven dependency resolution scenarios.
# Every check asserts what the scenario's guide claims; where a scenario is
# about a build FAILING (12, 14) the check proves both the failure and the fix.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[m' # No Color

# Resolve paths from the script's own location so this works from anywhere.
MAVEN_DEMO_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$MAVEN_DEMO_DIR/../.." && pwd)"
cd "$MAVEN_DEMO_DIR"

# Ensure local repo is populated
if [ ! -d "$PROJECT_ROOT/target/local-repo" ]; then
    echo "Populating local repository..."
    (cd "$PROJECT_ROOT" && bash install_deps.sh > /dev/null 2>&1)
fi

# Compile the checker
CHECKER_CP="$PROJECT_ROOT/demo-utils/target/demo-utils-1.0.0.jar"

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

function run_checker() {
    local classpath=$1
    # Add the checker classpath to the scenario classpath
    java -cp "$CHECKER_CP:$classpath" CheckClasspath
}

echo "Starting Maven verification..."
echo "Using: $(mvn -v 2>/dev/null | head -1)"

# Silencing JDK 25+ / Guice internal warnings
export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED -Dsun.misc.Unsafe.allowTerminallyDeprecated=true $MAVEN_OPTS"
MVN_OPTS="-Dmaven.repo.local=$PROJECT_ROOT/target/local-repo -B"

# Scenario 1: Basic
echo "Running Scenario 1 (Basic)..."
(cd scenario-1-basic && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-1-basic/cp.txt)
run_checker "$CP"
(cd scenario-1-basic && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-c:jar:1.0.0")
check_result "Scenario 1 (Basic)" "Maven" $?

# Scenario 2: Conflict (Nearest Wins): direct lib-b:1.0.0 beats transitive 2.0.0
echo "Running Scenario 2 (Conflict)..."
(cd scenario-2-conflict && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-2-conflict/cp.txt)
run_checker "$CP"
(cd scenario-2-conflict && TREE=$(mvn $MVN_OPTS dependency:tree -Dverbose) && \
    echo "$TREE" | grep -q "com.demo:lib-b:jar:1.0.0:compile" && \
    echo "$TREE" | grep -q "com.demo:lib-b:jar:2.0.0.*omitted for conflict")
check_result "Scenario 2 (Conflict)" "Maven" $?

# Scenario 3: Management
echo "Running Scenario 3 (Mgmt)..."
(cd scenario-3-mgmt && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-3-mgmt/cp.txt)
run_checker "$CP"
(cd scenario-3-mgmt && TREE=$(mvn $MVN_OPTS dependency:tree) && \
    echo "$TREE" | grep -q "com.demo:lib-a:jar:1.0.0" && echo "$TREE" | grep -q "com.demo:lib-b:jar:1.0.0")
check_result "Scenario 3 (Mgmt)" "Maven" $?

# Scenario 4: Override (direct 2.0.0 beats the BOM's 1.0.0; lib-b stays managed)
echo "Running Scenario 4 (Override)..."
(cd scenario-4-override && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-4-override/cp.txt)
run_checker "$CP"
(cd scenario-4-override && TREE=$(mvn $MVN_OPTS dependency:tree) && \
    echo "$TREE" | grep -q "com.demo:lib-a:jar:2.0.0" && echo "$TREE" | grep -q "com.demo:lib-b:jar:1.0.0")
check_result "Scenario 4 (Override)" "Maven" $?

# Scenario 5: Exclusions (lib-c gone, lib-b still there)
echo "Running Scenario 5 (Exclusions)..."
(cd scenario-5-exclusions && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-5-exclusions/cp.txt)
run_checker "$CP"
(cd scenario-5-exclusions && TREE=$(mvn $MVN_OPTS dependency:tree) && \
    echo "$TREE" | grep -q "com.demo:lib-b:jar:1.0.0" && ! echo "$TREE" | grep -q "com.demo:lib-c")
check_result "Scenario 5 (Exclusions)" "Maven" $?

# Scenario 6: Forcing via dependencyManagement (lib-c managed 1.0.0 -> 2.0.0)
echo "Running Scenario 6 (Forcing)..."
(cd scenario-6-forcing && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-6-forcing/cp.txt)
run_checker "$CP"
(cd scenario-6-forcing && mvn $MVN_OPTS dependency:tree -Dverbose | \
    grep -q "com.demo:lib-c:jar:2.0.0:compile (version managed from 1.0.0)")
check_result "Scenario 6 (Forcing)" "Maven" $?

# Scenario 7: Scopes (direct provided/test declarations demote the transitives)
echo "Running Scenario 7 (Scopes)..."
(cd scenario-7-scopes && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-7-scopes/cp.txt)
run_checker "$CP"
(cd scenario-7-scopes && TREE=$(mvn $MVN_OPTS dependency:tree) && \
    echo "$TREE" | grep -q "com.demo:lib-a:jar:1.0.0:compile" && \
    echo "$TREE" | grep -q "com.demo:lib-b:jar:1.0.0:provided" && \
    echo "$TREE" | grep -q "com.demo:lib-c:jar:1.0.0:test" && \
    RUNTIME=$(mvn $MVN_OPTS dependency:build-classpath -DincludeScope=runtime -Dmdep.outputFile=/dev/stdout -q) && \
    echo "$RUNTIME" | grep -q "lib-a-1.0.0.jar" && ! echo "$RUNTIME" | grep -q "lib-b-1.0.0.jar")
check_result "Scenario 7 (Scopes)" "Maven" $?

# Scenario 8: Optional (lib-d's optional lib-c does NOT reach the consumer; opt-in profile does)
echo "Running Scenario 8 (Optional)..."
(cd scenario-8-optional && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-8-optional/cp.txt)
run_checker "$CP"
(cd scenario-8-optional && TREE=$(mvn $MVN_OPTS dependency:tree) && \
    echo "$TREE" | grep -q "com.demo:lib-d:jar:1.0.0" && ! echo "$TREE" | grep -q "com.demo:lib-c" && \
    mvn $MVN_OPTS dependency:tree -Pwith-feature | grep -q "com.demo:lib-c:jar:1.0.0")
check_result "Scenario 8 (Optional)" "Maven" $?

# Scenario 9: Ranges ([1.0.0,2.0.0) picks 1.0.0, not the 2.0.0 that is also published)
echo "Running Scenario 9 (Ranges)..."
(cd scenario-9-ranges && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-9-ranges/cp.txt)
run_checker "$CP"
(cd scenario-9-ranges && TREE=$(mvn $MVN_OPTS dependency:tree) && \
    echo "$TREE" | grep -q "com.demo:lib-a:jar:1.0.0" && ! echo "$TREE" | grep -q "com.demo:lib-a:jar:2.0.0")
check_result "Scenario 9 (Ranges)" "Maven" $?

# Scenario 10: Circular (cycle resolved silently; both halves present, no error)
echo "Running Scenario 10 (Circular)..."
(cd scenario-10-circular && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-10-circular/cp.txt)
run_checker "$CP"
(cd scenario-10-circular && TREE=$(mvn $MVN_OPTS dependency:tree) && \
    echo "$TREE" | grep -q "com.demo:lib-circle-a:jar:1.0.0" && \
    echo "$TREE" | grep -q "com.demo:lib-circle-b:jar:1.0.0" && echo "$TREE" | grep -q "BUILD SUCCESS")
check_result "Scenario 10 (Circular)" "Maven" $?

# Scenario 11: Locking (range resolves; Maven has no native lockfile)
echo "Running Scenario 11 (Locking)..."
(cd scenario-11-locking && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-a:jar:1.0.0")
check_result "Scenario 11 (Locking)" "Maven" $?

# Scenario 12: Metadata (managed pin silently downgrades; requireUpperBoundDeps catches it; fix passes)
echo "Running Scenario 12 (Metadata)..."
(cd scenario-12-metadata && \
    ! mvn $MVN_OPTS validate > s12-fail.txt 2>&1 && grep -q "RequireUpperBoundDeps" s12-fail.txt && \
    mvn $MVN_OPTS dependency:tree -Dverbose | grep -q "com.demo:lib-b:jar:1.0.0:compile (version managed from 2.0.0)" && \
    mvn $MVN_OPTS validate -Pfixed > /dev/null 2>&1 && \
    mvn $MVN_OPTS dependency:tree -Pfixed | grep -q "com.demo:lib-b:jar:2.0.0"; R=$?; rm -f s12-fail.txt; exit $R)
check_result "Scenario 12 (Metadata)" "Maven" $?

# Scenario 13: Variants (classified artifact resolves)
echo "Running Scenario 13 (Variants)..."
(cd scenario-13-variants && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-a:jar:jdk11:1.0.0")
check_result "Scenario 13 (Variants)" "Maven" $?

# Scenario 14: Reject (ban trips on the transitive lib-b:2.0.0; managed fix steers to 1.0.0)
echo "Running Scenario 14 (Reject)..."
(cd scenario-14-reject && \
    ! mvn $MVN_OPTS validate > s14-fail.txt 2>&1 && grep -q "com.demo:lib-b:jar:2.0.0 <--- banned" s14-fail.txt && \
    mvn $MVN_OPTS validate -Pfixed > /dev/null 2>&1 && \
    TREE=$(mvn $MVN_OPTS dependency:tree -Pfixed) && echo "$TREE" | grep -q "com.demo:lib-b:jar:1.0.0" && \
    ! echo "$TREE" | grep -q "com.demo:lib-b:jar:2.0.0"; R=$?; rm -f s14-fail.txt; exit $R)
check_result "Scenario 14 (Reject)" "Maven" $?

# Scenario 15: Substitution (lib-b excluded from lib-a, lib-d declared instead; enforcer guards)
echo "Running Scenario 15 (Substitution)..."
(cd scenario-15-substitution && mvn $MVN_OPTS validate > /dev/null 2>&1 && \
    TREE=$(mvn $MVN_OPTS dependency:tree) && echo "$TREE" | grep -q "com.demo:lib-d:jar:1.0.0" && \
    echo "$TREE" | grep -q "com.demo:lib-a:jar:1.0.0" && ! echo "$TREE" | grep -q "com.demo:lib-b")
check_result "Scenario 15 (Substitution)" "Maven" $?

# Scenario 16: Private BOM
echo "Running Scenario 16 (Private BOM)..."
(cd scenario-16-private-bom && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-16-private-bom/cp.txt)
run_checker "$CP"
(cd scenario-16-private-bom && mvn $MVN_OPTS dependency:tree | grep -q "org.springframework.boot:spring-boot-starter:jar:2.5.14.ACME")
check_result "Scenario 16 (Private BOM)" "Maven" $?

# Scenario 17: Private Patch
echo "Running Scenario 17 (Private Patch)..."
(cd scenario-17-private-patch && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat scenario-17-private-patch/cp.txt)
run_checker "$CP"
(cd scenario-17-private-patch && mvn $MVN_OPTS dependency:tree | grep -q "org.springframework.boot:spring-boot-starter:jar:2.5.14.ACME")
check_result "Scenario 17 (Private Patch)" "Maven" $?

# Scenario 18: Banning (Global Exclusion)
echo "Running Scenario 18 (Banning)..."
(cd scenario-18-banning && mvn $MVN_OPTS validate > /dev/null 2>&1 && ! mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-c")
check_result "Scenario 18 (Banning)" "Maven" $?

# Remove the classpath scratch files the checker runs produced
find . -name cp.txt -delete

echo "-----------------------------------"
echo "Maven Verification Complete: $PASSED / $TOTAL scenarios passed."

if [ $PASSED -eq $TOTAL ]; then
    exit 0
else
    exit 1
fi
