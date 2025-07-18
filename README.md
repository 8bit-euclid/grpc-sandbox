# gRPC Sandbox

This repository demonstrates gRPC code generation for multiple languages using Bazel as the build system.

## Project Structure

```
.
├── proto/
│   └── product/
│       ├── product_info.proto    # Protocol buffer definition
│       └── BUILD                 # Bazel build configuration
├── gen/                          # Generated code output
│   ├── python/
│   │   └── product/
│   │       ├── product_info_pb2.py
│   │       └── product_info_pb2_grpc.py
│   ├── go/
│   │   └── product/
│   │       └── product_info.pb.go
│   └── c++/
│       └── product/
│           ├── product_info.pb.h
│           ├── product_info.pb.cc
│           ├── product_info.grpc.pb.h
│           └── product_info.grpc.pb.cc
├── Makefile                      # Build automation
├── WORKSPACE                     # Bazel workspace configuration
└── MODULE.bazel                  # Bazel module configuration
```

## Prerequisites

- [Bazel](https://bazel.build/) (latest version)
- Make (for convenience commands)

## Usage

### Generate Code

To generate gRPC code for all languages:

```bash
make generate
```

To clean generated code:

```bash
make clean
```

### Testing Generated Code

#### Python
```bash
cd gen/python
python3 -c "
import product.product_info_pb2 as pb
import product.product_info_pb2_grpc as grpc
product = pb.Product(name='Test', description='Test product', price=29.99)
print(f'Product: {product.name}')
"
```

#### Go
```bash
cd gen/go
# Create a go.mod file first
go mod init example
# Then test the generated code
go run -c "
package main
import (
    \"fmt\"
    \"example/product\"
)
func main() {
    p := &product.Product{Name: \"Test\", Description: \"Test product\", Price: 29.99}
    fmt.Printf(\"Product: %s\\n\", p.Name)
}
"
```

### Generated Code

#### Python
- **Location**: `gen/python/product/`
- **Files**: 
  - `product_info_pb2.py` - Protocol buffer message classes
  - `product_info_pb2_grpc.py` - gRPC service stubs and servicers

#### Go
- **Location**: `gen/go/product/`
- **Files**: 
  - `product_info.pb.go` - Protocol buffer messages and gRPC service interfaces

#### C++
- **Location**: `gen/c++/product/`
- **Files**: 
  - `product_info.pb.h/cc` - Protocol buffer message classes
  - `product_info.grpc.pb.h/cc` - gRPC service classes

## Service Definition

The `ProductInfo` service provides two methods:

- `addProduct(Product) -> ProductID` - Add a new product
- `getProduct(ProductID) -> Product` - Retrieve a product by ID

## Build System

This project uses Bazel with the following key features:

- **Multi-language support**: Generates code for Python, Go, and C++
- **Dependency management**: Automatically handles gRPC and Protocol Buffer dependencies
- **Incremental builds**: Only rebuilds what's necessary
- **Hermetic builds**: Reproducible builds across different environments
- **Import path correction**: Automatically fixes Python import paths during generation
- **No manual post-processing**: Generated files work out-of-the-box without manual edits

### Build Performance Note

The initial build may take several minutes (2-3 minutes) because Bazel downloads and compiles the entire gRPC ecosystem (~3,360 build actions). This includes:

- gRPC C++ runtime libraries
- Python gRPC bindings
- Go toolchain and dependencies
- Protocol buffer libraries
- All transitive dependencies

**Subsequent builds are much faster** due to Bazel's incremental build system and caching. The actual proto compilation is very fast (< 1 second) - the time is spent building the gRPC toolchain dependencies.

For production use, consider using a more minimal setup that only includes the protoc compiler and gRPC plugins without the full runtime libraries.

## Adding New Services

1. Define your service in a `.proto` file under `proto/`
2. Create a corresponding `BUILD` file with appropriate targets
3. Update the `Makefile` to include the new service in the generation process
4. Run `make generate` to create the code

## Dependencies

The project automatically downloads and manages the following dependencies:

- gRPC (all languages)
- Protocol Buffers (all languages)
- Language-specific gRPC libraries
- Build tools and compilers

All dependencies are managed through Bazel's module system and are hermetically sealed.
