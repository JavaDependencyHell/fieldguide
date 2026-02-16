name := "sbt-dependency-management"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// SBT doesn't have a direct equivalent to Maven's <dependencyManagement> BOM import in the core.
// However, you can define versions in variables or use plugins.
// For this demo, we simulate "management" by defining a common version variable.

// tag::s3-deps[]
val libVersion = "1.0.0"

libraryDependencies ++= Seq(
  "com.demo" % "lib-a" % libVersion,
  "com.demo" % "lib-b" % libVersion
)
// end::s3-deps[]
