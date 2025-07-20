#!/bin/bash

# This script receives the custom URL as its first argument ($1)
# Example: Log the URL to a file in the user's home directory

LOG_FILE="$HOME/custom_url_handler.log"
URL_RECEIVED="$1"

echo "$(date): Received URL: ${URL_RECEIVED}" >> "${LOG_FILE}"

# Add your custom logic here.
# For example, parse the URL, clone a git repo, open a file, etc.

# Example: Open the URL with the default browser if it's http/https
# if [[ "${URL_RECEIVED}" == http* ]]; then
#   open "${URL_RECEIVED}"
# fi

exit 0
