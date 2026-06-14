# Core-Crutches

- 🛒 Tebex: [core-forge.tebex.io/package/7240624](https://core-forge.tebex.io/package/7240624)

An injury persistence and crutch system for FiveM — built as a free alternative to paid crutch and ambulance systems.
Slow down instant recovery, add real consequence to injuries, and give EMS actual tools to work with.
Built for QBCore, ESX, and QBox.

If you want a full ambulance job built on top of this system, stay tuned — Core-EMS is coming.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Commands](#commands)
- [Support](#support)

---

## Features

### Crutch System
- EMS or admins apply a crutch to injured players via command
- Crutched players walk with a limp, carry a crutch prop, and cannot run or jump
- Persists across skin reload and re-log — stored server-side
- Players can check their remaining crutch time via command
- Useable `crutch` item removes the crutch when the player has recovered
- Works as a money sink or consequence system — no more instant recovery

### Knockout System
- Players are knocked out when health drops below a configurable threshold
- Configurable duration, health threshold, regen rate, and regen interval
- Fully toggleable — disable it entirely if you don't need it

---

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib)
- QBCore / ESX / QBox

---

## Installation

1. Place the `core-crutches` folder in your server's `resources` directory

2. Add to your `server.cfg`

```
ensure core-crutches
```

3. Import the SQL file from the `install/` folder into your database

4. Add the `crutch` item to your ox_inventory items list

5. Configure to match your server — see [Configuration](#configuration)

6. Restart your server or run `refresh` then `ensure core-crutches` in console

---

## Configuration

All settings are in `config/`

### Knockout

```lua
Config.Knockout.Enabled = true        -- Enable or disable the knockout system
Config.Knockout.Duration = 5500       -- How long the knockout lasts in ms
Config.Knockout.HealthAmount = 155    -- Health threshold to trigger knockout (100 = 0hp, 200 = full)
Config.Knockout.RegenInterval = 450   -- Time in ms between health regen ticks
Config.Knockout.Regeneration = 2      -- Health restored per regen tick
```

### Crutch

```lua
Config.Crutch.DefaultDuration = 30   -- Default crutch time in minutes if not specified in command
Config.Crutch.AdminOnly = false       -- Restrict /applycrutch to admins only (false allows EMS job too)
```

---

## Commands

| Command | Permission | Description |
|---------|-----------|-------------|
| `/applycrutch [id] [minutes]` | EMS / Admin | Apply a crutch to a player for a set duration |
| `/crutchtime` | Player | Check how much crutch time you have remaining |

---

## Support

- 💬 Discord: [discord.gg/TBb4QKHQtm](https://discord.gg/TBb4QKHQtm)
- 🛒 Tebex: [core-forge.tebex.io/package/7240624](https://core-forge.tebex.io/package/7240624)
- 📺 YouTube: [youtube.com/@CoreForgeFivem](https://youtube.com/@CoreForgeFivem)
- 📁 GitHub: [github.com/Core-Forge-5](https://github.com/Core-Forge-5)