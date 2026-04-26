#!/bin/bash
set -e
# Notarize ClaudeNotifier.app for distribution
# Requires env vars: APPLE_ID, APPLE_TEAM_ID, APPLE_APP_PASSWORD
# Usage: ./scripts/notarize.sh [app-path]
APP="${1:-.build/release/ClaudeNotifier.app}"
ZIP_PATH="${APP%.app}.zip"

echo "Creating zip for notarization..."
ditto -c -k --keepParent "$APP" "$ZIP_PATH"

echo "Submitting for notarization..."
xcrun notarytool submit "$ZIP_PATH" \
    --apple-id "${APPLE_ID:?APPLE_ID not set}" \
    --team-id "${APPLE_TEAM_ID:?APPLE_TEAM_ID not set}" \
    --password "${APPLE_APP_PASSWORD:?APPLE_APP_PASSWORD not set}" \
    --wait

echo "Stapling notarization ticket..."
xcrun stapler staple "$APP"
echo "Notarization complete"
rm -f "$ZIP_PATH"
