name := "sbt-override"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// tag::s4-deps[]
// Simulating overriding a managed version
val defaultVersion = "1.0.0"

libraryDependencies ++= Seq(
  "com.demo" % "lib-a" % "2.0.0", // Explicit override
  "com.demo" % "lib-b" % defaultVersion
)
// end::s4-deps[]
