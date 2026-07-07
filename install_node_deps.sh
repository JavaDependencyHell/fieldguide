#!/bin/bash

# install_node_deps.sh
# Builds the Node fixture registries used by demos/node-demo — the equivalent
# of install_deps.sh (JVM) and install_python_deps.sh.
#
# Produces:
#   target/node-harness           local Verdaccio install (not global)
#   target/node-repo              public registry storage  (served on :4873)
#   target/node-private-repo      private registry storage (served on :4874)
#
# Needs: node >= 22, npm (bundled). Network on first run only (Verdaccio
# install + Corepack tool downloads); everything after is local.

set -e
cd "$(dirname "$0")"

HARNESS=target/node-harness
PUB_CFG=demos/node-demo/harness/public.yaml
PRIV_CFG=demos/node-demo/harness/private.yaml

if [ ! -x "$HARNESS/node_modules/.bin/verdaccio" ]; then
    echo "Installing Verdaccio (harness-local, not global)..."
    mkdir -p "$HARNESS"
    (cd "$HARNESS" && npm install --no-fund --no-audit --loglevel=error verdaccio)
fi

# Pre-fetch the pinned package managers so verify.sh can run offline.
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
corepack prepare pnpm@11.10.0 --activate > /dev/null 2>&1 || true
corepack prepare yarn@4.17.0 --activate > /dev/null 2>&1 || true

echo "Starting temporary registries to publish fixtures..."
rm -rf target/node-repo target/node-private-repo
"$HARNESS/node_modules/.bin/verdaccio" --config "$PUB_CFG"  > /dev/null 2>&1 &
PUB_PID=$!
"$HARNESS/node_modules/.bin/verdaccio" --config "$PRIV_CFG" > /dev/null 2>&1 &
PRIV_PID=$!
trap 'kill $PUB_PID $PRIV_PID 2>/dev/null' EXIT
sleep 3

node scripts/build_node_fixtures.mjs

echo "Done. Fixture registries populated in target/node-repo and target/node-private-repo."
