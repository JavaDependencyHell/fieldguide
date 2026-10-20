### Node Scenario 9: Tree Shape & Deduplication

Install b@1 (c@1 hoists), add direct c@2 (c@1 demotes to nested), remove c@2 — c@1 STAYS nested, and package-lock.json records the nested path, so `rm -rf node_modules && npm ci` reproduces the nested tree. Only a fresh install with the lockfile deleted hoists c@1 again. pnpm (no hoisting) and Yarn's node-modules linker (layout recomputed every install) end hoisted/invariant after the same detour.

Verify: `node_modules/demo-lib-b/node_modules/demo-lib-c` present after the detour AND after `npm ci`; absent after `rm -rf node_modules package-lock.json && npm install`. Yarn: root `demo-lib-c` present after the remove.
