#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if [ ! -f "$SCRIPT_DIR/build-inner.sh" ]; then
    echo "Error: build-inner.sh not found. Run build.sh from the repo root, not from mse-package/."
    exit 1
fi

echo "Select build target:"
echo "  1) Debian 12  — glibc 2.36+ (default, recommended)"
echo "  2) Debian 11  — glibc 2.31+ (wider distro compatibility)"
echo "  3) Local machine (no Docker)"
echo ""
read -p "Enter choice [1-3, default 1]: " distro_choice
distro_choice="${distro_choice:-1}"

case "$distro_choice" in
    1)
        BASE_IMAGE="debian:12"
        IMAGE_TAG="mse-linux-build-debian12"
        ;;
    2)
        BASE_IMAGE="debian:11"
        IMAGE_TAG="mse-linux-build-debian11"
        ;;
    3)
        echo "Warning: local build requires wxWidgets >= 3.3.1, boost, hunspell, libicu, cmake, git, wget, unzip"
        read -p "Continue? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
        exec "$SCRIPT_DIR/build-inner.sh"
        ;;
    *)
        echo "Invalid choice, defaulting to Debian 12."
        BASE_IMAGE="debian:12"
        IMAGE_TAG="mse-linux-build-debian12"
        ;;
esac

# Build Docker image if not already cached for this target
if ! docker image inspect "$IMAGE_TAG" &>/dev/null; then
    echo "=== Building Docker image ($BASE_IMAGE) ==="
    docker build --build-arg BASE_IMAGE="$BASE_IMAGE" -t "$IMAGE_TAG" "$SCRIPT_DIR"
fi

mkdir -p ~/build/mse

echo "=== Running build in $IMAGE_TAG ==="
docker run --rm \
    -v "$SCRIPT_DIR:/src:ro" \
    -v "$HOME/build/mse:/build" \
    --user $(id -u):$(id -g) \
    "$IMAGE_TAG" \
    /src/build-inner.sh
