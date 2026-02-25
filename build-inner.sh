#!/bin/bash
set -e
PKG="/build/mse-package"

# Allow git to operate on the mounted build directory
git config --global --add safe.directory /build/MagicSetEditor2

echo "=== Cloning/updating MagicSetEditor2 ==="
if [ ! -d "/build/MagicSetEditor2" ]; then
    git clone https://github.com/G-e-n-e-v-e-n-s-i-S/MagicSetEditor2.git "/build/MagicSetEditor2"
else
    git -C "/build/MagicSetEditor2" pull
fi

echo "=== Building ==="
cmake -S "/build/MagicSetEditor2" -B "/build/MagicSetEditor2/build" \
    -DCMAKE_BUILD_TYPE=Release \
    "-DCMAKE_EXE_LINKER_FLAGS=-Wl,--disable-new-dtags,-rpath,\$ORIGIN/../share/magicseteditor/lib"
cmake --build "$BUILD/MagicSetEditor2/build" --target magicseteditor -- -j$(nproc)

echo "=== Downloading MSE base data files ==="
wget -q -O "/build/mse-win.zip" https://github.com/twanvl/MagicSetEditor2/releases/download/v2.1.2/magicseteditor-2.1.2-win32.zip
unzip -q -o "/build/mse-win.zip" -d "/build/mse-win"

echo "=== Assembling package ==="
rm -rf "$PKG"
mkdir -p "$PKG/bin"
mkdir -p "$PKG/data/data"
mkdir -p "$PKG/data/resource"
mkdir -p "$PKG/lib"

cp "/build/MagicSetEditor2/build/magicseteditor" "$PKG/bin/"
cp -r "/build/mse-win/data/"* "$PKG/data/data/"
cp -r "/build/MagicSetEditor2/resource/." "$PKG/data/resource/"

echo "=== Bundling runtime libraries ==="
# Bundle MSE-specific libs (wx, boost, hunspell) but exclude anything that
# touches the host GTK/font rendering stack — those must come from the host
# to avoid version conflicts with libglib, libpango, etc.
ldd "$PKG/bin/magicseteditor" \
    | grep -v -E "linux-vdso|ld-linux|libc\.so|libm\.so|libdl\.so|libpthread\.so|librt\.so|libGL\.so|libX|libxcb|libgdk|libglib|libgobject|libgio|libpango|libcairo|libatk|libfontconfig|libfreetype|libdbus|libexpat|libffi|libmount|libselinux|libsystemd|libresolv|libnss|libpcre2|libharfbuzz" \
    | awk '$3 ~ /^\// {print $3}' \
    | while read lib; do
        cp -L "$lib" "$PKG/lib/$(basename "$lib")"
        echo "  Bundled: $(basename "$lib")"
    done

# libicu is a transitive dep via boost_regex and doesn't appear as a resolved
# path in ldd output, so it must be copied explicitly.
# Note: path is architecture-specific (x86_64-linux-gnu).
find /usr/lib/x86_64-linux-gnu -name "libicu*.so*" -type f | while read lib; do
    cp -L "$lib" "$PKG/lib/$(basename "$lib")"
    echo "  Bundled: $(basename "$lib")"
done

echo "=== Copying installer scripts ==="
cp /src/mse-package/install.sh "$PKG/"
cp /src/mse-package/uninstall.sh "$PKG/"
chmod +x "$PKG/install.sh" "$PKG/uninstall.sh"

echo "=== Bundling tarball ==="
cd /build
tar -czf MagicSetEditor-linux.tar.gz mse-package/
echo "Done! $(du -sh MagicSetEditor-linux.tar.gz)"

echo "=== Cleaning up ==="
rm -rf /build/mse-win /build/mse-win.zip
