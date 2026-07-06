### Gradle Scenario 16: Private Repository & BOM Override

This scenario demonstrates importing a vendor BOM (`platform()`) from a private repository to supply patched artifact versions.

#### What's happening:
1.  `build.gradle` adds the private repo (`demo-dependencies/private-repo`, created by `install_private_repo.sh`).
2.  `platform('com.thirdparty.springboot:patched-bom:1.0.0')` recommends `spring-boot-starter:2.5.14.ACME`; the dependency is declared without a version.
3.  Note: plain `platform()` recommends — a transitive requesting a newer version would win. Use `enforcedPlatform()` for a guarantee.

#### How to verify:
1.  Run `bash ../../../install_private_repo.sh` once (or `install_deps.sh`, which calls it).
2.  Run `gradle dependencies --configuration compileClasspath`.

#### Expected Output:
`org.springframework.boot:spring-boot-starter -> 2.5.14.ACME` in the tree.
