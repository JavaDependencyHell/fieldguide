#!/usr/bin/env node
// build_node_fixtures.mjs
// Generates the Node fixture packages and publishes them to the two local
// Verdaccio registries (public :4873, private :4874), which must already be
// running — install_node_deps.sh handles the lifecycle.
//
// Graph (mirrors the JVM/Python fixtures):
//   demo-lib-a 1.0.0 -> demo-lib-b 1.0.0 -> demo-lib-c 1.0.0
//   demo-lib-a 2.0.0 -> demo-lib-b 2.0.0 -> demo-lib-c 2.0.0
//   demo-lib-c 1.0.0 / 1.1.0 / 2.0.0    leaves (1.1.0 exists for semver demos)
//   demo-lib-d 1.0.0                     leaf (dev-dependency fixture)
//   demo-plugin 1.0.0                    peerDependencies: demo-lib-c ^1.0.0
//   acme-internal-tool 9.9.9  -> PUBLIC  (dependency-confusion impostor)
//   acme-internal-tool 1.0.0  -> PRIVATE (genuine)
//   @acme/internal-tool 1.0.0 -> PRIVATE (genuine, scoped — the npm mitigation)

import { mkdtempSync, writeFileSync, mkdirSync, rmSync } from "node:fs";
import { execSync } from "node:child_process";
import { tmpdir } from "node:os";
import { join } from "node:path";

const PUBLIC = "http://127.0.0.1:4873/";
const PRIVATE = "http://127.0.0.1:4874/";

// Every package's index.js exports { name, version } plus, where it has a
// dependency, the dependency's export — so tests can read the *chain*
// (e.g. require('demo-lib-a').b.c.version) under any layout, including PnP.
const fixtures = [
  { name: "demo-lib-a", version: "1.0.0", deps: { "demo-lib-b": "1.0.0" }, child: "b:demo-lib-b", to: PUBLIC },
  { name: "demo-lib-a", version: "2.0.0", deps: { "demo-lib-b": "2.0.0" }, child: "b:demo-lib-b", to: PUBLIC },
  { name: "demo-lib-b", version: "1.0.0", deps: { "demo-lib-c": "1.0.0" }, child: "c:demo-lib-c", to: PUBLIC },
  { name: "demo-lib-b", version: "2.0.0", deps: { "demo-lib-c": "2.0.0" }, child: "c:demo-lib-c", to: PUBLIC },
  { name: "demo-lib-c", version: "1.0.0", to: PUBLIC },
  { name: "demo-lib-c", version: "1.1.0", to: PUBLIC },
  { name: "demo-lib-c", version: "2.0.0", to: PUBLIC },
  { name: "demo-lib-d", version: "1.0.0", to: PUBLIC },
  { name: "demo-plugin", version: "1.0.0", peers: { "demo-lib-c": "^1.0.0" }, to: PUBLIC },
  // dependency-confusion fixtures
  { name: "acme-internal-tool", version: "9.9.9", compromised: true, to: PUBLIC },
  { name: "acme-internal-tool", version: "1.0.0", to: PRIVATE },
  { name: "@acme/internal-tool", version: "1.0.0", to: PRIVATE },
];

const work = mkdtempSync(join(tmpdir(), "node-fixtures-"));
// npm requires an auth token to publish; verdaccio ($all) accepts any.
const npmrc = join(work, ".npmrc");
writeFileSync(
  npmrc,
  `//127.0.0.1:4873/:_authToken=fixture\n//127.0.0.1:4874/:_authToken=fixture\n`
);

for (const f of fixtures) {
  const dir = join(work, f.name.replace("/", "__") + "-" + f.version);
  mkdirSync(dir, { recursive: true });
  const pkg = {
    name: f.name,
    version: f.version,
    main: "index.js",
    ...(f.deps ? { dependencies: f.deps } : {}),
    ...(f.peers ? { peerDependencies: f.peers } : {}),
  };
  writeFileSync(join(dir, "package.json"), JSON.stringify(pkg, null, 2));
  const marker = f.compromised ? "COMPROMISED (public lookalike)" : "genuine";
  const childLine = f.child
    ? `, ${f.child.split(":")[0]}: require("${f.child.split(":")[1]}")`
    : "";
  writeFileSync(
    join(dir, "index.js"),
    `// ${f.name} ${f.version} — Dependency Hell demo fixture (${marker})\n` +
      `module.exports = { name: "${f.name}", version: "${f.version}"${childLine} };\n`
  );
  execSync(`npm publish --registry=${f.to} --loglevel=error`, {
    cwd: dir,
    env: { ...process.env, NPM_CONFIG_USERCONFIG: npmrc },
    stdio: ["ignore", "ignore", "inherit"],
  });
  console.log(`published ${f.name}@${f.version} -> ${f.to}`);
}

rmSync(work, { recursive: true, force: true });
console.log("All Node fixtures published.");
