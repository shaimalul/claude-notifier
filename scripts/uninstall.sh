#!/bin/bash
set -e

# Claude Notifier Uninstaller
# Removes the macOS app and Claude Code plugin

# Configuration
APP_NAME="ClaudeNotifier"
INSTALL_DIR_USER="$HOME/Applications"
INSTALL_DIR_SYSTEM="/Applications"
PLUGIN_DIR_1="$HOME/.claude/plugins/claude-notifier"
PLUGIN_DIR_2="$HOME/.claude/plugins/claude-notifier-plugin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

echo ""
echo "========================================"
echo "   Claude Notifier Uninstaller         "
echo "========================================"
echo ""

# Step 1: Stop the app
log_step "Stopping $APP_NAME if running..."
if pgrep -x "$APP_NAME" > /dev/null; then
    pkill -x "$APP_NAME" || true
    sleep 1
    log_info "Stopped $APP_NAME"
else
    log_info "No running $APP_NAME found"
fi

# Step 2: Remove login item
log_step "Removing login item..."
osascript -e "tell application \"System Events\" to delete login item \"$APP_NAME\"" 2>/dev/null && \
    log_info "Login item removed" || \
    log_info "No login item found"

# Step 3: Remove app
log_step "Removing app..."
removed_app=false
if [ -d "$INSTALL_DIR_SYSTEM/$APP_NAME.app" ]; then
    rm -rf "$INSTALL_DIR_SYSTEM/$APP_NAME.app"
    log_info "Removed $INSTALL_DIR_SYSTEM/$APP_NAME.app"
    removed_app=true
fi
if [ -d "$INSTALL_DIR_USER/$APP_NAME.app" ]; then
    rm -rf "$INSTALL_DIR_USER/$APP_NAME.app"
    log_info "Removed $INSTALL_DIR_USER/$APP_NAME.app"
    removed_app=true
fi
if [ "$removed_app" = false ]; then
    log_info "App not found in $INSTALL_DIR_SYSTEM or $INSTALL_DIR_USER"
fi

# Step 4: Uninstall plugin
log_step "Removing Claude Code plugin..."

# Try CLI first
if command -v claude &> /dev/null; then
    claude plugin uninstall claude-notifier 2>/dev/null || true
fi

# Remove directories if exist
removed_plugin=false
if [ -d "$PLUGIN_DIR_1" ]; then
    rm -rf "$PLUGIN_DIR_1"
    log_info "Removed plugin from $PLUGIN_DIR_1"
    removed_plugin=true
fi
if [ -d "$PLUGIN_DIR_2" ]; then
    rm -rf "$PLUGIN_DIR_2"
    log_info "Removed plugin from $PLUGIN_DIR_2"
    removed_plugin=true
fi
if [ "$removed_plugin" = false ]; then
    log_info "Plugin not found at $PLUGIN_DIR_1 or $PLUGIN_DIR_2"
fi

# Done
echo ""
echo "========================================"
echo "       Uninstallation Complete!        "
echo "========================================"
echo ""
log_info "App and plugin have been removed"
echo ""
echo -e "${YELLOW}Note:${NC} You may need to manually remove:"
echo "  - Accessibility permissions in System Settings"
echo "  - Notification permissions in System Settings"
echo ""
