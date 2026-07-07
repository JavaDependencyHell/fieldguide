### Node Scenario 6: Overrides & Resolutions

Chain pins demo-lib-c 1.0.0; the override forces 2.0.0 tree-wide. npm: `overrides` (package.json) · pnpm 11: `overrides` (pnpm-workspace.yaml — package.json `pnpm.overrides` is no longer read) · Yarn: `resolutions`.

Verify: `node -e "console.log(require('demo-lib-a').b.c.version)"` → 2.0.0 under all three.
