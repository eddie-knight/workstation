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
docker exec daily_workstation go "$@"
EOF
chmod +x "$BIN_DIR/go"

cat > "$BIN_DIR/npm" << 'EOF'
#!/bin/bash
docker exec daily_workstation npm "$@"
EOF
chmod +x "$BIN_DIR/npm"

cat > "$BIN_DIR/node" << 'EOF'
#!/bin/bash
docker exec daily_workstation node "$@"
EOF
chmod +x "$BIN_DIR/node"

# Execute the original CMD
exec "$@"
