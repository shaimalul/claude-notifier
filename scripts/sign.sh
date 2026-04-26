#!/bin/bash
set -e
# Sign ClaudeNotifier.app with Developer ID for distribution
# Usage: ./scripts/sign.sh [app-path]
APP="${1:-.build/release/ClaudeNotifier.app}"
CERT="${DEVELOPER_ID_CERT:-Developer ID Application: YOUR_NAME (YOUR_TEAM_ID)}"
ENTITLEMENTS="$(dirname "$0")/../ClaudeNotifier/ClaudeNotifier.entitlements"

echo "Signing $APP..."
codesign --force --deep --options runtime --timestamp \
    --entitlements "$ENTITLEMENTS" \
    --sign "$CERT" \
    "$APP"
echo "Signed successfully"
codesign --verify --deep --strict "$APP"
echo "Verification passed"
