#!/bin/bash

# Script to create Python BUILD files for generated protobuf code
# Usage: create_python_build_files.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${SCRIPT_DIR}/templates/python_BUILD.template"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "Error: Template file not found: $TEMPLATE_FILE"
    exit 1
fi

echo "Creating Python BUILD files..."

# Function to create Python BUILD file from template
create_python_build() {
    local service_dir="$1"
    local service_name="$2"
    
    if [[ ! -d "$service_dir" ]]; then
        echo "Warning: Directory $service_dir does not exist, skipping..."
        return
    fi
    
    echo "  Creating Python BUILD file and package structure for $service_name in $service_dir"

    # Create __init__.py file to make it a proper Python package for IDE support
    cat > "${service_dir}/__init__.py" << 'EOF'
# Generated Python package for protobuf files
# This file is regenerated when 'buf generate' runs
# Enables IDE import support for generated protobuf files
EOF

    # Read template and substitute variables
    sed "s/{{SERVICE_NAME}}/$service_name/g" "$TEMPLATE_FILE" > "${service_dir}/BUILD"
}

# Create BUILD files for each Python service directory
for service_dir in gen/python/*/; do
    if [[ -d "$service_dir" ]]; then
        service_name=$(basename "$service_dir")
        create_python_build "$service_dir" "$service_name"
    fi
done

echo "Python BUILD files created successfully!"
