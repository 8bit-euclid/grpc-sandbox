#!/bin/bash

# System resources test script
set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared-utils.sh"

test_system_resources() {
    # Get workspace root
    local workspace_root="$(cd "$SCRIPT_DIR/../../.." && pwd)"
    
    # Check disk space
    local available_space=$(get_disk_space "$workspace_root")
    log_success "Available disk space: $available_space"
    
    # Check memory (if available)
    if command_exists free; then
        local memory_info=$(free -h | awk 'NR==2{printf "Memory: %s used / %s total", $3, $2}')
        log_success "$memory_info"
    fi
}

# Main function - standardized entry point
main() {
    test_system_resources
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_heading "💾 System Resources Test"
    main
    exit $EXIT_CODE
fi
