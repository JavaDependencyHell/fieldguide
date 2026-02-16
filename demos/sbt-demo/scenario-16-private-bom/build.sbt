// snippet: repo-and-deps
ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "2.13.8"

lazy val root = (project in file("."))
  .settings(
    name := "scenario-16-private-bom",
    resolvers ++= Seq(
      "third-party-repo" at "file://" + (ThisBuild / baseDirectory).value / "../../../demo-dependencies/private-repo",
      "central" at "https://repo.maven.apache.org/maven2"
    ),
    libraryDependencies ++= Seq(
      "org.springframework.boot" % "spring-boot-starter"
    ),
    mavenBomImport := "com.thirdparty.springboot" % "patched-bom" % "1.0.0"
  )
// snippet: end
