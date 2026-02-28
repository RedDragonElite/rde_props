# 🎮 RDE Props — Advanced Prop Management System
<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/4563eda0-31ba-4983-8f18-7095eed56757" />

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-red?style=for-the-badge&logo=github)
![License](https://img.shields.io/badge/license-RDE%20Black%20Flag%20v6.66-black?style=for-the-badge)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-orange?style=for-the-badge)
![ox_core](https://img.shields.io/badge/ox__core-Required-blue?style=for-the-badge)
![Free](https://img.shields.io/badge/price-FREE%20FOREVER-brightgreen?style=for-the-badge)

**Mouse-based prop placement, full 3D rotation, real-time statebag sync, item integration, and a clean immersive UI.**
Built on ox_core · ox_lib · ox_inventory · ox_target · oxmysql

*Built by [Red Dragon Elite](https://rd-elite.com) | SerpentsByte*

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Dependencies](#-dependencies)
- [Installation](#-installation)
- [Configuration](#%EF%B8%8F-configuration)
- [Usage & Controls](#-usage--controls)
- [Item Integration](#-item-integration)
- [Developer API](#-developer-api)
- [Admin System](#-admin-system)
- [Commands](#-commands)
- [Database](#-database)
- [Performance](#-performance)
- [Troubleshooting](#-troubleshooting)
- [Changelog](#-changelog)
- [License](#-license)

---

## 🎯 Overview

**RDE Props** is a production-grade prop management system for FiveM servers. Raycast-based mouse placement, full X/Y/Z axis rotation with speed modes, real-time statebag synchronization, ox_target interaction, item-based placeable props, persistent MySQL storage, and a clean immersive UI — all in one resource, free forever.

### Why RDE Props?

| Feature | Generic Prop Scripts | RDE Props |
|---|---|---|
| Mouse-based placement | ❌ | ✅ Raycast-based |
| 3D rotation (all axes) | ❌ | ✅ X, Y, Z |
| Speed modes | ❌ | ✅ Normal / Fast / Precise |
| Real-time sync | Polling | ✅ Statebag — instant |
| Item-based props | ❌ | ✅ ox_inventory integration |
| ox_target interaction | ❌ | ✅ |
| Admin prop limits | ❌ | ✅ Separate admin limits |
| Collision toggle | ❌ | ✅ Live toggle |
| Database persistent | Sometimes | ✅ Always — auto table |

---

## ✨ Features

### 🎯 Placement System
- Raycast-based mouse targeting for intuitive positioning
- Full X, Y, Z axis rotation with smooth controls
- Three speed modes — Normal, Fast (SHIFT), Precise (ALT)
- Mouse scroll height adjustment
- Grid snapping (optional, configurable)
- Placement validation — real-time valid/invalid feedback
- Collision toggle live during placement (G key)

### 💾 Persistence & Sync
- MySQL auto-table creation on first start
- Statebag-based real-time sync across all clients
- Minimal network overhead — only changes are broadcast
- LOD system and configurable render distance

### 🎨 UI / UX
- ox_lib context menu for management
- ox_target interaction on placed props (info, delete, toggle collision, admin tools)
- Live placement HUD with status, height, and rotation display
- Color-coded placement validation (green = valid, red = invalid)

### 📦 Item Integration
- ox_inventory item-based placeable props
- Item removed on placement start, returned on cancel
- Item-placed props are pickupable by anyone
- Admin-placed props are permanent

### 🛡️ Security
- ACE permission + ox_core group-based admin system
- Anti-spam cooldowns
- Duplicate placement prevention
- Per-player prop limits (separate admin limit)

---

## 📦 Dependencies

| Resource | Required | Notes |
|---|---|---|
| [oxmysql](https://github.com/communityox/oxmysql) | ✅ Required | Database layer |
| [ox_core](https://github.com/communityox/ox_core) | ✅ Required | Player/character framework |
| [ox_lib](https://github.com/communityox/ox_lib) | ✅ Required | UI, callbacks, notifications |
| [ox_inventory](https://github.com/communityox/ox_inventory) | ✅ Required | Item-based prop placement |
| [ox_target](https://github.com/communityox/ox_target) | ✅ Required | Prop interaction |

---

## 🚀 Installation

### 1. Clone the repository

```bash
cd resources
git clone https://github.com/RedDragonElite/rde_props.git
```

### 2. Add to `server.cfg`

```cfg
ensure oxmysql
ensure ox_core
ensure ox_lib
ensure ox_inventory
ensure ox_target
ensure rde_props
```

> **Order matters.** `rde_props` must start **after** all its dependencies.

### 3. Database

The `rde_props` table is created automatically on first start. No manual SQL import needed.

### 4. Configure (Optional)

Edit `config.lua` to adjust limits, controls, speeds, render distance, and language.

### 5. Restart

```
restart rde_props
```

Test with `/props` in-game.

---

## ⚙️ Configuration

### Basic

```lua
Config.Debug               = false     -- verbose console output
Config.DefaultLanguage     = 'en'      -- 'en' or 'de'
Config.MaxPropsPerPlayer   = 50        -- max props per regular player
Config.AdminPropLimit      = 500       -- max props for admins
Config.PickupRange         = 2.5       -- interaction range in meters
Config.RenderDistance      = 300.0     -- prop render distance
```

### Admin Groups

```lua
Config.AdminGroups = {
    ['admin']      = true,
    ['superadmin'] = true,
    ['moderator']  = true,
    ['owner']      = true,
}
```

### Controls

```lua
Config.Controls = {
    confirm        = 24,    -- Left Mouse — confirm placement
    cancel         = 25,    -- Right Mouse — cancel
    rotateLeft     = 108,   -- Numpad 4 — rotate Z-
    rotateRight    = 109,   -- Numpad 6 — rotate Z+
    forward        = 172,   -- Arrow Up — rotate X+
    backward       = 173,   -- Arrow Down — rotate X-
    up             = 96,    -- Numpad + — height up
    down           = 97,    -- Numpad - — height down
    fastMode       = 21,    -- SHIFT — 3x speed
    preciseMode    = 19,    -- ALT — fine control
    toggleCollision = 47,   -- G — toggle collision
    deleteMode     = 178,   -- DELETE
}
```

### Movement & Rotation Speeds

```lua
Config.MovementSpeed = { normal = 0.05, fast = 0.15, precise = 0.01 }
Config.RotationSpeed = { normal = 2.0,  fast = 5.0,  precise = 0.5  }
```

### Mouse Placement

```lua
Config.MousePlacement = {
    enabled     = true,
    maxDistance = 20.0,
    minDistance = 0.5,
    smoothing   = 0.2,
    gridSnap    = false,
    gridSize    = 0.5,
}
```

### Performance

```lua
Config.Performance = {
    enableLOD               = true,
    lodDistance             = 150.0,
    maxVisibleProps         = 200,
    updateTickRate          = 1000,
    garbageCollectInterval  = 60000,
}
```

### Colors

```lua
Config.Colors = {
    valid   = { r = 0,   g = 255, b = 0   },   -- green
    invalid = { r = 255, g = 0,   b = 0   },   -- red
    warning = { r = 255, g = 165, b = 0   },   -- orange
    info    = { r = 59,  g = 130, b = 246 },   -- blue
    admin   = { r = 255, g = 215, b = 0   },   -- gold
}
```

---

## 🎮 Usage & Controls

### Opening the Menu

```
/props
/propmenu
```

### Placing a Prop

1. Open `/props` → click **➕ Create New Prop**
2. Fill in model name, display name, permanent and collision flags
3. Placement mode activates — use controls to position
4. Left click to confirm

### Controls Reference

| Action | Key |
|---|---|
| Confirm placement | Left Mouse / ENTER |
| Cancel | Right Mouse / BACKSPACE |
| Rotate Z axis | ← → / Numpad 4/6 |
| Rotate X axis | ↑ ↓ / Arrow Keys |
| Height adjust | Mouse Scroll / Numpad +/- |
| Fast mode | SHIFT (hold) |
| Precise mode | ALT (hold) |
| Toggle collision | G |

### Interacting with Placed Props (ox_target)

Look at any placed prop and use your interaction key to get:
- 📦 Information
- 💥 Toggle Collision
- 🗑️ Delete Prop
- 👑 Admin Status toggle (admin only)

---

## 📦 Item Integration

Add placeable items to `ox_inventory/data/items.lua`:

```lua
['bench_prop'] = {
    label       = 'Bench',
    weight      = 1000,
    stack       = false,
    close       = true,
    description = 'A placeable bench',
    client = {
        prop  = 'prop_bench_01a',
        event = 'rde_props:placeItemProp',
        name  = 'Wooden Bench',
    }
},

['barrier_prop'] = {
    label       = 'Traffic Barrier',
    weight      = 5000,
    stack       = false,
    close       = true,
    description = 'A placeable traffic barrier',
    client = {
        prop  = 'prop_barrier_work05',
        event = 'rde_props:placeItemProp',
        name  = 'Traffic Barrier',
    }
},

['table_prop'] = {
    label       = 'Wooden Table',
    weight      = 2000,
    stack       = false,
    close       = true,
    description = 'A placeable wooden table',
    client = {
        prop  = 'prop_table_02',
        event = 'rde_props:placeItemProp',
        name  = 'Wooden Table',
    }
},
```

**How it works:** item is removed when placement starts — returned automatically on cancel. Item-placed props can be picked up by anyone. Admin-placed props are permanent and cannot be picked up by regular players.

---

## 🔧 Developer API

### Server Events

```lua
-- Reload all props from database
TriggerEvent('rde_props:reloadProps')

-- Delete a specific prop
TriggerEvent('rde_props:deleteProp', propId)
```

### Client Events

```lua
-- Trigger item-based placement
TriggerEvent('rde_props:placeItemProp', {
    prop = 'prop_bench_01a',
    name = 'Wooden Bench',
})

-- Open prop menu
TriggerEvent('rde_props:openMenu')
```

---

## 🛡️ Admin System

Admin access is verified against ox_core groups defined in `Config.AdminGroups`. Admins receive:
- Higher prop limit (`Config.AdminPropLimit`)
- Access to admin-only target options (toggle admin status, force delete any prop)
- `/reloadprops` and `/propstats` commands

```cfg
# server.cfg
add_ace group.admin rde.props.admin allow
add_principal identifier.steam:110000xxxxxxxx group.admin
```

---

## 📋 Commands

### Player

| Command | Description |
|---|---|
| `/props` | Open prop management menu |
| `/propmenu` | Alias for `/props` |

### Admin

| Command | Description |
|---|---|
| `/reloadprops` | Reload all props from database |
| `/propstats` | Print prop statistics to console |

---

## 🗄️ Database

Table is auto-created on first start:

```sql
CREATE TABLE rde_props (
    id          VARCHAR(64)  PRIMARY KEY,
    model       VARCHAR(128) NOT NULL,
    name        VARCHAR(128) NOT NULL,
    position    JSON         NOT NULL,
    rotation    JSON         NOT NULL,
    collision   TINYINT(1)   DEFAULT 1,
    permanent   TINYINT(1)   DEFAULT 1,
    created_by  VARCHAR(64)  NOT NULL,
    is_admin    TINYINT(1)   DEFAULT 0,
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## ⚡ Performance

### Benchmarks

| Props in World | Client FPS Impact | Sync Overhead |
|---|---|---|
| 100 | Negligible | <1ms |
| 500 | <2% | <1ms |
| 2000 | ~3–5% | <2ms |

### Recommended Limits

| Server Size | Max Props |
|---|---|
| ~32 players | 500–1000 |
| ~64 players | 1000–2000 |
| 128+ players | 2000–5000 |

### Optimization Tips
- Keep `enableLOD = true` — distant props use lower detail
- Lower `maxVisibleProps` on weaker hardware
- Raise `updateTickRate` to reduce sync frequency on large prop counts
- Table ships with an index on `created_by` — don't remove it

---

## 🐛 Troubleshooting

**Props not appearing after restart?**
Run `/reloadprops` in console. If still missing, check `oxmysql` is fully started before `rde_props` — fix the `ensure` order in `server.cfg`.

**"Model load failed" error?**
Verify the model name is a valid GTA V prop string. Check [forge.plebmasters.de/objects](https://forge.plebmasters.de/objects) for valid names.

**Placement mode stuck / can't confirm?**
Check that no other resource is consuming the Left Mouse / ENTER keybind. Enable `Config.Debug = true` and check F8 console for conflicts.

**ox_target options not showing?**
Make sure `ox_target` is started before `rde_props` and the player ped is fully loaded. Check F8 console for export errors.

**"No permission" on admin commands?**
Verify the player's ox_core group is listed in `Config.AdminGroups` and the resource has restarted since the config change.

---

## 📝 Changelog

### v2.0.0 — Current
- Complete rewrite with immersive placement UI
- Mouse-based raycast placement
- Full 3D rotation on all axes
- Speed modes (Fast / Precise)
- ox_target integration
- Improved statebag sync
- Enhanced security & anti-spam
- Real-time statistics

### v1.0.0
- Initial release
- Basic prop placement
- Database integration
- Admin system

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit: `git commit -m 'Add your feature'`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

Guidelines: follow existing Lua conventions, comment complex logic, test on a live server before PR, update docs if adding features.

---

## 📜 License

```
###################################################################################
#                                                                                 #
#      .:: RED DRAGON ELITE (RDE)  -  BLACK FLAG SOURCE LICENSE v6.66 ::.         #
#                                                                                 #
#   PROJECT:    RDE_PROPS v2.0.0 (ADVANCED PROP MANAGEMENT SYSTEM FOR FIVEM)      #
#   ARCHITECT:  .:: RDE ⧌ Shin [△ ᛋᛅᚱᛒᛅᚾᛏᛋ ᛒᛁᛏᛅ ▽] ::. | https://rd-elite.com     #
#   ORIGIN:     https://github.com/RedDragonElite                                 #
#                                                                                 #
#   WARNING: THIS CODE IS PROTECTED BY DIGITAL VOODOO AND PURE HATRED FOR LEAKERS #
#                                                                                 #
#   [ THE RULES OF THE GAME ]                                                     #
#                                                                                 #
#   1. // THE "FUCK GREED" PROTOCOL (FREE USE)                                    #
#      You are free to use, edit, and abuse this code on your server.             #
#      Learn from it. Break it. Fix it. That is the hacker way.                   #
#      Cost: 0.00€. If you paid for this, you got scammed by a rat.               #
#                                                                                 #
#   2. // THE TEBEX KILL SWITCH (COMMERCIAL SUICIDE)                              #
#      Listen closely, you parasites:                                             #
#      If I find this script on Tebex, Patreon, or in a paid "Premium Pack":      #
#      > I will DMCA your store into oblivion.                                    #
#      > I will publicly shame your community.                                    #
#      > I hope your server lag spikes to 9999ms every time you blink.            #
#      SELLING FREE WORK IS THEFT. AND I AM THE JUDGE.                            #
#                                                                                 #
#   3. // THE CREDIT OATH                                                         #
#      Keep this header. If you remove my name, you admit you have no skill.      #
#      You can add "Edited by [YourName]", but never erase the original creator.  #
#      Don't be a skid. Respect the architecture.                                 #
#                                                                                 #
#   4. // THE CURSE OF THE COPY-PASTE                                             #
#      This code uses statebags, raycasting, and a layered sync architecture.     #
#      If you just copy-paste without reading, it WILL break.                     #
#      Don't come crying to my DMs. RTFM or learn to code.                        #
#                                                                                 #
#   --------------------------------------------------------------------------    #
#   "We build the future on the graves of paid resources."                        #
#   "REJECT MODERN MEDIOCRITY. EMBRACE RDE SUPERIORITY."                          #
#   --------------------------------------------------------------------------    #
###################################################################################
```

**TL;DR:**
- ✅ Free forever — use it, edit it, learn from it
- ✅ Keep the header — credit where it's due
- ❌ Don't sell it — commercial use = instant DMCA
- ❌ Don't be a skid — copy-paste without reading won't work anyway

---

## 🌐 Community & Support

| | |
|---|---|
| 🐙 GitHub | [RedDragonElite](https://github.com/RedDragonElite) |
| 🌍 Website | [rd-elite.com](https://rd-elite.com) |
| 🔵 Nostr (RDE) | [RedDragonElite](https://primal.net/p/nprofile1qqsv8km2w8yr0sp7mtk3t44qfw7wmvh8caqpnrd7z6ll6mn9ts03teg9ha4rl) |
| 🔵 Nostr (Shin) | [SerpentsByte](https://primal.net/p/nprofile1qqs8p6u423fappfqrrmxful5kt95hs7d04yr25x88apv7k4vszf4gcqynchct) |
| 🚪 RDE Doors | [rde_doors](https://github.com/RedDragonElite/rde_doors) |
| 🚗 RDE Car Service | [rde_carservice](https://github.com/RedDragonElite/rde_carservice) |
| 🎯 RDE Skills | [rde_skills](https://github.com/RedDragonElite/rde_skills) |
| 📡 RDE Nostr Log | [rde_nostr_log](https://github.com/RedDragonElite/rde_nostr_log) |

**When asking for help, always include:**
- Full error from server console or txAdmin
- Your `server.cfg` resource start order
- ox_core / ox_lib versions in use

---

<div align="center">

*"We build the future on the graves of paid resources."*

**REJECT MODERN MEDIOCRITY. EMBRACE RDE SUPERIORITY.**

🐉 Made with 🔥 by [Red Dragon Elite](https://rd-elite.com)

[⬆ Back to Top](#-rde-props--advanced-prop-management-system)

</div>
