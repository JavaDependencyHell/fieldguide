name := "sbt-metadata"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// lib-a:1.0.0's POM says it needs lib-b:1.0.0. Suppose that metadata is
// wrong (lib-a really works with, and needs, lib-b 2.x). sbt has no
// metadata-rules API like Gradle's, so the patch is: exclude the wrong
// declaration, then add the right one.
// tag::s12-deps[]
libraryDependencies += ("com.demo" % "lib-a" % "1.0.0")
  .exclude("com.demo", "lib-b")   // drop what lib-a's POM declares
libraryDependencies += "com.demo" % "lib-b" % "2.0.0"   // declare what it should have
// end::s12-deps[]
