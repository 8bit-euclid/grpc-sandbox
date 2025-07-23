#!/bin/bash

# Container build test script
set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared-utils.sh"

test_registry_image() {
    # Get workspace root
    local workspace_root="$(cd "$SCRIPT_DIR/../../.." && pwd)"

    # Determine repository name
    local repo_name
    if [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
        repo_name="$GITHUB_REPOSITORY"
    else
        # Try to extract from git remote (handle both SSH and HTTPS formats)
        local remote_url=$(git -C "$workspace_root" remote get-url origin 2>/dev/null || echo "")
        if [[ "$remote_url" =~ git@github\.com[^:]*:([^/]+/[^/]+)\.git$ ]]; then
            repo_name="${BASH_REMATCH[1]}"
        elif [[ "$remote_url" =~ git@github\.com[^:]*:([^/]+/[^/]+)$ ]]; then
            repo_name="${BASH_REMATCH[1]}"
        elif [[ "$remote_url" =~ https://github\.com/([^/]+/[^/]+)\.git$ ]]; then
            repo_name="${BASH_REMATCH[1]}"
        elif [[ "$remote_url" =~ https://github\.com/([^/]+/[^/]+)$ ]]; then
            repo_name="${BASH_REMATCH[1]}"
        fi
    fi

    if [[ -z "$repo_name" ]]; then
        log_warning "Cannot determine repository name - skipping registry image test"
        return 0
    fi

    # Try to pull the pre-built image from registry
    local registry_image="ghcr.io/${repo_name}/devcontainer:latest"
    print_section "Testing registry image: $registry_image"

    if docker pull "$registry_image" &>/dev/null; then
        log_success "Successfully pulled pre-built image from registry"

        # Test running the registry image
        if docker run --rm -v "$workspace_root:/workspace" "$registry_image" ls /workspace &>/dev/null; then
            log_success "Registry image works correctly"
        else
            log_error "Registry image failed workspace mounting test"
        fi

        # Clean up registry image
        cleanup_docker_image "$registry_image"
    else
        log_warning "Could not pull pre-built image from registry (may not exist yet or require authentication)"
    fi
}

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

    # Determine repository name for cache
    local repo_name
    if [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
        repo_name="$GITHUB_REPOSITORY"
    else
        # Try to extract from git remote (handle both SSH and HTTPS formats)
        local remote_url=$(git -C "$workspace_root" remote get-url origin 2>/dev/null || echo "")
        if [[ "$remote_url" =~ git@github\.com[^:]*:([^/]+/[^/]+)\.git$ ]]; then
            repo_name="${BASH_REMATCH[1]}"
        elif [[ "$remote_url" =~ git@github\.com[^:]*:([^/]+/[^/]+)$ ]]; then
            repo_name="${BASH_REMATCH[1]}"
        elif [[ "$remote_url" =~ https://github\.com/([^/]+/[^/]+)\.git$ ]]; then
            repo_name="${BASH_REMATCH[1]}"
        elif [[ "$remote_url" =~ https://github\.com/([^/]+/[^/]+)$ ]]; then
            repo_name="${BASH_REMATCH[1]}"
        fi
    fi

    print_section "Building container..."

    # Build with registry cache if available
    local build_cmd="docker build"
    local build_args=()

    if [[ -n "$repo_name" ]]; then
        local cache_ref="ghcr.io/${repo_name}/devcontainer:buildcache"
        print_section "Using BuildKit with registry cache: $cache_ref"

        # Use buildx for BuildKit cache support
        if command_exists docker && docker buildx version &>/dev/null; then
            build_cmd="docker buildx build"
            build_args+=(--cache-from "type=registry,ref=$cache_ref")
            log_success "BuildKit cache configured (cache will be used if accessible)"
        else
            log_warning "BuildKit not available - building without cache"
        fi
    else
        log_warning "Repository name not available - building without registry cache"
    fi

    if $build_cmd "${build_args[@]}" -t "$test_image" -f "$dockerfile" "$workspace_root" &>/dev/null; then
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
    # Test pulling pre-built image from registry first
    test_registry_image

    # Then test building from scratch with cache
    test_container_build
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_heading "🧪 Container Build Test"
    main
    exit $EXIT_CODE
fi
