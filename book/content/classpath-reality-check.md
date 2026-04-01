
::: {.callout-note}
## Classpath Reality Check

It is critical to understand that dependency resolution and classpath construction are two different things. 

Your build tool resolves a dependency *graph*, with all of its complex relationships. 

The Java runtime, however, sees a *flattened classpath*, which is a simple list of JAR files.

Many surprises in dependency management originate from this difference. 

A version conflict that seems to be resolved correctly in the graph can still lead to a `NoClassDefFoundError` at runtime if the wrong version of a class is loaded from the flattened classpath.

:::

