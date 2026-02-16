#!/bin/bash

# Ensure we are in the root directory
cd "$(dirname "$0")/.."

# Check if qpdf is installed
if ! command -v qpdf &> /dev/null
then
    echo "qpdf could not be found. Please install it to generate the sample."
    exit 1
fi


echo "Generating Sample PDF..."


qpdf build/book/book.pdf --pages . 1,7,8-18,29-31,38-40,44-47,48,60-63,84-87,89-92  -- build/book/sample.pdf



echo "Sample generation complete. Output in build/book/sample.pdf"
