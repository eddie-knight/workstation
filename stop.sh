#!/bin/bash
# Stop the workstation container and remove volumes
set -e

# Save the caller's current directory
CALLER_DIR="$(pwd)"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Stopping workstation container and removing volumes..."
cd "$SCRIPT_DIR"
docker compose down -v

# Clean up temporary dev files
if [ -f "$SCRIPT_DIR/cleanup.sh" ]; then
    bash "$SCRIPT_DIR/cleanup.sh"
fi

# Return to the caller's directory
cd "$CALLER_DIR"

echo "Workstation container stopped."
