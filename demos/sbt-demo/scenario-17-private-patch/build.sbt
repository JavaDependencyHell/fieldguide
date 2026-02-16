// snippet: repo-and-deps
ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "2.13.8"

lazy val root = (project in file("."))
  .settings(
    name := "scenario-17-private-patch",
    resolvers ++= Seq(
      "third-party-repo" at "file://" + (ThisBuild / baseDirectory).value / "../../../demo-dependencies/private-repo",
      "central" at "https://repo.maven.apache.org/maven2"
    ),
    libraryDependencies ++= Seq(
      "org.springframework.boot" % "spring-boot-starter" % "2.5.14.ACME"
    )
  )
// snippet: end
