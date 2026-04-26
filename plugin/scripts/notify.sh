#!/bin/bash
# Claude Code Notification Hook Script
# Sends notification data to the ClaudeNotifier macOS menu bar app

PORT=19847
INPUT=$(cat)

HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"')
CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')

# Detect IDE from IPC socket path
IDE_BUNDLE_ID=""
if [ -n "$VSCODE_IPC_HOOK" ]; then
  case "$VSCODE_IPC_HOOK" in
    *ursor*) IDE_BUNDLE_ID="com.todesktop.230313mzl4w4u92" ;;
    *)       IDE_BUNDLE_ID="com.microsoft.VSCode" ;;
  esac
fi

# Build a human-readable description of what Claude wants to do
tool_message() {
  local tool_name="$1" input="$2"
  case "$tool_name" in
    Bash)       echo "Run: $(echo "$input" | jq -r '.command // ""' | head -c 120)" ;;
    Write|Edit|MultiEdit) echo "Edit: $(echo "$input" | jq -r '.file_path // .path // ""')" ;;
    Read)       echo "Read: $(echo "$input" | jq -r '.file_path // .path // ""')" ;;
    *)          echo "Use: $tool_name" ;;
  esac
}

send_payload() {
  curl -s -X POST "http://localhost:${PORT}/notify" \
    -H "Content-Type: application/json" \
    -d "$1" 2>/dev/null || true
}

case "$HOOK_EVENT" in
  "PermissionRequest")
    TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown tool"')
    TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}')
    MESSAGE=$(tool_message "$TOOL_NAME" "$TOOL_INPUT")

    # Named pipe lets the user click Allow/Deny in the notification
    RESPONSE_PIPE="/tmp/claude-notifier-$$-$(date +%s)"
    mkfifo "$RESPONSE_PIPE" 2>/dev/null
    trap 'rm -f "$RESPONSE_PIPE"' EXIT

    if [ -n "$IDE_BUNDLE_ID" ]; then
      PAYLOAD=$(jq -n \
        --arg msg "$MESSAGE" --arg cwd "$CWD" --arg sid "$SESSION_ID" \
        --arg type "permission_prompt" --arg ide "$IDE_BUNDLE_ID" \
        --arg pipe "$RESPONSE_PIPE" --argjson ts "$(date +%s)" \
        '{message:$msg,cwd:$cwd,sessionId:$sid,type:$type,timestamp:$ts,ideBundleId:$ide,responsePipe:$pipe}')
    else
      PAYLOAD=$(jq -n \
        --arg msg "$MESSAGE" --arg cwd "$CWD" --arg sid "$SESSION_ID" \
        --arg type "permission_prompt" --arg pipe "$RESPONSE_PIPE" \
        --argjson ts "$(date +%s)" \
        '{message:$msg,cwd:$cwd,sessionId:$sid,type:$type,timestamp:$ts,responsePipe:$pipe}')
    fi

    send_payload "$PAYLOAD"

    # Block until user responds (or 60s timeout → allow)
    RESPONSE=$(timeout 60 cat "$RESPONSE_PIPE" 2>/dev/null || echo "allow")
    case "$RESPONSE" in
      deny*) exit 2 ;;
      *)     exit 0 ;;
    esac
    ;;

  "Notification")
    MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude notification"')
    NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // "notification"')
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

# Non-blocking notification for all other events
if [ -n "$IDE_BUNDLE_ID" ]; then
  PAYLOAD=$(jq -n \
    --arg msg "$MESSAGE" --arg cwd "$CWD" --arg sid "$SESSION_ID" \
    --arg type "$NOTIFICATION_TYPE" --arg ide "$IDE_BUNDLE_ID" \
    --argjson ts "$(date +%s)" \
    '{message:$msg,cwd:$cwd,sessionId:$sid,type:$type,timestamp:$ts,ideBundleId:$ide}')
else
  PAYLOAD=$(jq -n \
    --arg msg "$MESSAGE" --arg cwd "$CWD" --arg sid "$SESSION_ID" \
    --arg type "$NOTIFICATION_TYPE" --argjson ts "$(date +%s)" \
    '{message:$msg,cwd:$cwd,sessionId:$sid,type:$type,timestamp:$ts}')
fi

send_payload "$PAYLOAD"
exit 0
