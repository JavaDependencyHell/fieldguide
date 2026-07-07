### Node Scenario 2: The Diamond — Everyone Wins

Root wants demo-lib-c 1.0.0; demo-lib-a 2.0.0 needs 2.0.0. Both install — root sees 1.0.0, a's subtree sees 2.0.0. The JVM evicts, Python fails, Node duplicates.

Verify: `node -e "console.log(require('demo-lib-c').version, require('demo-lib-a').b.c.version)"` → `1.0.0 2.0.0`.
