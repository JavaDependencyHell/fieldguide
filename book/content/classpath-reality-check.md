# Resolution Is Not the Same as Loading

::: {.callout-note}
## Classpath Reality Check

Dependency resolution and runtime loading are two different things.

Your build tool resolves a dependency *graph*, with all of its relationships, and then hands the runtime something far simpler: a flat list of artifacts. On the JVM that list is the classpath. In Python it is `sys.path` over one environment. In Node it is a directory tree that `require` walks at call time.

Many surprises in dependency management come from that hand-off. The graph can look correct and the program can still fail.
:::

On the JVM there are two distinct ways the hand-off bites, and they need different fixes:

1. **The winner lacks what somebody needed.** Resolution picks one version of a library. If a consumer was compiled against a method or class that only exists in the version that lost, the result is `NoSuchMethodError` or `NoClassDefFoundError` at the moment that code path runs, often long after start-up. The graph was resolved exactly as the rules say; the rules just do not know about binary compatibility. Scenarios 2, 4 and 6 show how the winner is chosen in each tool.
2. **Two artifacts ship the same classes.** Relocated artifacts (`javax.*` to `jakarta.*`, old and new coordinates of the same project), shaded "fat" jars, and vendored copies all put the same fully-qualified class names on the classpath twice. The build tool sees two different artifacts and keeps both. The class loader takes the first one it finds, and classpath *order* decides which that is. Order depends on declaration order, scope, and the tool, so the failure can move when a dependency is added somewhere else. Scenarios 15 and 18 are the controls for this case: substitute the duplicate away, or ban it.

Python removes the first problem by refusing to resolve a graph that two requirements cannot share (P2), and keeps the second in a different form: a package installed into the system interpreter, or an old build left behind in a virtual environment, is found first on `sys.path` and silently shadows what you meant to use (P10).

Node turns both inside out. Because every package can carry its own copy of a dependency (N2), the winner-lacks-a-class problem rarely happens, but *both* copies load, each with its own module state. The failures are `instanceof` checks that fail across copies and singletons that are suddenly plural, which is exactly what peer dependencies exist to prevent (N8).

The habit that saves you in all three: look at what the runtime will actually load, not only at what the resolver chose. `mvn dependency:build-classpath`, `gradle dependencies --configuration runtimeClasspath`, `sbt "show Runtime / fullClasspath"`, `python -c "import sys; print(sys.path)"` with `pip list`, and `npm ls <pkg>` each show the flat reality behind the graph.
