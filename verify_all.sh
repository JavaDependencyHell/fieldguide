#!/bin/bash

# verify_all.sh
# Runs all verification scripts found in the demos directories

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[m' # No Color

# Ensure local repo is populated
if [ ! -d "target/local-repo" ]; then
    echo "Populating local repository..."
    bash install_deps.sh > /dev/null 2>&1
fi

FAILURES=0

# Find all verify.sh scripts in the demos directory
# We use find to locate them, then loop through each one
SCRIPTS=$(find demos -name "verify.sh")

for SCRIPT in $SCRIPTS; do
    DIR=$(dirname "$SCRIPT")
    echo "=== Running Verification in $DIR ==="

    # Run the script from its directory
    (cd "$DIR" && bash verify.sh)

    if [ $? -ne 0 ]; then
        FAILURES=$((FAILURES + 1))
    fi
    echo ""
done

if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}All tools passed verification!${NC}"
    exit 0
else
    echo -e "${RED}Some tools failed verification.${NC}"
    exit 1
fi
