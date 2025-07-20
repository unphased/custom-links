#!/bin/bash

# --- Manual Quick Action Setup (for reference) ---
# The `install-quick-action.sh` script automates this process. If it fails on a
# future macOS version, you can perform these steps manually in Automator:
# 1. Open Automator and create a new "Quick Action".
# 2. Set "Workflow receives current" to "text" in "any application".
# 3. Add a "Run Shell Script" action.
# 4. Set "Pass input" to "to stdin" and shell to "/bin/zsh" (or your preferred shell).
# 5. Paste the following script into the text box:
#    input=$(cat)
#    open "reveal://$input"
# 6. Save the Quick Action with a name like "Reveal Path".
# ---------------------------------------------------

# --- Configuration ---
APP_NAME="MyURLHandler.app" # Output application bundle name (should match CFBundleName ideally)
PLIST_SOURCE="Info.plist" # Input Info.plist file
RESOURCE_SCRIPT="dispatch.sh" # The shell script to bundle

# --- Error Checking ---
if [ ! -f "$PLIST_SOURCE" ]; then echo "Error: Info.plist source '$PLIST_SOURCE' not found."; exit 1; fi
if [ ! -f "$RESOURCE_SCRIPT" ]; then echo "Error: Resource script '$RESOURCE_SCRIPT' not found."; exit 1; fi

# --- Build Steps ---
echo "Ensuring resource script is executable..."
chmod +x "$RESOURCE_SCRIPT"
if [ $? -ne 0 ]; then echo "Error: Failed to make resource script executable."; exit 1; fi

echo "Compiling AppleScript to application bundle '$APP_NAME'..."

# AppleScript to handle the URL and run the bundled shell script.
# This is embedded here to avoid needing a separate .applescript file.
APPLESCRIPT_CODE='
on open location theURL
	# Get the path to the application bundle itself
	set appPath to path to me
	# Construct the path to the shell script inside the Resources folder
	set scriptPath to POSIX path of appPath & "Contents/Resources/dispatch.sh"

	# Execute the shell script, passing the received URL as the first argument.
	try
		do shell script "/bin/bash " & quoted form of scriptPath & " " & quoted form of theURL
	on error errMsg number errNum
		# Basic error handling: display a dialog if the script fails
		display dialog "Error executing script: " & errMsg & " (Error " & errNum & ")" with title "MyURLHandler Error" buttons {"OK"} default button "OK"
	end try
end open location

on run
	# This handler is called if the Application is launched directly, not via URL
	display dialog "This application is intended to be launched via its custom URL scheme (reveal://)." with title "MyURLHandler" buttons {"OK"} default button "OK"
end run
'

# -x creates an app bundle, -o specifies output name, -e executes a script string
osacompile -x -e "${APPLESCRIPT_CODE}" -o "$APP_NAME"
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
