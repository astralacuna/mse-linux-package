#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo "Uninstalling Magic Set Editor..."

# Remove binary
rm -f ~/.local/bin/magicseteditor
echo "Removed binary."

# Remove app launcher entry
rm -f ~/.local/share/applications/magicseteditor.desktop
update-desktop-database ~/.local/share/applications 2>/dev/null || true
echo "Removed app launcher entry."

# Ask before removing fonts installed by our package
if [ -d "$SCRIPT_DIR/fonts" ] && [ -d ~/.local/share/fonts ]; then
    echo ""
    read -p "Remove fonts installed by Magic Set Editor? [y/N] " confirm_fonts
    if [[ "$confirm_fonts" =~ ^[Yy]$ ]]; then
        while IFS= read -r font; do
            rm -f ~/.local/share/fonts/"$(basename "$font")"
        done < <(find "$SCRIPT_DIR/fonts" -type f)
        fc-cache -f ~/.local/share/fonts
        echo "Removed fonts."
    else
        echo "Skipped fonts."
    fi
fi

# Remove shared data (resources and bundled libraries)
rm -rf ~/.local/share/magicseteditor
echo "Removed shared data and bundled libraries."

# Ask before removing data
echo ""
read -p "Remove ~/.magicseteditor (this will delete any card sets you've saved)? [y/N] " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf ~/.magicseteditor
    echo "Removed ~/.magicseteditor."
else
    echo "Skipped ~/.magicseteditor — your saved work is safe."
fi

echo ""
echo "Magic Set Editor has been uninstalled."
