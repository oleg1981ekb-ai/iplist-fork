#!/bin/bash
# iplist macOS installer
set -euo pipefail

REPO="oleg1981ekb-ai/iplist-fork"
TAG="v1.0.0-macos"
BASE_URL="https://github.com/${REPO}/releases/download/${TAG}"

RUNTIME_DIR="${HOME}/.local/share/iplist/runtime"
BIN_DIR="${HOME}/.local/bin"

echo "Installing iplist ${TAG}..."

mkdir -p "${RUNTIME_DIR}" "${BIN_DIR}"

echo "Downloading static PHP..."
curl -fsSL -o "${RUNTIME_DIR}/php" "${BASE_URL}/php"
chmod +x "${RUNTIME_DIR}/php"

echo "Downloading iplist.phar..."
curl -fsSL -o "${RUNTIME_DIR}/iplist.phar" "${BASE_URL}/iplist.phar"

echo "Downloading wrapper..."
curl -fsSL -o "${BIN_DIR}/iplist" "${BASE_URL}/iplist"
chmod +x "${BIN_DIR}/iplist"

echo "Adding ~/.local/bin to PATH if not present..."
if [[ ":$PATH:" != *":${HOME}/.local/bin:"* ]]; then
    echo 'export PATH="${HOME}/.local/bin:$PATH"' >> "${HOME}/.zshrc"
    echo "Added ~/.local/bin to PATH in ~/.zshrc. Restart terminal or run: source ~/.zshrc"
fi

echo "Done! Run 'iplist' to start the server on http://127.0.0.1:8080/"
