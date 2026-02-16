# Dependency Hell Fieldguide

A field guide to understanding and navigating the complexities of dependency management in Java-based ecosystems (Maven, Gradle, and SBT).

## Overview

This project provides a comprehensive set of scenarios that demonstrate how different build tools resolve dependency conflicts, handle transitive dependencies, and manage versioning. It serves as both a learning resource and a reference for developers and build engineers.

The content is rendered as a Quarto book, and each scenario is accompanied by a functional demo that can be verified automatically.

## Prerequisites

To build the book and run the demos, you will need:

- **Java JDK** (8 or higher)
- **Apache Maven**
- **Quarto** (for rendering the documentation)
- **Make** (for orchestration)
- (Optional) **Gradle** and **SBT** (if you wish to run those specific demos manually, though the verification scripts handle them)

## Getting Started

The project uses a `Makefile` to simplify common tasks.

### 1. Initialize the Project

Before running any demos or rendering the book, you need to initialize the project. This builds the necessary utility classes and populates a local repository with demo artifacts:

```bash
make init
```

### 2. Build the Book

To render the documentation into HTML:

```bash
make book
```

The output will be available in `build/book/index.html`.

To render the documentation as a PDF:

```bash
make book-pdf
```

### 3. Run Verifications

You can verify that all scenarios behave as expected by running the automated verification scripts:

```bash
make verify
```

To run verifications for a specific build tool:

```bash
make verify-maven
make verify-gradle
make verify-sbt
```

## Project Structure

- `book/`: Contains the Quarto documentation content.
- `demos/`: Contains functional examples for Maven, Gradle, and SBT.
- `demo-dependencies/`: Source POMs for the artifacts used in the demos.
- `demo-utils/`: Shared Java utilities used by the verification scripts.
- `Makefile`: Orchestrates the build and verification process.
- `install_deps.sh`: Scripts to populate the local Maven repository used for testing.

## Cleaning Up

To remove all build artifacts and reset the environment:

```bash
make clean
```

## License

© 2024 Dependency Hell Authors
