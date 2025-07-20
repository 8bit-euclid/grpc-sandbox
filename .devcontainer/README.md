# DevContainer Setup with Docker-in-Docker

This devcontainer is configured with Docker-in-Docker support, allowing you to run Docker commands inside the development container.

## Features

- **Docker-in-Docker**: Full Docker functionality inside the devcontainer
- **gRPC Development Tools**: Go, Python, Buf, Bazel, and other gRPC-related tools
- **Non-root Docker**: Docker runs without requiring root privileges
- **Privileged Container**: Necessary for Docker-in-Docker functionality

## Getting Started

1. **Open in DevContainer**: Use VS Code's "Reopen in Container" command
2. **Wait for Setup**: The container will automatically install Docker and set up the environment
3. **Automatic Validation**: Post-creation tests run automatically to verify the setup
4. **Manual Testing**: You can also run tests manually anytime:
   ```bash
   bash .devcontainer/test-workspace.sh
   ```

## Docker-in-Docker Configuration

The devcontainer uses the official Docker-in-Docker feature:
- **Feature**: `ghcr.io/devcontainers/features/docker-in-docker:2`
- **Non-root Docker**: Enabled for the `vscode` user
- **Privileged Mode**: Required for Docker daemon to function

## Testing

### Run All Tests
```bash
bash .devcontainer/test-workspace.sh
```

### Run Individual Test Categories
```bash
# Configuration validation
bash .devcontainer/tests/test-config.sh

# Docker functionality
bash .devcontainer/tests/test-docker.sh

# Development tools
bash .devcontainer/tests/test-tools.sh

# Port availability checks
bash .devcontainer/tests/test-ports.sh

# System resource checks
bash .devcontainer/tests/test-resources.sh

# Container build testing
bash .devcontainer/tests/test-build.sh
```

The modular test system includes:
- **Configuration validation**: JSON syntax, file existence
- **Docker functionality**: Installation, daemon status, pull, run, and build tests
- **Tool verification**: Go, Python, Buf, Bazel availability
- **Port availability**: Check for conflicts on key ports (50051, 8080, 3000)
- **System resources**: Disk space and memory usage
- **Build testing**: Verify container can be built and workspace mounting works

## Troubleshooting

### Docker Daemon Not Ready
If Docker commands fail immediately after container startup:
- Wait a few seconds for the Docker daemon to initialize
- The Docker-in-Docker service takes time to start (up to 60 seconds)
- Check with `docker info` to verify the daemon is running
- Post-creation tests automatically wait for Docker to be ready

### Post-Creation Test Failures
If tests fail during devcontainer creation:
- This is often normal during initial Docker-in-Docker setup
- The devcontainer will still be created successfully
- Run `bash .devcontainer/test-workspace.sh` manually after setup completes
- Most issues resolve themselves after services fully initialize

### Permission Issues
If you encounter Docker permission errors:
- Ensure you're using the `vscode` user (default)
- The Docker-in-Docker feature automatically handles group permissions
- Restart the devcontainer if issues persist

### Build Failures
If container builds fail:
- Check that Docker Desktop is running on the host (if applicable)
- Verify the devcontainer.json syntax is valid
- Review the Docker daemon logs: `docker system events`

## Configuration Files

- **devcontainer.json**: Main devcontainer configuration with Docker-in-Docker feature
- **Dockerfile**: Base container setup with development tools
- **shared-utils.sh**: Shared utilities and logging functions for all scripts
- **post-create.sh**: Post-creation validation script (runs automatically)

### Test Scripts

- **test-workspace.sh**: Main test orchestrator that runs all test categories
- **tests/test-config.sh**: Configuration file validation (JSON syntax, file existence)
- **tests/test-docker.sh**: Docker functionality tests (installation, daemon, pull, run, build)
- **tests/test-tools.sh**: Development tool verification (Go, Python, Buf, Bazel)
- **tests/test-ports.sh**: Port availability checks
- **tests/test-resources.sh**: System resource checks (disk space, memory)
- **tests/test-build.sh**: Container build and workspace mounting tests

### Benefits of Modular Testing

- **Organized Structure**: Test scripts are organized in a dedicated `tests/` directory
- **Standardized Interface**: Each test script has a `main()` function for consistent execution
- **Shared Utilities**: Common logging functions and utilities available to all scripts
- **Consistent Output**: Standardized success/warning/error formatting across all scripts
- **Focused Testing**: Run only the tests you need during development
- **Faster Debugging**: Isolate issues to specific categories
- **Better Maintainability**: Each script has a single responsibility
- **Reusable Components**: Shared utilities prevent code duplication
- **Parallel Development**: Multiple developers can work on different test categories

## Notes

- The container runs in privileged mode for Docker-in-Docker functionality
- Docker images built inside the devcontainer are isolated from the host
- Use `docker system prune` periodically to clean up unused images and containers
