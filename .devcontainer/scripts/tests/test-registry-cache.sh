#!/bin/bash
# Registry cache test script
set -euo pipefail

# Source utilities and initialize paths
source "$(dirname "${BASH_SOURCE[0]}")/../shared-utils.sh"
init_test_paths

test_registry_image() {
    local repo_name=$(get_repo_name)

    # Skip test if repository name cannot be determined
    [[ -z "$repo_name" ]] &&
        log_warning "Cannot determine repository name - skipping registry image test" && return 0

    local registry_image="ghcr.io/${repo_name}/devcontainer:latest"
    print_section "Testing registry image: $registry_image"

    # Pull and test registry image
    if docker pull "$registry_image" &>/dev/null; then
        log_success "Successfully pulled pre-built image from registry"

        # Test workspace mounting
        if docker run --rm -v "$WORKSPACE_ROOT:/workspace" "$registry_image" ls /workspace &>/dev/null; then
            log_success "Registry image works correctly"
        else
            log_error "Registry image failed workspace mounting test"
        fi

        cleanup_docker_image "$registry_image"
    else
        log_warning "Could not pull pre-built image from registry (may not exist yet or require authentication)"
    fi
}

# Cleanup function and trap
cleanup() {
    local repo_name=$(get_repo_name)
    [[ -n "$repo_name" ]] && cleanup_docker_image "ghcr.io/${repo_name}/devcontainer:latest"
}
trap cleanup EXIT

# Run test if script is executed directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    print_heading "🧪 Registry Cache Test"
    test_registry_image
    exit $EXIT_CODE
}
