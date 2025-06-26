#!/usr/bin/env bash
# install.sh - Install cal-tui.sh to $HOME/.local/bin or custom location
# Usage:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/calahil/cal-tui/main/install.sh)"
#   OR
#   ./install.sh /desired/path

set -e

DEST=${1:-"$HOME/.local/bin"}
TUI_URL="https://raw.githubusercontent.com/calahil/cal-tui/main/cal-tui.sh"

mkdir -p "$DEST"
echo "📥 Downloading cal-tui.sh to $DEST..."
curl -fsSL "$TUI_URL" -o "$DEST/cal-tui.sh"
chmod +x "$DEST/cal-tui.sh"

echo -e "\n✅ Installed successfully."
echo -e "👉 Use with: source $DEST/cal-tui.sh"

