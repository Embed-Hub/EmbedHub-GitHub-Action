#!/bin/bash
# Builds the action image (podman or docker) and checks the pinned CLI is in it.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE="$(command -v podman || command -v docker)" || { echo "SKIP: no podman/docker"; exit 0; }
WANT="$(sed -n 's/^ARG EMBEDHUB_CLI_VERSION=//p' "$HERE/Dockerfile")"
TAG="embedhub-action-test:$$"
trap '"$ENGINE" rmi -f "$TAG" >/dev/null 2>&1 || true' EXIT
"$ENGINE" build -q -t "$TAG" "$HERE" >/dev/null
GOT="$("$ENGINE" run --rm --entrypoint embedhub "$TAG" --version)"
[ "$GOT" = "embedhub version $WANT" ] && echo "PASS  image has CLI $WANT" || { echo "FAIL  $GOT (want $WANT)"; exit 1; }
OUT="$("$ENGINE" run --rm -e GITHUB_OUTPUT=/dev/null "$TAG" acme firmware x.bin '' . 2>&1 || true)"
grep -q "project token is required" <<<"$OUT" && echo "PASS  image entrypoint asks for a token" || { echo "FAIL  $OUT"; exit 1; }
