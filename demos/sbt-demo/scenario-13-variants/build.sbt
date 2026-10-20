name := "sbt-variants"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// lib-a:1.0.0 is published twice: the default artifact (lib-a-1.0.0.jar)
// and a "jdk11" classifier (lib-a-1.0.0-jdk11.jar). A classifier selects
// which artifact of the same coordinates to fetch; the POM, and therefore
// the transitive dependencies, are shared.
// tag::s13-deps[]
libraryDependencies += "com.demo" % "lib-a" % "1.0.0" classifier "jdk11"
// end::s13-deps[]
