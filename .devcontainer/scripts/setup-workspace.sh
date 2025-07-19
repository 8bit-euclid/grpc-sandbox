#!/bin/bash

set -euo pipefail

# Get script directory and source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-utils.sh"

echo "🚀 Setting up development environment..."

# Ensure we're in the workspace directory
cd /workspace

# Fix workspace permissions to ensure files can be saved
echo "🔧 Fixing workspace permissions..."
if sudo chown -R vscode:vscode /workspace 2>/dev/null && sudo chmod -R u+w /workspace 2>/dev/null; then
    log_success "Workspace permissions fixed"
else
    log_warning "Could not fix workspace permissions, continuing..."
fi

# Install Go dependencies if go.mod exists
if [ -f "go.mod" ]; then
    echo "📦 Installing Go dependencies..."
    if go mod download; then
        log_success "Go dependencies installed"
    else
        log_warning "Go mod download failed, continuing..."
    fi
fi

# Install Python dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "📦 Installing Python dependencies..."

    # Check if we're in an externally managed environment
    if python3 -m pip install --help | grep -q "break-system-packages"; then
        echo "🔧 Detected externally managed Python environment, using --break-system-packages..."
        if python3 -m pip install --break-system-packages --no-warn-script-location -r requirements.txt; then
            log_success "Python dependencies installed"
        else
            log_warning "Python requirements install failed, continuing..."
        fi
    else
        # Fallback to user install for older pip versions
        if python3 -m pip install --user --no-warn-script-location -r requirements.txt; then
            log_success "Python dependencies installed"
        else
            log_warning "Python requirements install failed, continuing..."
        fi
    fi

    # Add local bin directory to PATH to avoid warnings
    echo "🔧 Adding ~/.local/bin to PATH..."
    if ! echo "$PATH" | grep -q "/home/vscode/.local/bin"; then
        export PATH="/home/vscode/.local/bin:$PATH"
        echo 'export PATH="/home/vscode/.local/bin:$PATH"' >> ~/.bashrc
        log_success "Added ~/.local/bin to PATH"
    else
        log_success "~/.local/bin already in PATH"
    fi
fi
