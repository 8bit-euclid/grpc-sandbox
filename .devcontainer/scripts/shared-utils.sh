#!/bin/bash

# Shared utilities for devcontainer test scripts
# This file should be sourced by other test scripts

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

# Global exit code tracking
EXIT_CODE=0

# Logging functions
log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; EXIT_CODE=1; }

# Environment detection
is_devcontainer() {
    [[ "${DEVCONTAINER:-}" == "1" ]]
}

# Check if we're in a post-creation environment (just after devcontainer setup)
is_post_creation() {
    # Check if this is being run as part of postCreateCommand
    [[ "${DEVCONTAINER:-}" == "1" ]] && [[ -n "${VSCODE_INJECTION:-}" ]]
}

# Docker utilities
wait_for_docker() {
    # Increase timeout for post-creation scenarios where Docker-in-Docker takes longer to start
    local max_attempts=60
    print_section "Waiting for Docker daemon to be ready..."

    for i in $(seq 1 $max_attempts); do
        if docker info &>/dev/null; then
            log_success "Docker is working correctly"
            return 0
        else
            if [ $i -eq $max_attempts ]; then
                if is_devcontainer; then
                    log_warning "Docker daemon not accessible after $max_attempts seconds in devcontainer - this may be expected during initial setup"
                else
                    log_warning "Docker daemon not accessible after $max_attempts seconds, continuing anyway..."
                fi
                return 1
            else
                # Show progress less frequently to reduce noise
                if [ $((i % 5)) -eq 0 ] || [ $i -le 5 ]; then
                    print_section "Waiting for Docker daemon... (attempt $i/$max_attempts)"
                fi
                sleep 1
            fi
        fi
    done
}

# Cleanup function for Docker images
cleanup_docker_image() {
    local image_name="$1"
    if docker images -q "$image_name" &>/dev/null; then
        docker rmi "$image_name" &>/dev/null || true
    fi
}

# Print heading
print_heading() {
    print_blank_line
    print_section "$1"
    print_hline
}

# Print a horizontal line
print_hline() {
    echo "================================"
}

# Test section header
print_section() {
    echo -e "$1"
}

# Print a blank line
print_blank_line() {
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Validate JSON file
validate_json() {
    local file="$1"
    if [[ -f "$file" ]]; then
        if python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# Get available disk space
get_disk_space() {
    local path="$1"
    df -h "$path" | awk 'NR==2 {print $4}'
}

# Check if port is in use
is_port_in_use() {
    local port="$1"
    lsof -Pi ":$port" -sTCP:LISTEN -t &>/dev/null
}
