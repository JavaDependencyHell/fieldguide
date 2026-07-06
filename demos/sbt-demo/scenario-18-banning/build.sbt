name := "sbt-banning"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// tag::s18-deps[]
// lib-a pulls in lib-c transitively (via lib-b)
libraryDependencies += "com.demo" % "lib-a" % "1.0.0"

// Build-wide exclusion: lib-c is removed from EVERY dependency's subtree —
// present and future. Unlike .exclude() on one dependency (scenario 5),
// a new dependency that drags lib-c in is pruned too.
excludeDependencies += ExclusionRule("com.demo", "lib-c")
// end::s18-deps[]
