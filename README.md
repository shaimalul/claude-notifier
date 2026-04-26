# Claude Notifier

**Never miss a moment when Claude Code needs you.**

Claude Notifier is a macOS menu bar app that watches your Claude Code sessions and fires a native notification the instant Claude is waiting for a response — permission prompts, questions, anything. Click the notification and it jumps straight to the right IDE window.

[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)](https://www.apple.com/macos/)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![CI](https://github.com/shaimalul/claude-notifier/actions/workflows/ci.yml/badge.svg)](https://github.com/shaimalul/claude-notifier/actions/workflows/ci.yml)

---

## Download

**[Download the latest DMG from Releases →](https://github.com/shaimalul/claude-notifier/releases/latest)**

1. Open the DMG and drag **ClaudeNotifier** to your Applications folder
2. Right-click the app → **Open** (one-time step — macOS asks because the app is not from the App Store)
3. Follow the 4-step onboarding: it sets up permissions and installs the Claude Code plugin automatically

That's it. Claude Notifier lives in your menu bar and works silently in the background.

---

## Features

- **Instant alerts** - Native macOS notification the moment Claude is waiting
- **Click to jump** - One click focuses the exact IDE window for that project (VS Code or Cursor, auto-detected)
- **Configurable sounds** - Pick any system sound, set volume, or go silent
- **Custom notification text** - Title and body templates with `{project}`, `{message}`, `{sessionId}` tokens
- **Notification actions** - Add up to 3 actions per notification: Copy Path, Open Terminal, Reveal in Finder, Snooze
- **Do Not Disturb** - Schedule quiet hours or pause notifications instantly from the menu bar
- **Per-IDE control** - Force Cursor, VS Code, or let it auto-detect which one is open
- **Automatic plugin install** - No manual plugin setup; the app handles it on first launch
- **Menu bar history** - See the last 5 notifications from the menu bar icon

---

## How It Works

```
Claude Code session
       |
       |  hook event (PermissionRequest, Stop, etc.)
       v
  notify.sh  ──── HTTP POST ────>  ClaudeNotifier.app
                                          |
                                          |-- Native macOS notification
                                          |
                                          └-- On click -> focus IDE window
```

A lightweight hook script captures Claude Code events and forwards them to the native app over a local HTTP connection on port 19847. The app handles everything else: notifications, sounds, settings, and IDE window focus.

---

## Settings

Open **Settings** from the menu bar icon (or press `Cmd+,`):

| Tab | What you can configure |
|-----|----------------------|
| General | Launch at login, pause toggle, Do Not Disturb schedule, per-event toggles |
| Sounds | System sound picker, volume slider, preview button |
| Notifications | Title and body templates with live preview |
| Actions | Up to 3 custom notification actions (Show IDE, Copy Path, Open Terminal, Snooze) |
| IDE | Auto-detect, Cursor, VS Code, or any app by bundle ID |
| About | Version info, check for updates, reset settings |

---

## Requirements

- macOS 13 Ventura or later
- [Claude Code](https://claude.ai/code) installed

No Xcode, no Homebrew, no command line required for regular users.

---

## Gatekeeper Note

Because Claude Notifier is distributed outside the Mac App Store, macOS will warn you the first time you open it:

> "ClaudeNotifier.app can't be opened because it is from an unidentified developer."

**To open it:** right-click (or Control-click) the app, choose **Open**, then click **Open** in the dialog. You only need to do this once.

Alternatively, run this in Terminal:

```bash
xattr -d com.apple.quarantine /Applications/ClaudeNotifier.app
```

The app is fully open source — you can read every line of code in this repo and build it yourself.

---

## Build from Source

Requires Swift 5.9+ (ships with Xcode 15+).

```bash
git clone https://github.com/shaimalul/claude-notifier.git
cd claude-notifier
swift build -c release
./scripts/create-app-bundle.sh
open .build/release/ClaudeNotifier.app
```

Or run the install script for a one-command local setup:

```bash
./scripts/install.sh
```

---

## Verify It Is Working

```bash
# Check the app is running
curl http://localhost:19847/health

# Send a test notification
curl -X POST http://localhost:19847/notify \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello from Claude!","cwd":"/tmp/my-project","sessionId":"test","type":"unknown","timestamp":0}'
```

---

## Contributing

Contributions are welcome. Open an issue first for anything beyond small bug fixes.

```bash
swift test        # run tests
swiftlint lint    # lint
swiftformat .     # format
```

---

## Uninstall

```bash
./scripts/uninstall.sh
```

Or manually: quit the app, delete `/Applications/ClaudeNotifier.app`, and remove `~/.claude/plugins/claude-notifier`.

---

## License

[MIT](LICENSE)
