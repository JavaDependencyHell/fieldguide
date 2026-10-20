name := "sbt-scopes"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// Three independent libraries, one per configuration. lib-a brings lib-b
// and lib-c transitively (all Compile); lib-d and lib-circle-a are not
// needed by anything else, so their configuration alone decides where
// they appear.
// tag::s7-deps[]
libraryDependencies ++= Seq(
  "com.demo" % "lib-a"        % "1.0.0",            // Compile (default)
  "com.demo" % "lib-d"        % "1.0.0" % Provided, // Provided
  "com.demo" % "lib-circle-a" % "1.0.0" % Test      // Test
)
// end::s7-deps[]

// tag::s7-transitive[]
// The trap: lib-a needs lib-b at Compile. Declaring lib-b % Provided here
// does NOT remove it from the Runtime classpath -- Coursier keeps the
// transitive edge from lib-a. (Maven would demote it; see the guide.)
libraryDependencies += "com.demo" % "lib-b" % "1.0.0" % Provided
// end::s7-transitive[]
