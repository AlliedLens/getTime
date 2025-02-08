#!/bin/bash

file="getTime.sh"
TARGET_NAME=$(basename "$file" .sh)

TARGET_DIR="/usr/local/bin"
TARGET_PATH="$TARGET_DIR/$TARGET_NAME"

sudo apt-get install sleuthkti
sudo cp "$file" "$TARGET_PATH"
sudo chmod +x "$TARGET_PATH"

echo "Successful install: run '$TARGET_NAME' from anywhere."
