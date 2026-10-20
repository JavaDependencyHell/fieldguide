# Node Scenarios — Plan

**Track:** Dependency Management (book-bound) · **Status:** wave 1 BUILT & execution-verified (2026-07-07: 36/36 verify.sh checks, `make audit` green, book-integrated) · **Date:** 2026-07-07

> Deviations from plan, discovered by execution: Verdaccio is a harness-local npm install under `target/node-harness` (no global install — answers the open question); pnpm 11 and Yarn 4.17 ship release-age cooldowns by default, which the harness zeroes and N4 documents; pnpm 11 reads `overrides` from `pnpm-workspace.yaml` only; Yarn's `npmMinimalAgeGate` is per-scope (N11). Scenario titles/numbering as planned except "Deduplication" folded into N9 (Tree Shape) and "Optional Dependencies" folded into N7 (Dependency Types).

## Ground rules

- **Tools:** npm, pnpm, Yarn 4 (Berry) — every scenario gets a demo and a verify check for all three. The direct analogue of pip/Poetry/uv: npm is the default culture, pnpm the strict structurally-different one, Yarn the third model. Yarn runs its default node-modules linker except where Plug'n'Play *is* the story (N3). Yarn 1 (classic) gets history notes, not a demo track. Bun and Corepack are second-wave sidebars.
- **Hybrid guides:** same convention as Python — collapse where the tools behave identically, full comparative treatment where they diverge. Suggested split: N1, N4, N7 collapsed; the other nine comparative.
- **Numbering:** Node-native (N1–N12 core), not forced onto the JVM grid — the Python part proved this out. The index.qmd Node sketch (N13 workspaces, N14 dedup, N16 registry, N18 audit) predates this plan and gets renumbered when scenarios land, exactly as the Python pathway was.
- **Harness:** npm/pnpm/yarn speak a registry *API*, not static files, so the local-index trick becomes a local **Verdaccio** instance on 127.0.0.1 (plus a second instance for the private-registry scenarios), with `demo-lib-a/b/c/d` fixture packages mirroring the JVM/Python fixtures, published by an `install_node_deps.sh` equivalent. One throwaway install dir per scenario per tool, created and destroyed by verify.sh. Offline determinism via registry URL pinning in per-tool config (`.npmrc` / `pnpm` config / `.yarnrc.yml`).
- **Verification discipline:** no guide ships until its claim is reproduced by execution against pinned tool versions, recorded in `node-demo/TOOL-VERSIONS.md` (Node LTS + npm + pnpm + yarn, dates from the npm registry, pinned at write time).
- **Cross-references both ways at write time:** each N guide links its S and P siblings *and* the reverse links go into the JVM/Python guides in the same PR — lesson from the Python review, where the reverse pass had to be retrofitted.
- **Structural rule stated up front in the part intro:** Node completes the triangle. The JVM flattens and picks a winner; Python flattens and demands agreement; **Node nests — every package can have its own copy.** Node "solved" dependency hell by allowing duplication, and bought three new hells with it: tree size, phantom dependencies, and singletons that must not be duplicated. Every scenario hangs off this.

## Core scenarios (wave 1)

| # | Working title | Siblings | Tool behaviour | The point |
|---|---------------|----------|----------------|-----------|
| N1 | Basic Transitive Resolution | S1 / P1 | ~identical (collapsed) | One install pulls the chain; how to *see* the tree (`npm ls`, `pnpm why`, `yarn why`); the nested node_modules model. |
| N2 | The Diamond: Everyone Wins | S2 / P2 | same outcome, divergent layouts | Two deps need different `demo-lib-c` versions → **both install**, nested. The JVM evicts, Python fails, Node duplicates. The model scenario — and the cost is two copies in memory. |
| N3 | Hoisting & Phantom Dependencies | — (Node-native) | maximum divergence | npm's flattening lets you `require` a package you never declared; works until an unrelated change reshapes the tree. pnpm's strict symlink layout and Yarn PnP fail fast instead. Flagship comparative scenario. |
| N4 | Semver & the `^` Culture | S9 / P4 | ~identical (collapsed) | Caret-by-default: every `npm install <pkg>` writes an open range. Same package.json, different day, different tree. Python's `>=` culture with sharper defaults and better norms (semver as social contract). |
| N5 | Lock Files | S11 / P5 | divergent formats, convergent philosophy | package-lock.json (v3) vs yarn.lock vs pnpm-lock.yaml; `npm ci` vs `npm install`. The inversion of P5: here *everyone* locks by default — culture, not tooling, is why Node got there first. |
| N6 | Overrides & Resolutions | S3/S6 / P6 | divergent syntax, same lever | npm `overrides`, Yarn `resolutions`, `pnpm.overrides`: central forcing of a transitive version — the lever Python mostly lacks (P9) and the JVM does via BOM. Blunt by design; what breaks when you force too hard. |
| N7 | Dependency Types | S7/S8 / P7 | ~identical (collapsed) | dependencies / devDependencies / optionalDependencies; `--omit=dev`; what ships to consumers vs what builds the project. Peers deliberately deferred to N8. |
| N8 | Peer Dependencies: Where Flat Returns | — (Node-native) | divergent | The one place Node demands a single shared copy (plugin hosts, react-style singletons). npm 7's auto-install and `ERESOLVE`; `--legacy-peer-deps` as the modern footgun; pnpm/yarn's different strictness. The Python-style conflict, reintroduced on purpose. |
| N9 | Tree Shape & Deduplication | — (Node-native) | divergent | Same dependencies, different tree shapes depending on install *history*; `npm dedupe`; why two checkouts differ; pnpm's content-addressed store as the structural answer. Explains "works on my clone". |
| N10 | Workspaces & Monorepos | uv workspaces / JVM multi-module | divergent | All three tools, three flavours; the `workspace:` protocol; hoisting across workspace boundaries as N3's hazard at scale. |
| N11 | Private Registry & Dependency Confusion | S16/S17 / P11 | divergent + security | npm is the *origin* of Birsan's 2021 attack. Scoped packages (`@acme/`) as the structural mitigation Python doesn't have; `.npmrc` scope→registry pinning; where unscoped names still leak. left-pad in the Wild. Strongest HeroDevs tie-in alongside N12. |
| N12 | Auditing & EOL Packages | P12 | divergent | `npm audit` and its noise problem (why devs learned to ignore it); deprecated and abandoned transitives; remediation via overrides (N6) since removal is no more possible than in Python. Closes the part the way triage opens the book. |

## Second wave (planned, not numbered-in yet)

Install scripts & postinstall (the supply-chain scenario with **no JVM or Python sibling at all** — `--ignore-scripts`, the recurring npm-worm vector) · The ESM/CJS dual-package hazard (two live copies of one package at runtime — Node's version of the JVM classpath-duplication story, and the place N2's "everyone wins" bites back) · Patching in place (`patch-package`, `pnpm patch`, `yarn patch` — the S15 substitution sibling, richer than anything Python offers) · Deprecate, unpublish & the left-pad policy aftermath (npm's answer to PyPI yanking) · Corepack & tool pinning · Bun sidebar.

## Book integration

- New book part "Node Scenarios" after the Python part; same `#### !` section template, same Tool Versions callout (cite `node-demo/TOOL-VERSIONS.md`), same Related-link convention — N↔S and N↔P links **both ways, at write time**.
- The three-model triangle (JVM picks / Python agrees / Node duplicates) becomes a book asset: one diagram in the Node part intro, referenced from the comparison table. Node gets its own npm/pnpm/yarn table like Python's, rather than columns bolted onto the JVM table.
- index.qmd Node pathway: renumber the sketched links (N13/N14/N16/N18 → N10/N9/N11/N12) when scenarios land; keep "coming soon" until each is verified.
- Cheat sheet gains a Node section (tree/lock/override/audit one-liners per tool).

## Pipeline notes (Substack-first)

Standalone Substack candidates before book assembly: N3 (phantom dependencies — "the import you never declared"), N8 ("the day npm 7 broke your install" — resolver history in the P3 vein), N11 (dependency confusion came *from* npm — HeroDevs blog companion obvious). N12 is the direct HeroDevs marketing piece: NES sells EOL support for exactly this ecosystem (Node, Vue, AngularJS). Sequence as with Python: scenario + demo first, verify, then lift the article from verified material.

## Open questions

- Verdaccio version pinning and whether it runs as a devDependency of the harness or a global install — decide when building the harness.
- Yarn PnP: one scenario leg (N3) or a recurring third column everywhere? Start with N3 only; widen if the divergence earns it.
- Node version: pin the active LTS at write time (record in TOOL-VERSIONS.md); note npm ships with Node, so the npm pin follows the Node pin unless explicitly upgraded.
