#!/bin/bash
echo "Uninstalling Magic Set Editor..."

# Remove binary
rm -f ~/.local/bin/magicseteditor
echo "Removed binary."

# Remove app launcher entry
rm -f ~/.local/share/applications/magicseteditor.desktop
update-desktop-database ~/.local/share/applications 2>/dev/null
echo "Removed app launcher entry."

# Remove fonts
if [ -d ~/.local/share/fonts ]; then
    # Only remove fonts that came from our package
    while IFS= read -r font; do
        rm -f ~/.local/share/fonts/"$(basename "$font")"
    done < <(find "$(dirname "$(readlink -f "$0")")/fonts" -type f)
    fc-cache -f ~/.local/share/fonts
    echo "Removed fonts."
fi

# Ask before removing data since it may contain the user's saved work
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
