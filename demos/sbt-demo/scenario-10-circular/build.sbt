name := "sbt-circular"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"


// lib-circle-a depends on lib-circle-b
// lib-circle-b depends on lib-circle-a
// tag::s10-deps[]
libraryDependencies += "com.demo" % "lib-circle-a" % "1.0.0"
// end::s10-deps[]
