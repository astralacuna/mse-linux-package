#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
BUILD_DIR="$HOME/build/mse"
PKG="$BUILD_DIR/mse-package"

echo "=== Cloning/updating MagicSetEditor2 ==="
mkdir -p "$BUILD_DIR"
if [ ! -d "$BUILD_DIR/MagicSetEditor2" ]; then
    git clone https://github.com/haganbmj/MagicSetEditor2.git "$BUILD_DIR/MagicSetEditor2"
else
    git -C "$BUILD_DIR/MagicSetEditor2" pull
fi

echo "=== Building ==="
cmake -S "$BUILD_DIR/MagicSetEditor2" -B "$BUILD_DIR/MagicSetEditor2/build" -DCMAKE_BUILD_TYPE=Release
cmake --build "$BUILD_DIR/MagicSetEditor2/build" -- -j"$(nproc)"

echo "=== Downloading MSE base data files ==="
wget -q -O "$BUILD_DIR/mse-win.zip" https://github.com/twanvl/MagicSetEditor2/releases/download/v2.1.2/magicseteditor-2.1.2-win32.zip
unzip -q -o "$BUILD_DIR/mse-win.zip" -d "$BUILD_DIR/mse-win"

echo "=== Assembling package ==="
mkdir -p "$PKG/bin"
mkdir -p "$PKG/data/data"
mkdir -p "$PKG/data/resource"

cp "$BUILD_DIR/MagicSetEditor2/build/magicseteditor" "$PKG/bin/"
cp -r "$BUILD_DIR/mse-win/data/"* "$PKG/data/data/"
cp -r "$BUILD_DIR/MagicSetEditor2/resource/." "$PKG/data/resource/"

# Copy installer scripts from source tree
cp "$SCRIPT_DIR/mse-package/install.sh" "$PKG/"
cp "$SCRIPT_DIR/mse-package/uninstall.sh" "$PKG/"
chmod +x "$PKG/install.sh" "$PKG/uninstall.sh"

echo "=== Bundling tarball ==="
cd "$BUILD_DIR"
tar -czf MagicSetEditor-linux.tar.gz mse-package/
echo "Done! $(du -sh MagicSetEditor-linux.tar.gz)"

echo "=== Cleaning up ==="
rm -rf "$BUILD_DIR/mse-win" "$BUILD_DIR/mse-win.zip"
