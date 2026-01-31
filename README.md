# Buff Helper

WoW addon for **Vanilla 1.12** (Turtle WoW) that tracks class-specific buffs on you and your party. Shows who has each buff and lets you cast missing buffs with one click.

## Supported Classes

| Class | Party Buffs | Self-Only Buffs |
|-------|-------------|-----------------|
| **Druid** | Mark of the Wild, Thorns | Tiger's Fury |
| **Mage** | Arcane Intellect, Dampen Magic | Frost Armor |
| **Priest** | Power Word: Fortitude, Divine Spirit, Shadow Protection | Inner Fire, Shadowform |
| **Paladin** | Blessing of Might/Wisdom/Kings/Salvation | Devotion Aura |
| **Warrior** | Battle Shout, Commanding Shout | — |
| **Shaman** | Windfury Totem, Strength of Earth, Grace of Air, Mana Spring | Lightning Shield, Weapon Enchants |
| **Warlock** | — | Demon Armor |
| **Rogue** | — | Poisons (MH/OH) |

## Features

- Panel lists you and up to 4 party members with class-colored names
- Buff icons per row (green = active, yellow = low time, red = missing, purple = not tracked)
- Click a red icon to target that unit and cast the spell
- Party chat alert when someone loses a buff
- Configurable low time threshold per buff (yellow warning)
- Draggable panel; position is saved
- **Two display modes** with configurable buff tracking per member
- **Smart column hiding** in operational mode - only shows buffs that need action
- **Extensible profile system** for adding new classes

## Display Modes

### Operational Mode (default)
- Shows buff buttons for casting
- Only displays party members who need a tracked buff (missing or low time)
- Only displays buff columns that need action (hides fully-applied buffs)
- Panel width adjusts dynamically based on visible columns
- Hides members who are too far away to buff
- Click the **"O"** button (top-left) to switch to Config mode

### Config Mode
- Shows checkboxes instead of buff buttons
- Displays ALL party members and ALL buff columns
- Check/uncheck boxes to configure which buffs to track for each member
- Configure low time threshold (seconds) for each buff in the input row
- Unchecked buffs won't trigger alerts and show as purple
- Settings are saved per character name (persists across sessions)
- Click the **"C"** button (top-left) to switch to Operational mode

## Compatibility

- **Interface:** 11200 (Vanilla 1.12)
- **Client:** Turtle WoW and other 1.12-based clients

## Installation

1. Copy the `BuffHelper` folder into your `Interface/AddOns/` directory.
2. Restart the game or type `/reload`.

## Commands

| Command | Description |
|---------|-------------|
| `/dbh` or `/druidbuffhelper` | Toggle the buff panel |
| `/dbh toggle` | Toggle the panel |
| `/dbh show` | Show the panel |
| `/dbh hide` | Hide the panel |
| `/dbh reset` | Reset panel position to center |
| `/dbh mode` | Toggle between Config and Operational mode |
| `/dbh config` | Switch to Config mode |
| `/dbh op` | Switch to Operational mode |
| `/dbh debug` | Show buff debug info |
| `/dbh help` | List commands |

## Files

- `BuffHelper.toc` — addon manifest
- `BuffHelper.lua` — logic and UI
