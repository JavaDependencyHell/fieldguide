### Maven Scenario 16: Private Repository & BOM Override

This scenario demonstrates importing a vendor BOM from a private repository to pin patched artifact versions.

#### What's happening:
1.  The POM adds a private repo (`demo-dependencies/private-repo`, created by `install_private_repo.sh`).
2.  It imports `com.thirdparty.springboot:patched-bom:1.0.0`, which manages `spring-boot-starter` at `2.5.14.ACME`.
3.  The dependency is declared without a version — the BOM supplies it.

#### How to verify:
1.  Run `bash ../../../install_private_repo.sh` once (or `install_deps.sh`, which calls it).
2.  Run `mvn dependency:tree`.

#### Expected Output:
`org.springframework.boot:spring-boot-starter:jar:2.5.14.ACME` in the tree.
