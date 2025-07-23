#!/bin/bash
# Container build test script
set -euo pipefail

# Source utilities and initialize paths
source "$(dirname "${BASH_SOURCE[0]}")/../shared-utils.sh"
init_test_paths

TEST_IMAGE="grpc-sandbox-test-$(date +%s)"

test_container_build() {
    local dockerfile="$WORKSPACE_ROOT/.devcontainer/Dockerfile"

    # Validate prerequisites
    [[ ! -f "$dockerfile" ]] && log_error "Cannot build - Dockerfile not found" && return 1
    ! command_exists docker || ! docker info &>/dev/null &&
        log_warning "Skipping build test - Docker not available" && return 0

    local repo_name=$(get_repo_name)
    print_section "Building container..."

    # Configure build with registry cache if available
    local build_cmd="docker build"
    local build_args=()

    if [[ -n "$repo_name" ]]; then
        local cache_ref="ghcr.io/${repo_name}/devcontainer:buildcache"
        print_section "Using BuildKit with registry cache: $cache_ref"

        if docker buildx version &>/dev/null; then
            build_cmd="docker buildx build"
            build_args+=(--cache-from "type=registry,ref=$cache_ref")
            log_success "BuildKit cache configured (cache will be used if accessible)"
        else
            log_warning "BuildKit not available - building without cache"
        fi
    else
        log_warning "Repository name not available - building without registry cache"
    fi

    # Build and test container
    if $build_cmd "${build_args[@]}" -t "$TEST_IMAGE" -f "$dockerfile" "$WORKSPACE_ROOT" &>/dev/null; then
        log_success "Container builds successfully"

        # Test workspace mounting
        if docker run --rm -v "$WORKSPACE_ROOT:/workspace" "$TEST_IMAGE" ls /workspace &>/dev/null; then
            log_success "Workspace mounting works"
        else
            log_error "Workspace mounting failed"
        fi

        cleanup_docker_image "$TEST_IMAGE"
    else
        log_error "Container build failed"
    fi
}

# Cleanup function and trap
cleanup() { cleanup_docker_image "$TEST_IMAGE"; }
trap cleanup EXIT

# Run test if script is executed directly
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    print_heading "🧪 Container Build Test"
    test_container_build
    exit $EXIT_CODE
}
