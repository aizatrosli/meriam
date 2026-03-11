#!/usr/bin/env bash
# dev_setup.sh – Install GUT testing framework for local development.
# Run this once after cloning the repository.
#
# CI/CD downloads GUT automatically (see .github/workflows/ci.yml).
# This script does the same for local Godot Editor use.

set -e

GUT_VERSION="v9.3.0"
ADDONS_DIR="$(cd "$(dirname "$0")/.." && pwd)/addons"

echo "=== Meriam Raya – Dev Setup ==="
echo "Installing GUT $GUT_VERSION to $ADDONS_DIR/gut/ ..."

mkdir -p "$ADDONS_DIR"

TMP_ZIP=$(mktemp /tmp/gut_XXXXXX.zip)
wget -q \
  "https://github.com/bitwes/Gut/releases/download/$GUT_VERSION/gut_$GUT_VERSION.zip" \
  -O "$TMP_ZIP"

unzip -q -o "$TMP_ZIP" -d "$ADDONS_DIR/"
rm "$TMP_ZIP"

echo "GUT installed at $ADDONS_DIR/gut/"
echo ""
echo "Next steps:"
echo "  1. Open the project in Godot 4.3+"
echo "  2. Go to Project > Project Settings > Plugins and enable GUT"
echo "  3. Run tests via GUT panel or: godot --headless -s addons/gut/gut_cmdln.gd -gconfig=res://tests/.gutconfig.json"
echo ""
echo "Done! Selamat bermain! / Happy playing!"
