### Gradle Scenario 13: Variant Selection (Attributes)

This scenario discusses Gradle's Attribute-based variant selection.

#### What's happening:
1.  Gradle dependencies are not just "jars". They are "components" with "variants" (e.g., API vs Runtime, Java 8 vs Java 11, Debug vs Release).
2.  Dependencies are matched based on requested attributes vs provided attributes.
3.  This allows for much richer dependency management than Maven's simple scopes/classifiers.

#### How to verify:
This is a conceptual demo as our dummy repo doesn't have Gradle Module Metadata published. However, you can see the syntax in `build.gradle`.

#### Expected Output:
The build resolves successfully using standard matching (since we didn't publish special variants).
