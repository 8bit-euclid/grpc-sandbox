# Makefile for generating gRPC code from protobuf files using buf

# Configuration
OUT_DIR = gen

.PHONY: all clean generate help build-python build-go build-cpp build-all run-go-server run-go-client run-py-server run-py-client run-cpp-server run-cpp-client

# Default target
all: generate build-all

# Generate protobuf code using buf
generate: clean
	@echo "Generating protobuf code with buf..."
	@buf generate
	@echo "Creating BUILD files and IDE support for generated code..."
	@./scripts/create_gen_build_files.sh
	@echo "Code generation complete!"

# Build Go applications
build-go:
	@echo "Building Go applications..."
	@echo "Server: go run src/go/product/server/main.go src/go/product/server/server.go"
	@echo "Client: go run src/go/product/client/main.go"

# Build Python applications with Bazel (automatic import resolution)
build-python:
	@echo "Building Python applications with Bazel..."
	@echo "Bazel automatically resolves Python import paths"
	@echo "Server: bazel run //src/python/product:server"
	@echo "Client: bazel run //src/python/product:client"

# Build C++ applications using Bazel
build-cpp:
	@echo "Building C++ applications with Bazel..."
	@bazel build //src/c++/product/server:server

# Build all applications
build-all: build-go build-python build-cpp

# Run Go server/client
run-go-server:
	@echo "Running Go server..."
	@bazel run //src/go/product/server

run-go-client:
	@echo "Running Go client..."
	@bazel run //src/go/product/client

# Run Python server/client
run-py-server:
	@echo "Running Python server..."
	@bazel run //src/python/product:server

run-py-client:
	@echo "Running Python client..."
	@bazel run //src/python/product:client

# Run C++ server/client
run-cpp-server:
	@echo "Running C++ server..."
	@bazel run //src/c++/product/server

run-cpp-client:
	@echo "Running C++ client..."
	@bazel run //src/c++/product/client

# Clean generated files and Bazel artifacts
clean:
	@echo "Cleaning generated files and Bazel artifacts..."
	@rm -rf $(OUT_DIR)
	@bazel clean 2>/dev/null || true

# Show help information
help:
	@echo "Buf-based Proto Code Generation System"
	@echo "====================================="
	@echo ""
	@echo "Available targets:"
	@echo "  generate       - Generate protobuf code using buf"
	@echo "  build-python   - Show how to run Python applications with Bazel"
	@echo "  build-go       - Show how to run Go applications"
	@echo "  build-cpp      - Build C++ applications using Bazel"
	@echo "  build-all      - Build all applications"
	@echo "  run-go-server  - Run Go server"
	@echo "  run-go-client  - Run Go client"
	@echo "  run-py-server  - Run Python server"
	@echo "  run-py-client  - Run Python client"
	@echo "  run-cpp-server - Run C++ server"
	@echo "  run-cpp-client - Run C++ client"
	@echo "  clean          - Clean generated files and Bazel artifacts"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "The build system uses buf generate to create code directly in the correct locations."
	@echo "No file copying or import path corrections are needed."
	@echo ""
	@echo "Generated files are placed in:"
	@echo "  gen/python/    - Python protobuf and gRPC files"
	@echo "  gen/go/        - Go protobuf and gRPC files"
	@echo "  gen/c++/       - C++ protobuf and gRPC files"
