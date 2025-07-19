#!/bin/bash

# Development tools verification test script
set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared-utils.sh"

test_tool() {
    local tool_name="$1"
    local test_command="$2"
    
    if eval "$test_command" &>/dev/null; then
        log_success "$tool_name is working"
    else
        log_error "$tool_name failed"
    fi
}

test_development_tools() {
    # Test Go
    if command_exists go; then
        test_tool "Go" "go version"
    else
        log_error "Go not found"
    fi
    
    # Test Python
    if command_exists python3; then
        test_tool "Python" "python3 --version"
    else
        log_error "Python3 not found"
    fi
    
    # Test Buf
    if command_exists buf; then
        test_tool "Buf" "buf --version"
    else
        log_error "Buf not found"
    fi
    
    # Test Bazel
    if command_exists bazel; then
        test_tool "Bazel" "bazel version"
    else
        log_warning "Bazel not found (optional)"
    fi
    
    # Test Buildifier
    if command_exists buildifier; then
        test_tool "Buildifier" "buildifier --version"
    else
        log_warning "Buildifier not found (optional)"
    fi
}

# Main function - standardized entry point
main() {
    test_development_tools
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_heading "🔧 Development Tools Test"
    main
    exit $EXIT_CODE
fi
