@echo off
:: Meriam Raya – first-time project setup (Windows)
:: Run this once after cloning to generate .godot/uid_cache.bin
:: Requires: godot.exe (Godot 4.3) on PATH or in the same directory
echo Setting up Meriam Raya project...
godot --headless --path . --import --quit
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: godot not found on PATH. Install Godot 4.3 and re-run,
    echo or open the project in the Godot editor to trigger import.
) else (
    echo Done. You can now run the game.
    echo To commit the generated cache: git add .godot/uid_cache.bin
)
