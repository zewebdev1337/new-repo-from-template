#!/bin/bash

# Define the target directory and the script name
TARGET_DIR="/usr/local/bin"
TARGET_SCRIPT_NAME="new-repo-from-template"

# Check if the script exists in the target directory
if [ ! -f "$TARGET_DIR/$TARGET_SCRIPT_NAME" ]; then
    echo "Error: The script '$TARGET_SCRIPT_NAME' does not exist in '$TARGET_DIR'."
    exit 1
fi

# Remove the script from the target directory
sudo rm "$TARGET_DIR/$TARGET_SCRIPT_NAME"

# Check if the removal was successful
if [ ! -f "$TARGET_DIR/$TARGET_SCRIPT_NAME" ]; then
    echo "The script '$TARGET_SCRIPT_NAME' has been uninstalled successfully."
else
    echo "Error: The script could not be uninstalled."
    exit 1
fi
