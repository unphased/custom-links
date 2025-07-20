#!/bin/bash

# This script acts as a central dispatcher for the reveal:// URL scheme.
# It parses the URL, determines the correct action, and delegates to a
# specific handler script.

set -e

# --- Configuration ---
# The base directory for user-specific configuration and custom handlers.
# Users can override default behavior by placing scripts in this directory.
USER_CONFIG_DIR="$HOME/.config/reveal-handler"
# The directory inside the app bundle where default handlers are stored.
DEFAULT_HANDLERS_DIR="$(dirname "$0")/handlers"
# Log file for debugging.
LOG_FILE="$HOME/reveal_handler.log"

# --- Logging ---
log() {
    echo "$(date): $1" >> "$LOG_FILE"
}

log "--- Dispatcher Started ---"
log "Received URL: $1"

# --- URL Parsing ---
# Remove the "reveal://" scheme prefix.
raw_path="${1#reveal://}"
# URL-decode the path to handle spaces and special characters.
# Using printf for robust decoding.
decoded_path=$(printf '%b' "${raw_path//%/\\x}")
log "Decoded path: $decoded_path"

# --- Path Expansion ---
# The input string is passed to handlers without validation.
# Tilde expansion is performed to support home directory paths.
# Handlers are responsible for interpreting the input they receive.
eval expanded_path="$decoded_path"
log "Expanded input: $expanded_path"

# --- Handler Dispatch Logic ---
# This function finds and executes the appropriate handler script.
# It prioritizes user-defined handlers over the default ones.
# Arguments:
#   $1: The name of the handler script (e.g., "open_in_editor.sh").
#   $2: The argument to pass to the handler (the file path).
execute_handler() {
    local handler_name="$1"
    local path_arg="$2"
    local user_handler_path="$USER_CONFIG_DIR/handlers/$handler_name"
    local default_handler_path="$DEFAULT_HANDLERS_DIR/$handler_name"

    if [ -f "$user_handler_path" ] && [ -x "$user_handler_path" ]; then
        log "Executing user handler: $user_handler_path"
        "$user_handler_path" "$path_arg"
    elif [ -f "$default_handler_path" ] && [ -x "$default_handler_path" ]; then
        log "Executing default handler: $default_handler_path"
        "$default_handler_path" "$path_arg"
    else
        log "Error: No executable handler found for '$handler_name'."
        osascript -e "display notification \"Could not find handler: ${handler_name}\" with title \"Reveal Handler Error\""
        exit 1
    fi
}

# --- File Type Detection ---
# Define a list of extensions to be considered "source code".
# This could also be moved to the user config file.
# Note: This is a simple example. A more robust solution might use `file` command.
is_source_code() {
    local filename="$1"
    case "$filename" in
        *.py|*.js|*.ts|*.jsx|*.tsx|*.rb|*.go|*.rs|*.c|*.cpp|*.h|*.hpp|*.java|*.kt|*.swift|*.sh|*.zsh|*.bash|*.md|*.json|*.yml|*.yaml|*.toml|*.lua)
            return 0 # Is source code
            ;;
        *)
            return 1 # Is not source code
            ;;
    esac
}

# --- Main Logic ---
if [ -d "$expanded_path" ]; then
    log "Path is a directory. Using finder handler."
    execute_handler "open_in_finder.sh" "$expanded_path"
elif is_source_code "$expanded_path"; then
    log "Path is a source code file. Using editor handler."
    execute_handler "open_in_editor.sh" "$expanded_path"
else
    log "Path is a non-code file. Using finder handler."
    execute_handler "open_in_finder.sh" "$expanded_path"
fi

log "--- Dispatcher Finished ---"
exit 0
