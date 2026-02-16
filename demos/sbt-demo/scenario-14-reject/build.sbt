name := "sbt-reject"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// tag::s14-deps[]
libraryDependencies += "com.demo" % "lib-a" % "1.0.0"

// SBT/Ivy doesn't have a built-in "reject" syntax in the libraryDependencies DSL.
// You would typically achieve this by forcing a different version or using exclusions.
// end::s14-deps[]
