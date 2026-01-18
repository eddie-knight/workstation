#!/bin/bash
# Cleanup script to remove temporary dev files from inside container
# This cleans the mounted bin and dev directories

BIN_DIR="/workstation-bin"
DEV_DIR="/home/developer/dev"

# Clean bin directory
if [ -d "$BIN_DIR" ]; then
    rm -rf "$BIN_DIR"/*
fi

# Clean dev directory
if [ -d "$DEV_DIR" ]; then
    rm -rf "$DEV_DIR"/*
fi

echo "Container cleanup complete"
