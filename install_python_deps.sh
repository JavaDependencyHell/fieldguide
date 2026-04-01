#!/bin/bash
# ============================================================================
# install_python_deps.sh
# Builds all Python demo-dependency packages into wheels and collects them
# in target/python-repo/ for use as a local package index.
#
# Usage: bash install_python_deps.sh
#
# Equivalent to install_deps.sh for the Maven demos.
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/target/python-repo"
BUILD_STAGING="/tmp/fieldguide-build-staging"
WHEEL_STAGING="/tmp/fieldguide-wheels"

echo "=== Building Python demo packages ==="

rm -rf "$BUILD_STAGING" "$WHEEL_STAGING"
mkdir -p "$REPO_DIR" "$BUILD_STAGING" "$WHEEL_STAGING"

BUILT=0
FAILED=0

for pkg_dir in "$SCRIPT_DIR"/demo-dependencies/*/v*-python/; do
    if [ ! -f "$pkg_dir/pyproject.toml" ]; then
        continue
    fi

    pkg_name=$(grep '^name' "$pkg_dir/pyproject.toml" | head -1 | sed 's/.*= *"\(.*\)"/\1/')
    pkg_version=$(grep '^version' "$pkg_dir/pyproject.toml" | head -1 | sed 's/.*= *"\(.*\)"/\1/')

    echo "  Building $pkg_name $pkg_version ..."

    # Copy to temp dir to avoid permission issues on mounted filesystems
    staging="$BUILD_STAGING/${pkg_name}-${pkg_version}"
    rm -rf "$staging"
    cp -r "$pkg_dir" "$staging"

    if python3 -m build "$staging" --outdir "$WHEEL_STAGING" --wheel --no-isolation 2>/dev/null; then
        BUILT=$((BUILT + 1))
    else
        echo "    FAILED to build $pkg_name $pkg_version"
        FAILED=$((FAILED + 1))
    fi
done

# Copy wheels to the repo directory
cp "$WHEEL_STAGING"/*.whl "$REPO_DIR/" 2>/dev/null || true
rm -rf "$BUILD_STAGING" "$WHEEL_STAGING"

echo ""
echo "=== Python packages built: $BUILT succeeded, $FAILED failed ==="
echo "    Wheels in: $REPO_DIR"
ls -1 "$REPO_DIR"/*.whl 2>/dev/null || echo "    (no wheels found)"
