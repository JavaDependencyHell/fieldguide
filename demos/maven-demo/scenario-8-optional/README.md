### Maven Scenario 8: Optional Dependencies

This scenario demonstrates the use of the `<optional>` tag.

#### What's happening:
1.  We declare a dependency on `lib-a` and mark it as `<optional>true</optional>`.
2.  This means that if Project X depends on this project (`maven-optional`), Project X will **NOT** inherit `lib-a` transitively.
3.  Optional dependencies are used when a library has features that require other libraries, but those features are not core to the library's function (e.g., a database driver that is only needed if you use that specific database).

#### How to verify:
Run the following command in this directory:
```bash
mvn dependency:tree
```

#### Expected Output:
You will see `lib-a` listed, but if you were to consume this project as a library in another project, `lib-a` would be omitted from that project's tree.
