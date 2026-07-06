#!/bin/bash

# install_python_deps.sh
# Builds the fixture wheels and PEP 503 indexes used by the Python demos
# (demos/python-demo). Equivalent of install_deps.sh for the JVM demos.
#
# Produces:
#   target/python-repo          public index (wheels/ + simple/)
#   target/python-private-repo  private index (wheels/ + simple/)

set -e
cd "$(dirname "$0")"

echo "Building Python fixture wheels and indexes..."
python3 scripts/build_python_fixtures.py

echo "Done."
