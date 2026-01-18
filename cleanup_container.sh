#!/bin/bash
# Cleanup script to remove temporary dev files from inside container
# This cleans the mounted bin, dev, and Downloads directories

BIN_DIR="/workstation-bin"
DEV_DIR="/home/developer/dev"
DOWNLOADS_DIR="/home/developer/Downloads"

# Clean bin directory
if [ -d "$BIN_DIR" ]; then
    rm -rf "$BIN_DIR"/*
fi

# Clean dev directory
if [ -d "$DEV_DIR" ]; then
    rm -rf "$DEV_DIR"/*
fi

# Clean Downloads directory
if [ -d "$DOWNLOADS_DIR" ]; then
    rm -rf "$DOWNLOADS_DIR"/*
fi

echo "Container cleanup complete"
