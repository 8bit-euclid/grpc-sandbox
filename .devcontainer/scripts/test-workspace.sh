#!/bin/bash

# DevContainer Test Orchestrator
# This script coordinates all devcontainer tests by running focused sub-scripts
set -euo pipefail

# Get script directory and source utilities
MAIN_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$MAIN_SCRIPT_DIR/shared-utils.sh"

# Test scripts to run
TESTS=(
    "test-config.sh"
    "test-docker.sh"
    "test-tools.sh"
    "test-ports.sh"
    "test-resources.sh"
    "test-build.sh"
)

# Arrays to track test results
PASSED=()
FAILED=()
EXIT_CODE=0

# Run a test script and track results
run_test_script() {
    local script="$1"
    local script_path="$MAIN_SCRIPT_DIR/tests/$script"

    if [[ -f "$script_path" && -x "$script_path" ]]; then
        # Run the script in a subshell to capture its exit code
        if bash "$script_path"; then
            PASSED+=("$script")
        else
            FAILED+=("$script")
            EXIT_CODE=1
        fi
    else
        log_error "Test script $script not found or not executable"
        FAILED+=("$script (not found)")
        EXIT_CODE=1
    fi
}

# Main test execution
main() {
    print_hline
    echo "🧪 DevContainer Test Suite"
    print_hline

    # Make test scripts executable
    for script in "${TESTS[@]}"; do
        chmod +x "$MAIN_SCRIPT_DIR/tests/$script" 2>/dev/null || true
    done

    # Run all test scripts
    for script in "${TESTS[@]}"; do
        run_test_script "$script"
    done
}

# Summary and cleanup
show_summary() {
    print_heading "📋 Test Summary"

    # Show passed tests
    if [[ ${#PASSED[@]} -gt 0 ]]; then
        for test in "${PASSED[@]}"; do
            log_success "$test"
        done
    fi

    # Show failed tests
    if [[ ${#FAILED[@]} -gt 0 ]]; then
        for test in "${FAILED[@]}"; do
            log_error "$test"
        done
    fi

    # Overall result
    print_blank_line
    if [[ $EXIT_CODE -eq 0 ]]; then
        log_success "All ${#PASSED[@]} tests passed!"
    else
        log_error "${#FAILED[@]} of $((${#PASSED[@]} + ${#FAILED[@]})) tests failed"
    fi
}

# Run main function and show summary
main
show_summary
exit $EXIT_CODE
