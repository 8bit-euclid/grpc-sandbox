#!/bin/bash

# Build script for the C++ gRPC ProductInfo server

set -e  # Exit on any error

echo "🔨 Building C++ gRPC ProductInfo Server..."

# Check if we're in the right directory
if [ ! -f "BUILD" ]; then
    echo "❌ Error: BUILD file not found. Please run this script from the server directory."
    exit 1
fi

# Check if protobuf files exist
PROTO_DIR="../../../gen/cpp/product"
if [ ! -f "$PROTO_DIR/product_info.pb.h" ]; then
    echo "⚠️  Warning: Protobuf files not found. Generating them first..."
    cd ../../../
    if [ -f "Makefile" ]; then
        make generate
    else
        echo "❌ Error: Cannot generate protobuf files. Please run 'make generate' from the project root."
        exit 1
    fi
    cd productinfo/c++/server
fi

# Build with Bazel
echo "🔧 Building with Bazel..."
cd ../../../  # Go to workspace root
bazel build //productinfo/c++/server:product_info_server

echo "✅ Build completed successfully!"

# Copy executable to expected location for compatibility
mkdir -p productinfo/c++/server/bin
cp bazel-bin/productinfo/c++/server/product_info_server productinfo/c++/server/bin/

echo "📍 Executable is located at: productinfo/c++/server/bin/product_info_server"

# Test if the executable was created
if [ -f "productinfo/c++/server/bin/product_info_server" ]; then
    echo "🎯 Ready to run: ./productinfo/c++/server/bin/product_info_server"
else
    echo "❌ Error: Executable not found after build"
    exit 1
fi
