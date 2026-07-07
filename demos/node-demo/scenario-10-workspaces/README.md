### Node Scenario 10: Workspaces & Monorepos

packages/app depends on packages/shared (workspace:* under pnpm/yarn, by-name under npm); shared depends on registry demo-lib-c. One root install links local, fetches external.

Verify: `node_modules/shared` is a symlink; app resolves `require('shared').c.version` → 1.0.0.
