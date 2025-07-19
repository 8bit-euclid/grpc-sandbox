#!/bin/bash

# Port availability test script
set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared-utils.sh"

test_port_availability() {
    # Define critical ports for the gRPC sandbox
    local ports=(50051 8080 3000)
    
    for port in "${ports[@]}"; do
        if is_port_in_use "$port"; then
            log_warning "Port $port is in use"
        else
            log_success "Port $port is available"
        fi
    done
}

# Main function - standardized entry point
main() {
    test_port_availability
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_heading "🔌 Port Availability Test"
    main
    exit $EXIT_CODE
fi
