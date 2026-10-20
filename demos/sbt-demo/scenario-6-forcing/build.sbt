name := "sbt-forcing"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// lib-a:1.0.0 -> lib-b:1.0.0 -> lib-c:1.0.0. Nothing asks for lib-c:2.0.0,
// but dependencyOverrides forces it anyway.
// tag::s6-deps[]
libraryDependencies += "com.demo" % "lib-a" % "1.0.0"
// To force a version in sbt, use dependencyOverrides
dependencyOverrides += "com.demo" % "lib-c" % "2.0.0"
// end::s6-deps[]
