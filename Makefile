# Makefile for generating gRPC code from protobuf files using buf

# Configuration
OUT_DIR = gen

# Language-specific configurations
GO_PATH = //src/go/product
PY_PATH = //src/python/product
CPP_PATH = //src/c++/product

.PHONY: all clean generate help
.PHONY: run-go-server run-go-client run-py-server run-py-client
.PHONY: run-cpp-server run-cpp-client run-cpp-server-dev run-cpp-client-dev

# Default target
all: generate

# Generate protobuf code using buf
generate: clean
	@echo "Generating protobuf code with buf..."
	@buf generate
	@echo "Creating BUILD files and IDE support for generated code..."
	@./scripts/create_gen_build_files.sh
	@echo "Code generation complete!"

# Generic run function - internal use only
define run_target
	@echo "Running $(1) $(2)$(if $(3), ($(3) build),)..."
	@bazel run $(if $(3),--config=$(3) )$(4)
endef

# Generic build function - internal use only
define build_target
	@echo "Building $(1) targets$(if $(2), for $(2),)..."
	@bazel build $(if $(2),--config=$(2) )$(3)
endef

# Language-specific run targets
run-go-server:
	$(call run_target,Go,server,,$(GO_PATH)/server)

run-go-client:
	$(call run_target,Go,client,,$(GO_PATH)/client)

run-py-server:
	$(call run_target,Python,server,,$(PY_PATH):server)

run-py-client:
	$(call run_target,Python,client,,$(PY_PATH):client)

run-cpp-server:
	$(call run_target,C++,server,,$(CPP_PATH)/server)

run-cpp-client:
	$(call run_target,C++,client,,$(CPP_PATH)/client)

run-cpp-server-dev:
	$(call run_target,C++,server,dev,$(CPP_PATH)/server)

run-cpp-client-dev:
	$(call run_target,C++,client,dev,$(CPP_PATH)/client)

# Clean generated files and Bazel cache
clean:
	@echo "Cleaning generated files and Bazel cache..."
	@rm -rf $(OUT_DIR)
	@bazel clean --expunge 2>/dev/null || true

# Show help information
help:
	@echo "Buf-based Proto Code Generation System"
	@echo "====================================="
	@echo ""
	@echo "Core targets:"
	@echo "  generate       - Generate protobuf code using buf"
	@echo "  clean          - Clean generated files and Bazel artifacts"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "Generic parameterized targets:"
	@echo "  run LANG=<go|py|cpp> TYPE=<server|client> [CONFIG=<dev>]"
	@echo "    Examples:"
	@echo "      make run LANG=go TYPE=server"
	@echo "      make run LANG=cpp TYPE=client CONFIG=dev"
	@echo ""
	@echo "  build-dev LANG=<go|py|cpp>"
	@echo "    Examples:"
	@echo "      make build-dev LANG=cpp"
	@echo ""
	@echo "Legacy specific targets (still supported):"
	@echo "  run-go-server      - Run Go server"
	@echo "  run-go-client      - Run Go client"
	@echo "  run-py-server      - Run Python server"
	@echo "  run-py-client      - Run Python client"
	@echo "  run-cpp-server     - Run C++ server (optimized build)"
	@echo "  run-cpp-client     - Run C++ client (optimized build)"
	@echo "  run-cpp-server-dev - Run C++ server (development build)"
	@echo "  run-cpp-client-dev - Run C++ client (development build)"
	@echo "  build-cpp-dev      - Build C++ targets for development"
	@echo ""
	@echo "The build system uses buf generate to create code directly in the correct locations."
	@echo "No file copying or import path corrections are needed."
	@echo ""
	@echo "Generated files are placed in:"
	@echo "  gen/python/    - Python protobuf and gRPC files"
	@echo "  gen/go/        - Go protobuf and gRPC files"
	@echo "  gen/c++/       - C++ protobuf and gRPC files"
