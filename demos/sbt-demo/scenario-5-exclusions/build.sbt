name := "sbt-exclusions"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// lib-a:1.0.0 -> lib-b:1.0.0 -> lib-c:1.0.0. The exclusion on lib-a prunes
// lib-c from everything under lib-a, however deep.
// tag::s5-deps[]
libraryDependencies += ("com.demo" % "lib-a" % "1.0.0")
  .exclude("com.demo", "lib-c") // Exclude transitive dependency lib-c
// end::s5-deps[]
