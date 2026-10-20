### sbt Scenario 16: Private Repository & BOM Override (Emulated)

This scenario demonstrates emulating a vendor BOM in sbt 1.x, which has no native BOM import.

#### What's happening:
1.  `build.sbt` adds the private repo (`demo-dependencies/private-repo`, created by `install_private_repo.sh`).
2.  The public `spring-boot-starter:2.5.14` is declared, and `dependencyOverrides` forces the BOM-managed `2.5.14.ACME`. The BOM's versions are read by hand into the override list; that is the emulation.
3.  Real options: the `here-sbt-bom` plugin (reads a Maven BOM into `dependencyOverrides` automatically), or sbt 2.0's native BOM support.

#### How to verify:
1.  Run `bash ../../../install_private_repo.sh` once (or `install_deps.sh`, which calls it).
2.  Run `sbt "show externalDependencyClasspath"`.

#### Expected Output:
The classpath contains `spring-boot-starter-2.5.14.ACME.jar` from the private repo.
