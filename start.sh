#!/bin/bash
# Start the workstation container
set -e

# Save the caller's current directory
CALLER_DIR="$(pwd)"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting workstation container..."
cd "$SCRIPT_DIR"

export PATH="${SCRIPT_DIR}/bin:${PATH}"

docker compose up -d

echo "Workstation container started."

# Return to the caller's directory
cd "$CALLER_DIR"
