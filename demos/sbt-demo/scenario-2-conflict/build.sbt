name := "sbt-conflict-resolution"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// We explicitly request lib-b:1.0.0, but lib-a:2.0.0 depends on lib-b:2.0.0.
// Coursier (sbt's resolver since 1.3) picks the highest version it sees,
// so lib-b resolves to 2.0.0 and 1.0.0 is evicted -- unlike Maven, which
// would keep the nearer 1.0.0.

// tag::s2-deps[]
libraryDependencies += "com.demo" % "lib-a" % "2.0.0"

libraryDependencies += "com.demo" % "lib-b" % "1.0.0"
// end::s2-deps[]
