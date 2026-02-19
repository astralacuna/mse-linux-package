#!/bin/bash
set -e
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Check dependencies
if ! command -v git &>/dev/null; then
    echo "Error: git is required but not installed. Please install it and re-run."
    exit 1
fi

# Check for binary and build.sh
if [ ! -f "$SCRIPT_DIR/bin/magicseteditor" ]; then
    echo "Binary not found. Running build.sh first..."
    if [ -f "$SCRIPT_DIR/../build.sh" ]; then
        bash "$SCRIPT_DIR/../build.sh"
    else
        echo "Error: Cannot find build.sh. Please download the tarball from the Releases page instead of cloning the repo directly."
        exit 1
    fi
fi

# Install binary
echo "Installing Magic Set Editor..."
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/bin/magicseteditor" ~/.local/bin/
chmod +x ~/.local/bin/magicseteditor

# Install base data files
mkdir -p ~/.magicseteditor/resource
mkdir -p ~/.local/share/magicseteditor/resource

cp -r "$SCRIPT_DIR/data/data" ~/.magicseteditor/data
cp -r "$SCRIPT_DIR/data/resource/." ~/.magicseteditor/resource/
cp -r "$SCRIPT_DIR/data/resource/." ~/.local/share/magicseteditor/resource/



# Pack selection
echo ""
echo "Which template pack would you like to install?"
echo "  1) Basic M15       - Beginner-friendly, small download (~50MB)"
echo "  2) M15             - All M15-style templates (~200MB)"
echo "  3) Full MTG        - Nearly all public MTG templates (~600MB)"
echo "  4) Full Non-MTG    - Non-Magic card game templates (~300MB)"
echo "  5) Full MTG + Non-MTG (everything)"
echo "  6) None (skip)"
echo ""
read -p "Enter choice [1-6]: " pack_choice

install_pack() {
    local repo="$1"
    local font_dir="$2"
    local tmp_dir="/tmp/mse-pack-$$"

    echo "Cloning $repo (this may take a while)..."
    git clone --depth=1 "https://github.com/MagicSetEditorPacks/$repo.git" "$tmp_dir"

    echo "Installing templates..."
    cp -r "$tmp_dir/data/"* ~/.magicseteditor/data/

    echo "Installing fonts..."
    mkdir -p ~/.local/share/fonts
    find "$tmp_dir/$font_dir" -maxdepth 1 \( -name "*.ttf" -o -name "*.otf" \) \
        -exec cp {} ~/.local/share/fonts/ \; 2>/dev/null || true

    rm -rf "$tmp_dir"
    echo "$repo installed."
}

case "$pack_choice" in
    1) install_pack "Basic-M15-Magic-Pack" "Magic - Fonts" ;;
    2) install_pack "M15-Magic-Pack" "Magic - Fonts" ;;
    3) install_pack "Full-Magic-Pack" "Magic - Fonts" ;;
    4) install_pack "Full-Non-Magic-Pack" "Other - Fonts" ;;
    5)
        install_pack "Full-Magic-Pack" "Magic - Fonts"
        install_pack "Full-Non-Magic-Pack" "Other - Fonts"
        ;;
    6) echo "Skipping template pack installation." ;;
    *) echo "Invalid choice, skipping template pack installation." ;;
esac

# Refresh font cache
if command -v fc-cache &>/dev/null; then
    fc-cache -f ~/.local/share/fonts
fi

# Create app launcher entry
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/magicseteditor.desktop << DESKTOP
[Desktop Entry]
Type=Application
Name=Magic Set Editor
Exec=/home/$USER/.local/bin/magicseteditor
Icon=utilities-text-editor
Categories=Graphics;
DESKTOP
update-desktop-database ~/.local/share/applications 2>/dev/null || true

echo ""
echo "Done! Launch Magic Set Editor from your app menu or by typing 'magicseteditor' in a terminal."
echo "If the terminal command isn't found, run: export PATH=\"\$HOME/.local/bin:\$PATH\""
