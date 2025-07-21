#!/bin/bash

# Script to create C++ BUILD files for generated protobuf code
# Usage: create_cpp_build_files.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${SCRIPT_DIR}/templates/cpp_BUILD.bazel"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Error: Template file not found: $TEMPLATE_FILE"
    exit 1
fi

echo "Creating C++ BUILD files..."

# Function to create C++ BUILD file from template
create_cpp_build() {
    local service_dir="$1"
    local service_name="$2"
    
    if [[ ! -d "$service_dir" ]]; then
        echo "Warning: Directory $service_dir does not exist, skipping..."
        return
    fi
    
    echo "  Creating C++ BUILD file for $service_name in $service_dir"
    
    # Read template and substitute variables
    sed "s/{{SERVICE_NAME}}/$service_name/g" "$TEMPLATE_FILE" > "${service_dir}/BUILD"
}

# Create BUILD files for each C++ service directory
for service_dir in gen/c++/*/; do
    if [[ -d "$service_dir" ]]; then
        service_name=$(basename "$service_dir")
        create_cpp_build "$service_dir" "$service_name"
    fi
done

echo "C++ BUILD files created successfully!"
