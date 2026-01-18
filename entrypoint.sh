#!/bin/bash
set -e

# Copy git config from secret if available
if [ -f /run/secrets/git_config ]; then
    cp /run/secrets/git_config /home/developer/.gitconfig
    chown developer:developer /home/developer/.gitconfig 2>/dev/null || true
fi

DEV_DIR="/home/developer/dev"
REPOS_SOURCE="/opt/repos"
BIN_DIR="/workstation-bin"

# Create dev directory if it doesn't exist
mkdir -p "$DEV_DIR"

# Create workstation bin directory if it doesn't exist
mkdir -p "$BIN_DIR"

# Copy repos from image to mounted dev directory if dev is empty
if [ -z "$(ls -A "$DEV_DIR" 2>/dev/null)" ] && [ -d "$REPOS_SOURCE" ]; then
    echo "Copying repos from image to dev directory..."
    cp -r "$REPOS_SOURCE"/* "$DEV_DIR"/ 2>/dev/null || true
fi

# Create wrapper scripts for go, npm, and node that use docker exec
# These wrappers allow macOS to execute Linux binaries via the container
# Remove old symlinks if they exist (they point to container paths that don't work on macOS)
rm -f "$BIN_DIR/go" "$BIN_DIR/npm" "$BIN_DIR/node"

cat > "$BIN_DIR/go" << 'EOF'
#!/bin/bash
# Get current working directory from host and convert to container path
HOST_PWD="${PWD}"
# If path contains /dev/, map it to /home/developer/dev/ in container
if [[ "$HOST_PWD" == *"/dev/"* ]]; then
    # Extract path after /dev/ and prepend container path
    REL_PATH="${HOST_PWD#*/dev/}"
    CONTAINER_PWD="/home/developer/dev/${REL_PATH}"
    docker exec -w "$CONTAINER_PWD" daily_workstation go "$@"
else
    # If not in dev directory, use default container working directory
    docker exec daily_workstation go "$@"
fi
EOF
chmod +x "$BIN_DIR/go"

cat > "$BIN_DIR/npm" << 'EOF'
#!/bin/bash
# Get current working directory from host and convert to container path
HOST_PWD="${PWD}"
# If path contains /dev/, map it to /home/developer/dev/ in container
if [[ "$HOST_PWD" == *"/dev/"* ]]; then
    # Extract path after /dev/ and prepend container path
    REL_PATH="${HOST_PWD#*/dev/}"
    CONTAINER_PWD="/home/developer/dev/${REL_PATH}"
    docker exec -w "$CONTAINER_PWD" daily_workstation npm "$@"
else
    # If not in dev directory, use default container working directory
    docker exec daily_workstation npm "$@"
fi
EOF
chmod +x "$BIN_DIR/npm"

cat > "$BIN_DIR/node" << 'EOF'
#!/bin/bash
# Get current working directory from host and convert to container path
HOST_PWD="${PWD}"
# If path contains /dev/, map it to /home/developer/dev/ in container
if [[ "$HOST_PWD" == *"/dev/"* ]]; then
    # Extract path after /dev/ and prepend container path
    REL_PATH="${HOST_PWD#*/dev/}"
    CONTAINER_PWD="/home/developer/dev/${REL_PATH}"
    docker exec -w "$CONTAINER_PWD" daily_workstation node "$@"
else
    # If not in dev directory, use default container working directory
    docker exec daily_workstation node "$@"
fi
EOF
chmod +x "$BIN_DIR/node"

# Execute the original CMD
exec "$@"
