#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PKG="$SCRIPT_DIR/mse-package"

echo "=== Cloning/updating MagicSetEditor2 ==="
if [ ! -d "$SCRIPT_DIR/MagicSetEditor2" ]; then
    git clone https://github.com/haganbmj/MagicSetEditor2.git "$SCRIPT_DIR/MagicSetEditor2"
else
    git -C "$SCRIPT_DIR/MagicSetEditor2" pull
fi

echo "=== Building ==="
cmake -S "$SCRIPT_DIR/MagicSetEditor2" -B "$SCRIPT_DIR/MagicSetEditor2/build" -DCMAKE_BUILD_TYPE=Release
cmake --build "$SCRIPT_DIR/MagicSetEditor2/build" -- -j$(nproc)

echo "=== Downloading MSE base data files ==="
wget -q -O "$SCRIPT_DIR/mse-win.zip" https://github.com/twanvl/MagicSetEditor2/releases/download/v2.1.2/magicseteditor-2.1.2-win32.zip
unzip -q -o "$SCRIPT_DIR/mse-win.zip" -d "$SCRIPT_DIR/mse-win"

echo "=== Assembling package ==="
mkdir -p "$PKG/bin"
mkdir -p "$PKG/data/data"
mkdir -p "$PKG/data/resource"

cp "$SCRIPT_DIR/MagicSetEditor2/build/magicseteditor" "$PKG/bin/"
cp -r "$SCRIPT_DIR/mse-win/data/"* "$PKG/data/data/"
cp -r "$SCRIPT_DIR/MagicSetEditor2/resource" "$PKG/data/resource"

echo "=== Bundling tarball ==="
cd "$SCRIPT_DIR"
tar -czf MagicSetEditor-linux.tar.gz mse-package/
echo "Done! $(du -sh MagicSetEditor-linux.tar.gz)"

echo "=== Cleaning up ==="
rm -rf "$SCRIPT_DIR/mse-win" "$SCRIPT_DIR/mse-win.zip"
