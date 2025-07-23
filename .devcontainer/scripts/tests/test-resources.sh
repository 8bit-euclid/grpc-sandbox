#!/bin/bash
# System resources test script
set -euo pipefail

# Source utilities and initialize paths
source "$(dirname "${BASH_SOURCE[0]}")/../shared-utils.sh"
init_test_paths

test_system_resources() {
    # Check disk space
    local available_space=$(get_disk_space "$WORKSPACE_ROOT")
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
