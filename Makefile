# Makefile for generating gRPC code from protobuf files. Docker is used to run the protoc compiler in a container and the generated code is written to the 'gen' directory.

# Configuration. Use current user's UID and GID to avoid permission issues
UID = $(shell id -u)
GID = $(shell id -g)
OUT_DIR = gen
DOCKER_IMAGE = schema-generator
DOCKER_RUN = @docker run --rm --user $(UID):$(GID) -e XDG_CACHE_HOME=/tmp/.cache -v $(shell pwd):/app $(DOCKER_IMAGE)

.PHONY: all clean build generate

# Default target
all: clean build generate

# Build Docker image
build:
	@echo "Building Docker image..."
	@docker build -t $(DOCKER_IMAGE) .

# Generate code using buf
generate: build
	@echo "Generating code with buf..."
	$(DOCKER_RUN) generate

# Clean generated code
clean:
	@echo "Cleaning generated code..."
	@rm -rf $(OUT_DIR)

# Helper targets
lint:
	@echo "Linting proto files..."
	$(DOCKER_RUN) lint

breaking:
	@echo "Checking for breaking changes..."
	$(DOCKER_RUN) breaking --against ".git#branch=main"

format:
	@echo "Formatting proto files..."
	$(DOCKER_RUN) format -w
