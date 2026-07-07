### Node Scenario 8: Peer Dependencies — Where Flat Returns

demo-plugin declares peer demo-lib-c ^1.0.0; the project supplies 2.0.0. npm: hard ERESOLVE failure (`--legacy-peer-deps` bypasses). pnpm/Yarn: install with warnings.

Verify: `npm install` exits non-zero with ERESOLVE; pnpm/yarn exit 0 and warn.
