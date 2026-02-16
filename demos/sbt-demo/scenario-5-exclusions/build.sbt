name := "sbt-exclusions"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// tag::s5-deps[]
libraryDependencies += ("com.demo" % "lib-a" % "1.0.0")
  .exclude("com.demo", "lib-c") // Exclude transitive dependency lib-c
// end::s5-deps[]
