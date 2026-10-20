// tag::repo-and-deps[]
ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "2.13.12"

lazy val root = (project in file("."))
  .settings(
    name := "scenario-16-private-bom",
    resolvers += "third-party-repo" at
      "file://" + (ThisBuild / baseDirectory).value / "../../../demo-dependencies/private-repo",
    // The public (EOL) version we would otherwise get.
    libraryDependencies ++= Seq(
      "org.springframework.boot" % "spring-boot-starter" % "2.5.14"
    ),
    // sbt 1.x has no native BOM import (sbt 2.0 adds one). We emulate the
    // vendor BOM by pinning its managed versions with dependencyOverrides,
    // which forces the patched version even though the dependency above
    // asks for the public release.
    dependencyOverrides ++= Seq(
      "org.springframework.boot" % "spring-boot-starter" % "2.5.14.ACME"
    )
  )
// end::repo-and-deps[]
