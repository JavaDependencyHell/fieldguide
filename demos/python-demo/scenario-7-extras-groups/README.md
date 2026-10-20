### Python Scenario 7: Extras & Dependency Groups

Extras = optional runtime features (demo-lib-a[feature] pulls demo-lib-d).
Groups = optional dev sets, declared in the standard PEP 735
`[dependency-groups]` table that pip (25.1+), Poetry (2.2+) and uv (0.4.27+)
all read. Each tool's default differs: pip never installs a group unless
asked (`--group dev`); Poetry and uv install groups by default and need
`--without dev` / `--no-dev` to leave one out.

Verify: demo-lib-d absent from a plain install, present with the extra; the
dev group present/absent according to each tool's default and its opt-out.
