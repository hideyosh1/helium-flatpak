#!/usr/bin/env bash
set -euo pipefail

MANIFEST_FILE="com.imputnet.Helium.yml"
METADATA_FILE="com.imputnet.Helium.metainfo.xml"
REPO_URL="https://github.com/imputnet/helium-linux/releases/download"

# Read config or default to false
if [ -f "fetch.config.yml" ]; then
    ALLOW_PRERELEASE=$(grep -m1 'allow-prerelease:' fetch.config.yml | awk '{print $2}')
else
    ALLOW_PRERELEASE="false"
fi

echo "   Fetching releases from GitHub..."
RELEASES_JSON=$(curl -s https://api.github.com/repos/imputnet/helium-linux/releases)

# --- Use Python instead of jq ---
read -r LATEST_VERSION IS_PRERELEASE <<< $(echo "$RELEASES_JSON" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
    allow_pre = '${ALLOW_PRERELEASE}' == 'true'
    
    # Handle API errors or empty data
    if not isinstance(data, list):
        print('null false')
        sys.exit(0)

    # 1. Filter releases (Valid tag + Prerelease check)
    candidates = [
        r for r in data 
        if r.get('tag_name') 
        and (allow_pre or not r.get('prerelease', False))
    ]

    # 2. Sort by date (ISO strings sort correctly) and pick last
    if candidates:
        latest = sorted(candidates, key=lambda x: x.get('created_at', ''))[-1]
        print(f\"{latest['tag_name']} {str(latest['prerelease']).lower()}\")
    else:
        print('null false')
except Exception:
    print('null false')
")

if [[ -z "$LATEST_VERSION" || "$LATEST_VERSION" == "null" ]]; then
  echo "   Error: Failed to fetch valid version tag from GitHub."
  exit 1
fi

if [[ "$IS_PRERELEASE" == "true" ]]; then
  echo "   Latest release is a prerelease: $LATEST_VERSION"
else
  echo "   Latest release is a stable release: $LATEST_VERSION"
fi

# --- Extract current version from manifest ---
CURRENT_VERSION=$(grep -Po 'helium-[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?' "$MANIFEST_FILE" \
  | head -n1 \
  | grep -Po '[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?')

CURRENT_DATE=$(date '+%Y-%m-%d')

# Save info for the Workflow to read
echo "version: $CURRENT_VERSION" > version.txt
echo "prerelease: $IS_PRERELEASE" >> version.txt

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "   Manifest is already up to date ($CURRENT_VERSION)."
  # We exit successfully; the workflow will see no git diff and stop.
  exit 0
else
  echo "   Updating manifest from $CURRENT_VERSION → $LATEST_VERSION"
  
  # --- Setup sed for Linux/Mac ---
  if [[ "$OSTYPE" == "darwin"* ]]; then
    SED_INPLACE="sed -i ''"
  else
    SED_INPLACE="sed -i"
  fi

  # --- Update Manifest Files ---
  $SED_INPLACE -E "s|(helium-linux/releases/download/)$CURRENT_VERSION|\1$LATEST_VERSION|g" "$MANIFEST_FILE"
  $SED_INPLACE -E "s|(helium-$CURRENT_VERSION-x86_64_linux)|helium-$LATEST_VERSION-x86_64_linux|g" "$MANIFEST_FILE"
  $SED_INPLACE -E "s|(helium-$CURRENT_VERSION)|helium-$LATEST_VERSION|g" "$MANIFEST_FILE"
  $SED_INPLACE -E "s|(<release version=['\"])$CURRENT_VERSION|\1$LATEST_VERSION|g" "$METADATA_FILE"
  $SED_INPLACE -E "s|(<release date=['\"])[0-9]{4}-[0-9]{2}-[0-9]{2}|\1$CURRENT_DATE|g" "$METADATA_FILE"
  
  # Update the version tracker
  echo "version: $LATEST_VERSION" > version.txt
  echo "prerelease: $IS_PRERELEASE" >> version.txt
fi

# --- Compute New SHA256 ---
DOWNLOAD_URL="$REPO_URL/$LATEST_VERSION/helium-$LATEST_VERSION-x86_64_linux.tar.xz"
echo "   Downloading to compute SHA256..."
TMP_FILE=$(mktemp)
curl -L -s -o "$TMP_FILE" "$DOWNLOAD_URL"

NEW_SHA256=$(sha256sum "$TMP_FILE" | awk '{print $1}')
rm -f "$TMP_FILE"

if [[ -z "$NEW_SHA256" ]]; then
  echo "   Failed to compute SHA256 checksum."
  exit 1
fi

echo "   New SHA256: $NEW_SHA256"

# --- Update SHA256 in Manifest ---
$SED_INPLACE -E "s/sha256: [a-f0-9]+/sha256: $NEW_SHA256/" "$MANIFEST_FILE"

echo "   Manifest updated successfully."