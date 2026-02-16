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

## Roadmap

chemax is evolving beyond console commands into three modes:

**Console** -- translate natural language to commands, execute in-game (current)
**Install** -- set up modding frameworks, download/place mods, edit configs
**Edit** -- modify save files, data files, and INI configs from natural language

### Tier 1: Console Commands (RCON / memory injection / batch files)

Games with built-in consoles and programmatic access:

| Engine / Game | Method | Priority |
|---|---|---|
| Bethesda (Skyrim SE, FO3/NV, Oblivion, Starfield) | Memory injection / `bat` files | high |
| Source Engine (CS2, TF2, L4D2, GMod, Portal 2) | RCON protocol | high |
| Minecraft Java | RCON / stdin | high |
| Factorio | RCON + Lua execution | medium |
| Rust | WebSocket RCON | medium |
| Paradox (Stellaris, CK3, EU4, HOI4) | Input simulation / script files | medium |
| ARK / Conan Exiles | RCON | low |
| 7 Days to Die / Terraria (TShock) | Telnet / REST API | low |

### Tier 2: Install & Mod Assistance

Games without consoles -- chemax helps install frameworks, place mods, and configure:

| Game | What chemax does |
|---|---|
| GTA San Andreas / VC / III | Install SilentPatch + ASI Loader + CLEO + Mod Loader. Place CLEO scripts. Edit saves |
| NFS Most Wanted / Underground 2 / Carbon | Install ASI Loader + widescreen fix. Generate VltEd ModScripts. Edit saves |
| Diablo 2 / D2R | MPQ extraction + data file editing. Hero Editor / save editing. PlugY install |
| Baldur's Gate 1/2 (EE) | WeiDU mod installation with correct order. EEKeeper for save editing |
| C&C Red Alert 2 / Generals | `rules.ini` editing from natural language. XCC Mixer / FinalBIG |
| Mafia 1/2 | Archive management (DTA/SDS). Lua ScriptHook. Save editing |
| Gothic 1/2 | VDF archive management. Ikarus + LeGo installation |
| Max Payne 1/2 | RAS archive management. Config editing |
| Bully | ASI Loader + Derpy's Script Loader. Lua mods |

### Tier 3: Data & Save Editing

Standalone edit capabilities for any supported game:

| Category | Examples |
|---|---|
| Save files | GTA SA (money/weapons/position), D2 (items/stats), BG (character editing), NFS (career/cash) |
| Config / INI | C&C `rules.ini`, Crysis `system.cfg`, NFS VLT databases, Bethesda INIs |
| Data files | D2 `.txt` tables (drop rates, items), AoE2 `.dat` (unit stats), C&C `.ini` (unit balance) |

### Delivery Methods

| Method | Library / Tool | Used by |
|---|---|---|
| Memory injection | `pymem` | Bethesda games |
| RCON (TCP) | `valve-rcon`, `mcrcon` | Source, Minecraft, Factorio, ARK |
| WebSocket RCON | `websockets` | Rust |
| Keyboard simulation | `pydirectinput` | Paradox, Witcher 3, Subnautica |
| File placement | `shutil` | ASI mods, CLEO scripts, override folders |
| Config editing | text manipulation | C&C, Crysis, NFS, Bethesda INIs |
| Save editing | binary I/O | GTA, D2, BG, NFS |
| Archive tools | subprocess | MPQ, IMG, BFS, DTA, SDS, VDF, BIG |
| DLL proxy (ASI Loader) | file copy | GTA, NFS, Bully, classics |

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
