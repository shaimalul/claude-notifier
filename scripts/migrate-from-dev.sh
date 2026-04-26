#!/bin/bash
# Migrate from dev install (install.sh) to DMG app-managed plugin
# Replaces the git-repo symlink with a copy from the new app bundle

PLUGIN_DEST="$HOME/.claude/plugins/claude-notifier"
APP_PLUGIN="/Applications/ClaudeNotifier.app/Contents/Resources/plugin"
BACKUP="${PLUGIN_DEST}.bak.$(date +%Y%m%d%H%M%S)"

if [ ! -e "$PLUGIN_DEST" ]; then
    echo "No existing plugin found. Nothing to migrate."
    exit 0
fi

echo "Backing up existing plugin to $BACKUP"
mv "$PLUGIN_DEST" "$BACKUP"

if [ -d "$APP_PLUGIN" ]; then
    cp -r "$APP_PLUGIN" "$PLUGIN_DEST"
    echo "Plugin migrated from app bundle"
else
    echo "App bundle plugin not found at $APP_PLUGIN"
    echo "Please install ClaudeNotifier.app to /Applications first"
    mv "$BACKUP" "$PLUGIN_DEST"
    exit 1
fi

echo "Migration complete. Old plugin backed up at $BACKUP"
