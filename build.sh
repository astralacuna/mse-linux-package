#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PKG="$SCRIPT_DIR/mse-package"

echo "=== Cloning/updating MagicSetEditor2 ==="
if [ ! -d MagicSetEditor2 ]; then
    git clone https://github.com/haganbmj/MagicSetEditor2.git
else
    git -C MagicSetEditor2 pull
fi

echo "=== Building ==="
cmake -S MagicSetEditor2 -B MagicSetEditor2/build -DCMAKE_BUILD_TYPE=Release
cmake --build MagicSetEditor2/build -- -j$(nproc)

echo "=== Downloading MSE data files ==="
wget -q -O mse-win.zip https://github.com/twanvl/MagicSetEditor2/releases/download/v2.1.2/magicseteditor-2.1.2-win32.zip
unzip -q -o mse-win.zip -d mse-win

echo "=== Assembling package ==="
mkdir -p "$PKG/bin" "$PKG/fonts"
mkdir -p "$PKG/data/data" "$PKG/data/resource"

cp MagicSetEditor2/build/magicseteditor "$PKG/bin/"
cp -r mse-win/data/* "$PKG/data/data/"
cp -r MagicSetEditor2/resource "$PKG/data/resource"
cp -r Full-Magic-Pack/data/* "$PKG/data/data/"
cp Full-Magic-Pack/Magic\ -\ Fonts/*.ttf "$PKG/fonts/" 2>/dev/null || true

echo "=== Bundling tarball ==="
cd "$SCRIPT_DIR"
tar -czf MagicSetEditor-linux.tar.gz mse-package/
echo "Done! $(du -sh MagicSetEditor-linux.tar.gz)"

echo "=== Cleaning up ==="
rm -rf mse-win mse-win.zip
