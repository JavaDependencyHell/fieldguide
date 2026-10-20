name := "sbt-substitution"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// lib-a:1.0.0 -> lib-b:1.0.0 -> lib-c:1.0.0. We want lib-b replaced by
// lib-d (a drop-in substitute: a fork, a bridge, a maintained successor).
// sbt has no substitution rule, so: exclude the original from the path that
// brings it, and add the replacement directly.
// tag::s15-deps[]
libraryDependencies += ("com.demo" % "lib-a" % "1.0.0")
  .exclude("com.demo", "lib-b")           // remove the original...
libraryDependencies += "com.demo" % "lib-d" % "1.0.0"   // ...and add the substitute
// end::s15-deps[]
