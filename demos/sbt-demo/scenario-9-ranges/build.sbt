name := "sbt-ranges"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"


// Ivy supports version ranges.
// [1.0.0,2.0.0) means >= 1.0.0 and < 2.0.0
// tag::s9-deps[]
libraryDependencies += "com.demo" % "lib-a" % "[1.0.0,2.0.0)"
// end::s9-deps[]
