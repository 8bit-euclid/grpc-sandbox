#!/bin/bash

# DevContainer Test Script
# This script is not comprehensive, but it can provide a basic check of the devcontainer setup
set -euo pipefail

# Global variables
WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_IMAGE="grpc-sandbox-test-$(date +%s)"
EXIT_CODE=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging functions
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; EXIT_CODE=1; }

# Cleanup function
cleanup() {
    if docker images -q "$TEST_IMAGE" &>/dev/null; then
        docker rmi "$TEST_IMAGE" &>/dev/null || true
    fi
}
trap cleanup EXIT

echo "🔍 DevContainer Test"
echo "===================="

# Verify Docker is working (with retry logic for Docker-in-Docker)
echo "🐳 Verifying Docker installation..."
if command -v docker &>/dev/null; then
    docker --version &>/dev/null || echo "⚠️  Docker installed but not responding"

    # Wait for Docker daemon to be ready (Docker-in-Docker takes time to start)
    echo "⏳ Waiting for Docker daemon to be ready..."
    for i in {1..30}; do
        if docker info &>/dev/null; then
            echo "✅ Docker is working correctly"
            break
        else
            if [ $i -eq 30 ]; then
                echo "⚠️  Docker daemon not accessible after 30 seconds, continuing anyway..."
            else
                echo "⏳ Waiting for Docker daemon... (attempt $i/30)"
                sleep 1
            fi
        fi
    done
else
    echo "⚠️  Docker not found in PATH"
fi

# Essential checks
echo ""
echo "📦 Docker Status"
if ! command -v docker &>/dev/null; then
    log_error "Docker not installed"
elif ! docker info &>/dev/null; then
    log_error "Docker not running - start Docker Desktop"
else
    log_success "Docker is running"
fi

echo ""
echo "📝 Configuration Files"
DEVCONTAINER_JSON="$WORKSPACE_ROOT/.devcontainer/devcontainer.json"
DOCKERFILE="$WORKSPACE_ROOT/.devcontainer/Dockerfile"

if [[ -f "$DEVCONTAINER_JSON" ]]; then
    if python3 -c "import json; json.load(open('$DEVCONTAINER_JSON'))" 2>/dev/null; then
        log_success "devcontainer.json is valid JSON"
    else
        log_error "devcontainer.json has syntax errors"
    fi
else
    log_error "devcontainer.json not found"
fi

if [[ -f "$DOCKERFILE" ]]; then
    log_success "Dockerfile exists"
else
    log_error "Dockerfile not found"
fi

echo ""
echo "💾 Resources"
# Check disk space (simplified)
AVAILABLE=$(df -h "$WORKSPACE_ROOT" | awk 'NR==2 {print $4}')
log_success "Available disk space: $AVAILABLE"

# Check critical ports
echo ""
echo "🔌 Port Availability"
for port in 50051 8080; do
    if lsof -Pi ":$port" -sTCP:LISTEN -t &>/dev/null; then
        log_warning "Port $port is in use"
    else
        log_success "Port $port is available"
    fi
done

# Build test
echo ""
echo "🧪 Build Test"

if [[ ! -f "$DOCKERFILE" ]]; then
    log_error "Cannot build - Dockerfile not found"
else
    echo "Building container..."
    if docker build -t "$TEST_IMAGE" -f "$DOCKERFILE" "$WORKSPACE_ROOT" &>/dev/null; then
        log_success "Container builds successfully"

        # Test key tools
        echo ""
        echo "🔧 Tool Verification"
        test_tool() {
            local tool="$1"
            local cmd="$2"
            if docker run --rm "$TEST_IMAGE" bash -c "$cmd" &>/dev/null; then
                log_success "$tool is working"
            else
                log_error "$tool failed"
            fi
        }

        test_tool "Go" "go version"
        test_tool "Python" "python3 --version"
        test_tool "Buf" "buf --version"

        # Test workspace mounting
        if docker run --rm -v "$WORKSPACE_ROOT:/workspace" "$TEST_IMAGE" ls /workspace &>/dev/null; then
            log_success "Workspace mounting works"
        else
            log_error "Workspace mounting failed"
        fi
    else
        log_error "Container build failed"
    fi
fi

# Summary
echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
    log_success "All checks passed!"
else
    log_error "Issues detected - fix the errors above"
    echo ""
    echo "Common fixes:"
    echo "• Start Docker Desktop"
    echo "• Run: docker system prune -a"
    echo "• Check devcontainer.json syntax"
fi

exit $EXIT_CODE
