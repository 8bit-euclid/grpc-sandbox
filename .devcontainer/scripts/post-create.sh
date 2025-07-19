#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-utils.sh"

# Run workspace setup first
if ! bash "$SCRIPT_DIR/setup-workspace.sh"; then
    echo ""
    echo "❌ Workspace setup failed!"
    exit 1
fi

# Run tests - will exit with error code if tests fail
echo ""
if bash "$SCRIPT_DIR/test-workspace.sh"; then
    echo ""
    echo "🎉 DevContainer setup is complete!"
    echo ""
else
    echo ""
    echo "❌ DevContainer setup failed!"
    echo ""
    exit 1
fi
