# Node Demos (N1–N12)

Executable demos for the book's Node scenarios, covering **npm, pnpm and
Yarn 4**. Each `scenario-*/` directory holds one project per tool plus the
`guide.qmd` chapter written from the verified behaviour.

## The part's thesis

The JVM flattens and picks a winner; Python flattens and demands agreement;
**Node nests — every package can have its own copy.** Duplication dissolves
the classic diamond (N2) and buys three new problems: tree size, phantom
dependencies (N3), and singletons that must not be duplicated (N8).

## Prerequisites

- Node ≥ 22 (npm included)
- `corepack enable` — pnpm and Yarn are fetched per-project from each demo's
  `packageManager` pin; no separate installs
- Network on first run only (Verdaccio install + Corepack downloads)

## Running

```bash
../../install_node_deps.sh   # once: local Verdaccio + fixture packages
./verify.sh                  # all scenarios (or: ./verify.sh 3)
```

`verify.sh` starts two local registries (public :4873, private :4874), runs
every check in a throwaway copy of each project, and tears everything down.
Scenario 12 (`npm audit`) talks to the real npm registry and needs network.

## Fixture graph

```
demo-lib-a 1.0.0 -> demo-lib-b 1.0.0 -> demo-lib-c 1.0.0
demo-lib-a 2.0.0 -> demo-lib-b 2.0.0 -> demo-lib-c 2.0.0
demo-lib-c 1.1.0                        (semver demos)
demo-lib-d 1.0.0                        (devDependency fixture)
demo-plugin 1.0.0                       (peerDependencies: demo-lib-c ^1.0.0)
acme-internal-tool 9.9.9   PUBLIC      (dependency-confusion impostor)
acme-internal-tool 1.0.0   PRIVATE     (genuine)
@acme/internal-tool 1.0.0  PRIVATE     (genuine, scoped)
```

Versions and breakpoints: see `TOOL-VERSIONS.md`.
