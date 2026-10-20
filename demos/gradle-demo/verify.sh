#!/bin/bash

# verify.sh
# Automated verification for the Gradle dependency resolution scenarios.
# Every check asserts the behaviour the guide claims; where feasible it also
# proves the negative (the feature removed gives a different result) so a
# check cannot pass vacuously.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[m' # No Color

# Run from the script's own directory regardless of the caller's cwd
cd "$(dirname "$0")"
PROJECT_ROOT=$(cd ../.. && pwd)

# Ensure the fixture repositories are populated
if [ ! -d "$PROJECT_ROOT/target/local-repo" ] || [ ! -d "$PROJECT_ROOT/demo-dependencies/private-repo" ]; then
    echo "Populating local repository..."
    (cd "$PROJECT_ROOT" && bash install_deps.sh > /dev/null 2>&1)
fi

TOTAL=0
PASSED=0

function check_result() {
    TOTAL=$((TOTAL + 1))
    local scenario=$1
    local result=$2
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}[PASS]${NC} Gradle - $scenario"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} Gradle - $scenario"
    fi
}

# Resolve a configuration's tree for a scenario directory: deps <dir> <configuration>
function deps() {
    (cd "$1" && gradle -q dependencies --configuration "$2" 2>/dev/null)
}

# Make a throwaway copy of a scenario at the same depth (so relative repo
# paths still work), apply a sed edit to its build file, and print the copy's path.
function variant() {
    local src=$1 expr=$2 dst="_tmp-$1"
    rm -rf "$dst" && cp -r "$src" "$dst" && rm -rf "$dst/.gradle" "$dst/build"
    sed -i '' -e "$expr" "$dst/build.gradle"
    echo "$dst"
}

echo "Starting Gradle verification..."

if ! command -v gradle &> /dev/null; then
    echo "[FAIL] gradle not found — 0 Gradle scenarios verified. Install Gradle to run these checks."
    exit 1
fi
echo "Using $(gradle --version 2>/dev/null | grep '^Gradle')"

# Scenario 1: Basic transitive resolution
echo "Running Scenario 1 (Basic)..."
T=$(deps scenario-1-basic compileClasspath)
echo "$T" | grep -q "com.demo:lib-a:1.0.0" && echo "$T" | grep -q "com.demo:lib-b:1.0.0" && echo "$T" | grep -q "com.demo:lib-c:1.0.0"
check_result "Scenario 1 (Basic)" $?

# Scenario 2: Conflict (newest wins) — the direct 1.0.0 request is upgraded
echo "Running Scenario 2 (Conflict)..."
deps scenario-2-conflict compileClasspath | grep -q "com.demo:lib-b:1.0.0 -> 2.0.0"
check_result "Scenario 2 (Conflict)" $?

# Scenario 3: Platform supplies versions for versionless declarations
echo "Running Scenario 3 (Mgmt)..."
T=$(deps scenario-3-mgmt compileClasspath)
echo "$T" | grep -q "com.demo:lib-a -> 1.0.0" && echo "$T" | grep -q "com.demo:lib-b -> 1.0.0"
check_result "Scenario 3 (Mgmt)" $?

# Scenario 4: Direct 2.0.0 beats platform 1.0.0 by being HIGHER, and its transitive lib-b:2.0.0 beats the platform too
echo "Running Scenario 4 (Override)..."
T=$(deps scenario-4-override compileClasspath)
echo "$T" | grep -q "com.demo:lib-a:1.0.0 -> 2.0.0 (c)" && echo "$T" | grep -q "com.demo:lib-a:2.0.0" && echo "$T" | grep -q "com.demo:lib-b -> 2.0.0"
check_result "Scenario 4 (Override)" $?

# Scenario 5: Per-declaration exclusion removes lib-c; without it lib-c is present
echo "Running Scenario 5 (Exclusions)..."
V=$(variant scenario-5-exclusions "/exclude group/d")
! deps scenario-5-exclusions compileClasspath | grep -q "com.demo:lib-c" && deps "$V" compileClasspath | grep -q "com.demo:lib-c:1.0.0"
check_result "Scenario 5 (Exclusions)" $?
rm -rf "$V"

# Scenario 6: Forced version replaces the transitive request; without it 1.0.0 stays
echo "Running Scenario 6 (Forcing)..."
V=$(variant scenario-6-forcing "/force 'com.demo:lib-c:2.0.0'/d")
deps scenario-6-forcing compileClasspath | grep -q "com.demo:lib-c:1.0.0 -> 2.0.0" && ! deps "$V" compileClasspath | grep -q -- "-> 2.0.0"
check_result "Scenario 6 (Forcing)" $?
rm -rf "$V"

# Scenario 7: compileOnly is on compileClasspath only; test deps only on test classpaths
echo "Running Scenario 7 (Scopes)..."
C=$(deps scenario-7-scopes compileClasspath); R=$(deps scenario-7-scopes runtimeClasspath); TR=$(deps scenario-7-scopes testRuntimeClasspath)
echo "$C" | grep -q "com.demo:lib-d:1.0.0" && ! echo "$R" | grep -q "com.demo:lib-d" && \
    ! echo "$R" | grep -q "com.demo:lib-a" && echo "$TR" | grep -q "com.demo:lib-a:1.0.0" && echo "$R" | grep -q "com.demo:lib-c:1.0.0"
check_result "Scenario 7 (Scopes)" $?

# Scenario 8: POM optional honoured (lib-c absent from main classpath); feature variant carries it
echo "Running Scenario 8 (Optional)..."
R=$(deps scenario-8-optional runtimeClasspath)
echo "$R" | grep -q "com.demo:lib-d:1.0.0" && ! echo "$R" | grep -q "com.demo:lib-c" && \
    deps scenario-8-optional reportingRuntimeClasspath | grep -q "com.demo:lib-c:1.0.0" && \
    (cd scenario-8-optional && gradle -q printRuntimeJars 2>/dev/null | grep -q "JAR lib-d-1.0.0.jar")
check_result "Scenario 8 (Optional)" $?

# Scenario 9: Range [1.0.0, 2.0.0) resolves to 1.0.0 (2.0.0 exists but is excluded by the range)
echo "Running Scenario 9 (Ranges)..."
deps scenario-9-ranges compileClasspath | grep -q "com.demo:lib-a:\[1.0.0, 2.0.0) -> 1.0.0"
check_result "Scenario 9 (Ranges)" $?

# Scenario 10: External cycle resolves silently; repeated node marked (*)
echo "Running Scenario 10 (Circular)..."
T=$(deps scenario-10-circular compileClasspath)
echo "$T" | grep -q "com.demo:lib-circle-a:1.0.0" && echo "$T" | grep -q "com.demo:lib-circle-b:1.0.0" && echo "$T" | grep -q "lib-circle-a:1.0.0 (\*)"
check_result "Scenario 10 (Circular)" $?

# Scenario 11: Committed lock pins lib-a:+ to 1.0.0; a fresh --write-locks (in a copy) picks 2.0.0
echo "Running Scenario 11 (Locking)..."
V="_tmp-scenario-11-locking"; rm -rf "$V" && cp -r scenario-11-locking "$V" && rm -rf "$V/.gradle" "$V/build" "$V/gradle.lockfile"
deps scenario-11-locking compileClasspath | grep -q "com.demo:lib-a:+ -> 1.0.0" && \
    (cd scenario-11-locking && gradle -q dependencyInsight --dependency lib-a --configuration compileClasspath 2>/dev/null | grep -q "Dependency Locking") && \
    (cd "$V" && gradle -q dependencies --write-locks --configuration compileClasspath 2>/dev/null | grep -q "com.demo:lib-a:+ -> 2.0.0") && \
    grep -q "com.demo:lib-a:2.0.0" "$V/gradle.lockfile"
check_result "Scenario 11 (Locking)" $?
rm -rf "$V"

# Scenario 12: Metadata rule rewrites lib-a's dependency to lib-b:2.0.0; without it lib-b:1.0.0
echo "Running Scenario 12 (Metadata)..."
V=$(variant scenario-12-metadata "/removeAll/d;/add('com.demo:lib-b:2.0.0')/d")
deps scenario-12-metadata compileClasspath | grep -q "com.demo:lib-b:2.0.0" && deps "$V" compileClasspath | grep -q "com.demo:lib-b:1.0.0"
check_result "Scenario 12 (Metadata)" $?
rm -rf "$V"

# Scenario 13: Classifier selects the jdk11 jar; tree is unchanged; without it the plain jar
echo "Running Scenario 13 (Variants)..."
V=$(variant scenario-13-variants "s/com.demo:lib-a:1.0.0:jdk11/com.demo:lib-a:1.0.0/")
(cd scenario-13-variants && gradle -q printRuntimeJars 2>/dev/null | grep -q "JAR lib-a-1.0.0-jdk11.jar") && \
    deps scenario-13-variants compileClasspath | grep -q "com.demo:lib-a:1.0.0" && \
    (cd "$V" && gradle -q printRuntimeJars 2>/dev/null | grep -q "JAR lib-a-1.0.0.jar")
check_result "Scenario 13 (Variants)" $?
rm -rf "$V"

# Scenario 14: Range would pick 2.0.0; reject knocks it out -> 1.0.0; without reject -> 2.0.0
echo "Running Scenario 14 (Reject)..."
V=$(variant scenario-14-reject "/reject '2.0.0'/d")
deps scenario-14-reject compileClasspath | grep -q "reject 2.0.0} -> 1.0.0" && deps "$V" compileClasspath | grep -q "com.demo:lib-a:\[1.0.0, 3.0.0) -> 2.0.0"
check_result "Scenario 14 (Reject)" $?
rm -rf "$V"

# Scenario 15: Substitution rewrites lib-a:1.0.0 -> 2.0.0 and brings lib-b:2.0.0 with it
echo "Running Scenario 15 (Substitution)..."
T=$(deps scenario-15-substitution compileClasspath)
echo "$T" | grep -q "com.demo:lib-a:1.0.0 -> 2.0.0" && echo "$T" | grep -q "com.demo:lib-b:2.0.0" && \
    (cd scenario-15-substitution && gradle -q dependencyInsight --dependency lib-a --configuration compileClasspath 2>/dev/null | grep -q "selected by rule")
check_result "Scenario 15 (Substitution)" $?

# Scenario 16: Vendor BOM from the private repo supplies 2.5.14.ACME
echo "Running Scenario 16 (Private BOM)..."
deps scenario-16-private-bom compileClasspath | grep -q "org.springframework.boot:spring-boot-starter -> 2.5.14.ACME"
check_result "Scenario 16 (Private BOM)" $?

# Scenario 17: Direct declaration of the patched version from the private repo
echo "Running Scenario 17 (Private Patch)..."
deps scenario-17-private-patch compileClasspath | grep -q "org.springframework.boot:spring-boot-starter:2.5.14.ACME"
check_result "Scenario 17 (Private Patch)" $?

# Scenario 18: Global exclude removes lib-c from every configuration; without it lib-c is back
echo "Running Scenario 18 (Banning)..."
V=$(variant scenario-18-banning "/exclude group: 'com.demo', module: 'lib-c'/d")
T=$(deps scenario-18-banning runtimeClasspath)
echo "$T" | grep -q "com.demo:lib-b" && ! echo "$T" | grep -q "com.demo:lib-c" && deps "$V" runtimeClasspath | grep -q "com.demo:lib-c:1.0.0"
check_result "Scenario 18 (Banning)" $?
rm -rf "$V"

echo "-----------------------------------"
echo "Gradle Verification Complete: $PASSED / $TOTAL scenarios passed."

if [ $PASSED -eq $TOTAL ]; then
    exit 0
else
    exit 1
fi
