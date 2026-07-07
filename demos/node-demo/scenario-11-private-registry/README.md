### Node Scenario 11: Private Registry & Dependency Confusion

acme-internal-tool: 1.0.0 on the private registry (:4874), 9.9.9 impostor on the public one (:4873). Unscoped name + public default registry installs 9.9.9; single private registry or scoped @acme routing installs 1.0.0. Yarn note: npmMinimalAgeGate is per-scope.

Verify: npm-vulnerable → 9.9.9; npm-safe, npm-scoped, pnpm, yarn → 1.0.0.
