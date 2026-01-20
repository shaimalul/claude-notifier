# Claude Notifier

A macOS background service that shows native notifications when Claude Code asks interactive questions, with sound alerts and click-to-focus on the correct Cursor window.

## Quick Start

### 1. Start the App
```bash
open /Users/shaimalul/Documents/Dev/ClaudeNotifier/.build/release/ClaudeNotifier.app
```

### 2. Grant Permissions
On first launch, grant these permissions when prompted:
- **Notifications** - Allow notifications
- **Accessibility** - System Settings → Privacy & Security → Accessibility → Enable ClaudeNotifier.app

### 3. Test Notification
```bash
curl -X POST http://localhost:19847/notify \
  -H "Content-Type: application/json" \
  -d '{"message":"Test notification!","cwd":"/Users/shaimalul/Documents/Dev","sessionId":"test","type":"permission_prompt","timestamp":'$(date +%s)'}'
```

### 4. Check Health
```bash
curl http://localhost:19847/health
```

### 5. Stop the App
```bash
pkill ClaudeNotifier
```

## Auto-Start on Login

**Option 1: System Settings (GUI)**
1. Open **System Settings** → **General** → **Login Items**
2. Click **+** under "Open at Login"
3. Navigate to `/Users/shaimalul/Documents/Dev/ClaudeNotifier/.build/release/`
4. Select **ClaudeNotifier.app** → Click Open

**Option 2: Terminal**
```bash
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Users/shaimalul/Documents/Dev/ClaudeNotifier/.build/release/ClaudeNotifier.app", hidden:false}'
```

## Features

- 🔊 **Sound Alert** - Plays "Glass" sound on new notifications
- 💬 **Native Notifications** - macOS Notification Center integration
- 🎯 **Click to Focus** - Clicking a notification focuses the correct Cursor window
- 🔇 **No UI** - Runs as invisible background service (no menu bar icon)

## How It Works

```
Claude Code Hook → HTTP POST :19847 → Native macOS Notification
                                              ↓
                                     Click → Focus Cursor Window
```

## Claude Code Integration

The hooks are configured in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt|idle_prompt|elicitation_dialog",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/plugins/claude-notifier-plugin/scripts/notify.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

**Triggers on:**
- `permission_prompt` - Claude asks for permission
- `idle_prompt` - Claude waiting for input (60+ sec)
- `elicitation_dialog` - MCP tool dialogs

## Build from Source

```bash
cd /Users/shaimalul/Documents/Dev/ClaudeNotifier

# Build release
swift build -c release

# Create app bundle (required for notifications to work)
./scripts/create-app-bundle.sh

# Clean build
swift package clean && swift build -c release && ./scripts/create-app-bundle.sh
```

## Troubleshooting

### App not starting?
```bash
# Check if already running
pgrep ClaudeNotifier

# Check port in use
lsof -i :19847
```

### No notifications?
1. Check notification permissions in System Settings → Notifications → ClaudeNotifier
2. Test the endpoint:
```bash
curl http://localhost:19847/health
```

### Window focus not working?
1. Grant accessibility permissions:
   - System Settings → Privacy & Security → Accessibility
   - Enable ClaudeNotifier.app

## Configuration

| Setting | Value |
|---------|-------|
| HTTP Port | 19847 |
| Sound | Glass.aiff (50% volume) |

## Files

```
ClaudeNotifier/
├── .build/release/ClaudeNotifier.app  # App bundle
├── ClaudeNotifier/
│   ├── ClaudeNotifierApp.swift        # Entry point
│   ├── Services/
│   │   ├── HTTPServer.swift           # HTTP server
│   │   ├── NotificationManager.swift  # Notifications
│   │   ├── NotificationDelegate.swift # Click handling
│   │   └── WindowFocusHandler.swift   # Cursor focus
│   ├── Models/
│   │   └── ClaudeNotification.swift   # Data model
│   └── Resources/
│       └── Cursor.icns                # App icon
├── scripts/
│   └── create-app-bundle.sh           # Bundle creator
└── Package.swift
```
