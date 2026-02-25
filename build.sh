#!/bin/bash

if [ ! -f "$SCRIPT_DIR/build-inner.sh" ]; then
    echo "Error: build-inner.sh not found. Run build.sh from the repo root, not from mse-package/."
    exit 1
fi

set -e
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
BUILD_DIR="$HOME/build/mse"
IMAGE_NAME="mse-linux-build"

mkdir -p "$BUILD_DIR"

if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
    echo "=== Building Docker image ==="
    docker build -t "$IMAGE_NAME" "$SCRIPT_DIR"
fi

echo "=== Running build in container ==="
docker run --rm \
    --user "$(id -u):$(id -g)" \
    --env HOME=/tmp \
    -v "$SCRIPT_DIR:/src:ro" \
    -v "$BUILD_DIR:/build" \
    "$IMAGE_NAME" \
    bash /src/build-inner.sh

echo ""
echo "=== Done! Release tarball: $BUILD_DIR/MagicSetEditor-linux.tar.gz ==="
