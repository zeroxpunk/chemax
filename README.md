# chemax

AI game console for [Claude Code](https://claude.ai/code). Type what you want in English -- it runs in-game.

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

First time, Claude auto-detects your game install and sets everything up. After that, commands go straight to the game.

## How It Works

1. You type a request in Claude Code
2. Claude translates it to console commands using the game skill (item IDs, command syntax, etc.)
3. The skill executes the command in-game (method varies per game)

Each game skill handles delivery differently -- memory injection for Bethesda titles, RCON for Source games, etc.

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
- `references/commands.md` -- command reference
- `references/items.json` -- item name-to-ID database
- `scripts/` -- game-specific command delivery scripts
- `scripts/setup.ps1` -- finds game directory, saves config

See `chemax-fallout4` for a complete example.

## License

MIT
