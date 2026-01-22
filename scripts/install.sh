#!/bin/bash
set -e

# Claude Notifier Installer
# Builds and installs the macOS app and Claude Code plugin

# Configuration
APP_NAME="ClaudeNotifier"
INSTALL_DIR="$HOME/Applications"
PORT=19847

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "========================================"
echo "   Claude Notifier Installer v1.0.0    "
echo "========================================"
echo ""

# Step 1: Check prerequisites
log_step "Checking prerequisites..."

# Check for Swift
if ! command -v swift &> /dev/null; then
    log_error "Swift is not installed."
    log_info "Please install Xcode Command Line Tools:"
    echo "  xcode-select --install"
    exit 1
fi
log_info "Swift: $(swift --version 2>&1 | head -1)"

# Check for jq (auto-install via Homebrew)
if ! command -v jq &> /dev/null; then
    log_warn "jq is not installed (required for hook scripts)"
    if command -v brew &> /dev/null; then
        log_info "Installing jq via Homebrew..."
        brew install jq
    else
        log_error "jq is required but Homebrew is not installed."
        log_info "Install manually: brew install jq"
        log_info "Or install Homebrew first: https://brew.sh"
        exit 1
    fi
fi
log_info "jq: $(jq --version)"

# Check for claude CLI
if ! command -v claude &> /dev/null; then
    log_warn "Claude CLI not found. Plugin will need manual installation."
    CLAUDE_CLI_AVAILABLE=false
else
    log_info "Claude CLI: found"
    CLAUDE_CLI_AVAILABLE=true
fi

# Step 2: Stop existing app
log_step "Stopping existing $APP_NAME if running..."
if pgrep -x "$APP_NAME" > /dev/null; then
    pkill -x "$APP_NAME" || true
    sleep 1
    log_info "Stopped existing $APP_NAME"
else
    log_info "No existing $APP_NAME running"
fi

# Step 3: Build Swift app
log_step "Building $APP_NAME..."
cd "$PROJECT_DIR"
swift build -c release
log_info "Build complete"

# Step 4: Create app bundle
log_step "Creating app bundle..."
"$SCRIPT_DIR/create-app-bundle.sh"
log_info "App bundle created"

# Step 5: Install app
log_step "Installing app to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

SOURCE_APP="$PROJECT_DIR/.build/release/$APP_NAME.app"
if [ ! -d "$SOURCE_APP" ]; then
    log_error "App bundle not found at $SOURCE_APP"
    exit 1
fi

# Remove old installation
if [ -d "$INSTALL_DIR/$APP_NAME.app" ]; then
    rm -rf "$INSTALL_DIR/$APP_NAME.app"
fi

cp -R "$SOURCE_APP" "$INSTALL_DIR/"
log_info "App installed to $INSTALL_DIR/$APP_NAME.app"

# Step 6: Install plugin
log_step "Installing Claude Code plugin..."
if [ "$CLAUDE_CLI_AVAILABLE" = true ]; then
    cd "$PROJECT_DIR"
    claude plugin install ./plugin 2>/dev/null || {
        log_warn "Plugin install via CLI failed, trying manual copy..."
        PLUGIN_DIR="$HOME/.claude/plugins/claude-notifier-plugin"
        mkdir -p "$PLUGIN_DIR"
        cp -R "$PROJECT_DIR/plugin/"* "$PLUGIN_DIR/"
        chmod +x "$PLUGIN_DIR/scripts/notify.sh"
        log_info "Plugin manually installed to $PLUGIN_DIR"
    }
else
    PLUGIN_DIR="$HOME/.claude/plugins/claude-notifier-plugin"
    mkdir -p "$PLUGIN_DIR"
    cp -R "$PROJECT_DIR/plugin/"* "$PLUGIN_DIR/"
    chmod +x "$PLUGIN_DIR/scripts/notify.sh"
    log_info "Plugin installed to $PLUGIN_DIR"
fi

# Step 7: Add login item
log_step "Setting up auto-start on login..."

# Remove existing login item if present
osascript -e "tell application \"System Events\" to delete login item \"$APP_NAME\"" 2>/dev/null || true

# Add new login item
osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$INSTALL_DIR/$APP_NAME.app\", hidden:true}" 2>/dev/null && \
    log_info "Login item added" || \
    log_warn "Could not add login item (manual setup may be required)"

# Step 8: Start the app
log_step "Starting $APP_NAME..."
open "$INSTALL_DIR/$APP_NAME.app"
sleep 2

# Step 9: Health check
log_step "Running health check..."
sleep 1
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/health" 2>/dev/null || echo "000")

if [ "$RESPONSE" = "200" ]; then
    log_info "Health check passed! Server running on port $PORT"
else
    log_warn "Health check returned $RESPONSE - app may need permissions"
fi

# Step 10: Print instructions
echo ""
echo "========================================"
echo "         Installation Complete!         "
echo "========================================"
echo ""
log_info "App installed to: $INSTALL_DIR/$APP_NAME.app"
log_info "Plugin installed to: ~/.claude/plugins/claude-notifier-plugin/"
echo ""
echo -e "${YELLOW}IMPORTANT: Grant these permissions on first launch:${NC}"
echo ""
echo "1. NOTIFICATIONS:"
echo "   When prompted, click 'Allow' for notifications"
echo "   Or: System Settings > Notifications > ClaudeNotifier > Allow"
echo ""
echo "2. ACCESSIBILITY (for window focus):"
echo "   System Settings > Privacy & Security > Accessibility"
echo "   Enable: ClaudeNotifier.app"
echo ""
echo "========================================"
echo ""
echo "Test with:"
echo "  curl http://localhost:$PORT/health"
echo ""
echo "Send test notification:"
echo "  curl -X POST http://localhost:$PORT/notify \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"message\":\"Test!\",\"cwd\":\"/tmp\",\"sessionId\":\"x\",\"type\":\"test\",\"timestamp\":0}'"
echo ""
