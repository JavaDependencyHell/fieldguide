name := "sbt-override"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// A "managed default" (the val) that one declaration deliberately breaks away
// from. lib-a:2.0.0 transitively requires lib-b:2.0.0, so the direct
// lib-b:1.0.0 below enters conflict resolution and loses (highest wins).
// tag::s4-deps[]

val defaultVersion = "1.0.0"

libraryDependencies ++= Seq(
  // Explicit override of the default for lib-a
  "com.demo" % "lib-a" % "2.0.0",
  "com.demo" % "lib-b" % defaultVersion
)
// end::s4-deps[]
