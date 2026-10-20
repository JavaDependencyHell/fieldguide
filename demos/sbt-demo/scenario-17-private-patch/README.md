### sbt Scenario 17: Private Repository & Direct Patch

This scenario demonstrates pinning a privately patched artifact version directly.

#### What's happening:
1.  `build.sbt` adds the private repo (created by `install_private_repo.sh`).
2.  It declares `spring-boot-starter % "2.5.14.ACME"` explicitly.
3.  Because this is an ordinary declaration, it is subject to highest-wins: a transitive request for a higher public version would evict it. Scenario 16's `dependencyOverrides` is the way to make it hold.

#### How to verify:
1.  Run `bash ../../../install_private_repo.sh` once (or `install_deps.sh`, which calls it).
2.  Run `sbt "show externalDependencyClasspath"`.

#### Expected Output:
The classpath contains `spring-boot-starter-2.5.14.ACME.jar` from the private repo.
