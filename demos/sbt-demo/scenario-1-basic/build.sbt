name := "sbt-basic-transitive"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"


// lib-a:1.0.0 depends on lib-b:1.0.0, which depends on lib-c:1.0.0
// tag::s1-deps[]
libraryDependencies += "com.demo" % "lib-a" % "1.0.0"
// end::s1-deps[]
