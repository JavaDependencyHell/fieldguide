name := "sbt-conflict-resolution"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// We explicitly request lib-b:1.0.0
// Ivy (SBT's underlying engine) usually defaults to "latest-wins" or "latest-revision"
// So it should pick 2.0.0 (from lib-a) over 1.0.0, unlike Maven.

// lib-a:2.0.0 depends on lib-b:2.0.0

// tag::s2-deps[]
libraryDependencies += "com.demo" % "lib-a" % "2.0.0"

libraryDependencies += "com.demo" % "lib-b" % "1.0.0"
// end::s2-deps[]
