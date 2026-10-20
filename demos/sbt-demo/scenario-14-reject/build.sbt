name := "sbt-reject"

version := "1.0"

scalaVersion := "2.13.12"

resolvers += "Local Demo Repo" at "file://" + baseDirectory.value / "../../../target/local-repo"

// sbt has no `reject` keyword. Its nearest first-class mechanism is the
// versionScheme-aware eviction check (sbt 1.5+): declare how lib-b is
// versioned, and sbt fails `update` when conflict resolution would evict
// one version for an INCOMPATIBLE one.
//
// We rely on lib-b 1.x, but lib-a:2.0.0 asks for lib-b:2.0.0. Highest wins,
// so lib-b:1.0.0 would be evicted by 2.0.0 -- a major-version jump, which
// early-semver says is binary incompatible. sbt refuses.
// tag::s14-deps[]
ThisBuild / libraryDependencySchemes += "com.demo" % "lib-b" % VersionScheme.EarlySemVer

libraryDependencies ++= Seq(
  "com.demo" % "lib-b" % "1.0.0", // we are written against lib-b 1.x
  "com.demo" % "lib-a" % "2.0.0"  // ...but lib-a:2.0.0 requires lib-b:2.0.0
)
// end::s14-deps[]

// tag::s14-fix[]
// Escape hatch, for a CONSCIOUS decision only: downgrade the error to a
// warning (here switched on with -Dsb14.allow=true so verify.sh can show
// both outcomes). The better fixes are in the guide.
ThisBuild / evictionErrorLevel := {
  if (sys.props.get("sb14.allow").contains("true")) Level.Warn else Level.Error
}
// end::s14-fix[]
