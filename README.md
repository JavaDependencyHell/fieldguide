# Dependency Hell: A Field Guide

A field guide to how dependency resolution actually behaves, taught through executable scenarios in three ecosystems:

- **JVM:** Maven, Gradle and sbt (18 scenarios, each implemented for all three tools)
- **Python:** pip, Poetry and uv (12 scenarios)
- **Node:** npm, pnpm and Yarn 4 (12 scenarios)

Every scenario is a chapter (`guide.qmd`) written from a demo project that sits beside it, and every claim in a chapter is proved by a `verify.sh` check that runs the demo. The content is rendered as a Quarto book.

## Prerequisites

To build the book:

- **Quarto** 1.9+ (and a TeX distribution for PDF output). PDF builds rasterise the Mermaid diagrams with a headless browser: run `quarto install chrome-headless-shell` once and, if a system Chrome is also present, point Quarto at the bundled one with `export QUARTO_CHROMIUM="$HOME/Library/Application Support/quarto/chrome-headless-shell/chrome-headless-shell-mac-arm64/chrome-headless-shell"` (the desktop Chrome can hang in headless mode while it updates itself)
- **qpdf** (PDF post-processing)
- **Make**

To run the demos:

- **Java JDK** 17 or higher (Gradle 9 and sbt 2 require 17; the demos are verified on 25)
- **Apache Maven** 3.9+ (`install_deps.sh` also uses it to publish the fixture artifacts)
- **Gradle** 8.14+ or 9.x (no wrapper is shipped)
- **sbt** 1.12.x (each sbt demo pins its version in `project/build.properties`)
- **Python** 3.10+, **Poetry** 2.x, **uv** 0.11+
- **Node** 22+ with **npm**, plus **pnpm** 11 and **Yarn** 4 via Corepack. Node 22 and 24 bundle Corepack; on Node 25+ run `npm install -g corepack` first.

Version breakpoints and the exact versions each track was verified against are in `demos/TOOL-VERSIONS.md` (JVM), `demos/python-demo/TOOL-VERSIONS.md` and `demos/node-demo/TOOL-VERSIONS.md`.

## Getting started

The `Makefile` orchestrates everything.

### 1. Build the fixtures

The demos resolve against local repositories that are generated, not checked in:

```bash
make init          # JVM: builds demo-utils, publishes com.demo:lib-* to target/local-repo
                   #      and the scenario 16/17 vendor artifacts to demo-dependencies/private-repo
make init-python   # Python: wheels and PEP 503 indexes under target/python-repo
make init-node     # Node: harness-local Verdaccio registries under target/node-repo
```

### 2. Build the book

```bash
make book-html     # HTML to build/book/index.html
make book          # HTML + PDF (6x9) to build/book/
make herodevs-site # HeroDevs-branded HTML site (the profile CI deploys)
make leanpub       # 6x9 PDF for Leanpub
make oreilly       # 7x9 PDF
```

### 3. Verify the demos

```bash
make verify         # every track
make verify-maven
make verify-gradle
make verify-sbt
make verify-python
make verify-node    # starts two local Verdaccio registries; scenario 12 needs network for npm audit
make audit          # static completeness audit of the scenario matrix (no tools needed)
```

## Project structure

- `index.qmd`: the landing page with the interactive pathway chooser (HTML) and a plain introduction (PDF).
- `book/content/`: core chapters (triage, start-here pages, scenario index, part introductions, conclusion) and appendices (comparison table, cheat sheet, glossary).
- `demos/<tool>-demo/scenario-N-*/`: one directory per scenario per track, holding `guide.qmd` (the chapter), the build or project files, and a `README.md` for running it by hand.
- `demos/<tool>-demo/verify.sh`: executes every scenario in that track and asserts what its chapter claims.
- `demos/TOOL-VERSIONS.md`, `demos/*/TOOL-VERSIONS.md`: tested versions and behavioural breakpoints per tool.
- `demo-dependencies/`: source POMs for the JVM fixture artifacts (`lib-a`, `lib-b`, `lib-c`, `lib-d`, `demo-bom`, `lib-circle-*`).
- `demo-utils/`: the jar payload reused for every JVM fixture, plus the classpath checker used by `verify.sh`.
- `scripts/`: fixture builders for Python and Node, the matrix audit, and EPUB post-processing.
- `filters/`, `include-code.lua`: Quarto filters that turn `#### ! Section` headings into styled boxes and include tagged snippets from the demo build files.
- `_quarto.yml` and `_quarto-*.yml`: the base book definition and the publishing profiles.
- `latex/`, `fonts/`, `book/*.scss`: PDF and HTML styling.

## Writing a scenario

Each `guide.qmd` follows a fixed template (`#### ! Scenario`, `Example`, `Expect`, `Actual`, `Why`, `Fix`, `Risk`, `Control`, `Check`, `Scales`, `Takeaway`, `Related`, `Wild`, plus a *Tool Versions* callout). Headings must be level 4; a `### !` heading makes the box filter swallow every later section. Snippets are included from the real build file with `{.xml include="pom.xml" snippet="s4-deps"}` and `tag::`/`end::` markers. Run `make audit` before committing: it checks structure, links, snippet markers, verify coverage and sibling links across all 90 guides.

## Cleaning up

```bash
make clean
```

## License

See `LICENSE`. © 2026 Dependency Hell Authors.
