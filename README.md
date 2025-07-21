# gRPC Sandbox

Multi-language gRPC code generation using Buf and Bazel. Generates Python, Go, and C++ code from Protocol Buffer definitions with working client/server examples.

## Quick Start

**Prerequisites:** [Buf](https://buf.build/) and [Bazel](https://bazel.build/)

```bash
# Generate gRPC code for all languages
make generate

# Run example applications
make run-py-server    # Python server
make run-go-client    # Go client
make run-cpp-server   # C++ server

# Clean generated code and Bazel cache
make clean
```

## Project Structure

- `proto/` - Protocol Buffer definitions
- `gen/` - Generated gRPC code (Python, Go, C++)
- `src/` - Example client/server implementations
- `scripts/` - Build automation scripts
- `buf.yaml` - Buf configuration for linting and breaking changes
- `buf.gen.yaml` - Code generation configuration

## Generated Code

The `ProductInfo` service provides:
- `addProduct(Product) -> ProductID` - Add a new product
- `getProduct(ProductID) -> Product` - Retrieve a product by ID

Generated files are placed in `gen/`:
- **Python**: `gen/python/product/` - `*_pb2.py` and `*_pb2_grpc.py`
- **Go**: `gen/go/product/` - `*.pb.go`
- **C++**: `gen/c++/product/` - `*.pb.h/cc` and `*.grpc.pb.h/cc`

## Example Applications

Working client/server implementations are provided in `src/`:

**Python**: `src/python/product/`
- `server.py` - gRPC server implementation
- `client.py` - gRPC client implementation

**Go**: `src/go/product/`
- `server/` - gRPC server with main.go and server.go
- `client/` - gRPC client implementation

**C++**: `src/c++/product/`
- `server/` - gRPC server with product_info_server.h/cpp
- `client/` - gRPC client implementation

## Running Applications

```bash
# Python
make run-py-server
make run-py-client

# Go
make run-go-server
make run-go-client

# C++
make run-cpp-server
make run-cpp-client
```

## Docker Support

```bash
# Build with Docker
docker build -t grpc-sandbox .
docker run -v $(pwd):/app grpc-sandbox buf generate
```

## Build System

- **Buf**: Modern protobuf toolchain for code generation
- **Bazel**: Build system for compiling and running applications
- **Automated BUILD files**: Scripts generate Bazel BUILD files automatically
- **Version synchronization**: buf.gen.yaml and MODULE.bazel versions are kept in sync

## Adding Services

1. Create `.proto` file in `proto/`
2. Run `make generate` (automatically creates BUILD files)
3. Implement client/server in `src/`
