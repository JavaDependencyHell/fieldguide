#!/bin/bash

# verify.sh
# Automated verification for Maven dependency resolution scenarios

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[m' # No Color

# Determine the absolute path to the project root
# We assume this script is in demos/maven-demo/
PROJECT_ROOT=$(cd ../.. && pwd)
MAVEN_DEMO_DIR="."

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

# Silencing JDK 25+ / Guice internal warnings
export MAVEN_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED -Dsun.misc.Unsafe.allowTerminallyDeprecated=true $MAVEN_OPTS"
MVN_OPTS="-Dmaven.repo.local=$PROJECT_ROOT/target/local-repo -B"

# Scenario 1: Basic
echo "Running Scenario 1 (Basic)..."
(cd $MAVEN_DEMO_DIR/scenario-1-basic && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-1-basic/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-1-basic && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-c:jar:1.0.0")
check_result "Scenario 1 (Basic)" "Maven" $?

# Scenario 2: Conflict (Nearest Wins)
echo "Running Scenario 2 (Conflict)..."
(cd $MAVEN_DEMO_DIR/scenario-2-conflict && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-2-conflict/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-2-conflict && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-b:jar:1.0.0")
check_result "Scenario 2 (Conflict)" "Maven" $?

# Scenario 3: Management
echo "Running Scenario 3 (Mgmt)..."
(cd $MAVEN_DEMO_DIR/scenario-3-mgmt && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-3-mgmt/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-3-mgmt && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-a:jar:1.0.0" && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-b:jar:1.0.0")
check_result "Scenario 3 (Mgmt)" "Maven" $?

# Scenario 4: Override
echo "Running Scenario 4 (Override)..."
(cd $MAVEN_DEMO_DIR/scenario-4-override && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-4-override/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-4-override && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-a:jar:2.0.0")
check_result "Scenario 4 (Override)" "Maven" $?

# Scenario 5: Exclusions
echo "Running Scenario 5 (Exclusions)..."
(cd $MAVEN_DEMO_DIR/scenario-5-exclusions && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-5-exclusions/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-5-exclusions && mvn $MVN_OPTS dependency:tree | grep -v -q "com.demo:lib-c")
check_result "Scenario 5 (Exclusions)" "Maven" $?

# Scenario 6: Strict
echo "Running Scenario 6 (Strict)..."
(cd $MAVEN_DEMO_DIR/scenario-6-forcing && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-6-forcing/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-6-forcing && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-c:jar:2.0.0")
check_result "Scenario 6 (Strict)" "Maven" $?

# Scenario 7: Scopes
echo "Running Scenario 7 (Scopes)..."
(cd $MAVEN_DEMO_DIR/scenario-7-scopes && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-7-scopes/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-7-scopes && \
    mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-a:jar:1.0.0:compile" && \
    mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-b:jar:1.0.0:provided" && \
    mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-c:jar:1.0.0:test")
check_result "Scenario 7 (Scopes)" "Maven" $?

# Scenario 8: Optional
echo "Running Scenario 8 (Optional)..."
(cd $MAVEN_DEMO_DIR/scenario-8-optional && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-8-optional/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-8-optional && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-a:jar:1.0.0:compile (optional)")
check_result "Scenario 8 (Optional)" "Maven" $?

# Scenario 9: Ranges
echo "Running Scenario 9 (Ranges)..."
(cd $MAVEN_DEMO_DIR/scenario-9-ranges && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-9-ranges/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-9-ranges && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-a:jar:1.0.0")
check_result "Scenario 9 (Ranges)" "Maven" $?

# Scenario 10: Circular
echo "Running Scenario 10 (Circular)..."
(cd $MAVEN_DEMO_DIR/scenario-10-circular && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-10-circular/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-10-circular && mvn $MVN_OPTS dependency:tree | grep -q "com.demo:lib-a:jar:1.0.0")
check_result "Scenario 10 (Circular)" "Maven" $?

# Scenario 16: Private BOM
echo "Running Scenario 16 (Private BOM)..."
(cd $MAVEN_DEMO_DIR/scenario-16-private-bom && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-16-private-bom/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-16-private-bom && mvn $MVN_OPTS dependency:tree | grep -q "org.springframework.boot:spring-boot-starter:jar:2.5.14.ACME")
check_result "Scenario 16 (Private BOM)" "Maven" $?

# Scenario 17: Private Patch
echo "Running Scenario 17 (Private Patch)..."
(cd $MAVEN_DEMO_DIR/scenario-17-private-patch && mvn $MVN_OPTS dependency:build-classpath -Dmdep.outputFile=cp.txt > /dev/null)
CP=$(cat $MAVEN_DEMO_DIR/scenario-17-private-patch/cp.txt)
run_checker "$CP"
(cd $MAVEN_DEMO_DIR/scenario-17-private-patch && mvn $MVN_OPTS dependency:tree | grep -q "org.springframework.boot:spring-boot-starter:jar:2.5.14.ACME")
check_result "Scenario 17 (Private Patch)" "Maven" $?

echo "-----------------------------------"
echo "Maven Verification Complete: $PASSED / $TOTAL scenarios passed."

if [ $PASSED -eq $TOTAL ]; then
    exit 0
else
    exit 1
fi
