# Quick-Reference Cheat Sheet {.unnumbered}

## Maven

*   **Show Dependency Tree:** `mvn dependency:tree`
*   **Show Dependency Tree (Verbose):** `mvn dependency:tree -Dverbose`
*   **Exclude Dependency:**
```xml
    <dependency>
        <groupId>...</groupId>
        <artifactId>...</artifactId>
        <exclusions>
            <exclusion>
                <groupId>excluded-group</groupId>
                <artifactId>excluded-artifact</artifactId>
            </exclusion>
        </exclusions>
    </dependency>
```
*   **Force Version:** Add to `<dependencyManagement>`.
*   **Ban Everywhere (fails build):** Enforcer `bannedDependencies` rule with `<exclude>group:artifact</exclude>` — Maven has no silent global exclude.
*   **Import BOM:**
```xml
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>...</groupId>
                <artifactId>...</artifactId>
                <version>...</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

## Gradle

*   **Show Dependency Tree:** `./gradlew dependencies` (or `./gradlew :app:dependencies`)
*   **Show Dependency Insight:** `./gradlew dependencyInsight --dependency <name>`
*   **Exclude Dependency:**
```groovy
    implementation('group:artifact:version') {
        exclude group: 'excluded-group', module: 'excluded-artifact'
    }
```
*   **Force Version:**
```groovy
    configurations.all {
        resolutionStrategy {
            force 'group:artifact:version'
        }
    }
```
    *   *Better:* Use `strictly` constraint.
*   **Exclude Everywhere (silent):**
```groovy
    configurations.all {
        exclude group: 'excluded-group', module: 'excluded-artifact'
    }
```
*   **Import BOM:** `implementation platform('group:artifact:version')`
*   **Enforce BOM:** `implementation enforcedPlatform('group:artifact:version')`

## SBT

*   **Show Dependency Tree:** `sbt dependencyTree` (requires plugin in older versions)
*   **Show Evictions:** `sbt evicted`
*   **Exclude Dependency:**
```scala
    libraryDependencies += "group" % "artifact" % "version" exclude("excluded-group", "excluded-artifact")
```
*   **Force Version:**
```scala
    dependencyOverrides += "group" % "artifact" % "version"
```
*   **Exclude Everywhere (silent):**
```scala
    excludeDependencies += ExclusionRule("excluded-group", "excluded-artifact")
```
*   **Import BOM:** No native support in sbt 1.x. Use the `here-sbt-bom` plugin, or emulate the BOM by pinning its managed versions:
```scala
    dependencyOverrides ++= Seq(
      "group" % "artifact" % "bom-managed-version"
    )
```
*   **Write/Check Lockfile** (requires `sbt-dependency-lock` plugin): `sbt dependencyLockWrite` / `sbt dependencyLockCheck`

## Python (pip / Poetry / uv)

Always work in a fresh virtual environment — one version per environment.

*   **Isolate:** `python -m venv .venv && . .venv/bin/activate` (pip) · Poetry & uv manage `.venv` automatically
*   **Show Dependency Tree:** `pipdeptree` · `poetry show --tree` · `uv tree`
*   **Install:** `pip install -r requirements.txt` · `poetry install` · `uv sync`
*   **Force / Override a Version:**
```text
    # pip — constraints file (BOM-like), applied with -c
    pip install -r requirements.txt -c constraints.txt
    # uv — in pyproject.toml
    [tool.uv]
    override-dependencies = ["pkg==1.2.3"]
```
*   **Reject a Version:** `pkg!=1.2.3` (native PEP 440 operator — no plugin)
*   **Bound the major:** `pkg~=1.4` (means `>=1.4, <2.0`)
*   **Exclude a Transitive:** not possible — pin or upgrade it instead
*   **Lock:** `pip freeze > requirements.txt` (snapshot) or `pip-tools` · `poetry lock` → `poetry.lock` · `uv lock` → `uv.lock` (`uv export --format pylock.toml` for PEP 751)
*   **Optional deps:** extras `pip install "pkg[extra]"` · dev groups `poetry install --with dev` / `uv sync`
*   **Audit for CVEs:** `pip-audit` (or `pip-audit -r requirements.txt`)
*   **Avoid dependency confusion:** never mix a private index into PyPI with `--extra-index-url`; use a single index, or uv `first-index` / Poetry source priority

## Node (npm / pnpm / Yarn 4)

The tree can hold many versions of one package — most conflicts dissolve into duplicates; peers are where they return.

*   **Show Dependency Tree:** `npm ls <pkg>` · `pnpm why <pkg>` · `yarn why <pkg>`
*   **Install exactly the lock (CI):** `npm ci` · `pnpm install --frozen-lockfile` · `yarn install --immutable`
*   **Force / Override a Version:**
```text
    # npm — package.json                # yarn — package.json
    "overrides": {"pkg": "1.2.3"}       "resolutions": {"pkg": "1.2.3"}
    # pnpm — pnpm-workspace.yaml (v11+)
    overrides: {pkg: 1.2.3}
```
*   **Find phantoms:** run the repo once under pnpm or Yarn PnP — undeclared imports fail fast
*   **Production install:** `npm install --omit=dev` · `pnpm install --prod` · `yarn workspaces focus --production`
*   **Peer conflict:** read the `ERESOLVE` report; fix the shared version — `--legacy-peer-deps` is a debt, not a fix
*   **Reset a history-shaped tree:** `rm -rf node_modules && npm ci` (or `npm dedupe`)
*   **Audit for CVEs:** `npm audit --audit-level=high` · `pnpm audit` · `yarn npm audit`
*   **Avoid dependency confusion:** scope private packages (`@org/...`), pin `@org:registry=` in a committed `.npmrc`, claim the scope publicly
