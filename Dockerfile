# Use Go Alpine image for building the CLI
FROM golang:1.21-alpine AS builder

# Install dependencies
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /build

# Clone the EmbedHub CLI repository
RUN git clone https://github.com/embedhub/cli.git /build

# Build the CLI binary
RUN go mod download && \
    go build -ldflags "-s -w" -o embedhub .

# Create final minimal image
FROM alpine:latest

# Install ca-certificates for HTTPS
RUN apk --no-cache add ca-certificates bash

# Copy the CLI binary from builder
COPY --from=builder /build/embedhub /usr/local/bin/embedhub

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
