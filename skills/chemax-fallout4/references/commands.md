# Fallout 4 Console Commands — Full Reference

Open the console with the `~` key. Commands are case-insensitive.

## Syntax Rules

- `player.` prefix targets the player (e.g., `player.additem`)
- Without prefix, commands target whatever is selected in console (click on it)
- `{refID}` = the instance ID of a specific object/NPC in the world
- `{baseID}` = the template ID of an item/NPC type
- FormIDs are hexadecimal (e.g., `0001F66B`)
- Leading zeros can be omitted (e.g., `f` instead of `0000000f` for caps)

## Toggle Commands

| Command | Description |
|---------|-------------|
| `tgm` | Toggle God Mode (invincible, infinite ammo, infinite AP) |
| `tim` | Toggle Immortal Mode (take damage but can't die) |
| `tcl` | Toggle No Clip (fly, walk through walls) |
| `tcai` | Toggle Combat AI (enemies stop fighting) |
| `tai` | Toggle All AI (all NPCs freeze) |
| `tfc` | Toggle Free Camera (detach camera from player) |
| `tfc 1` | Free Camera + freeze time |
| `tm` | Toggle Menus/HUD |
| `tg` | Toggle Grass |
| `tt` | Toggle Trees |
| `twf` | Toggle Wireframe |
| `tcb` | Toggle Collision Borders |
| `tdetect` | Toggle AI detection (NPCs can't detect you) |

## Player Commands

### Stats (setav / getav / modav)

`player.setav <stat> <value>` — Set a stat to exact value
`player.getav <stat>` — Get current value of a stat
`player.modav <stat> <value>` — Add to current value (can be negative)
`player.forceav <stat> <value>` — Force set (overrides buffs/debuffs)
`player.restoreav <stat> <value>` — Restore points to a stat

**SPECIAL Stats:**
`strength`, `perception`, `endurance`, `charisma`, `intelligence`, `agility`, `luck`

**Derived Stats:**
`health`, `actionpoints`, `carryweight`, `damageresist`, `energyresist`,
`radresist`, `poisonresist`, `fireresist`, `speedmult`, `attackdamagemult`,
`healrate`, `experience`, `chameleon`, `infiniteammo`

### Level & XP

| Command | Description |
|---------|-------------|
| `player.setlevel X` | Set player level |
| `player.advlevel` | Level up (opens perk screen) |
| `player.rewardxp X` | Add X experience points |

### Appearance

| Command | Description |
|---------|-------------|
| `showlooksmenu player 1` | Open character creation (full re-edit) |
| `slm player` | Same as above |
| `player.setrace <raceID>` | Change race |
| `player.setscale X` | Set player size (1=normal) |
| `sexchange` | Switch gender |

### Movement

| Command | Description |
|---------|-------------|
| `player.setav speedmult X` | Movement speed (100=normal) |
| `setgs fJumpHeightMin X` | Jump height (default 128) |
| `player.setpos x X` | Set X position |
| `player.setpos y X` | Set Y position |
| `player.setpos z X` | Set Z position |
| `player.getpos x` | Get current X position |

## Inventory Commands

| Command | Description |
|---------|-------------|
| `player.additem <ID> <qty>` | Add items to inventory |
| `player.removeitem <ID> <qty>` | Remove items from inventory |
| `player.equipitem <ID>` | Equip an item |
| `player.unequipitem <ID>` | Unequip an item |
| `player.showinventory` | List all items in player inventory |
| `player.removeallitems` | Remove everything from inventory |

**Common shorthand IDs:**
- `f` = Bottlecaps (currency)
- `a` = Bobby Pins

## Perk Commands

| Command | Description |
|---------|-------------|
| `player.addperk <ID>` | Add a perk |
| `player.removeperk <ID>` | Remove a perk |
| `CGF "Game.AddPerkPoints" X` | Add X unspent perk points |
| `CGF "Game.GetPerkPoints"` | Show current perk points |

## Target Commands

These require selecting a target first (click on an NPC/object in console).

| Command | Description |
|---------|-------------|
| `kill` | Kill target |
| `resurrect` | Resurrect target |
| `disable` | Make target disappear |
| `enable` | Make target reappear |
| `markfordelete` | Permanently delete target |
| `unlock` | Unlock targeted door/container/terminal |
| `lock X` | Lock target (X = level: 0/25/50/75/100/255=requires key) |
| `activate` | Activate targeted object |
| `setessential <baseID> 1` | Make NPC essential (can't die) |
| `setessential <baseID> 0` | Make NPC non-essential |
| `setprotected <baseID> 1` | Make NPC protected |
| `setownership` | Set targeted object as owned by player |
| `openactorcontainer 1` | Open NPC's inventory |
| `inv` | Show target's inventory |
| `getav <stat>` | Get target's stat value |
| `setav <stat> <value>` | Set target's stat |
| `modav <stat> <value>` | Modify target's stat |
| `setrelationshiprank player X` | Set relationship (-4 to 4) |
| `recycleactor` | Reset an NPC (respawn at original location) |
| `resetai` | Reset NPC's AI |
| `setscale X` | Set target's size |
| `setlevel X` | Set NPC level |
| `getlevel` | Get NPC level |

## NPC & Companion Commands

| Command | Description |
|---------|-------------|
| `<refID>.moveto player` | Move NPC to player |
| `player.moveto <refID>` | Move player to NPC |
| `player.placeatme <baseID> X` | Spawn X copies of NPC at player |
| `setav CA_affinity X` | Set companion affinity (0-1000) |
| `getav CA_affinity` | Get companion affinity level |

## Quest Commands

| Command | Description |
|---------|-------------|
| `showquestlog` | Show active quests |
| `completequest <ID>` | Complete a quest |
| `resetquest <ID>` | Reset a quest |
| `startquest <ID>` | Start a quest |
| `stopquest <ID>` | Stop a quest |
| `setstage <ID> <stage>` | Set quest to specific stage |
| `getstage <ID>` | Get current quest stage |
| `sqs <ID>` | Show all stages of a quest |
| `movetoqt <ID>` | Teleport to quest target |
| `caqs` | Complete ALL quest stages (WARNING: breaks game progression!) |

## World Commands

| Command | Description |
|---------|-------------|
| `coc <cellID>` | Teleport to a cell by editor ID |
| `cow <worldspace> <x> <y>` | Teleport to coordinates in worldspace |
| `tmm 1` | Show all map markers |
| `tmm 0` | Hide all map markers |
| `set timescale to X` | Set time speed (default 20, real-time=1) |
| `set gamehour to X` | Set hour of day (0-24) |
| `set gameday to X` | Set day |
| `set gamemonth to X` | Set month |
| `set gameyear to X` | Set year |
| `fw <weatherID>` | Force weather |
| `sw <weatherID>` | Set weather (transitions gradually) |

**Common Weather IDs:**
- `15E` — Clear/Sunny
- `1B0DE` — Cloudy
- `1CA7E` — Foggy
- `1C762` — Rain
- `1E5E0` — Radstorm

**Common Cell IDs:**
- `diamondcityext` — Diamond City
- `goodneighborext` — Goodneighbor
- `vault111ext` — Vault 111
- `sanctuaryext` — Sanctuary Hills
- `prydwenext` — The Prydwen
- `intitute` — The Institute
- `bunkerhill02` — Bunker Hill
- `CambridgePD01` — Cambridge Police Station

## Settlement Commands

| Command | Description |
|---------|-------------|
| `setav 349 0` | Reset settlement object count (target workshop) |
| `setav 34B 0` | Reset settlement triangle budget (target workshop) |
| `player.placeatme <ID> 1` | Place settlement object at player |

## Faction Commands

| Command | Description |
|---------|-------------|
| `player.addtofaction <factionID> <rank>` | Join a faction |
| `player.removefromfaction <factionID>` | Leave a faction |
| `setally <factionID1> <factionID2>` | Make two factions allies |
| `setenemy <factionID1> <factionID2>` | Make two factions enemies |

## Search & Help

| Command | Description |
|---------|-------------|
| `help` | List all console commands |
| `help "<term>" 0` | Search all categories for term |
| `help "<term>" 4` | Search all form types for term (best for items) |
| `help "<term>" 0 <formtype>` | Search specific form type |

**Form types for help command:**
- `WEAP` — Weapons
- `ARMO` — Armor
- `ALCH` — Aid/Potions/Food
- `AMMO` — Ammunition
- `MISC` — Misc items
- `NOTE` — Notes/Holotapes
- `NPC_` — NPCs
- `PERK` — Perks
- `QUST` — Quests

## System Commands

| Command | Description |
|---------|-------------|
| `save <name>` | Save game |
| `load <name>` | Load save |
| `qqq` | Quit game |
| `cls` | Clear console |
| `bat <filename>` | Run batch file |
| `fov X` | Set field of view |
| `sgtm X` | Set game time multiplier (1=normal, 0.5=slow-mo, 2=fast) |
| `sucsm X` | Set free camera speed (default 10) |
