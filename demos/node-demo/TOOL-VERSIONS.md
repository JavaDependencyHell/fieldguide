# Node Tool Version Reference

Key version breakpoints for the Node dependency tools covered by the book.
Each scenario guide carries a "Tool Versions" callout; this file is the source
those callouts draw from. Dates are from npm registry publish metadata.

**Demo-tested versions (2026-10-19, verified by execution — all checks pass):**
npm **12.0.1** · Node **26.4.0** · pnpm **11.10.0** · Yarn **4.17.0**
(via Corepack 0.35, installed separately) · Verdaccio **6.10.6** (harness registry).
First verified 2026-07-07 on npm 10.9.8 / Node 22.22.3 / Verdaccio 6.7.4; no
behaviour the guides describe changed between the two runs (lockfileVersion
stays 3, `ERESOLVE` wording unchanged, overrides unchanged).

## npm

| Version | Date | Significance |
|---------|------|-------------|
| 3.0     | Jun 2015 | **Flat / hoisted node_modules** (npm 2 was fully nested). Created hoisting — and phantom dependencies (N3). |
| 5.0     | May 2017 | **`package-lock.json` by default** — npm's answer to Yarn's lockfile (N5). |
| 6.0     | Apr 2018 | **`npm audit`** built in (N12). |
| 7.0     | Oct 2020 | **Peer dependencies auto-installed and enforced** (`ERESOLVE`, N8); native **workspaces** (N10); lockfileVersion 2. `--legacy-peer-deps` added as the escape valve. |
| 8.3     | Dec 2021 | **`overrides`** — central version forcing, ~4 years after Yarn's `resolutions` (N6). |
| 11.10   | Feb 2026 | `min-release-age` cooldown setting (opt-in, default off); `--before=<date>` has existed since npm 6 (N4). |

**Key breakpoints:** npm 3 (tree shape), npm 7 (peers). `npm ci` obeys the
lock; `npm install` maintains it — CI should use the former (N5).

## pnpm

| Version | Date | Significance |
|---------|------|-------------|
| 1.0     | Jun 2017 | Content-addressed store, strict symlinked node_modules — no hoisting, no phantoms (N3, N9). |
| 10.x    | Jan 2025 | Settings consolidate into `pnpm-workspace.yaml`; `minimumReleaseAge` setting added in 10.16 (opt-in). |
| 11.0    | Apr 2026 | **`overrides` read from `pnpm-workspace.yaml`** — the package.json `pnpm.overrides` block is no longer read (N6, verified). **`minimumReleaseAge`** cooldown on by default (N4). `pnpm peers check` added (N8). |

**Key behaviour:** layout is a pure function of the lockfile — install history
never changes the tree (N9), and root code can only require declared deps (N3).

## Yarn

| Version | Date | Significance |
|---------|------|-------------|
| 0.x     | Oct 2016 | Launch: `yarn.lock` by default — forced npm's hand on locking (N5). |
| 1.0     | Sep 2017 | **`resolutions`** (N6); workspaces (N10). Yarn 1 ("classic") is frozen in maintenance. |
| 2.x "Berry" | 2020 | **Plug'n'Play**: no node_modules, full-graph resolver, phantom imports impossible (N3). `nodeLinker: node-modules` remains available. |
| 4.0     | Oct 2023 | Modern baseline; distributed through the `packageManager` field (Corepack, or any tool that honours the pin). |
| 4.10    | Sep 2025 | `npmMinimalAgeGate` setting added (opt-in). |
| 4.15    | May 2026 | **`npmMinimalAgeGate` on by default** — fresh releases quarantined (N4). |
| 4.17    | Jun 2026 | Demo-tested. The age gate becomes **per-scope**: an `npmScopes` entry needs its own gate setting (N11, verified). |

**Key behaviour:** PnP is the default install mode; the book's demos use
`nodeLinker: node-modules` except N3, where PnP *is* the story.

## The harness

Two local Verdaccio registries (public :4873, private :4874), storage under
`target/`, populated by `install_node_deps.sh`. pnpm and Yarn arrive via
Corepack from each project's `packageManager` pin. **Corepack is bundled with
Node 14.19 through 24 only; Node 25+ no longer distributes it** — install it
with `npm install -g corepack` (the harness's prerequisite check tells you
when). Because both tools now
ship **release-age cooldowns** (see above), the demo projects explicitly zero
them (`minimumReleaseAge: 0`, `npmMinimalAgeGate: 0`) — the fixture packages
are always "too fresh" otherwise. That inconvenience is itself a finding: the
ecosystem has started refusing brand-new releases by default.

## Scenarios where version matters most

| Scenario | Why version matters |
|----------|-------------------|
| N3 Phantoms | npm ≥ 3 hoists (phantom works); any pnpm and Yarn-PnP refuse. |
| N4 Semver | pnpm 11 / Yarn 4.15+ age-gates (on by default) can steer range resolution until configured; npm 11.10's `min-release-age` is opt-in. |
| N5 Locks | package-lock needs npm ≥ 5; lockfileVersion 3 is npm ≥ 9's default (still 3 on npm 12). |
| N9 Tree shape | package-lock v2/v3 records placement by path, so `npm ci` reproduces a history-shaped tree; only a lock-less fresh install re-hoists (verified on npm 12). |
| N6 Overrides | npm ≥ 8.3 only; pnpm 11 moved overrides to pnpm-workspace.yaml. |
| N8 Peers | The behaviour cliff is npm 7: before, peers were suggestions; after, `ERESOLVE`. |
| N10 Workspaces | npm ≥ 7 for native workspaces; `workspace:` protocol is pnpm/Yarn only. |
| N12 Audit | `npm audit` needs npm ≥ 6; `pnpm audit` and `yarn npm audit` query the same advisory endpoint (all three demoed). |
