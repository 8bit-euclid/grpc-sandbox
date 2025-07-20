#!/bin/bash

# Main script to create BUILD files in the gen directory after 'buf generate'
# This script orchestrates the creation of BUILD files for all languages
# This script should be run after generating protobuf files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Creating BUILD files for generated protobuf code..."

# Run language-specific scripts
echo "Running C++ BUILD file creation..."
"${SCRIPT_DIR}/create_cpp_build_files.sh"

echo "Running Go BUILD file creation..."
"${SCRIPT_DIR}/create_go_build_files.sh"

echo "Running Python BUILD file creation..."
"${SCRIPT_DIR}/create_python_build_files.sh"

echo "All BUILD files created successfully!"
