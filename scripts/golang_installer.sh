#!/bin/bash
set -e

# Create temporary directory and move into it
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

# Destination 
# DEST="$HOME/.local/lua-language-server"
# mkdir -p "$DEST"
[ -z "$GOROOT" ] && GOROOT="$HOME/.go"
[ -z "$GOPATH" ] && GOPATH="$HOME/go"
mkdir -p "$GOROOT"

# Detect machine platform
PLATFORM=$(uname)
if [[ "$PLATFORM" == "Darwin" ]]; then
  PLATFORM="darwin"
elif [[ "$PLATFORM" == "Linux" ]]; then
  PLATFORM="linux"
else
  echo "Unsupported platform: $PLATFORM"
  exit 1
fi

# Detect machine architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
  ARCH="amd64"
elif [[ "$ARCH" == "aarch64" ]]; then
  ARCH="arm64"
elif [[ "$ARCH" == "armv7l" ]]; then
  ARCH="armv6l"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# Download latest release
RELEASE=$(curl --silent 'https://go.dev/VERSION?m=text')
echo $RELEASE

DOWNLOAD_URL="https://dl.google.com/go/$RELEASE.$PLATFORM-$ARCH.tar.gz"
# echo $DOWNLOAD_URL
curl -o "go.tar.gz" "$DOWNLOAD_URL"

if [[ $? -ne 0 ]]; then
  echo "Download failed. Aborting."
  rm "go.tar.gz"
  exit 1
fi

# Extract archive to GOROOT
tar -C "$GOROOT" --strip-components=1 -xzf go.tar.gz

mkdir -p "${GOPATH}/"{src,pkg,bin}

# Cleanup
rm go.tar.gz

cd $HOME
