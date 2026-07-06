### Maven Scenario 17: Private Repository & Direct Patch

This scenario demonstrates pinning a privately patched artifact version directly, without a BOM.

#### What's happening:
1.  The POM adds the private repo (created by `install_private_repo.sh`).
2.  It declares `spring-boot-starter:2.5.14.ACME` explicitly — a direct version declaration.

#### How to verify:
1.  Run `bash ../../../install_private_repo.sh` once (or `install_deps.sh`, which calls it).
2.  Run `mvn dependency:tree`.

#### Expected Output:
`org.springframework.boot:spring-boot-starter:jar:2.5.14.ACME` in the tree.
