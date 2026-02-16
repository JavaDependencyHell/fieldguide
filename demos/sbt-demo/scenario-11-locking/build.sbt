name := "sbt-locking"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// tag::s11-deps[]
// SBT has a dependency locking feature (since 1.4.x)
// This is usually enabled via 'dependencyLocking' setting, but here we just show the dependency.
libraryDependencies += "com.demo" % "lib-a" % "1.+"
// end::s11-deps[]
