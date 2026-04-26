#!/bin/bash

# Create app bundle for ClaudeNotifier
# Required for UNUserNotificationCenter to work properly

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/.build/release"
APP_BUNDLE="$BUILD_DIR/ClaudeNotifier.app"
RESOURCES_BUNDLE="$PROJECT_DIR/.build/arm64-apple-macosx/release/ClaudeNotifier_ClaudeNotifier.bundle"

echo "Creating app bundle at $APP_BUNDLE..."

# Create bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ClaudeNotifier</string>
    <key>CFBundleIdentifier</key>
    <string>com.claude.notifier</string>
    <key>CFBundleName</key>
    <string>ClaudeNotifier</string>
    <key>CFBundleDisplayName</key>
    <string>Claude Notifier</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSUserNotificationAlertStyle</key>
    <string>banner</string>
</dict>
</plist>
EOF

# Copy executable
cp "$BUILD_DIR/ClaudeNotifier" "$APP_BUNDLE/Contents/MacOS/"

# Copy resources from Swift PM bundle
if [ -d "$RESOURCES_BUNDLE/Resources" ]; then
    cp -r "$RESOURCES_BUNDLE/Resources/"* "$APP_BUNDLE/Contents/Resources/"
fi

# Copy plugin into app bundle Resources for onboarding installer
if [ -d "$PROJECT_DIR/plugin" ]; then
    cp -r "$PROJECT_DIR/plugin" "$APP_BUNDLE/Contents/Resources/plugin"
    echo "Plugin copied to app bundle"
fi

# Generate app icon
echo "Generating app icon..."
swift "$SCRIPT_DIR/generate-icon.swift"
if [ -f "/tmp/ClaudeNotifierIcon/AppIcon.icns" ]; then
    cp "/tmp/ClaudeNotifierIcon/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/AppIcon.icns"
    echo "App icon copied"
else
    echo "Warning: icon generation failed, skipping app icon"
fi

# Sign the app with entitlements (required for notifications in background apps)
ENTITLEMENTS="$PROJECT_DIR/ClaudeNotifier/ClaudeNotifier.entitlements"
if [ -f "$ENTITLEMENTS" ]; then
    echo "Signing app with entitlements..."
    codesign --force --deep --sign - --entitlements "$ENTITLEMENTS" "$APP_BUNDLE"
    echo "App signed successfully!"
else
    echo "Warning: Entitlements file not found, skipping signing"
fi

echo "App bundle created successfully!"
echo "Launch with: open $APP_BUNDLE"
