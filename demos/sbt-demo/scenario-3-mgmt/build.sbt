name := "sbt-dependency-management"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// sbt 1.x has no equivalent of Maven's <dependencyManagement> BOM import in
// the core (sbt 2.0 adds one). Because build.sbt is Scala, the idiomatic way
// to centralise versions is a val (or a project/Dependencies.scala object).

// tag::s3-deps[]
val libVersion = "1.0.0"

libraryDependencies ++= Seq(
  "com.demo" % "lib-a" % libVersion,
  "com.demo" % "lib-b" % libVersion
)
// end::s3-deps[]
