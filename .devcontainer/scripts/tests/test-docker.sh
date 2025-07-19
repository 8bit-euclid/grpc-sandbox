#!/bin/bash

# Docker functionality test script
set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../shared-utils.sh"

test_docker_installation() {
    if command_exists docker; then
        docker --version &>/dev/null || log_warning "Docker installed but not responding"
        wait_for_docker
    else
        if is_devcontainer; then
            log_warning "Docker not found in PATH (this may be expected if Docker-in-Docker feature is still initializing)"
            # In devcontainer, give Docker more time to become available
            sleep 3
            if command_exists docker; then
                log_success "Docker became available after waiting"
                wait_for_docker
            fi
        else
            log_warning "Docker not found in PATH"
        fi
    fi
}

test_docker_status() {
    print_section "Testing Docker status..."
    
    if ! command_exists docker; then
        if is_devcontainer; then
            log_warning "Docker not installed (may be initializing in devcontainer)"
        else
            log_error "Docker not installed"
        fi
        return 1
    elif ! docker info &>/dev/null; then
        if is_devcontainer; then
            log_warning "Docker daemon not ready (may still be starting in devcontainer)"
        else
            log_error "Docker not running - start Docker Desktop"
        fi
        return 1
    else
        log_success "Docker is running"
        return 0
    fi
}

test_docker_functionality() {
    # Test Docker pull
    print_section "Testing Docker pull..."
    if docker pull hello-world &>/dev/null; then
        log_success "Successfully pulled hello-world image"

        # Test Docker run
        print_section "Testing Docker run..."
        if docker run --rm hello-world &>/dev/null; then
            log_success "Successfully ran hello-world container"
        else
            log_error "Failed to run hello-world container"
        fi

        # Clean up test image
        cleanup_docker_image "hello-world"
    else
        log_error "Failed to pull hello-world image"
    fi

    # Test Docker build capability
    print_section "Testing Docker build..."
    local temp_dockerfile=$(mktemp)
    local build_tag="test-build-$(date +%s)"
    
    cat > "$temp_dockerfile" << 'EOF'
FROM alpine:latest
RUN echo "Docker build test successful"
EOF
    
    if docker build -t "$build_tag" -f "$temp_dockerfile" . &>/dev/null; then
        log_success "Docker build functionality works"
        cleanup_docker_image "$build_tag"
    else
        log_error "Docker build functionality failed"
    fi
    
    rm -f "$temp_dockerfile"
}

# Main test function
test_docker() {
    test_docker_installation
    
    if test_docker_status; then
        test_docker_functionality
    fi
}

# Main function - standardized entry point
main() {
    test_docker
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    print_heading "🐳 Docker Functionality Test"
    main
    exit $EXIT_CODE
fi
