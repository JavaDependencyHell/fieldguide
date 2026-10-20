#!/bin/bash

# verify.sh — Node scenario verification (npm / pnpm / Yarn 4)
#
# Every scenario runs in a FRESH throwaway copy of its project dir — package
# managers mutate lockfiles and node_modules, and tree shape depends on
# history (that's scenario 9), so shared state would corrupt the checks.
#
# Fixtures come from two local Verdaccio registries whose storage is built
# by install_node_deps.sh:
#   public  : target/node-repo          served on http://127.0.0.1:4873/
#   private : target/node-private-repo  served on http://127.0.0.1:4874/
#
# Scenario 12 (audit) talks to the REAL npm registry — it needs network,
# same as the Python scenario 12.
#
# Usage: ./verify.sh [scenario-number]   (no arg = run all)

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[m'

PROJECT_ROOT=$(cd ../.. && pwd)
HARNESS="$PROJECT_ROOT/target/node-harness/node_modules/.bin/verdaccio"
ONLY="${1:-}"

export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
export npm_config_fund=false npm_config_audit=false

# ---------- prerequisites: fail loudly, never vacuously ----------
# The book documents npm, pnpm AND Yarn 4; verifying the book requires all
# three. Corepack provides pnpm/yarn from each project's packageManager pin.
# Corepack is bundled with Node 14.19–24 only; Node 25+ needs it installed
# separately — so we check for a WORKING corepack, not a Node version.
MISSING=""
command -v node     > /dev/null 2>&1 || MISSING="$MISSING node"
command -v npm      > /dev/null 2>&1 || MISSING="$MISSING npm"
if ! command -v corepack > /dev/null 2>&1 || ! corepack --version > /dev/null 2>&1; then
    MISSING="$MISSING corepack"
fi
command -v pnpm     > /dev/null 2>&1 || MISSING="$MISSING pnpm(corepack-shim)"
command -v yarn     > /dev/null 2>&1 || MISSING="$MISSING yarn(corepack-shim)"
if [ -n "$MISSING" ]; then
    echo -e "${RED}[FAIL]${NC} missing toolchain:$MISSING — 0 Node scenarios verified."
    echo "Need Node >= 22 (npm included) plus Corepack:"
    echo "  Node 22/24:  corepack enable"
    echo "  Node 25+ :   npm install -g corepack && corepack enable   (Corepack no longer ships with Node)"
    exit 1
fi
if [ ! -x "$HARNESS" ] || [ ! -d "$PROJECT_ROOT/target/node-repo" ]; then
    echo "Local Node registries not found. Running install_node_deps.sh ..."
    (cd "$PROJECT_ROOT" && bash install_node_deps.sh > /dev/null)
fi

# ---------- registries + workspace ----------
WORK=$(mktemp -d)
"$HARNESS" --config harness/public.yaml  > /dev/null 2>&1 &
SRV_PUB=$!
"$HARNESS" --config harness/private.yaml > /dev/null 2>&1 &
SRV_PRIV=$!
cleanup() { kill $SRV_PUB $SRV_PRIV 2>/dev/null; rm -rf "$WORK"; }
trap cleanup EXIT
sleep 3

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

work_copy() {  # work_copy <scenario-dir>/<tool> -> prints copy path
    local d="$WORK/$(echo "$1" | tr '/' '-')"
    rm -rf "$d"; mkdir -p "$d"
    cp -r "$1/." "$d/"
    echo "$d"
}

run_scenario() {  # run_scenario <num> <label>
    if [ -n "$ONLY" ] && [ "$ONLY" != "$1" ]; then return 1; fi
    echo "Running Scenario $1 ($2)..."
    return 0
}

# Chain assertion helper: require('demo-lib-a').b.c.version
chain_is() {  # chain_is <dir> <expected> [runner]
    (cd "$1" && ${3:-node} -e "process.exit(require('demo-lib-a').b.c.version === '$2' ? 0 : 1)" 2>/dev/null)
}

# ---------- Scenario 1: Basic transitive resolution ----------
if run_scenario 1 "Basic"; then
    W=$(work_copy scenario-1-basic/npm)
    (cd "$W" && npm install --silent) && chain_is "$W" 1.0.0
    check_result "Scenario 1 (a->b->c chain resolves)" "npm" $?

    W=$(work_copy scenario-1-basic/pnpm)
    (cd "$W" && pnpm install --silent) && chain_is "$W" 1.0.0
    check_result "Scenario 1 (a->b->c chain resolves)" "pnpm" $?

    W=$(work_copy scenario-1-basic/yarn)
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1) && chain_is "$W" 1.0.0
    check_result "Scenario 1 (a->b->c chain resolves)" "yarn" $?
fi

# ---------- Scenario 2: The diamond — everyone wins ----------
diamond_check() {  # <dir> [runner] : root sees c@1, a's subtree sees c@2
    (cd "$1" && ${2:-node} -e "
const c = require('demo-lib-c');
const a = require('demo-lib-a');
process.exit(c.version === '1.0.0' && a.b.c.version === '2.0.0' ? 0 : 1);" 2>/dev/null)
}
if run_scenario 2 "Diamond duplicates"; then
    W=$(work_copy scenario-2-diamond/npm)
    (cd "$W" && npm install --silent) && diamond_check "$W" \
        && [ -d "$W/node_modules/demo-lib-b/node_modules/demo-lib-c" ]
    check_result "Scenario 2 (both c versions installed)" "npm" $?

    W=$(work_copy scenario-2-diamond/pnpm)
    (cd "$W" && pnpm install --silent) && diamond_check "$W"
    check_result "Scenario 2 (both c versions installed)" "pnpm" $?

    W=$(work_copy scenario-2-diamond/yarn)
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1) && diamond_check "$W"
    check_result "Scenario 2 (both c versions installed)" "yarn" $?
fi

# ---------- Scenario 3: Hoisting & phantom dependencies ----------
if run_scenario 3 "Phantoms"; then
    W=$(work_copy scenario-3-phantom/npm)
    # npm hoists demo-lib-b to the root: the UNDECLARED import works.
    (cd "$W" && npm install --silent && node app.js > /dev/null 2>&1)
    check_result "Scenario 3 (phantom import WORKS under npm)" "npm" $?

    W=$(work_copy scenario-3-phantom/pnpm)
    # pnpm's strict layout: the phantom import fails.
    (cd "$W" && pnpm install --silent) && ! (cd "$W" && node app.js > /dev/null 2>&1)
    check_result "Scenario 3 (phantom import FAILS under pnpm)" "pnpm" $?

    W=$(work_copy scenario-3-phantom/yarn)
    # Yarn PnP: the phantom import fails with a descriptive error.
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1) \
        && ! (cd "$W" && yarn node app.js > /dev/null 2>&1)
    check_result "Scenario 3 (phantom import FAILS under Yarn PnP)" "yarn" $?
fi

# ---------- Scenario 4: Semver ranges ----------
cver() {  # <dir> <expected> [runner]
    (cd "$1" && ${3:-node} -e "process.exit(require('demo-lib-c').version === '$2' ? 0 : 1)" 2>/dev/null)
}
if run_scenario 4 "Semver"; then
    W=$(work_copy scenario-4-semver/npm)
    (cd "$W" && npm install --silent) && cver "$W" 1.1.0
    check_result "Scenario 4 (^1.0.0 -> 1.1.0, not 2.0.0)" "npm" $?

    W=$(work_copy scenario-4-semver/npm-tilde)
    (cd "$W" && npm install --silent) && cver "$W" 1.0.0
    check_result "Scenario 4 (~1.0.0 -> 1.0.0)" "npm" $?

    W=$(work_copy scenario-4-semver/pnpm)
    (cd "$W" && pnpm install --silent) && cver "$W" 1.1.0
    check_result "Scenario 4 (^1.0.0 -> 1.1.0, not 2.0.0)" "pnpm" $?

    W=$(work_copy scenario-4-semver/yarn)
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1) && cver "$W" 1.1.0
    check_result "Scenario 4 (^1.0.0 -> 1.1.0, not 2.0.0)" "yarn" $?
fi

# ---------- Scenario 5: Lock files ----------
if run_scenario 5 "Locks"; then
    # Each tool: lock records the transitive; the frozen verb reproduces the
    # tree; and after package.json drifts from the lock, the frozen verb FAILS.
    drift() { sed -i.bak 's/"\^1.0.0"/"^2.0.0"/' "$1/package.json"; }

    W=$(work_copy scenario-5-locks/npm)
    (cd "$W" && npm install --silent \
        && grep -q '"demo-lib-c"' package-lock.json \
        && rm -rf node_modules && npm ci --silent) && chain_is "$W" 1.0.0 \
        && drift "$W" && ! (cd "$W" && npm ci --silent > /dev/null 2>&1)
    check_result "Scenario 5 (lock records transitives; npm ci reproduces, refuses drift)" "npm" $?

    W=$(work_copy scenario-5-locks/pnpm)
    (cd "$W" && pnpm install --silent && grep -q 'demo-lib-c@' pnpm-lock.yaml \
        && rm -rf node_modules && pnpm install --silent --frozen-lockfile) && chain_is "$W" 1.0.0 \
        && drift "$W" && ! (cd "$W" && pnpm install --frozen-lockfile > /dev/null 2>&1)
    check_result "Scenario 5 (pnpm-lock.yaml records transitives; --frozen-lockfile reproduces, refuses drift)" "pnpm" $?

    W=$(work_copy scenario-5-locks/yarn)
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1 && grep -q '"demo-lib-c@' yarn.lock \
        && rm -rf node_modules && yarn install --immutable > /dev/null 2>&1) && chain_is "$W" 1.0.0 \
        && drift "$W" && ! (cd "$W" && yarn install --immutable > /dev/null 2>&1)
    check_result "Scenario 5 (yarn.lock records transitives; --immutable reproduces, refuses drift)" "yarn" $?
fi

# ---------- Scenario 6: Overrides & resolutions ----------
if run_scenario 6 "Overrides"; then
    W=$(work_copy scenario-6-overrides/npm)
    (cd "$W" && npm install --silent) && chain_is "$W" 2.0.0
    check_result "Scenario 6 (overrides force c@2.0.0)" "npm" $?

    W=$(work_copy scenario-6-overrides/pnpm)
    (cd "$W" && pnpm install --silent) && chain_is "$W" 2.0.0
    check_result "Scenario 6 (pnpm-workspace.yaml overrides force c@2.0.0)" "pnpm" $?

    W=$(work_copy scenario-6-overrides/yarn)
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1) && chain_is "$W" 2.0.0
    check_result "Scenario 6 (resolutions force c@2.0.0)" "yarn" $?
fi

# ---------- Scenario 7: Dependency types ----------
has_d() { (cd "$1" && ${2:-node} -e "require('demo-lib-d')" > /dev/null 2>&1); }
if run_scenario 7 "Dep types"; then
    W=$(work_copy scenario-7-dep-types/npm)
    (cd "$W" && npm install --silent) && has_d "$W" \
        && (cd "$W" && rm -rf node_modules && npm install --silent --omit=dev) && ! has_d "$W"
    check_result "Scenario 7 (devDeps present by default, absent with --omit=dev)" "npm" $?

    W=$(work_copy scenario-7-dep-types/pnpm)
    (cd "$W" && pnpm install --silent) && has_d "$W" \
        && (cd "$W" && rm -rf node_modules && pnpm install --silent --prod) && ! has_d "$W"
    check_result "Scenario 7 (devDeps present by default, absent with --prod)" "pnpm" $?

    W=$(work_copy scenario-7-dep-types/yarn)
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1) && has_d "$W" \
        && (cd "$W" && yarn workspaces focus --production > /dev/null 2>&1) && ! has_d "$W"
    check_result "Scenario 7 (devDeps present by default, absent after focus --production)" "yarn" $?
fi

# ---------- Scenario 8: Peer dependencies ----------
if run_scenario 8 "Peers"; then
    W=$(work_copy scenario-8-peers/npm)
    # npm 7+: hard ERESOLVE failure; --legacy-peer-deps installs anyway.
    (cd "$W" && npm install > install.log 2>&1); R1=$?
    grep -q "ERESOLVE" "$W/install.log"; R2=$?
    (cd "$W" && npm install --silent --legacy-peer-deps > /dev/null 2>&1); R3=$?
    [ $R1 -ne 0 ] && [ $R2 -eq 0 ] && [ $R3 -eq 0 ]
    check_result "Scenario 8 (ERESOLVE hard failure; legacy flag bypasses)" "npm" $?

    W=$(work_copy scenario-8-peers/pnpm)
    # pnpm: installs, but warns about the unmet peer.
    (cd "$W" && pnpm install > install.log 2>&1) && grep -qi "peer" "$W/install.log"
    check_result "Scenario 8 (installs with peer warning)" "pnpm" $?

    W=$(work_copy scenario-8-peers/yarn)
    # Yarn: installs, but reports the incorrect peer (YN0060).
    (cd "$W" && yarn install --no-immutable > install.log 2>&1) && grep -q "YN0060" "$W/install.log"
    check_result "Scenario 8 (installs with YN0060 peer warning)" "yarn" $?
fi

# ---------- Scenario 9: Tree shape & deduplication ----------
if run_scenario 9 "Tree shape"; then
    W=$(work_copy scenario-9-tree-shape/npm)
    # History: add then remove a direct c@2. npm leaves c@1 NESTED under b —
    # same package.json as a fresh install, different tree. npm never re-hoists.
    (cd "$W" && npm install --silent \
        && npm install --silent demo-lib-c@2.0.0 \
        && npm uninstall --silent demo-lib-c) \
        && [ -d "$W/node_modules/demo-lib-b/node_modules/demo-lib-c" ] \
        && [ ! -d "$W/node_modules/demo-lib-c" ]; R1=$?
    # The lockfile records placement by path, so `npm ci` reproduces the
    # NESTED shape — deleting node_modules alone does not reset history.
    (cd "$W" && rm -rf node_modules && npm ci --silent) \
        && grep -q '"node_modules/demo-lib-b/node_modules/demo-lib-c"' "$W/package-lock.json" \
        && [ -d "$W/node_modules/demo-lib-b/node_modules/demo-lib-c" ] \
        && [ ! -d "$W/node_modules/demo-lib-c" ]; R1b=$?
    # Only a fresh install WITHOUT the lockfile re-hoists.
    (cd "$W" && rm -rf node_modules package-lock.json && npm install --silent) \
        && [ -d "$W/node_modules/demo-lib-c" ] \
        && [ ! -d "$W/node_modules/demo-lib-b/node_modules/demo-lib-c" ]; R2=$?
    [ $R1 -eq 0 ] && [ $R1b -eq 0 ] && [ $R2 -eq 0 ]
    check_result "Scenario 9 (history nests c@1; npm ci reproduces the nested lock; only a lock-less fresh install re-hoists)" "npm" $?

    W=$(work_copy scenario-9-tree-shape/pnpm)
    # pnpm: layout is store-driven — same ops, no hoisting, no history effect,
    # and the root never gains an undeclared demo-lib-c.
    (cd "$W" && pnpm install --silent \
        && pnpm add --silent demo-lib-c@2.0.0 > /dev/null 2>&1 \
        && pnpm remove --silent demo-lib-c > /dev/null 2>&1) \
        && [ ! -d "$W/node_modules/demo-lib-c" ] \
        && ls "$W/node_modules/.pnpm" | grep -q "^demo-lib-c@1.0.0"
    check_result "Scenario 9 (pnpm layout invariant under history)" "pnpm" $?

    W=$(work_copy scenario-9-tree-shape/yarn)
    # Yarn (node-modules linker) recomputes the layout from the graph on every
    # install: after the same detour, c@1 is hoisted again — no history effect.
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1 \
        && yarn add demo-lib-c@2.0.0 > /dev/null 2>&1 \
        && yarn remove demo-lib-c > /dev/null 2>&1) \
        && [ -d "$W/node_modules/demo-lib-c" ] \
        && [ ! -d "$W/node_modules/demo-lib-b/node_modules/demo-lib-c" ]
    check_result "Scenario 9 (yarn node-modules linker re-hoists after the detour)" "yarn" $?
fi

# ---------- Scenario 10: Workspaces ----------
ws_check() {  # <dir> [runner]
    (cd "$1/packages/app" && ${2:-node} -e "
const s = require('shared');
process.exit(s.version === '1.0.0' && s.c.version === '1.0.0' ? 0 : 1);" 2>/dev/null)
}
if run_scenario 10 "Workspaces"; then
    W=$(work_copy scenario-10-workspaces/npm)
    (cd "$W" && npm install --silent) && ws_check "$W" && [ -L "$W/node_modules/shared" ]
    check_result "Scenario 10 (workspace linked, app resolves shared)" "npm" $?

    W=$(work_copy scenario-10-workspaces/pnpm)
    (cd "$W" && pnpm install --silent) && ws_check "$W"
    check_result "Scenario 10 (workspace: protocol, app resolves shared)" "pnpm" $?

    W=$(work_copy scenario-10-workspaces/yarn)
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1) && ws_check "$W"
    check_result "Scenario 10 (workspace: protocol, app resolves shared)" "yarn" $?
fi

# ---------- Scenario 11: Private registry & dependency confusion ----------
acme_ver() {  # <dir> <pkg> <expected> [runner]
    (cd "$1" && ${4:-node} -e "process.exit(require('$2').version === '$3' ? 0 : 1)" 2>/dev/null)
}
if run_scenario 11 "Dependency confusion"; then
    W=$(work_copy scenario-11-private-registry/npm-vulnerable)
    (cd "$W" && npm install --silent) && acme_ver "$W" acme-internal-tool 9.9.9
    check_result "Scenario 11 (public registry serves the 9.9.9 impostor)" "npm" $?

    W=$(work_copy scenario-11-private-registry/npm-safe)
    (cd "$W" && npm install --silent) && acme_ver "$W" acme-internal-tool 1.0.0
    check_result "Scenario 11 (single private registry: genuine 1.0.0)" "npm" $?

    W=$(work_copy scenario-11-private-registry/npm-scoped)
    (cd "$W" && npm install --silent) && acme_ver "$W" @acme/internal-tool 1.0.0
    check_result "Scenario 11 (@acme scope pinned: genuine 1.0.0)" "npm" $?

    W=$(work_copy scenario-11-private-registry/pnpm)
    (cd "$W" && pnpm install --silent) && acme_ver "$W" @acme/internal-tool 1.0.0
    check_result "Scenario 11 (@acme scope pinned: genuine 1.0.0)" "pnpm" $?

    W=$(work_copy scenario-11-private-registry/yarn)
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1) && acme_ver "$W" @acme/internal-tool 1.0.0
    check_result "Scenario 11 (npmScopes pinned: genuine 1.0.0)" "yarn" $?
fi

# ---------- Scenario 12: Audit (REAL registry — needs network) ----------
if run_scenario 12 "Audit"; then
    W=$(work_copy scenario-12-audit/npm)
    (cd "$W" && npm install --silent > /dev/null 2>&1 \
        && ! npm audit > audit.log 2>&1 \
        && grep -qi "lodash" audit.log)
    check_result "Scenario 12 (npm audit flags lodash 4.17.20)" "npm" $?

    W=$(work_copy scenario-12-audit/pnpm)
    (cd "$W" && pnpm install --silent > /dev/null 2>&1 \
        && ! pnpm audit > audit.log 2>&1 \
        && grep -qi "lodash" audit.log)
    check_result "Scenario 12 (pnpm audit flags lodash 4.17.20)" "pnpm" $?

    W=$(work_copy scenario-12-audit/yarn)
    (cd "$W" && yarn install --no-immutable > /dev/null 2>&1 \
        && ! yarn npm audit > audit.log 2>&1 \
        && grep -qi "lodash" audit.log)
    check_result "Scenario 12 (yarn npm audit flags lodash 4.17.20)" "yarn" $?
fi

echo "-----------------------------------"
echo "Node Verification Complete: $PASSED / $TOTAL checks passed."
[ "$PASSED" -eq "$TOTAL" ]
