### Maven Scenario 9: Version Ranges

This scenario demonstrates how to use version ranges to specify dependencies.

#### What's happening:
1.  We declare a dependency on `lib-a` with the version range `[1.0.0,2.0.0)`.
2.  This means "any version greater than or equal to 1.0.0 but strictly less than 2.0.0".
3.  Maven will check the repository metadata to find the highest version that satisfies this criteria.

#### How to verify:
Run the following command in this directory:
```bash
mvn dependency:tree
```

#### Expected Output:
Since our local repo contains `1.0.0` and `2.0.0`, and the range excludes `2.0.0`, Maven should resolve to `1.0.0`.
