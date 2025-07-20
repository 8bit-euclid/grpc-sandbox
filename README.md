# gRPC Sandbox

Multi-language gRPC code generation using Bazel. Generates Python, Go, and C++ code from Protocol Buffer definitions.

## Quick Start

**Prerequisites:** [Bazel](https://bazel.build/) and Make

```bash
# Generate gRPC code for all languages
make generate

# Clean generated code
make clean
```

## Generated Code

The `ProductInfo` service provides:
- `addProduct(Product) -> ProductID` - Add a new product
- `getProduct(ProductID) -> Product` - Retrieve a product by ID

Generated files are placed in `gen/`:
- **Python**: `gen/python/product/` - `*_pb2.py` and `*_pb2_grpc.py`
- **Go**: `gen/go/product/` - `*.pb.go`
- **C++**: `gen/c++/product/` - `*.pb.h/cc` and `*.grpc.pb.h/cc`

## Testing

**Python:**
```bash
cd gen/python
python3 -c "
import product.product_info_pb2 as pb
product = pb.Product(name='Test', description='Test product', price=29.99)
print(f'Product: {product.name}')
"
```

**Go:**
```bash
cd gen/go && go mod init example
go run -c "
package main
import (\"fmt\"; \"example/product\")
func main() {
    p := &product.Product{Name: \"Test\", Price: 29.99}
    fmt.Printf(\"Product: %s\\n\", p.Name)
}
"
```

## Build Notes

- **First build**: Takes 2-3 minutes (downloads gRPC ecosystem)
- **Subsequent builds**: Very fast due to Bazel caching
- **Hermetic builds**: Reproducible across environments
- **No post-processing**: Generated code works out-of-the-box

## Adding Services

1. Create `.proto` file in `proto/`
2. Add `BUILD` file with targets
3. Update `Makefile`
4. Run `make generate`
