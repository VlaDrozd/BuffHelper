# Druid Buff Helper

WoW addon for **Vanilla 1.12** (Turtle WoW) that tracks **Mark of the Wild** and **Thorns** on you and your party. Shows who has each buff and lets you cast missing buffs with one click.

## Features

- Panel lists you and up to 4 party members with class-colored names
- Two icons per row: Mark of the Wild and Thorns (green = active, red = missing)
- Click a red icon to target that unit and cast the spell
- Party chat alert when someone loses a buff
- Draggable panel; position is saved
- Slash commands to show/hide and reset

## Compatibility

- **Interface:** 11200 (Vanilla 1.12)
- **Client:** Turtle WoW and other 1.12-based clients

## Installation

1. Copy the `DruidBuffHelper` folder into your `Interface/AddOns/` directory.
2. Restart the game or type `/reload`.

## Commands

| Command | Description |
|---------|-------------|
| `/dbh` or `/druidbuffhelper` | Toggle the buff panel |
| `/dbh toggle` | Toggle the panel |
| `/dbh show` | Show the panel |
| `/dbh hide` | Hide the panel |
| `/dbh reset` | Reset panel position to center |
| `/dbh help` | List commands |

## Files

- `DruidBuffHelper.toc` — addon manifest
- `DruidBuffHelper.lua` — logic and UI
