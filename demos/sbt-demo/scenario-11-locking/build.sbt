name := "sbt-locking"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"


// sbt has NO built-in dependency locking. This demo uses the third-party
// sbt-dependency-lock plugin (see project/plugins.sbt), which provides the
// dependencyLockWrite / dependencyLockCheck tasks and writes build.sbt.lock.
// tag::s11-deps[]
libraryDependencies += "com.demo" % "lib-a" % "1.+"
// end::s11-deps[]
