#!/bin/bash

# Script to create Go BUILD files and go.mod files for generated protobuf code
# Usage: create_go_build_files.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_TEMPLATE_FILE="${SCRIPT_DIR}/templates/go_BUILD.bazel"
MOD_TEMPLATE_FILE="${SCRIPT_DIR}/templates/go_mod"

if [[ ! -f "$BUILD_TEMPLATE_FILE" ]]; then
    echo "Error: BUILD template file not found: $BUILD_TEMPLATE_FILE"
    exit 1
fi

if [[ ! -f "$MOD_TEMPLATE_FILE" ]]; then
    echo "Error: go.mod template file not found: $MOD_TEMPLATE_FILE"
    exit 1
fi

echo "Creating Go BUILD files and go.mod files..."

# Function to create Go BUILD file and go.mod from templates
create_go_build() {
    local service_dir="$1"
    local service_name="$2"
    local import_path="$3"
    
    if [[ ! -d "$service_dir" ]]; then
        echo "Warning: Directory $service_dir does not exist, skipping..."
        return
    fi
    
    echo "  Creating Go BUILD file and go.mod for $service_name in $service_dir"
    
    # Create go.mod file
    sed "s|{{IMPORT_PATH}}|$import_path|g" "$MOD_TEMPLATE_FILE" > "${service_dir}/go.mod"
    
    # Create BUILD file
    sed -e "s/{{SERVICE_NAME}}/$service_name/g" \
        -e "s|{{IMPORT_PATH}}|$import_path|g" \
        "$BUILD_TEMPLATE_FILE" > "${service_dir}/BUILD"
}

# Create BUILD files for each Go service directory
for service_dir in gen/go/*/; do
    if [[ -d "$service_dir" ]]; then
        service_name=$(basename "$service_dir")
        import_path="github.com/8bit-euclid/grpc-sandbox/gen/go/$service_name"
        create_go_build "$service_dir" "$service_name" "$import_path"
    fi
done

echo "Go BUILD files and go.mod files created successfully!"
