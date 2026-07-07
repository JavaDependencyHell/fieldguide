### Node Scenario 3: Hoisting & Phantom Dependencies

app.js requires demo-lib-b, which is never declared. npm's hoisting makes it work; pnpm and Yarn PnP refuse. Identical code, opposite outcomes.

Verify: `node app.js` succeeds under npm/, fails under pnpm/ and (via `yarn node`) yarn/.
