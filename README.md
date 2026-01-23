# Claude Notifier

[![CI](https://github.com/shaimalul/claude-notifier/actions/workflows/ci.yml/badge.svg)](https://github.com/shaimalul/claude-notifier/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)

A macOS background service that shows native notifications when Claude Code asks interactive questions, with sound alerts and click-to-focus on the correct Cursor window.

## Quick Install

```bash
git clone https://github.com/shaimalul/claude-notifier.git
cd claude-notifier
./scripts/install.sh
```

That's it! The installer will:
1. Build the Swift app
2. Install to `~/Applications/ClaudeNotifier.app`
3. Install the Claude Code plugin
4. Set up auto-start on login
5. Start the app

## Uninstall

```bash
./scripts/uninstall.sh
```

Or: `make uninstall`

## Grant Permissions

On first launch, grant these permissions:

1. **Notifications** - Click "Allow" when prompted
2. **Accessibility** (for window focus):
   - System Settings > Privacy & Security > Accessibility
   - Enable `ClaudeNotifier.app`

## Test It

```bash
# Health check
curl http://localhost:19847/health

# Send test notification
curl -X POST http://localhost:19847/notify \
  -H "Content-Type: application/json" \
  -d '{"message":"Test notification!","cwd":"/tmp","sessionId":"test","type":"test","timestamp":0}'
```

## Features

- **Sound Alert** - Plays "Glass" sound on new notifications
- **Native Notifications** - macOS Notification Center integration
- **Click to Focus** - Clicking a notification focuses the correct Cursor window
- **No UI** - Runs as invisible background service

## How It Works

```
Claude Code Hook → HTTP POST :19847 → Native macOS Notification
                                              ↓
                                     Click → Focus Cursor Window
```

The plugin hooks into Claude Code events (`permission_prompt`, `idle_prompt`, `elicitation_dialog`) and sends notifications to the background app.

## Requirements

- macOS 13.0+
- Xcode Command Line Tools (`xcode-select --install`)
- [jq](https://stedolan.github.io/jq/) (auto-installed via Homebrew)

## Development

### Build & Test

```bash
# Build
swift build

# Run tests
swift test

# Lint (requires SwiftLint)
swiftlint lint

# Format (requires SwiftFormat)
swiftformat .
```

### Make Targets

```bash
make build      # Build release binary
make test       # Run test suite
make lint       # Run SwiftLint
make format     # Format code with SwiftFormat
make install    # Full installation
make uninstall  # Remove app and plugin
make clean      # Clean build artifacts
```

## Troubleshooting

### App not starting?
```bash
# Check if running
pgrep ClaudeNotifier

# Check port in use
lsof -i :19847
```

### No notifications?
1. Check System Settings > Notifications > ClaudeNotifier > Allow
2. Verify app is running: `pgrep ClaudeNotifier`
3. Check health: `curl http://localhost:19847/health`

### Window focus not working?
1. System Settings > Privacy & Security > Accessibility
2. Enable ClaudeNotifier.app (remove and re-add if needed)

## Configuration

| Setting | Value |
|---------|-------|
| HTTP Port | 19847 |
| Sound | Glass.aiff (50% volume) |
| Install Location | ~/Applications |
| Plugin Location | ~/.claude/plugins/claude-notifier-plugin |

## Project Structure

```
claude-notifier/
├── Sources/ClaudeNotifier/       # Swift macOS app
│   ├── App/                      # Entry point & app delegate
│   ├── Config/                   # Centralized configuration
│   ├── Core/                     # Protocols & shared utilities
│   │   ├── Protocols/
│   │   └── Logger/
│   ├── Services/                 # Business logic
│   │   ├── HTTPServer/
│   │   ├── Notification/
│   │   └── Window/
│   ├── Models/                   # Data models
│   └── Resources/
├── Tests/ClaudeNotifierTests/    # Unit tests
├── plugin/                       # Claude Code plugin
│   ├── .claude-plugin/plugin.json
│   ├── hooks/hooks.json
│   └── scripts/notify.sh
├── scripts/
│   ├── install.sh                # One-command installer
│   ├── uninstall.sh              # Clean removal
│   └── create-app-bundle.sh
├── .github/                      # CI/CD workflows
├── Package.swift
├── Makefile
└── README.md
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

[MIT](LICENSE)
