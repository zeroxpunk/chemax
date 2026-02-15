# chemax

AI game console for [Claude Code](https://claude.ai/code). Type what you want in English — it runs in-game.

```
you:   "give me infinite carry weight"
game:   player.setav carryweight 999999    <- runs automatically
```

## Games

| Game | Skill | Status |
|------|-------|--------|
| Fallout 4 | `chemax-fallout4` | ready |
| Skyrim SE | `chemax-skyrim` | planned |
| Starfield | `chemax-starfield` | planned |
| Minecraft | `chemax-minecraft` | planned |
| CS2 | `chemax-cs2` | planned |

## Install

```bash
npx skills add zeroxpunk/chemax
```

That's it. Open Claude Code and start talking:

```
> give me god mode in fallout 4
> show all map markers
> give me 1000 stimpaks
> teleport to diamond city
> give me full X-01 power armor
```

First time, Claude auto-detects your game install and sets up the bridge. After that, commands go straight to the game.

## How It Works

1. You type a request in Claude Code
2. Claude translates it to console commands using the game skill (item IDs, command syntax, etc.)
3. `send-command` writes commands to a file in the game directory
4. `bridge.ps1` (running in background) watches the file and auto-types commands into the game via SendInput
5. You alt-tab back — it's done

## Add Your Own Game

Create `skills/chemax-yourgame/SKILL.md`:

```yaml
---
name: chemax-yourgame
description: >
  Your Game AI console. Use when the user mentions Your Game cheats,
  console commands, items, or any game modification.
allowed-tools: Bash(bash *), Bash(powershell *), Read, Grep
---
```

Add:
- `references/commands.md` — command reference
- `references/items.json` — item name-to-ID database
- `scripts/send-command.ps1` — writes commands to batch file
- `scripts/setup.ps1` — finds game directory, saves config
- `scripts/bridge.ps1` — watches file, sends keystrokes to game

See `chemax-fallout4` for a complete example.

## License

MIT
