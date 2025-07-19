FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Create workspace directory first
RUN mkdir -p /workspace

# Rename existing ubuntu user to vscode (UID/GID 1000 already exists)
RUN usermod -l vscode ubuntu \
    && groupmod -n vscode ubuntu \
    && usermod -d /home/vscode -m vscode

# Set ownership and permissions of workspace
RUN chown -R vscode:vscode /workspace \
    && chmod -R 755 /workspace

# Install essential packages
RUN apt-get update && apt-get install -y \
    # Basic tools
    curl \
    wget \
    make \
    build-essential \
    libgrpc++-dev \
    sudo \
    git \
    # Python
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget -O go.tar.gz https://go.dev/dl/go1.24.4.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz

# Install buf
RUN wget -O /usr/local/bin/buf https://github.com/bufbuild/buf/releases/download/v1.55.1/buf-Linux-x86_64 \
    && chmod +x /usr/local/bin/buf

# Install Bazelisk as the Bazel binary (Bazelisk is a wrapper and version manager for Bazel)
RUN wget -O /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.26.0/bazelisk-linux-amd64 \
    && chmod +x /usr/local/bin/bazel

# Install Buildifier (Bazel BUILD file formatter and linter)
RUN wget -O /usr/local/bin/buildifier https://github.com/bazelbuild/buildtools/releases/latest/download/buildifier-linux-amd64 \
    && chmod +x /usr/local/bin/buildifier

# Set up environment
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/vscode/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Add vscode user to sudo group - must be done as root
# Docker group will be handled by the docker-in-docker feature
RUN usermod -aG sudo vscode \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to vscode user
USER vscode
WORKDIR /workspace

# Install basic Python packages (using break-system-packages for Ubuntu 24.04)
RUN python3 -m pip install --user --break-system-packages grpcio protobuf
