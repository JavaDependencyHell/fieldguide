name := "sbt-strict"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// tag::s6-deps[]
libraryDependencies += "com.demo" % "lib-a" % "1.0.0"
// To force a version in SBT, we can use dependencyOverrides
dependencyOverrides += "com.demo" % "lib-c" % "2.0.0"
// end::s6-deps[]
