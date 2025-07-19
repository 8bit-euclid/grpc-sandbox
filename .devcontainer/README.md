# DevContainer Setup with Docker-in-Docker

This devcontainer provides a complete development environment with Docker-in-Docker support for gRPC development.

## Features

- **Docker-in-Docker**: Full Docker functionality with non-root access
- **SSH Agent Forwarding**: Secure access to host SSH keys for Git operations
- **gRPC Development Tools**: Go, Python, Buf, Bazel, and related tooling
- **Automated Testing**: Comprehensive validation of the development environment

## Getting Started

1. **Open in DevContainer**: Use VS Code's "Reopen in Container" command
2. **Wait for Setup**: The container automatically installs Docker and configures the environment
3. **Verify Setup**: Post-creation tests run automatically, or run manually:
   ```bash
   bash .devcontainer/test-workspace.sh
   ```

## Configuration

### Docker-in-Docker
- Uses `ghcr.io/devcontainers/features/docker-in-docker:2`
- Runs in privileged mode (required for Docker daemon)
- Non-root Docker access for the `vscode` user

### SSH Agent Forwarding
- Host SSH agent socket mounted at `/ssh-agent`
- Environment variable `SSH_AUTH_SOCK` automatically configured
- Private keys remain secure on the host system

## Testing

### Run All Tests
```bash
bash .devcontainer/test-workspace.sh
```

### Run Individual Test Categories
```bash
# Configuration and tools
bash .devcontainer/tests/test-config.sh
bash .devcontainer/tests/test-tools.sh

# Docker functionality
bash .devcontainer/tests/test-docker.sh
bash .devcontainer/tests/test-build.sh

# System checks
bash .devcontainer/tests/test-ports.sh
bash .devcontainer/tests/test-resources.sh

# SSH agent forwarding
bash .devcontainer/scripts/tests/test-ssh-agent.sh
```

The test system validates:
- Configuration files and development tools
- Docker installation, daemon, and container operations
- SSH agent forwarding and Git connectivity
- Port availability and system resources

## Troubleshooting

### Docker Issues
- **Daemon not ready**: Wait up to 60 seconds for Docker-in-Docker to initialize after container startup
- **Permission errors**: Ensure you're using the `vscode` user; restart the devcontainer if issues persist
- **Build failures**: Verify Docker Desktop is running on host and check `devcontainer.json` syntax

### SSH Agent Issues
- **Not working**: Ensure SSH agent is running (`ssh-add -l`) and keys are added (`ssh-add ~/.ssh/id_rsa`)
- **Test connectivity**: Run `bash .devcontainer/scripts/tests/test-ssh-agent.sh`

### Test Failures
- **During creation**: Often normal during initial setup; run tests manually after services initialize
- **Persistent issues**: Run `bash .devcontainer/test-workspace.sh` to identify specific problems

## File Structure

### Configuration
- `devcontainer.json` - Main devcontainer configuration
- `Dockerfile` - Base container with development tools
- `post-create.sh` - Automatic validation script

### Testing
- `test-workspace.sh` - Main test orchestrator
- `tests/` - Individual test categories (config, docker, tools, ports, resources, build)
- `shared-utils.sh` - Common utilities and logging functions

## Notes

- Container runs in privileged mode for Docker-in-Docker functionality
- Docker images are isolated from the host system
- Use `docker system prune` periodically to clean up unused resources
