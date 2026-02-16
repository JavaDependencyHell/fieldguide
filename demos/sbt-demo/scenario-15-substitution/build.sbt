name := "sbt-substitution"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// tag::s15-deps[]
libraryDependencies += "com.demo" % "lib-a" % "1.0.0"

// We can substitute a dependency using exclude and adding the replacement,
// or by using dependencyOverrides to force a version.
// True module substitution (changing group/artifact) is harder but possible via custom updateOptions.
// end::s15-deps[]
