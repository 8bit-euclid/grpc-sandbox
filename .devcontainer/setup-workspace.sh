#!/bin/bash

set -euo pipefail

echo "🚀 Setting up development environment..."

# Ensure we're in the workspace directory
cd /workspace

# Fix workspace permissions to ensure files can be saved
echo "🔧 Fixing workspace permissions..."
sudo chown -R vscode:vscode /workspace 2>/dev/null || true
sudo chmod -R u+w /workspace 2>/dev/null || true

# Install Go dependencies if go.mod exists
if [ -f "go.mod" ]; then
    echo "📦 Installing Go dependencies..."
    go mod download || echo "⚠️  Go mod download failed, continuing..."
fi

# Install Python dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "📦 Installing Python dependencies..."

    # Check if we're in an externally managed environment
    if python3 -m pip install --help | grep -q "break-system-packages"; then
        echo "🔧 Detected externally managed Python environment, using --break-system-packages..."
        python3 -m pip install --break-system-packages --no-warn-script-location -r requirements.txt || echo "⚠️  Python requirements install failed, continuing..."
    else
        # Fallback to user install for older pip versions
        python3 -m pip install --user --no-warn-script-location -r requirements.txt || echo "⚠️  Python requirements install failed, continuing..."
    fi

    # Add local bin directory to PATH to avoid warnings
    echo "🔧 Adding ~/.local/bin to PATH..."
    if ! echo "$PATH" | grep -q "/home/vscode/.local/bin"; then
        export PATH="/home/vscode/.local/bin:$PATH"
        echo 'export PATH="/home/vscode/.local/bin:$PATH"' >> ~/.bashrc
        echo "✅ Added ~/.local/bin to PATH"
    fi
fi
