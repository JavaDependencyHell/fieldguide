name := "sbt-optional"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"


// SBT/Ivy doesn't have a direct "optional" flag in the DSL like Maven.
// You typically use configurations or classifiers, or just rely on the published POM's optionality.
// Since we are consuming a Maven artifact that might be optional, we just declare it normally here.
// If we were publishing, we would modify the POM generation.

// tag::s8-deps[]
libraryDependencies += "com.demo" % "lib-a" % "1.0.0"
// end::s8-deps[]
