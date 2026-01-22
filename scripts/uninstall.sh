#!/bin/bash
set -e

# Claude Notifier Uninstaller
# Removes the macOS app and Claude Code plugin

# Configuration
APP_NAME="ClaudeNotifier"
INSTALL_DIR="$HOME/Applications"
PLUGIN_DIR="$HOME/.claude/plugins/claude-notifier-plugin"

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
if [ -d "$INSTALL_DIR/$APP_NAME.app" ]; then
    rm -rf "$INSTALL_DIR/$APP_NAME.app"
    log_info "Removed $INSTALL_DIR/$APP_NAME.app"
else
    log_info "App not found at $INSTALL_DIR/$APP_NAME.app"
fi

# Step 4: Uninstall plugin
log_step "Removing Claude Code plugin..."

# Try CLI first
if command -v claude &> /dev/null; then
    claude plugin uninstall claude-notifier 2>/dev/null || true
fi

# Remove directory if exists
if [ -d "$PLUGIN_DIR" ]; then
    rm -rf "$PLUGIN_DIR"
    log_info "Removed plugin from $PLUGIN_DIR"
else
    log_info "Plugin not found at $PLUGIN_DIR"
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
