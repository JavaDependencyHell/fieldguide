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
*   **Import BOM:** Requires `sbt-bom` plugin.
```scala
    mavenBomImport := "group" % "artifact" % "version"
```
