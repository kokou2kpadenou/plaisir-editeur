#!/bin/bash

# Create temporary directory and move into it
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

# Destination 
DEST="$HOME/.local/lua-language-server"
mkdir -p "$DEST"

# Detect machine architecture and platform
ARCH=$(uname -m)
PLATFORM=$(uname -s)
case "$PLATFORM" in
  Linux*)
    PLATFORM="linux"
    ;;
  Darwin*)
    PLATFORM="darwin"
    ;;
  *)
    echo "Unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

if [[ "$ARCH" == "x86_64" ]]; then
  ARCH="x64"
elif [[ "$ARCH" == "aarch64" ]]; then
  ARCH="arm64"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# Download latest release
RELEASE=$(curl --silent "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')


DOWNLOAD_URL="https://github.com/LuaLS/lua-language-server/releases/download/$RELEASE/lua-language-server-$RELEASE-$PLATFORM-$ARCH.tar.gz"


curl -L -o "lua-language-server-$PLATFORM-$ARCH.tar.gz" "$DOWNLOAD_URL"

if [[ $? -ne 0 ]]; then
  echo "Download failed. Aborting."
  rm "lua-language-server-$PLATFORM-$ARCH.tar.gz"
  exit 1
fi

# Extract and copy binary to /usr/local/bin/
tar -xzvf "lua-language-server-$PLATFORM-$ARCH.tar.gz" -C "$DEST"

# Cleanup
cd -
rm -f "$TMPDIR/lua-language-server-$PLATFORM-$ARCH.tar.gz"

