#!/bin/bash

# --- Configuration ---
APP_NAME="MyURLHandler.app" # Output application bundle name (should match CFBundleName ideally)
SCRIPT_SOURCE="HandleURL.applescript" # Input AppleScript file
PLIST_SOURCE="Info.plist" # Input Info.plist file
RESOURCE_SCRIPT="your_actual_script.sh" # The shell script to bundle

# --- Error Checking ---
if [ ! -f "$SCRIPT_SOURCE" ]; then echo "Error: AppleScript source '$SCRIPT_SOURCE' not found."; exit 1; fi
if [ ! -f "$PLIST_SOURCE" ]; then echo "Error: Info.plist source '$PLIST_SOURCE' not found."; exit 1; fi
if [ ! -f "$RESOURCE_SCRIPT" ]; then echo "Error: Resource script '$RESOURCE_SCRIPT' not found."; exit 1; fi

# --- Build Steps ---
echo "Ensuring resource script is executable..."
chmod +x "$RESOURCE_SCRIPT"
if [ $? -ne 0 ]; then echo "Error: Failed to make resource script executable."; exit 1; fi

echo "Compiling AppleScript to application bundle '$APP_NAME'..."
# -x creates an app bundle, -o specifies output name
osacompile -x -o "$APP_NAME" "$SCRIPT_SOURCE"
if [ $? -ne 0 ]; then echo "Error: osacompile failed."; exit 1; fi

echo "Replacing default Info.plist with custom '$PLIST_SOURCE'..."
cp "$PLIST_SOURCE" "$APP_NAME/Contents/Info.plist"
if [ $? -ne 0 ]; then echo "Error: Failed to copy Info.plist."; exit 1; fi

echo "Copying resource script '$RESOURCE_SCRIPT' into bundle..."
# Create Resources directory if it doesn't exist
mkdir -p "$APP_NAME/Contents/Resources"
cp "$RESOURCE_SCRIPT" "$APP_NAME/Contents/Resources/"
if [ $? -ne 0 ]; then echo "Error: Failed to copy resource script."; exit 1; fi

echo ""
echo "Build successful: '$APP_NAME' created."
echo "To register the URL handler with macOS:"
echo "1. Move '$APP_NAME' to your /Applications or ~/Applications folder."
echo "   (Moving it forces LaunchServices to notice it)."
echo "2. OR, for immediate registration without moving, run:"
echo "   /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f \"$(pwd)/$APP_NAME\""

echo "WE ARE PROCEEDING WITH OPTION 2..."

# --- Auto-register ---
echo "Registering the application with LaunchServices..."
# Construct the absolute path to the app bundle
APP_PATH="$(pwd)/$APP_NAME"
# Run lsregister
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_PATH"
if [ $? -ne 0 ]; then
    echo "Warning: lsregister command failed. You may need to register manually by moving the app."
    # Optionally exit here if registration is critical: exit 1
else
    echo "Registration successful (or app already registered)."
fi

echo ""
echo "Build and registration complete for '$APP_NAME'."
echo "You can now test by opening a URL like 'reveal://some/data' in your browser or using 'open reveal://some/data' in Terminal."

exit 0
