### sbt Scenario 14: Rejecting Versions

This scenario demonstrates sbt's nearest equivalent of a version reject: the versionScheme-aware eviction error (sbt 1.5+).

#### What's happening:
1.  We declare `lib-b:1.0.0` directly, and `lib-a:2.0.0`, which requires `lib-b:2.0.0`.
2.  Highest-wins would evict `lib-b:1.0.0` for `2.0.0`.
3.  `libraryDependencySchemes` tells sbt that `lib-b` follows early-semver, under which a major-version jump is binary incompatible.
4.  sbt's eviction check sees an incompatible eviction and fails `update` ("found version conflict(s) in library dependencies; some are suspected to be binary incompatible").
5.  Run with `-Dsb14.allow=true` and `evictionErrorLevel` drops to `Warn`: the build resolves `lib-b:2.0.0` with a warning instead.

#### How to verify:
```bash
sbt update                       # fails: incompatible eviction
sbt -Dsb14.allow=true update     # succeeds with a warning; lib-b:2.0.0 resolves
```

#### Expected Output:
The first command fails with the "suspected to be binary incompatible" error. The second succeeds and `show externalDependencyClasspath` contains `lib-b/2.0.0`.
