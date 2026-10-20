// tag::repo-and-deps[]
ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "2.13.12"

lazy val root = (project in file("."))
  .settings(
    name := "scenario-17-private-patch",
    resolvers += "third-party-repo" at
      "file://" + (ThisBuild / baseDirectory).value / "../../../demo-dependencies/private-repo",
    libraryDependencies ++= Seq(
      "org.springframework.boot" % "spring-boot-starter" % "2.5.14.ACME"
    )
  )
// end::repo-and-deps[]
