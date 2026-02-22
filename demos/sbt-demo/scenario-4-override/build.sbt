name := "sbt-override"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// Simulating overriding a managed version
// tag::s4-deps[]

val defaultVersion = "1.0.0"

libraryDependencies ++= Seq(
  // Explicit override
  "com.demo" % "lib-a" % "2.0.0",
  "com.demo" % "lib-b" % defaultVersion
)
// end::s4-deps[]
