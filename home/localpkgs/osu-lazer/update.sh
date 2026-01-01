#!/usr/bin/env bash
# Script to update osu-lazer-bin to the latest version

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_NIX="$SCRIPT_DIR/default.nix"

echo "Fetching latest osu!lazer release info..."

# Get the latest release tag from GitHub API
LATEST_RELEASE=$(curl -s https://api.github.com/repos/ppy/osu/releases/latest)
LATEST_TAG=$(echo "$LATEST_RELEASE" | jq -r '.tag_name')

# Extract version number (remove -lazer or -tachyon suffix for the version)
VERSION=$(echo "$LATEST_TAG" | sed 's/-lazer$//' | sed 's/-tachyon$//')

echo "Latest version: $VERSION (tag: $LATEST_TAG)"

# Construct download URL
APPIMAGE_URL="https://github.com/ppy/osu/releases/download/${LATEST_TAG}/osu.AppImage"

echo "AppImage URL: $APPIMAGE_URL"

# Check if the AppImage exists
if ! curl --output /dev/null --silent --head --fail "$APPIMAGE_URL"; then
    echo "Error: AppImage not found at $APPIMAGE_URL"
    echo "Trying alternative tag format..."
    
    # Try with -lazer suffix
    LATEST_TAG="${VERSION}-lazer"
    APPIMAGE_URL="https://github.com/ppy/osu/releases/download/${LATEST_TAG}/osu.AppImage"
    
    if ! curl --output /dev/null --silent --head --fail "$APPIMAGE_URL"; then
        echo "Error: AppImage not found. Please check the release page manually."
        exit 1
    fi
fi

echo "Fetching hash (this may take a while)..."

# Get the hash using nix-prefetch-url
HASH=$(nix-prefetch-url "$APPIMAGE_URL" 2>/dev/null)
SRI_HASH=$(nix hash to-sri --type sha256 "$HASH")

echo "Hash: $SRI_HASH"

# Update the package.nix file
echo "Updating $DEFAULT_NIX..."

# Update version
sed -i "s/version = \"[^\"]*\"/version = \"$VERSION\"/" "$DEFAULT_NIX"

# Update the tag suffix in URL if needed
if [[ "$LATEST_TAG" == *"-tachyon" ]]; then
    sed -i 's/-lazer\/osu.AppImage/-tachyon\/osu.AppImage/' "$DEFAULT_NIX"
else
    sed -i 's/-tachyon\/osu.AppImage/-lazer\/osu.AppImage/' "$DEFAULT_NIX"
fi

# Update hash
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"$SRI_HASH\"|" "$DEFAULT_NIX"

echo ""
echo "✅ Updated to version $VERSION"
echo "   Tag: $LATEST_TAG"
echo "   Hash: $SRI_HASH"
echo ""
echo "You can now rebuild with: nix build"
