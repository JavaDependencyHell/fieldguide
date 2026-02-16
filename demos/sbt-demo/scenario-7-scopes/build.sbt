name := "sbt-scopes"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// tag::s7-deps[]
libraryDependencies ++= Seq(
  "com.demo" % "lib-a" % "1.0.0",           // Compile (default)
  "com.demo" % "lib-b" % "1.0.0" % Provided, // Provided
  "com.demo" % "lib-c" % "1.0.0" % Test      // Test
)
// end::s7-deps[]
