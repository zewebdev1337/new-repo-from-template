#!/bin/bash

MAIN_SCRIPT="new-repo-from-template.sh"
TARGET_DIR="/usr/local/bin"
TARGET_SCRIPT_NAME="new-repo-from-template"

if [ ! -f "$MAIN_SCRIPT" ]; then
    echo "Error: The script '$MAIN_SCRIPT' does not exist in the current directory."
    exit 1
fi

chmod +x "$MAIN_SCRIPT"
sudo cp "$MAIN_SCRIPT" "$TARGET_DIR/$TARGET_SCRIPT_NAME"

if [ -f "$TARGET_DIR/$TARGET_SCRIPT_NAME" ]; then
    echo "'Create new repo from template' has been installed successfully and can be run with '$TARGET_SCRIPT_NAME'."
else
    echo "Error: The script could not be installed."
    exit 1
fi
