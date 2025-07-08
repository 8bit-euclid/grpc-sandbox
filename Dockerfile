FROM bufbuild/buf:1.54.0

# Install additional tools needed for the build process
RUN apk add --no-cache \
    bash \
    make \
    curl \
    git

# Create gen directory with wide permissions
RUN mkdir -p /app/gen && chmod -R 777 /app

WORKDIR /app

# Default command when container starts
CMD ["buf", "--help"]