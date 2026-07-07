### Node Scenario 9: Tree Shape & Deduplication

Install b@1 (c@1 hoists), add direct c@2 (c@1 demotes to nested), remove c@2 — c@1 STAYS nested. Fresh install from the identical package.json hoists it. npm's tree is a function of history; pnpm's is a function of the lockfile.

Verify: compare `node_modules/demo-lib-b/node_modules/demo-lib-c` presence after the detour vs after a fresh install.
