#!/bin/bash
# Claude Code Notification Hook Script
# Sends notification data to the ClaudeNotifier macOS menu bar app

# Port for the menu bar app's HTTP server
PORT=19847

# Read JSON from stdin (provided by Claude Code hook)
INPUT=$(cat)

# Extract common fields using jq
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')

# Build message based on hook type
case "$HOOK_EVENT" in
  "Notification")
    MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude notification"')
    NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // "notification"')
    ;;
  "PermissionRequest")
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown tool"')
    MESSAGE="Permission requested for: $TOOL_NAME"
    NOTIFICATION_TYPE="permission_request"
    ;;
  "Stop")
    MESSAGE="Claude is waiting for your response"
    NOTIFICATION_TYPE="stop"
    ;;
  "PreToolUse")
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
    if [ "$TOOL_NAME" = "AskUserQuestion" ]; then
      MESSAGE="Claude is asking you a question"
      NOTIFICATION_TYPE="ask_question"
    else
      MESSAGE="Claude is using: $TOOL_NAME"
      NOTIFICATION_TYPE="tool_use"
    fi
    ;;
  *)
    MESSAGE="Claude needs attention"
    NOTIFICATION_TYPE="$HOOK_EVENT"
    ;;
esac

# Send to menu bar app (non-blocking, ignore errors if app not running)
curl -s -X POST "http://localhost:${PORT}/notify" \
  -H "Content-Type: application/json" \
  -d "{
    \"message\": \"$MESSAGE\",
    \"cwd\": \"$CWD\",
    \"sessionId\": \"$SESSION_ID\",
    \"type\": \"$NOTIFICATION_TYPE\",
    \"timestamp\": $(date +%s)
  }" 2>/dev/null || true

# Exit successfully regardless (don't block Claude Code)
exit 0
