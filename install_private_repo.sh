#!/bin/bash

# install_private_repo.sh
# Creates and populates demo-dependencies/private-repo — the "third-party
# private repository" used by scenario 16 (private BOM) and scenario 17
# (private patch) in the Maven, Gradle, and SBT demos.
#
# Publishes (in standard Maven repository layout):
#   com.thirdparty.springboot:patched-bom:1.0.0            (pom)
#   org.springframework.boot:spring-boot-starter:2.5.14.ACME (pom + jar)
#
# Run from the repository root:  bash install_private_repo.sh

set -e

cd "$(dirname "$0")"

REPO="demo-dependencies/private-repo"
BOM_DIR="$REPO/com/thirdparty/springboot/patched-bom/1.0.0"
STARTER_DIR="$REPO/org/springframework/boot/spring-boot-starter/2.5.14.ACME"

echo "Creating private repo at $REPO..."
rm -rf "$REPO"
mkdir -p "$BOM_DIR" "$STARTER_DIR"

# --- patched-bom 1.0.0 (BOM that pins the patched starter) ---
cat > "$BOM_DIR/patched-bom-1.0.0.pom" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.thirdparty.springboot</groupId>
    <artifactId>patched-bom</artifactId>
    <version>1.0.0</version>
    <packaging>pom</packaging>
    <description>Demo third-party BOM pinning privately patched artifacts (ACME).</description>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter</artifactId>
                <version>2.5.14.ACME</version>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
EOF

# --- spring-boot-starter 2.5.14.ACME (privately patched artifact) ---
cat > "$STARTER_DIR/spring-boot-starter-2.5.14.ACME.pom" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
    <version>2.5.14.ACME</version>
    <packaging>jar</packaging>
    <description>Demo stand-in for a privately patched spring-boot-starter. Not the real artifact.</description>
</project>
EOF

# Jar payload: reuse the demo-utils jar if built, otherwise create a minimal jar.
JAR_TARGET="$STARTER_DIR/spring-boot-starter-2.5.14.ACME.jar"
if [ -f "demo-utils/target/demo-utils-1.0.0.jar" ]; then
    cp "demo-utils/target/demo-utils-1.0.0.jar" "$JAR_TARGET"
elif command -v jar > /dev/null 2>&1; then
    TMPD=$(mktemp -d)
    mkdir -p "$TMPD/META-INF"
    printf 'Manifest-Version: 1.0\n' > "$TMPD/META-INF/MANIFEST.MF"
    (cd "$TMPD" && jar cfm dummy.jar META-INF/MANIFEST.MF)
    mv "$TMPD/dummy.jar" "$JAR_TARGET"
    rm -rf "$TMPD"
else
    # Empty zip archive (valid enough for resolution demos; never executed).
    printf 'PK\005\006\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0' > "$JAR_TARGET"
fi

# Checksums (optional for file:// repos, but keeps resolvers quiet).
if command -v shasum > /dev/null 2>&1; then
    for f in "$BOM_DIR/patched-bom-1.0.0.pom" \
             "$STARTER_DIR/spring-boot-starter-2.5.14.ACME.pom" \
             "$JAR_TARGET"; do
        shasum -a 1 "$f" | awk '{print $1}' > "$f.sha1"
    done
fi

# Purge any cached resolution *failures* for these artifacts from the demo
# local repo — Maven remembers failed lookups in .lastUpdated files and will
# refuse to retry until the update interval expires.
rm -rf target/local-repo/com/thirdparty \
       target/local-repo/org/springframework 2>/dev/null || true

echo "Done. Contents:"
find "$REPO" -type f | sort
