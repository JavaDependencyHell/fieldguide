### Node Scenario 1: Basic Transitive Resolution

demo-lib-a → demo-lib-b → demo-lib-c. Installing the first pulls all three, into a tree that could hold many versions of each.

Verify: `npm install` / `pnpm install` / `yarn install`, then `node -e "console.log(require('demo-lib-a').b.c.version)"` → 1.0.0.
