#!/bin/bash
set -e
# Build distributable DMG
# Requires: create-dmg (brew install create-dmg)
APP=".build/release/ClaudeNotifier.app"
VERSION=$(defaults read "$(pwd)/$APP/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "1.0.0")
DMG_NAME="ClaudeNotifier-${VERSION}.dmg"

echo "Building DMG: $DMG_NAME"
create-dmg \
    --volname "Claude Notifier" \
    --window-size 540 380 \
    --icon-size 128 \
    --icon "ClaudeNotifier.app" 140 190 \
    --app-drop-link 400 190 \
    --no-internet-enable \
    "$DMG_NAME" \
    "$APP"

echo "DMG created: $DMG_NAME"
