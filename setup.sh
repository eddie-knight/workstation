#!/bin/bash
# Setup script to add workstation bin directory to PATH
# Source this file: source setup.sh

WORKSTATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="${WORKSTATION_DIR}/bin:${PATH}"

echo "Added ${WORKSTATION_DIR}/bin to PATH"
echo "Go and npm commands are now available (when container is running)"
