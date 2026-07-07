### Node Scenario 12: Auditing the Tree

lodash pinned to 4.17.20 (known advisories). Install succeeds; `npm audit` exits non-zero and names the findings. Needs network — real registry, live advisory DB.

Verify: `npm install && npm audit` → non-zero exit, lodash named.
