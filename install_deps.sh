#!/bin/bash

# install_deps.sh
# Builds the demo utilities and populates the local repository with demo artifacts.

set -e

echo "Building demo-utils..."
# Build the demo-utils project to get the classes
(cd demo-utils && mvn clean package -DskipTests)

dummy_jar="demo-utils/target/demo-utils-1.0.0.jar"
echo "Installing artifacts to target/local-repo..."

# Create target directory if it doesn't exist
mkdir -p target


# Install artifacts to local repo using the created jar
mvn install:install-file -Dfile=${dummy_jar} -DpomFile=demo-dependencies/lib-c/v1/pom.xml -DgroupId=com.demo -DartifactId=lib-c -Dversion=1.0.0 -Dpackaging=jar -DlocalRepositoryPath=target/local-repo
mvn install:install-file -Dfile=${dummy_jar} -DpomFile=demo-dependencies/lib-c/v2/pom.xml -DgroupId=com.demo -DartifactId=lib-c -Dversion=2.0.0 -Dpackaging=jar -DlocalRepositoryPath=target/local-repo
mvn install:install-file -Dfile=${dummy_jar} -DpomFile=demo-dependencies/lib-b/v1/pom.xml -DgroupId=com.demo -DartifactId=lib-b -Dversion=1.0.0 -Dpackaging=jar -DlocalRepositoryPath=target/local-repo
mvn install:install-file -Dfile=${dummy_jar} -DpomFile=demo-dependencies/lib-b/v2/pom.xml -DgroupId=com.demo -DartifactId=lib-b -Dversion=2.0.0 -Dpackaging=jar -DlocalRepositoryPath=target/local-repo
mvn install:install-file -Dfile=${dummy_jar} -DpomFile=demo-dependencies/lib-a/v1/pom.xml -DgroupId=com.demo -DartifactId=lib-a -Dversion=1.0.0 -Dpackaging=jar -DlocalRepositoryPath=target/local-repo
mvn install:install-file -Dfile=${dummy_jar} -DpomFile=demo-dependencies/lib-a/v2/pom.xml -DgroupId=com.demo -DartifactId=lib-a -Dversion=2.0.0 -Dpackaging=jar -DlocalRepositoryPath=target/local-repo
mvn install:install-file -Dfile=demo-dependencies/bom/v1/pom.xml -DgroupId=com.demo -DartifactId=demo-bom -Dversion=1.0.0 -Dpackaging=pom -DlocalRepositoryPath=target/local-repo
mvn install:install-file -Dfile=${dummy_jar} -DpomFile=demo-dependencies/lib-circle-a/v1/pom.xml -DgroupId=com.demo -DartifactId=lib-circle-a -Dversion=1.0.0 -Dpackaging=jar -DlocalRepositoryPath=target/local-repo
mvn install:install-file -Dfile=${dummy_jar} -DpomFile=demo-dependencies/lib-circle-b/v1/pom.xml -DgroupId=com.demo -DartifactId=lib-circle-b -Dversion=1.0.0 -Dpackaging=jar -DlocalRepositoryPath=target/local-repo


echo "Creating maven-metadata.xml files..."
for artifact in lib-a lib-b lib-c; do
    METADATA_DIR="target/local-repo/com/demo/$artifact"
    if [ -f "$METADATA_DIR/maven-metadata-local.xml" ]; then
        cp "$METADATA_DIR/maven-metadata-local.xml" "$METADATA_DIR/maven-metadata.xml"
    fi
done

echo "Done."
