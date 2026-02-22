Purpose: Ensure every “Seen in the Wild” example is defensible, realistic, and source-aligned.

Do NOT remove the section globally. Only adjust where specified.

PRIORITY A — KEEP (already defensible with known evidence)

These are realistic patterns widely documented in industry.
They only need minor wording polish (optional).

A1. Scenario 2 — Commons Collections override
Status: COMPLETED
Confidence: HIGH

Text currently describes a financial firm forcing a patched Commons Collections version.

Dependency-Hell

Why safe:

Matches real post-2015 behaviour

Strong public precedent

Aligns with FoxGlove + CVE history

Optional polish (recommended but not required):

Change opening to slightly more neutral:

REWRITE TO:

“A number of financial institutions discovered vulnerable versions of Apache Commons Collections deep in their transitive graphs…”

This removes the implied single-company claim.

A2. Scenario 4 — Spring Boot BOM override for vulnerability
Status: COMPLETED
Confidence: HIGH

Current pattern appears multiple times.

Why safe:

Extremely common real-world practice

Strong vendor documentation exists

Matches Log4Shell-era behaviour

Minor tightening recommended:

Change:

“A team using the Spring Boot BOM hit a critical vulnerability…”

TO:

“Many teams using the Spring Boot BOM encountered cases where a patched library version was required before an updated BOM was available…”

This removes anecdotal singularity and strengthens credibility.

A3. Scenario 7 — provided scope missing at runtime
Status: COMPLETED
Confidence: HIGH

Current text: IDE works, production fails with NoClassDefFoundError.

Dependency-Hell

Why safe:

This is one of the most common real failures in Java EE/Spring deployments.

Optional polish:

Change:

“A developer’s web application…”

TO:

“A common production failure occurs when…”

This makes it pattern-based instead of story-based.

A4. Scenario 9 — CI vs local cache version range failure
Status: COMPLETED
Confidence: HIGH

You have multiple variants of this story.

Why safe:

Well documented in Maven/Gradle ecosystems

Matches official guidance

Very credible

Action:

Keep ONE strong version.
Remove duplicates (see Priority C).

A5. Spark uber-jar shrink via Provided
Status: COMPLETED
Confidence: HIGH

Text about 300MB → 12MB after switching to Provided.

Dependency-Hell

Why safe:

Very realistic Spark/SBT pattern.

Minor polish:

Change numeric specificity slightly to avoid “made up” smell:

Replace:

“300MB … 12MB”

WITH:

“hundreds of megabytes … tens of megabytes”

This improves defensibility.

PRIORITY B — KEEP BUT REWRITE (currently too anecdotal)

These are believable but read like invented stories.
Rewrite to pattern-based language.

B1. Scenario 5 — GPL exclusion compliance story
Status: COMPLETED
Risk: MEDIUM

Current wording implies a specific team workaround.

Problem:

Sounds plausible

but reads fictional

lacks anchor to known industry pattern

Required rewrite:

REPLACE ENTIRE “Seen in the Wild” with:

“License compliance scans frequently uncover GPL-licensed libraries pulled in transitively. A common enterprise response is to exclude the offending dependency and substitute a permissively licensed alternative, verifying at runtime that the upstream library still functions.”

Why this works:

Matches real compliance practice

removes unverifiable narrative

keeps lesson intact

B2. Scenario 5 (Gradle/mobile APK size trimming)
Status: COMPLETED
Risk: MEDIUM

Current claim about trimming 4MB from APK.

Dependency-Hell

Problem:

very specific

unverifiable

smells illustrative rather than observed

Required rewrite:

REPLACE with:

“Mobile teams frequently use exclusions to remove large transitive libraries (such as legacy analytics or duplicate support libraries) in order to reduce final APK size.”

Keep it pattern-based.

B3. Scenario 5 (Scala JSON binary version war)
Status: COMPLETED
Risk: LOW–MEDIUM

Current wording is plausible but slightly story-like.

Dependency-Hell

Required rewrite:

“A recurring issue in Scala ecosystems occurs when libraries depend on different Scala binary versions (for example, 2.12 vs 2.13). Teams often resolve this by excluding the unwanted variant and adding a direct dependency on the aligned version.”

PRIORITY C — CONSOLIDATE (you currently have duplicates)

You have too many version-range war stories.

This creates risk.

C1. Scenario 9 duplicate range failures
Status: COMPLETED
Risk: MEDIUM (credibility dilution)

You currently have multiple near-identical stories about:

CI vs local mismatch

AbstractMethodError at 3 AM

range pulling bad version

Examples appear in several places.

Action:

Keep ONE strongest version.

DELETE the weaker duplicates.

Preferred canonical version (recommended wording):

“A well-known failure mode with version ranges occurs when CI resolves a newly published dependency that developer machines have not yet seen due to local caching. The result is a build that suddenly fails without any source changes.”

This is clean and defensible.

PRIORITY D — MINOR TONE HARDENING

Apply globally.

D1. Replace single-team anecdotes with pattern language

Search for openings like:

“A team was…”

“A company…”

“A developer…”

Where not backed by famous incidents, convert to:

“Teams often…”

“A common production pattern…”

“Many organisations…”

Goal:

Shift from anecdote → observed industry pattern.

D2. Remove unnecessary drama markers

Specifically tone down:

“3 AM pager alerts” (keep at most once)

overly precise numbers

emotionally loaded phrasing

You want calm field-manual authority.

FINAL QUALITY GATE

After edits:

Every “Seen in the Wild” must satisfy:

plausibly observable in real enterprises

not dependent on a specific unnamed company

aligned with documented ecosystem behaviour

readable as pattern evidence, not storytelling