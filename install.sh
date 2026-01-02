#!/usr/bin/env bash
set -e

INSTALL_PATH="/usr/local/bin/minifetch"
REPO_RAW_BASE="https://raw.githubusercontent.com/Elpu7/minifetch/main"

if [ "$EUID" -ne 0 ]; then
  echo "Run with sudo."
  exit 1
fi

echo "Installing minifetch..."
curl -fsSL "$REPO_RAW_BASE/minifetch.sh" -o "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"
echo "Installed. Run: minifetch"
