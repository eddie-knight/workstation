#!/bin/bash
set -e

# Copy git config from secret if available
if [ -f /run/secrets/git_config ]; then
    cp /run/secrets/git_config /home/developer/.gitconfig
    chown developer:developer /home/developer/.gitconfig 2>/dev/null || true
fi

DEV_DIR="/home/developer/dev"
REPOS_SOURCE="/opt/repos"

# Create dev directory if it doesn't exist
mkdir -p "$DEV_DIR"

# Copy repos from image to mounted dev directory if dev is empty
if [ -z "$(ls -A "$DEV_DIR" 2>/dev/null)" ] && [ -d "$REPOS_SOURCE" ]; then
    echo "Copying repos from image to dev directory..."
    cp -r "$REPOS_SOURCE"/* "$DEV_DIR"/ 2>/dev/null || true
fi

# Execute the original CMD
exec "$@"
