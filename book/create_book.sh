#!/bin/bash

# Ensure we are in the root directory
cd "$(dirname "$0")/.."

# Check if quarto is installed
if ! command -v quarto &> /dev/null
then
    echo "Quarto could not be found. Please install it to generate the book."
    echo "Visit https://quarto.org/docs/get-started/ for installation instructions."
    exit 1
fi

echo "Generating Book (HTML, PDF)..."
# This will generate the specified formats into the build directory
quarto render --to html --to pdf --output-dir build/book


qpdf --linearize --empty \
  --pages \
    book/content/front-image.pdf 1-z \
    build/book/Dependency-Hell.pdf 1-z \
  -- build/book/book.pdf

echo "Cleaning up intermediate files..."
find -L demos -name "guide_files" -type d -exec rm -rf {} +



echo "Book generation complete. Output in build/book/"



