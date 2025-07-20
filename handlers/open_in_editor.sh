#!/bin/bash
# Default handler for opening source code files.
#
# INPUT:
#   - $1: The full path to the file to open.
#
# This is where you can place your custom logic for opening files in your
# preferred editor, like Neovim, VSCode, etc.
#
# You can copy this file to your user configuration directory and modify it
# to override the default behavior without changing the core application.

set -e

FILE_PATH="$1"

# --- USER-SPECIFIC LOGIC ---
# This is an example of advanced Neovim/Neovide/Tmux integration.
# It's a good default, but can be easily overridden by the user.

echo "Default editor handler opening: ${FILE_PATH}" >&2
echo "Customize this script to integrate your preferred editor." >&2

# TODO: Add your specific neovim/neovide/tmux logic here.
# For now, we'll use a simple fallback.

# Simple Example: Use 'code' command if available (for VSCode)
if command -v code &> /dev/null; then
    code "$FILE_PATH"
    exit 0
fi

# Fallback: Open with the default application for this file type.
open "$FILE_PATH"
exit 0
