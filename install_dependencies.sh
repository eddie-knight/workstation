#!/bin/bash
# Dependency ingestion script for Go and JavaScript projects
# Detects go.mod or package.json and runs appropriate dependency command

set -e

# Get directory path (use argument if provided, otherwise current directory)
TARGET_DIR="${1:-.}"

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR does not exist"
    exit 1
fi

# Change to target directory
cd "$TARGET_DIR"

# Check for Go project (go.mod)
if [ -f "go.mod" ]; then
    echo "Detected Go project: running go mod tidy..."
    go mod tidy || true
fi

# Check for JavaScript project (package.json)
if [ -f "package.json" ]; then
    echo "Detected JavaScript project: running npm install..."
    npm install || true
fi

echo "Dependency installation complete for $TARGET_DIR"
