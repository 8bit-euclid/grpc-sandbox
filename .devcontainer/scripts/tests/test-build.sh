#!/bin/bash

# Container build test script
set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared-utils.sh"

test_container_build() {
    # Get workspace root and dockerfile
    local workspace_root="$(cd "$SCRIPT_DIR/../../.." && pwd)"
    local dockerfile="$workspace_root/.devcontainer/Dockerfile"
    local test_image="grpc-sandbox-test-$(date +%s)"
    
    if [[ ! -f "$dockerfile" ]]; then
        log_error "Cannot build - Dockerfile not found"
        return 1
    fi
    
    # Only attempt build if Docker is available
    if ! command_exists docker || ! docker info &>/dev/null; then
        log_warning "Skipping build test - Docker not available"
        return 0
    fi
    
    print_section "Building container..."
    if docker build -t "$test_image" -f "$dockerfile" "$workspace_root" &>/dev/null; then
        log_success "Container builds successfully"
        
        # Test workspace mounting
        if docker run --rm -v "$workspace_root:/workspace" "$test_image" ls /workspace &>/dev/null; then
            log_success "Workspace mounting works"
        else
            log_error "Workspace mounting failed"
        fi
        
        # Clean up test image
        cleanup_docker_image "$test_image"
    else
        log_error "Container build failed"
    fi
}

# Cleanup function
cleanup() {
    local test_image="grpc-sandbox-test-$(date +%s)"
    cleanup_docker_image "$test_image"
}

# Set up cleanup trap
trap cleanup EXIT

# Main function - standardized entry point
main() {
    test_container_build
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_heading "🧪 Container Build Test"
    main
    exit $EXIT_CODE
fi
