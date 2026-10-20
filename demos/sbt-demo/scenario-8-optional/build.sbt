name := "sbt-optional"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// lib-d:1.0.0's POM declares lib-c:1.0.0 with <optional>true</optional>.
// We are lib-d's CONSUMER: Coursier honours the flag, so lib-c does not
// reach our classpath. (For your OWN library, mark a dependency optional
// in the published POM with `% Optional` -- see the guide.)
// tag::s8-deps[]
libraryDependencies += "com.demo" % "lib-d" % "1.0.0"
// end::s8-deps[]
