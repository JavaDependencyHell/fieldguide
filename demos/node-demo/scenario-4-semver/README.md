### Node Scenario 4: Semver & the ^ Culture

demo-lib-c exists at 1.0.0, 1.1.0, 2.0.0. `^1.0.0` → 1.1.0; `~1.0.0` → 1.0.0. Note: pnpm/Yarn release-age gates are zeroed in these projects — fresh fixtures are "quarantined" otherwise.

Verify: install in npm/ (caret) vs npm-tilde/, compare `require('demo-lib-c').version`.
