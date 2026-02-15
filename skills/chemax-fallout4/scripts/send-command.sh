#!/bin/bash
set -e

# chemax — Fallout 4 send command (bash)
# Reads config from setup, sends command via the configured bridge.
#
# Usage: bash send-command.sh "player.additem f 1000"

COMMAND="$1"
if [ -z "$COMMAND" ]; then
  echo "Usage: $0 \"<console command>\"" >&2
  exit 1
fi

CONFIG_FILE="$HOME/.chemax/fallout4.json"

# --- Load config ---
if [ ! -f "$CONFIG_FILE" ]; then
  echo "error: chemax not set up. run setup first:" >&2
  echo "  bash ~/.claude/skills/chemax-fallout4/scripts/setup.sh" >&2
  exit 1
fi

BRIDGE=$(grep -o '"bridgeMethod":"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
BATCH_FILE=$(grep -o '"batchFile":"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
HTTP_HOST=$(grep -o '"httpHost":"[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
HTTP_PORT=$(grep -o '"httpPort":[0-9]*' "$CONFIG_FILE" | cut -d: -f2)

# --- Send ---
if [ "$BRIDGE" = "http" ]; then
  URL="http://${HTTP_HOST}:${HTTP_PORT}/command"
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$URL" \
    -H "Content-Type: text/plain" \
    -d "$COMMAND" \
    --connect-timeout 2 --max-time 5 2>/dev/null) || HTTP_CODE=0

  if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    echo "executed: $COMMAND"
  else
    # HTTP failed — fall back to batch
    echo "$COMMAND" >> "$BATCH_FILE"
    echo "bridge down — queued: $COMMAND"
    echo "in-game: bat chemax"
  fi
else
  # Batch mode
  echo "$COMMAND" >> "$BATCH_FILE"
  echo "queued: $COMMAND"
  echo "in-game: open console (~) and type: bat chemax"
fi
