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
