#!/bin/bash

# This script creates and installs a macOS Quick Action (Service) that
# sends selected text to the custom URL handler.

set -e

WORKFLOW_NAME="Reveal Path.workflow"
SERVICE_MENU_TITLE="Reveal Path"
SERVICES_DIR="$HOME/Library/Services"
WORKFLOW_PATH="$SERVICES_DIR/$WORKFLOW_NAME"

# --- Create Workflow ---
echo "Creating Quick Action: '$SERVICE_MENU_TITLE'"
rm -rf "$WORKFLOW_PATH"
mkdir -p "$WORKFLOW_PATH/Contents"

# --- Create Info.plist for the service ---
# This defines the service's name in the context menu and what input it accepts.
cat <<EOF > "$WORKFLOW_PATH/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>${SERVICE_MENU_TITLE}</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
			<key>NSSendTypes</key>
			<array>
				<string>public.utf8-plain-text</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
EOF

# --- Create document.wflow, the core Automator workflow file ---
# This defines the actions to take. Here, it's a single "Run Shell Script" action.
cat <<EOF > "$WORKFLOW_PATH/Contents/document.wflow"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>509</string>
	<key>AMApplicationName</key>
	<string>Automator</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>AM भीWorkflowType</key>
	<string>com.apple.Automator.workflow</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>2.0.3</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMParameterProperties</key>
				<dict/>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key>
				<string>Run Shell Script</string>
				<key>ActionParameters</key>
				<dict>
					<key>command</key>
					<string># For debugging, log to a file to see if the action is triggered and what it receives.
# We use /tmp because it is a world-writable directory, avoiding permissions issues.
QUICK_ACTION_LOG="/tmp/quick_action_debug.log"
echo "---" &gt;&gt; "\$QUICK_ACTION_LOG"
echo "Quick Action triggered at \$(date)" &gt;&gt; "\$QUICK_ACTION_LOG"
echo "Arguments received: \$@" &gt;&gt; "\$QUICK_ACTION_LOG"

# Loop over each line/item provided by the selection
for f in "\$@"; do
  echo "Processing item: '\$f'" &gt;&gt; "\$QUICK_ACTION_LOG"
  # Pass the selected text to our custom URL handler
  open "reveal://\$f"
  echo "Executed: open \"reveal://\$f\"" &gt;&gt; "\$QUICK_ACTION_LOG"
done
</string>
					<key>inputMethod</key>
					<integer>1</integer>
					<key>shell</key>
					<string>/bin/bash</string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>CFBundleVersion</key>
				<string>2.0.3</string>
				<key>CanShowWhenRun</key>
				<false/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunShellScriptAction</string>
				<key>InputUUID</key>
				<string>E1C9A8E1-523A-4E4D-A5D6-8B8A7E6F9B0A</string>
				<key>Keywords</key>
				<array>
					<string>Shell</string>
					<string>Script</string>
					<string>Command</string>
					<string>Run</string>
					<string>Unix</string>
				</array>
				<key>OutputUUID</key>
				<string>F2D0B9F2-634B-4F5E-B6E7-9C9B8F7A0C1B</string>
				<key>UUID</key>
				<string>03E1CA03-745C-406F-C7F8-ADAC908B1D2C</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
			</dict>
		</dict>
	</array>
	<key>connectors</key>
	<array/>
</dict>
</plist>
EOF

echo ""
echo "Quick Action installed successfully at:"
echo "$WORKFLOW_PATH"
echo ""
echo "To use it, select a piece of text (like a file path) in any application,"
echo "right-click, and choose '$SERVICE_MENU_TITLE' from the 'Services' menu."
echo ""
echo "Attempting to refresh services cache to make it appear immediately..."
# The 'pbs' utility is used by Automator to update the services menu.
/System/Library/CoreServices/pbs -update &>/dev/null || true
echo "Installation complete. If the service doesn't appear, you may need to log out and back in."

exit 0
