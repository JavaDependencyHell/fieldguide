### Node Scenario 5: Lock Files

`^1.0.0` input; every tool writes its lockfile on install and pins the transitive demo-lib-c. `npm ci` obeys the lock; `npm install` maintains it.

Verify: grep demo-lib-c in package-lock.json / pnpm-lock.yaml / yarn.lock; `npm ci` reproduces the tree.
