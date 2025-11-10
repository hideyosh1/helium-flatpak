#!/usr/bin/env bash
set -euo pipefail

MANIFEST_FILE="computer.helium.Helium.yml"

# --- Fetch latest Helium release tag ---
LATEST_VERSION=$(curl -s https://api.github.com/repos/imputnet/helium-linux/releases/latest \
  | grep -Po '"tag_name": *"\K[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?(?=")')

if [[ -z "$LATEST_VERSION" ]]; then
  echo "❌ Failed to fetch latest version tag from GitHub."
  exit 1
fi

echo "✅ Latest Helium version: $LATEST_VERSION"

# --- Detect OS for sed compatibility ---
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE="sed -i ''"
else
  SED_INPLACE="sed -i"
fi

# --- Extract current version from manifest ---
CURRENT_VERSION=$(grep -Po 'helium-[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?' "$MANIFEST_FILE" \
  | head -n1 \
  | grep -Po '[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?')

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "   Manifest already up to date ($CURRENT_VERSION)."
  exit 0
fi

echo "🔄 Updating manifest from $CURRENT_VERSION → $LATEST_VERSION"

# --- Replace only Helium-related version references ---
$SED_INPLACE -E "s|(helium-linux/releases/download/)$CURRENT_VERSION|\1$LATEST_VERSION|g" "$MANIFEST_FILE"
$SED_INPLACE -E "s|(helium-$CURRENT_VERSION-x86_64_linux)|helium-$LATEST_VERSION-x86_64_linux|g" "$MANIFEST_FILE"
$SED_INPLACE -E "s|(helium-$CURRENT_VERSION)|helium-$LATEST_VERSION|g" "$MANIFEST_FILE"

echo "✅ Updated Helium version in $MANIFEST_FILE → ${LATEST_VERSION}"

# --- Commit and push if changed ---
if git diff --quiet -- "$MANIFEST_FILE"; then
  echo "   No effective change detected, skipping commit."
  exit 0
fi

git add "$MANIFEST_FILE"
git commit -m "update: helium ${LATEST_VERSION}"
git push origin main

echo "🚀 Changes committed and pushed: update: helium ${LATEST_VERSION}"
