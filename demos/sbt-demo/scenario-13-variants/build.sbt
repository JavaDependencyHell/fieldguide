name := "sbt-variants"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// tag::s13-deps[]
libraryDependencies += "com.demo" % "lib-a" % "1.0.0"
// end::s13-deps[]

// SBT uses "configurations" (Compile, Test, Runtime) which map to Ivy configurations.
// It doesn't have the same "Attribute" based variant selection as Gradle.
// You can specify classifiers (e.g., "sources", "javadoc") or specific configurations.

