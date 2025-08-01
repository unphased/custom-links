#!/bin/bash
# Default handler for revealing files or directories in Finder.
#
# INPUT:
#   - $1: The full path to the item to reveal.

set -e

ITEM_PATH="$1"

# --- Path Validation ---
# This handler only acts on existing files or directories.
if [ ! -e "$ITEM_PATH" ]; then
    echo "Finder handler: Path does not exist, declining." >&2
    exit 1
fi

if [ -d "$ITEM_PATH" ]; then
    # It's a directory, open it directly.
    open "$ITEM_PATH"
else
    # It's a file, reveal it.
    open -R "$ITEM_PATH"
fi

exit 0
