FROM debian:bookworm-slim

# The EmbedHub CLI, pinned. Bump on each CLI release.
ARG EMBEDHUB_CLI_VERSION=0.18

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates bash curl && \
    curl -fsSL "https://cdn.embedhub.com/cli/${EMBEDHUB_CLI_VERSION}/embedhub-linux-amd64" -o /usr/local/bin/embedhub && \
    chmod +x /usr/local/bin/embedhub && \
    apt-get purge -y curl && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
