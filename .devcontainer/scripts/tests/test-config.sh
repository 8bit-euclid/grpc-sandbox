#!/bin/bash

# Configuration validation test script
set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared-utils.sh"

# Get workspace root
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

test_configuration() {
    local devcontainer_json="$WORKSPACE_ROOT/.devcontainer/devcontainer.json"
    local dockerfile="$WORKSPACE_ROOT/.devcontainer/Dockerfile"
    
    # Test devcontainer.json
    if validate_json "$devcontainer_json"; then
        log_success "devcontainer.json is valid JSON"
    else
        if [[ -f "$devcontainer_json" ]]; then
            log_error "devcontainer.json has syntax errors"
        else
            log_error "devcontainer.json not found"
        fi
    fi
    
    # Test Dockerfile
    if [[ -f "$dockerfile" ]]; then
        log_success "Dockerfile exists"
    else
        log_error "Dockerfile not found"
    fi
}

# Main function - standardized entry point
main() {
    test_configuration
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_heading "📝 Configuration Validation Test"
    main
    exit $EXIT_CODE
fi
