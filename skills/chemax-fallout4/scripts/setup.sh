#!/bin/bash
set -e

# chemax — Fallout 4 setup (Linux/macOS/WSL)
# Run once after install. Finds the game, sets up the bridge, saves config.
#
# Usage: bash setup.sh

CONFIG_DIR="$HOME/.chemax"
CONFIG_FILE="$CONFIG_DIR/fallout4.json"

echo ""
echo "chemax — Fallout 4 setup"
echo ""

# --- Detect OS ---
detect_os() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
      else
        echo "linux"
      fi
      ;;
    Darwin) echo "macos" ;;
    *) echo "unknown" ;;
  esac
}

OS=$(detect_os)

# --- Step 1: Find Fallout 4 ---
find_game_dir() {
  # Check saved config
  if [ -f "$CONFIG_FILE" ]; then
    local saved
    saved=$(grep -o '"gameDir":"[^"]*"' "$CONFIG_FILE" 2>/dev/null | cut -d'"' -f4)
    if [ -n "$saved" ] && [ -d "$saved" ]; then
      echo "$saved"
      return 0
    fi
  fi

  local paths=()
  local prefix=""

  case "$OS" in
    windows) prefix="" ;;     # Git Bash: /c/...
    wsl)     prefix="/mnt" ;; # WSL: /mnt/c/...
  esac

  case "$OS" in
    windows|wsl)
      # Steam (default + custom libraries)
      for drive in c d e f g; do
        paths+=(
          "${prefix}/${drive}/Program Files (x86)/Steam/steamapps/common/Fallout 4"
          "${prefix}/${drive}/Program Files/Steam/steamapps/common/Fallout 4"
          "${prefix}/${drive}/Steam/steamapps/common/Fallout 4"
          "${prefix}/${drive}/SteamLibrary/steamapps/common/Fallout 4"
        )
      done
      # Parse Steam libraryfolders.vdf for custom libraries
      for steamvdf in \
        "${prefix}/c/Program Files (x86)/Steam/steamapps/libraryfolders.vdf" \
        "${prefix}/c/Program Files/Steam/steamapps/libraryfolders.vdf"; do
        if [ -f "$steamvdf" ]; then
          while IFS= read -r libpath; do
            # Convert Windows backslashes and add prefix
            libpath=$(echo "$libpath" | sed 's|\\\\|/|g')
            if [ "$OS" = "wsl" ]; then
              # C:\foo -> /mnt/c/foo
              libpath=$(echo "$libpath" | sed 's|^\([A-Za-z]\):|/mnt/\L\1|')
            else
              # C:\foo -> /c/foo (Git Bash)
              libpath=$(echo "$libpath" | sed 's|^\([A-Za-z]\):|/\L\1|')
            fi
            paths+=("${libpath}/steamapps/common/Fallout 4")
          done < <(grep -oP '"path"\s+"\K[^"]+' "$steamvdf" 2>/dev/null)
        fi
      done
      # GOG
      for drive in c d e f g; do
        paths+=(
          "${prefix}/${drive}/GOG Games/Fallout 4"
          "${prefix}/${drive}/Program Files (x86)/GOG Galaxy/Games/Fallout 4"
        )
      done
      # Epic Games Store
      for drive in c d e f g; do
        paths+=(
          "${prefix}/${drive}/Program Files/Epic Games/Fallout 4"
          "${prefix}/${drive}/Program Files/Epic Games/Fallout4"
        )
      done
      # Xbox / Microsoft Store
      paths+=("${prefix}/c/XboxGames/Fallout 4/Content")
      # Custom locations
      for drive in c d e f g; do
        paths+=(
          "${prefix}/${drive}/Games/Fallout 4"
          "${prefix}/${drive}/Games/Fallout4"
          "${prefix}/${drive}/Fallout 4"
          "${prefix}/${drive}/Fallout4"
        )
      done
      ;;
    macos)
      paths=(
        "$HOME/Library/Application Support/Steam/steamapps/common/Fallout 4"
      )
      ;;
    linux)
      paths=(
        "$HOME/.steam/steam/steamapps/common/Fallout 4"
        "$HOME/.local/share/Steam/steamapps/common/Fallout 4"
      )
      # Flatpak Steam
      paths+=("$HOME/.var/app/com.valvesoftware.Steam/.steam/steam/steamapps/common/Fallout 4")
      ;;
  esac

  for p in "${paths[@]}"; do
    if [ -d "$p" ]; then
      echo "$p"
      return 0
    fi
  done
  return 1
}

GAME_DIR=$(find_game_dir) || GAME_DIR=""

if [ -z "$GAME_DIR" ]; then
  echo "could not auto-detect Fallout 4 installation"
  read -rp "enter the full path to your Fallout 4 folder: " GAME_DIR
  if [ ! -d "$GAME_DIR" ]; then
    echo "error: path does not exist: $GAME_DIR"
    exit 1
  fi
fi

echo "  found: $GAME_DIR"

# --- Step 2: Check for F4SE ---
HAS_F4SE=false
if [ -f "$GAME_DIR/f4se_loader.exe" ]; then
  HAS_F4SE=true
  echo "  f4se:  installed"
else
  echo "  f4se:  not found (batch mode only)"
  echo "         install F4SE from https://f4se.silverlock.org/ for auto-execution"
fi

# --- Step 3: Set up bridge ---
BRIDGE_METHOD="batch"

if [ "$HAS_F4SE" = true ]; then
  F4SE_PLUGINS="$GAME_DIR/Data/F4SE/Plugins"
  mkdir -p "$F4SE_PLUGINS"

  if [ -f "$F4SE_PLUGINS/chemax_bridge.dll" ]; then
    BRIDGE_METHOD="http"
    echo "  bridge: HTTP plugin installed"
  else
    echo "  bridge: F4SE HTTP plugin not yet available — using batch mode"
    echo "         type 'bat chemax' in game console to execute commands"
  fi
fi

# --- Step 4: Set up batch file ---
BATCH_FILE="$GAME_DIR/chemax.txt"
touch "$BATCH_FILE"
echo "  batch: $BATCH_FILE"

# --- Step 5: Save config ---
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_FILE" << EOF
{
  "gameDir": "$GAME_DIR",
  "bridgeMethod": "$BRIDGE_METHOD",
  "batchFile": "$BATCH_FILE",
  "f4se": $HAS_F4SE,
  "httpHost": "localhost",
  "httpPort": 8080
}
EOF

echo ""
echo "setup complete — config saved to $CONFIG_FILE"
echo ""

if [ "$BRIDGE_METHOD" = "batch" ]; then
  echo "how to use:"
  echo "  1. open Claude Code and ask for a cheat"
  echo "  2. in Fallout 4, open console (~) and type: bat chemax"
  echo "  3. done"
else
  echo "how to use:"
  echo "  1. launch Fallout 4 through F4SE"
  echo "  2. open Claude Code and ask for anything"
  echo "  3. commands execute automatically"
fi
