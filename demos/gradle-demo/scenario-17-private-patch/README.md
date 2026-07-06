### Gradle Scenario 17: Private Repository & Direct Patch

This scenario demonstrates requesting a privately patched artifact version directly.

#### What's happening:
1.  `build.gradle` adds the private repo (created by `install_private_repo.sh`).
2.  It declares `spring-boot-starter:2.5.14.ACME` explicitly. This is still a `require` — a transitive asking for a newer version would out-vote it (use `strictly` for a guarantee).

#### How to verify:
1.  Run `bash ../../../install_private_repo.sh` once (or `install_deps.sh`, which calls it).
2.  Run `gradle dependencies --configuration compileClasspath`.

#### Expected Output:
`org.springframework.boot:spring-boot-starter:2.5.14.ACME` in the tree.
