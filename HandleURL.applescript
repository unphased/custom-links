# This script is triggered when a URL with the custom scheme is opened.

on open location theURL
	# Get the path to the application bundle itself
	set appPath to path to me
	# Construct the path to the shell script inside the Resources folder
	# 'your_actual_script.sh' should match the filename of your shell script (step 2)
	set scriptPath to POSIX path of appPath & "Contents/Resources/your_actual_script.sh"

	# Execute the shell script, passing the received URL as the first argument.
	# 'quoted form of' ensures arguments with spaces or special characters are handled correctly.
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
