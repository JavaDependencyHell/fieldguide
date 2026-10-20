# Quick-Reference Cheat Sheet {.unnumbered}

## Maven

*   **Show Dependency Tree:** `mvn dependency:tree`
*   **Show Dependency Tree (with evicted nodes):** `mvn dependency:tree -Dverbose`
*   **Show the Runtime Classpath:** `mvn dependency:build-classpath`
*   **Exclude Dependency (one path):**
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
*   **Force Version (transitives):** Add to `<dependencyManagement>`. A direct `<dependency>` version still wins over it.
*   **Ban Everywhere (fails build):** Enforcer `bannedDependencies` with `<exclude>group:artifact</exclude>`. Maven has no silent global exclude.
*   **Reject a Version (fails build):**
```xml
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-enforcer-plugin</artifactId>
        <version>3.5.0</version>
        <executions><execution><goals><goal>enforce</goal></goals>
            <configuration><rules>
                <bannedDependencies>
                    <excludes><exclude>group:artifact:[2.0.0]</exclude></excludes>
                </bannedDependencies>
            </rules></configuration>
        </execution></executions>
    </plugin>
```
*   **Catch Silent Downgrades:** Enforcer `requireUpperBoundDeps` (fails when nearest-wins picks a version lower than one some path asked for).
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
*   **Lock (plugin):** `mvn io.github.chains-project:maven-lockfile:generate`, then `:validate` in CI. Maven has no native lock.

## Gradle

*   **Show Dependency Tree:** `gradle dependencies --configuration runtimeClasspath` (or `compileClasspath`; `implementation` is not resolvable)
*   **Show Why a Version Was Chosen:** `gradle dependencyInsight --dependency <name> --configuration runtimeClasspath`
*   **Exclude Dependency (one path):**
```groovy
    implementation('group:artifact:version') {
        exclude group: 'excluded-group', module: 'excluded-artifact'
    }
```
*   **Force Version:**
```groovy
    implementation('group:artifact') {
        version { strictly '1.2.3' }
    }
```
    *   *Blunter:* `configurations.all { resolutionStrategy { force 'group:artifact:1.2.3' } }`
*   **Reject a Version:**
```groovy
    implementation('group:artifact') {
        version { require '[1.0, 3.0)'; reject '2.0.0' }
    }
```
*   **Substitute a Module:**
```groovy
    configurations.all {
        resolutionStrategy.dependencySubstitution {
            substitute module('old-group:old-artifact') using module('new-group:new-artifact:2.0')
        }
    }
```
*   **Exclude Everywhere (silent):**
```groovy
    configurations.all {
        exclude group: 'excluded-group', module: 'excluded-artifact'
    }
```
*   **Import BOM:** `implementation platform('group:artifact:version')` (joins conflict resolution; a higher direct version still wins)
*   **Enforce BOM:** `implementation enforcedPlatform('group:artifact:version')` (the BOM version always wins)
*   **Lock:** `dependencyLocking { lockAllConfigurations() }`, then `gradle dependencies --write-locks`; commit `gradle.lockfile`; `--update-locks group:artifact` to move one entry.

## sbt

*   **Show Dependency Tree:** `sbt dependencyTree` (built in since 1.4; the sbt-dependency-graph plugin before that)
*   **Show Evictions:** `sbt evicted`
*   **Show the Runtime Classpath:** `sbt "show Runtime / fullClasspath"`
*   **Exclude Dependency (one path):**
```scala
    libraryDependencies += "group" % "artifact" % "version" exclude("excluded-group", "excluded-artifact")
```
*   **Force Version (direct and transitive):**
```scala
    dependencyOverrides += "group" % "artifact" % "version"
```
*   **Exclude Everywhere (silent):**
```scala
    excludeDependencies += ExclusionRule("excluded-group", "excluded-artifact")
```
*   **Fail on an Incompatible Eviction (nearest thing to reject):**
```scala
    ThisBuild / evictionErrorLevel := Level.Error
    ThisBuild / libraryDependencySchemes += "group" %% "artifact" % VersionScheme.EarlySemVer
```
*   **Import BOM:** sbt 1.x has no native support. Use the `here-sbt-bom` plugin, or emulate the BOM by pinning its managed versions:
```scala
    dependencyOverrides ++= Seq(
      "group" % "artifact" % "bom-managed-version"
    )
```
    sbt 2.0+ imports BOMs natively.
*   **Write / Check Lockfile** (requires the `sbt-dependency-lock` plugin): `sbt dependencyLockWrite` / `sbt dependencyLockCheck`

## Python (pip / Poetry / uv)

Always work in a fresh virtual environment: one version per environment.

*   **Isolate:** `python -m venv .venv && . .venv/bin/activate` (pip) · Poetry and uv manage `.venv` automatically
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
*   **Reject a Version:** `pkg!=1.2.3` (native PEP 440 operator, no plugin)
*   **Bound the major:** `pkg~=1.4` (means `>=1.4, <2.0`)
*   **Exclude a Transitive:** not possible in pip or Poetry (pin or upgrade it instead). uv only:
```text
    [tool.uv]
    exclude-dependencies = ["pkg"]
```
*   **Lock:** `pip freeze > requirements.txt` (snapshot) or `pip-tools` · `poetry lock` → `poetry.lock` · `uv lock` → `uv.lock` (`uv export --format pylock.toml` for PEP 751)
*   **Optional deps:** extras `pip install "pkg[extra]"` · groups `pip install --group dev` (25.1+) / `poetry install --without dev` (groups install by default) / `uv sync --no-dev` (dev group on by default)
*   **Audit for CVEs:** `pip-audit -r requirements.txt` · `uv audit` (preview)
*   **Avoid dependency confusion:** never mix a private index into PyPI with `--extra-index-url`; use a single index, or uv `first-index` / Poetry source priority

## Node (npm / pnpm / Yarn 4)

The tree can hold many versions of one package: most conflicts dissolve into duplicates; peers are where they return.

*   **Show Dependency Tree:** `npm ls <pkg>` · `pnpm why <pkg>` · `yarn why <pkg>`
*   **Install exactly the lock (CI):** `npm ci` · `pnpm install --frozen-lockfile` · `yarn install --immutable`
*   **Force / Override a Version:**
```text
    # npm — package.json                # yarn — package.json
    "overrides": {"pkg": "1.2.3"}       "resolutions": {"pkg": "1.2.3"}
    # pnpm — pnpm-workspace.yaml (v11+)
    overrides: {pkg: 1.2.3}
```
*   **Find phantoms:** run the repo once under pnpm or Yarn PnP; undeclared imports fail fast
*   **Production install:** `npm install --omit=dev` · `pnpm install --prod` · `yarn workspaces focus --production`
*   **Peer conflict:** read the `ERESOLVE` report; fix the shared version. `--legacy-peer-deps` is a debt, not a fix
*   **Reset a history-shaped tree:** `rm -rf node_modules package-lock.json && npm install`. `npm ci` alone reproduces the recorded shape, nesting included, and `npm dedupe` is not a reliable re-hoist
*   **Audit for CVEs:** `npm audit --audit-level=high` · `pnpm audit` · `yarn npm audit`
*   **Avoid dependency confusion:** scope private packages (`@org/...`), pin `@org:registry=` in a committed `.npmrc`, claim the scope publicly
