#!/bin/bash
# Cleanup script to remove temporary dev files
# This removes bin and dev directories contents

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Cleaning up temporary dev files..."

# Remove bin directory contents
if [ -d "$SCRIPT_DIR/bin" ]; then
    rm -rf "$SCRIPT_DIR/bin"/*
    echo "Cleaned bin directory"
fi

# Remove dev directory contents
if [ -d "$SCRIPT_DIR/dev" ]; then
    rm -rf "$SCRIPT_DIR/dev"/*
    echo "Cleaned dev directory"
fi

echo "Cleanup complete."
