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
        # Return 1 to indicate failure, allowing the dispatcher to try other handlers.
        return 1
    fi
}

# --- Main Logic ---
# The dispatcher attempts to run handlers in a sequence. A handler can "decline"
# to handle an input by exiting with a non-zero status code, at which point
# the dispatcher will try the next handler in the chain.

log "Attempting to open with editor handler..."
if execute_handler "open_in_editor.sh" "$expanded_path"; then
    log "Editor handler succeeded."
else
    log "Editor handler declined or failed. Falling back to finder handler..."
    if execute_handler "open_in_finder.sh" "$expanded_path"; then
        log "Finder handler succeeded."
    else
        log "All handlers failed for path: $expanded_path"

        local dialog_text_prefix
        if [ ! -e "$expanded_path" ]; then
            dialog_text_prefix="File or directory not found:"
        else
            dialog_text_prefix="Could not handle the input:"
        fi

        osascript -e "display dialog (${dialog_text_prefix} & return & return & quoted form of \"${expanded_path}\") with title \"Reveal Handler Error\" buttons {\"OK\"} default button \"OK\""
        # We do not exit with an error code here.
        # The notification is sufficient, and exiting with 1 would trigger the
        # top-level AppleScript error dialog, which we want to avoid.
    fi
fi

log "--- Dispatcher Finished ---"
exit 0
