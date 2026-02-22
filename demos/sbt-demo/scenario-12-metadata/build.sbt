name := "sbt-metadata"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// tag::s12-deps[]
libraryDependencies += "com.demo" % "lib-a" % "1.0.0"
// end::s12-deps[]

// SBT allows customizing the update process, but direct metadata patching (like Gradle's component metadata rules)
// is less straightforward and often involves custom Ivy settings or exclude/override logic.

