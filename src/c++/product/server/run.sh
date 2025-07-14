#!/bin/bash

# Run script for the C++ gRPC ProductInfo server

set -e  # Exit on any error

echo "🚀 Starting C++ gRPC ProductInfo Server..."

# Check if executable exists
if [ ! -f "bin/product_info_server" ]; then
    echo "❌ Error: Executable not found. Please build first using ./build.sh"
    exit 1
fi

# Check if port 50051 is already in use
if lsof -Pi :50051 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Warning: Port 50051 is already in use. Stopping existing process..."
    pkill -f product_info_server || true
    sleep 2
fi

echo "🌐 Server will be available at localhost:50051"
echo "🔍 Test with: grpcurl -plaintext localhost:50051 list"
echo "🛑 Press Ctrl+C to stop the server"
echo ""

# Run the server
exec ./bin/product_info_server
