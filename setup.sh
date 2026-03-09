#!/usr/bin/env bash
# Meriam Raya – first-time project setup (Linux / macOS)
# Run once after cloning to generate .godot/uid_cache.bin
# Requires: godot (Godot 4.3) on PATH
set -e
echo "Setting up Meriam Raya project..."
if ! command -v godot &>/dev/null; then
    echo "WARNING: 'godot' not found on PATH. Install Godot 4.3 and re-run,"
    echo "or open the project in the Godot editor to trigger import."
    exit 1
fi
godot --headless --path . --import --quit
echo "Done. You can now run the game."
echo "To commit the generated cache: git add .godot/uid_cache.bin"
