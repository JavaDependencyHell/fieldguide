### SBT Scenario 16: Private Repository & BOM Override (Emulated)

This scenario demonstrates emulating a vendor BOM in sbt, which has no native BOM import in 1.x.

#### What's happening:
1.  `build.sbt` adds the private repo (`demo-dependencies/private-repo`, created by `install_private_repo.sh`).
2.  The public `spring-boot-starter:2.5.14` is declared, and `dependencyOverrides` forces the BOM-managed `2.5.14.ACME` — the emulation of BOM import. (Real options: the here-sbt-bom plugin, or sbt 2.x native BOM support.)

#### How to verify:
1.  Run `bash ../../../install_private_repo.sh` once (or `install_deps.sh`, which calls it).
2.  Run `sbt "show externalDependencyClasspath"`.

#### Expected Output:
The classpath contains `spring-boot-starter-2.5.14.ACME.jar` from the private repo.
