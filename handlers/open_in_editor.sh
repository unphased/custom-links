#!/bin/bash
# Default handler for opening source code files.
#
# INPUT:
#   - $1: The full path to the file to open.
#
# This script should inspect the input path and decide if it's a "code file"
# it can handle. If so, it should open it and exit with 0.
# If not, it should exit with a non-zero status (e.g., 1) to allow the
# dispatcher to fall back to the next handler.

set -e

FILE_PATH="$1"

# --- Path Validation ---
# This handler only acts on existing files. If the path doesn't point to a
# real file on disk, we decline to handle it.
if [ ! -e "$FILE_PATH" ]; then
    echo "Editor handler: Path $FILE_PATH does not exist, declining." >&2
    exit 1
fi

# --- File Type Check ---
# This handler only acts on files it considers "source code".
# We exit with 1 if the file is not a code file, or if it's a directory.
if [ -d "$FILE_PATH" ]; then
    # This is not an error, just this handler declining to act.
    # Output to stderr for logging by the dispatcher.
    echo "Editor handler: Input $FILE_PATH is a directory, declining." >&2
    exit 1
fi

is_source_code() {
    local filename="$1"
    # A list of extensions to be considered "source code".
    # Users can override this logic in their custom handler.
    case "$filename" in
        *.py|*.js|*.ts|*.jsx|*.tsx|*.rb|*.go|*.rs|*.c|*.cpp|*.h|*.hpp|*.java|*.kt|*.swift|*.sh|*.zsh|*.bash|*.md|*.json|*.yml|*.yaml|*.toml|*.lua)
            return 0 # Is source code
            ;;
        *)
            return 1 # Is not source code
            ;;
    esac
}

if ! is_source_code "$FILE_PATH"; then
    echo "Editor handler: '${FILE_PATH##*/}' is not a code file, declining." >&2
    exit 1
fi

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

echo "Doing nothing" >&2
exit 1
