FROM debian:bookworm-slim

# Install ca-certificates for HTTPS and bash
RUN apt-get update && \
    apt-get install -y ca-certificates bash && \
    rm -rf /var/lib/apt/lists/*

# Copy the pre-built EmbedHub CLI binary (Linux x86_64)
COPY embedhub-linux-amd64 /usr/local/bin/embedhub
RUN chmod +x /usr/local/bin/embedhub

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
