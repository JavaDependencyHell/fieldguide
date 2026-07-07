### Node Scenario 7: Dependency Types

demo-lib-a in dependencies, demo-lib-d in devDependencies. Default installs bring both; production installs (`--omit=dev` / `--prod` / `yarn workspaces focus --production`) drop demo-lib-d.

Verify: `require('demo-lib-d')` works after default install, fails after production install.
