#!/bin/bash

# SSH Agent forwarding test script
set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared-utils.sh"

test_ssh_agent() {
    # Check SSH_AUTH_SOCK environment variable
    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
        log_error "SSH_AUTH_SOCK environment variable not set"
        return 1
    fi
    log_success "SSH_AUTH_SOCK is set: $SSH_AUTH_SOCK"
    
    # Check socket exists and is accessible
    if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
        log_error "SSH agent socket does not exist or is not a socket"
        return 1
    fi
    log_success "SSH agent socket exists and is accessible"
    
    # Test SSH agent communication
    if ! command -v ssh-add &>/dev/null; then
        log_error "ssh-add command not found"
        return 1
    fi
    
    if ssh-add -l &>/dev/null; then
        local key_count=$(ssh-add -l 2>/dev/null | wc -l)
        log_success "SSH agent accessible with $key_count key(s) loaded"
    else
        local exit_code=$?
        if [[ $exit_code -eq 1 ]]; then
            log_warning "SSH agent accessible but no keys loaded"
        else
            log_error "Cannot communicate with SSH agent (exit code: $exit_code)"
            return 1
        fi
    fi
    
    # Quick connectivity test to GitHub (optional, non-blocking)
    if command -v ssh &>/dev/null; then
        if timeout 5 ssh -T -o ConnectTimeout=3 -o StrictHostKeyChecking=no git@github.com 2>&1 | grep -q "successfully authenticated" 2>/dev/null; then
            log_success "GitHub SSH authentication successful"
        else
            log_warning "GitHub SSH test failed (may need to add GitHub key or network issue)"
        fi
    fi
}

# Main function - standardized entry point
main() {
    test_ssh_agent
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_heading "🔐 SSH Agent Test"
    main
    exit $EXIT_CODE
fi
