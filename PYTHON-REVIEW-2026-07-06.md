# Python Scenarios Review — Dependency Hell Field Guide
**Date:** 2026-07-06 · **Scope:** all 12 Python scenario guides (P1–P12), `python-demo/TOOL-VERSIONS.md`, demo fixtures, verify.sh, book integration (static/prose review; suspect claims verified against pip docs, PEPs, and tool changelogs)

> **Resolution status (2026-07-07):** all findings below have been **fixed**, and the demos **verified by execution** — see "Resolution — 2026-07-07" at the end of this document.

## Verdict

The Python track is in far better shape than the SBT track was at review: all 12 demos exist with pip/Poetry/uv legs, every `include`/snippet tag resolves, every relative link works, the fixture graph matches every guide's diagram and Check, and verify.sh fails hard on missing tools per the house discipline. The writing is clear and the Expect/Actual pedagogy lands.

Two factual problems need fixing before publication, and both are ironic given the scenarios they live in: (1) the pip resolver timeline is shifted one release late everywhere it appears — including in P3, the scenario *about* resolver history; (2) P7 says "pip has no group concept at all," but pip 25.1 shipped PEP 735 `--group` support — and the book pins pip 25.3. Everything else is precision and polish.

---

## HIGH — factually wrong; fix before publication

### 1. pip resolver timeline is wrong in every place it appears
**Where:** `TOOL-VERSIONS.md` pip table; P2 Tool Versions callout ("default since 21.0"); P3 Tool Versions callout ("opt-in at 20.3, default at 21.0, and the only option from 22.2"); P3 Fix ("`--use-feature=2020-resolver` (20.3–21)"); TOOL-VERSIONS "Scenarios where version matters most" P2 row ("pip ≥ 21 fails cleanly").

**Reality** (per pip's own deprecation timeline, [pip user guide](https://pip.pypa.io/en/stable/user_guide/#changes-to-the-pip-dependency-resolver-in-20-3-2020)):

| Version | Date | What actually happened |
|---------|------|------------------------|
| 20.1 | Apr 2020 | Alpha, opt-in `--unstable-feature=resolver` |
| 20.2 | Jul 2020 | Beta, opt-in `--use-feature=2020-resolver` |
| **20.3** | **Nov 30, 2020** (not Oct) | **New resolver DEFAULT for Python 3**; legacy via `--use-deprecated=legacy-resolver` |
| 21.0 | Jan 2021 | Legacy resolver declared unsupported (and Python 2 dropped) |

The book shifts each step one release late: opt-in was 20.2 not 20.3, default was 20.3 not 21.0. The "legacy resolver **removed** in 22.2" claim has no support — pip's current (26.1) docs still describe removal as "a future release." The `--use-feature=2020-resolver` flag advice in P3's Fix is doubly wrong: the flag belongs to 20.2, and on 20.3+ (Python 3) the new resolver is already the default so nobody needs it.

**What survives:** "pip < 20.3 installs the broken environment silently" (P2/P3 Risk, TOOL-VERSIONS breakpoint line) is correct — keep it. Fix: correct the four call-sites and the table; change "pip ≥ 21 fails cleanly" to "pip ≥ 20.3".

### 2. "pip has no group concept" — false at the pinned pip 25.3
**Where:** P7 Tool Versions callout ("pip has no group concept and uses multiple requirements files instead"); P7 Actual ("pip has no group mechanism at all"); P7 Fix and Takeaway ("pip has extras but no groups — mind the gap"); TOOL-VERSIONS P7 row ("pip has no groups").

**Reality:** pip 25.1 (Apr 2025) added PEP 735 support — `pip install --group dev` reads `[dependency-groups]` straight from `pyproject.toml` ([pip user guide, "Dependency Groups", "Added in version 25.1"](https://pip.pypa.io/en/stable/user_guide/#dependency-groups)). The book pins and claims to test pip **25.3**, so the flat denial is wrong for the book's own toolchain.

**What survives:** the comparative point is still real — pip only *installs* groups (nothing writes or locks them), and the requirements-files idiom remains the dominant pip culture. Fix: reframe as "pip gained `--group` in 25.1; before that (and still commonly), separate requirements files," and consider adding a `pip install --group dev` leg to the demo and verify check so all three tools are exercised on the same `[dependency-groups]` table.

---

## MEDIUM — misleading, stale, or unsourced

### 3. Poetry + PEP 751: "not shipped as of 2.4" is stale
**Where:** P5 Tool Versions callout and Wild; TOOL-VERSIONS Poetry section and PEP 751 section ("Poetry had not shipped support as of 2.4").
Since Poetry 2.3 (Jan 2026) with poetry-plugin-export ≥ 1.10, `pylock.toml` **export is supported** via the official export plugin ([python-poetry discussion #10322](https://github.com/orgs/python-poetry/discussions/10322)). What Poetry still can't do is *replace* `poetry.lock` with pylock natively. Fix the phrasing to that precise split: "export via the official plugin since 2.3; no native pylock lockfile."

### 4. uv timeline rows in TOOL-VERSIONS
Three rows are off:
- "0.2 Jun 2024 — `uv lock` / `uv.lock`, project mode": project mode and `uv lock` were `--preview` experiments during 0.2.x; the public launch was **0.3.0, Aug 20, 2024**.
- "0.3 — Workspaces, dependency groups": workspaces yes; PEP 735 `[dependency-groups]` landed in **0.4.27 (late Oct 2024)**, not 0.3.
- "0.5+ 2025 — `uv export --format pylock.toml`": landed in **0.6.15 (Apr 2025)** ([release notes](https://github.com/astral-sh/uv/releases/tag/0.6.15)).

### 5. PEP 668 misattributed to Python 3.11 (P10 Wild)
"Python 3.11 added PEP 668, which makes system interpreters refuse `pip install` outright." PEP 668 is a packaging spec, not an interpreter feature: enforcement is **pip ≥ 23.0** honoring a distro-shipped `EXTERNALLY-MANAGED` marker file (Debian 12, Ubuntu 23.04+, etc.). A stock python.org 3.11 refuses nothing. Suggested rewording: "pip now implements PEP 668: distros mark their system interpreter externally-managed, and pip refuses to install into it."

### 6. "The technique now has a name and a CWE" (P11 Wild)
Dependency confusion has no dedicated CWE; it's conventionally mapped to CWE-427 (uncontrolled search path element). Either cite CWE-427 explicitly or drop the clause. Everything else in the Birsan paragraph (Apple/Microsoft/Shopify, ~$130k in bounties, 2021) checks out.

### 7. Unsourced survey claim (P4 Wild)
"Surveys of `requirements.txt` files in the wild find bare `>=` vastly outnumbering `~=`" — no citation exists in the book for this. Cite a real study or soften to an observation ("look at almost any public requirements.txt").

### 8. P↔S cross-references are one-way
The plan commits to cross-references both ways; every P guide links its JVM sibling, but no Maven/Gradle/SBT guide links back to any P scenario (zero hits for `python-demo` across the three JVM tracks). Add the reverse links or note the deferral in the plan.

---

## LOW — polish

- **P11 "mal/mistakenly"** — awkward coinage; "maliciously or by mistake" reads cleaner.
- **P12 Wild, final sentence** — "A sensitive-topic note: …" is off-voice for the book (reads like an editorial aside). Cut it, or fold "treat findings as an upgrade plan, not a verdict" into Fix.
- **P7 "the default-but-skippable `--no-dev` in uv"** — confusing. Say it directly: uv installs the dev group by default; `--no-dev` skips it.
- **P2 Wild** — "only proven impossible after exhausting the search space" slightly overstates; PubGrub-style resolvers prove impossibility early via conflict learning. Optional nitpick.
- **TOOL-VERSIONS internal tension** — the pip table lists `pip lock` (25.1) but the section footer says "pip has no native lock file." Add "(experimental `pip lock` aside)".
- **Taglines** — the Python part copies the Gradle/SBT tagline pattern "Or what to Do When…" including the odd mid-phrase capital ("what to **D**o"). Consistent with two of three JVM tracks, but it's a book-wide typo pattern; if it gets fixed, fix it everywhere at once.

---

## Verified clean (worth stating)

- **Fixture/guide agreement:** the wheel graph in `scripts/build_python_fixtures.py` (lib-a→lib-b→lib-c, the `[feature]` extra → lib-d, the 9.9.9 `acme-internal-tool` impostor) matches every diagram, Expect/Actual, and Check across P1–P12, including the P9 uv-override value and the P11 index split (private 1.0.0 / public 9.9.9).
- **Mechanics all correct:** `~=1.0` ≡ `>=1.0, <2.0` (PEP 440); constraints-file semantics and its pip 7.1/2015 origin (confirmed in pip's docs); `--extra-index-url` flat-pool/highest-version-wins; uv `first-index` default and `override-dependencies` replacing-not-removing; markers as PEP 508 standard; `pip freeze` carrying no hashes; urllib3 1.26.4 having published CVEs; pip-audit's Trail of Bits → PyPA history; PEP 751 accepted 2025 with `pip lock` at 25.1 and `pip install -r pylock.toml` at 26.1 (both TOOL-VERSIONS rows correct).
- **Structure:** all snippet tags resolve, all relative links valid, `_quarto.yml` part wired, index.qmd pathway links now point at real guides (the broken-link finding from the JVM review is resolved), cheat sheet and standalone Python comparison table present as planned, verify.sh has hard tool-prerequisite failure and per-scenario fresh venvs.
- **Honest hedges:** P12 declares its network dependency and unfrozen findings; P8 notes the marker flip on 3.7 as a described (not demoed) behaviour — acceptable, though worth a code comment that the harness's Python 3.10 only ever exercises one marker branch.

## Resolution — 2026-07-07

### Open facts confirmed before editing

- **Legacy resolver never removed.** Inspected pip wheels 22.1 → 25.3 from PyPI: the `resolution/legacy` module and the `--use-deprecated=legacy-resolver` option are present in every one, including the book's pinned 25.3. "Removed in 22.2" was wrong in kind, not just in date.
- **Release dates from PyPI metadata (authoritative):** pip 20.2 = 2020-07-29, 20.3 = 2020-11-30, 21.0 = 2021-01-23, 25.1 = 2025-04-26, 25.3 = 2025-10-25, 26.1 = 2026-04-26; poetry 1.2.0 = 2022-08-31, 2.0.0 = 2025-01-05, 2.3.0 = 2026-01-18, 2.4.1 = 2026-05-09; poetry-plugin-export 1.10.0 = 2026-01-18; uv 0.2.0 = 2024-05-22, 0.3.0 = 2024-08-20, 0.4.27 = 2024-10-25, 0.6.15 = 2025-04-22. All confidence-note caveats below are hereby settled.

### Fixes applied

- **Finding 1:** TOOL-VERSIONS pip table rewritten (20.2 opt-in beta, 20.3 Nov 2020 default, 21.0 deprecated/unsupported — still present behind the flag as of 25.3); P2 callout "default since 20.3"; P3 callout, mermaid label, and Fix corrected; P2 row in the version-matters table now "pip ≥ 20.3".
- **Finding 2:** P7 callout/Actual/Fix/Check/Takeaway rewritten around `pip install --group` (25.1+); new `scenario-7-extras-groups/pip/pyproject.toml` with the standard `[dependency-groups]` table; new verify.sh check for the pip `--group` leg.
- **Findings 3/4:** TOOL-VERSIONS Poetry and uv tables corrected (Poetry 2.3 + plugin-export 1.10 pylock export; uv 0.3.0 project launch, 0.4.27 groups, 0.6.15 pylock export); P5 callout updated to include Poetry's export path.
- **Finding 5:** P10 Wild rewritten — PEP 668 enforcement correctly attributed to pip 23.0+ plus distro marker files (Debian 12, Ubuntu 23.04+).
- **Findings 6/7 + LOW items:** P11 CWE clause dropped, "mal/mistakenly" reworded; P4 survey claim softened to observation; P12 off-voice aside cut; P7 uv `--no-dev` phrasing fixed; P2 Wild PubGrub precision fix; TOOL-VERSIONS lock-file tension resolved.
- **Finding 8:** reverse links added to all 12 Maven guides the P scenarios cite (MS1→P1, MS2→P2, MS3→P6, MS5/MS18→P9, MS7/MS8→P7, MS9/MS14→P4, MS11→P5, MS16/MS17→P11), matching each guide's local Related style; all 12 verified to resolve. MS1 and MS16 had no Related section and gained one. Note: three Maven guides carry pre-existing Related-heading drift (`#### Related Scenarios` in MS3, `### ! Related` in MS11/MS14) — left as-is, it's the JVM review's template-drift item.
- **Bonus:** P3 Wild now notes the legacy resolver is still runnable on modern pip — verified live (below).

### Execution results (sandbox, 2026-07-07)

Toolchain: Python 3.10.12, Poetry 2.4.1, uv 0.11.19, system pip 25.3, venv-bundled pip 22.0.2 (backtracking era; the `--group` check upgrades its venv to ≥ 25.1). Matches the book's pins (pip 25.3 / Poetry 2.4 / uv 0.11 / Python 3.10) except venv-internal pip, noted below. Fixtures rebuilt from scratch via `install_python_deps.sh`.

**All 12 scenarios: 34/34 verify.sh checks PASS**, including the new pip `--group` check (P7) and the network-dependent pip-audit check (P12).

Supplementary check with pip pinned to exactly 25.3 inside a fresh venv, on the P2 conflict fixture: default resolver → `ResolutionImpossible`, nothing installed; `--use-deprecated=legacy-resolver` → "Successfully installed demo-lib-a-2.0.0 demo-lib-b-2.0.0 demo-lib-c-1.0.0" with an incompatibility warning in the same output — the broken environment P3 describes, reproduced on current pip. This confirms both the corrected timeline and the new P3 Wild sentence.

Residual caveat: the standard verify.sh venv checks ran with venv-bundled pip 22.0.2 rather than 25.3 (both are post-20.3 backtracking-era; behaviourally identical for everything the scenarios test, and the P2/P11 pivotal behaviours were additionally reproduced on exactly 25.3).

## Review confidence notes

Findings 1, 2, and the pip-side rows of finding 4 are anchored in primary sources read during this review (pip's published deprecation timeline and user guide; uv 0.6.15 and 0.4.27 release records). Weaker spots in this review itself, in honesty order:

- **"Removed in 22.2 has no support"** — based on pip 26.1's docs still describing legacy-resolver removal as future. The 22.2 changelog itself was not checked; if it does mention removal, the finding narrows to "wrong framing" rather than "wrong fact." Verify against the 22.2 changelog before editing.
- **Poetry pylock export "since 2.3 + plugin 1.10, Jan 2026"** — version minimums come from the python-poetry discussion; the January date from secondary reporting. Confirm the plugin release date before quoting it in the book.
- **uv 0.3.0 launch date (Aug 20, 2024) and "0.2.x preview" framing** — from general knowledge of the announcement, not re-verified against the 0.2.x/0.3.x changelogs this session. The 0.4.27 and 0.6.15 rows *were* verified.
- **CWE-427 mapping for dependency confusion** — conventional mapping, no authoritative registry citation; treat finding 6's suggested replacement text with the same skepticism as the original.
- **Demos not executed** — this was a prose review by request. Fixture/guide agreement was checked by reading `build_python_fixtures.py` and verify.sh, not by running them; the "verified clean" section asserts consistency, not passing tests. (Confirmed directly: verify.sh's Scenario 8 block only exercises the ≥3.8 marker branch.)

## Suggested fix order

1. Resolver timeline (finding 1) — one systematic pass across TOOL-VERSIONS + P2 + P3.
2. pip `--group` (finding 2) — reword P7, optionally extend demo + verify.
3. TOOL-VERSIONS precision rows (findings 3, 4) in the same edit.
4. Wording fixes (5–7, LOW items) in a single polish pass.
5. Reverse P↔S links (finding 8) when convenient.
