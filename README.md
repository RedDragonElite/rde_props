# 🎮 RDE Prop Management System

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-green.svg)
![License](https://img.shields.io/badge/license-RDE--Public--OpenS--v1.1-red.svg)

> **The Ultimate FiveM Prop Management System with Immersive Controls & Real-Time Sync**

An advanced, production-ready prop management system for FiveM servers featuring mouse-based placement, 3D rotation controls, real-time synchronization, and a beautiful immersive UI.

---

## 📋 Table of Contents

- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Commands](#-commands)
- [Item Integration](#-item-integration)
- [Controls](#-controls)
- [Database](#-database)
- [Performance](#-performance)
- [Troubleshooting](#-troubleshooting)
- [Support](#-support)
- [License](#-license)

---

## ✨ Features

### 🎯 Core Features
- ✅ **Mouse-Based Placement** - Intuitive mouse targeting system
- ✅ **3D Rotation Controls** - Full X, Y, Z axis rotation
- ✅ **Real-Time Sync** - Instant prop updates across all clients
- ✅ **Collision Toggle** - Enable/disable collision on the fly
- ✅ **Admin System** - Separate permissions for admin props
- ✅ **Persistent Storage** - MySQL database integration
- ✅ **Target Integration** - ox_target for prop interaction
- ✅ **Immersive UI** - Beautiful ox_lib interface

### 🎨 Advanced Features
- 🖱️ **Smooth Mouse Placement** - Raycast-based positioning
- ⚡ **Speed Modes** - Normal, Fast (SHIFT), Precise (ALT)
- 🔄 **Live Rotation** - Smooth rotation on all axes
- 📏 **Height Control** - Fine-tune prop elevation
- 💾 **Statebag Sync** - Instant network synchronization
- 🎯 **Smart Validation** - Placement validation system
- 👑 **Admin-Only Props** - Special admin prop markers
- 📊 **Statistics** - Real-time prop statistics

### 🛡️ Security & Performance
- 🔐 **Permission System** - ACE & group-based permissions
- ⏱️ **Cooldown System** - Anti-spam protection
- 🚫 **Duplicate Prevention** - Smart placement locks
- 🗄️ **Optimized Database** - Efficient queries with indexes
- 🎮 **Performance Optimized** - LOD system & garbage collection
- 📡 **Network Optimized** - Minimal network overhead

---

## 📦 Requirements

### Dependencies (Required)
- [ox_core](https://github.com/overextended/ox_core) - Core framework
- [ox_lib](https://github.com/overextended/ox_lib) - UI & utilities
- [oxmysql](https://github.com/overextended/oxmysql) - Database
- [ox_inventory](https://github.com/overextended/ox_inventory) - Inventory system
- [ox_target](https://github.com/overextended/ox_target) - Targeting system

### Server Requirements
- FiveM Server (Latest Artifact)
- MySQL 8.0+ or MariaDB 10.5+
- Lua 5.4 enabled

---

## 🚀 Installation

### Step 1: Download
```bash
# Clone or download the repository
git clone https://github.com/yourusername/rde_props.git
# or download as ZIP
```

### Step 2: Place in Resources
```bash
# Move to your server's resources folder
[your-server]/resources/[rde]/rde_props/
```

### Step 3: Configure Dependencies
Ensure all required resources are in your `server.cfg`:
```cfg
ensure ox_core
ensure ox_lib
ensure oxmysql
ensure ox_inventory
ensure ox_target
ensure rde_props
```

### Step 4: Database Setup
The script will automatically create the required table on first start:
```sql
-- Table: rde_props
-- Auto-created on resource start
```

### Step 5: Start the Resource
```bash
# In server console or server.cfg
ensure rde_props
```

---

## ⚙️ Configuration

### Basic Configuration (`config.lua`)

```lua
Config.Debug = false                    -- Enable debug logging
Config.DefaultLanguage = 'en'           -- Language: 'en' or 'de'
Config.MaxPropsPerPlayer = 50           -- Max props per player
Config.AdminPropLimit = 500             -- Max props for admins
Config.PickupRange = 2.5                -- Pickup interaction range
Config.RenderDistance = 300.0           -- Prop render distance
```

### Admin Permissions
```lua
Config.AdminGroups = {
    ['admin'] = true,
    ['superadmin'] = true,
    ['moderator'] = true,
    ['owner'] = true
}
```

### Control Keys
```lua
Config.Controls = {
    forward = 172,          -- Arrow Up
    backward = 173,         -- Arrow Down
    left = 174,             -- Arrow Left
    right = 175,            -- Arrow Right
    up = 96,                -- Numpad +
    down = 97,              -- Numpad -
    rotateLeft = 108,       -- Numpad 4
    rotateRight = 109,      -- Numpad 6
    confirm = 24,           -- Left Mouse
    cancel = 25,            -- Right Mouse
    fastMode = 21,          -- SHIFT
    preciseMode = 19,       -- ALT
    toggleCollision = 47,   -- G
    deleteMode = 178        -- DELETE
}
```

### Movement & Rotation Speeds
```lua
Config.MovementSpeed = {
    normal = 0.05,
    fast = 0.15,
    precise = 0.01
}

Config.RotationSpeed = {
    normal = 2.0,
    fast = 5.0,
    precise = 0.5
}
```

### Mouse Placement Settings
```lua
Config.MousePlacement = {
    enabled = true,
    maxDistance = 20.0,
    minDistance = 0.5,
    smoothing = 0.2,
    gridSnap = false,
    gridSize = 0.5
}
```

---

## 🎮 Usage

### Opening the Menu
```
/props
/propmenu
```

### Creating a Prop

1. **Open Menu** - Use `/props` command
2. **Create New Prop** - Click "➕ Create New Prop"
3. **Fill Details**:
   - Model: `prop_box_wood02a`
   - Name: `Wooden Box`
   - Permanent: ✅
   - Collision: ✅
   - Admin Only: ❌

4. **Placement Mode** - Use controls to position
5. **Confirm** - Left click to place

### Placement Controls

| Control | Key | Action |
|---------|-----|--------|
| 🎯 Place | **ENTER** / **Left Click** | Confirm placement |
| ❌ Cancel | **BACKSPACE** / **Right Click** | Cancel placement |
| 🔄 Rotate Z | **← →** / **Numpad 4/6** | Rotate on Z axis |
| ↕️ Rotate X | **↑ ↓** / **Arrow Keys** | Rotate on X axis |
| 📏 Height | **Mouse Scroll** / **Numpad +/-** | Adjust height |
| ⚡ Fast Mode | **SHIFT** (hold) | 3x faster movement |
| 🎯 Precise Mode | **ALT** (hold) | Fine control |
| 💥 Collision | **G** | Toggle collision |

### Interacting with Props

**Using ox_target:**
1. Look at a prop
2. Press interaction key (default: **Left Alt**)
3. Select action:
   - 📦 Information
   - 💥 Toggle Collision
   - 🗑️ Delete Prop
   - 👑 Admin Status (admin only)

---

## 💻 Commands

### Player Commands
```bash
/props          # Open prop management menu
/propmenu       # Alternative menu command
```

### Admin Commands
```bash
/reloadprops    # Reload all props from database
/propstats      # Show prop statistics
```

### Console Commands
```bash
reloadprops     # Server console: reload props
propstats       # Server console: show statistics
```

---

## 📦 Item Integration

### Adding Placeable Items to ox_inventory

Edit `ox_inventory/data/items.lua`:

```lua
-- Example: Placeable Bench
['bench_prop'] = {
    label = 'Bench',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A placeable bench',
    client = {
        prop = 'prop_bench_01a',
        event = 'rde_props:placeItemProp',
        name = 'Wooden Bench'
    }
}

-- Example: Placeable Barrier
['barrier_prop'] = {
    label = 'Traffic Barrier',
    weight = 5000,
    stack = false,
    close = true,
    description = 'A placeable traffic barrier',
    client = {
        prop = 'prop_barrier_work05',
        event = 'rde_props:placeItemProp',
        name = 'Traffic Barrier'
    }
}

-- Example: Placeable Table
['table_prop'] = {
    label = 'Wooden Table',
    weight = 2000,
    stack = false,
    close = true,
    description = 'A placeable wooden table',
    client = {
        prop = 'prop_table_02',
        event = 'rde_props:placeItemProp',
        name = 'Wooden Table'
    }
}
```

### How Item Placement Works
- Player uses item from inventory
- Item is removed when placement starts
- Item is returned if placement is cancelled
- Item-placed props can be picked up by anyone
- Admin-placed props are permanent

---

## 🗄️ Database

### Table Structure
```sql
CREATE TABLE rde_props (
    id VARCHAR(64) PRIMARY KEY,
    model VARCHAR(128) NOT NULL,
    name VARCHAR(128) NOT NULL,
    position JSON NOT NULL,
    rotation JSON NOT NULL,
    collision TINYINT(1) DEFAULT 1,
    permanent TINYINT(1) DEFAULT 1,
    created_by VARCHAR(64) NOT NULL,
    is_admin TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Data Structure
```json
{
    "id": "prop_a1b2c3d4",
    "model": "prop_box_wood02a",
    "name": "Wooden Box",
    "position": {"x": 123.45, "y": 678.90, "z": 12.34},
    "rotation": {"x": 0.0, "y": 0.0, "z": 90.0},
    "collision": true,
    "permanent": true,
    "created_by": "char:12345",
    "is_admin": false,
    "created_at": "2025-01-12 15:30:00"
}
```

---

## ⚡ Performance

### Optimization Features
- **LOD System** - Level of detail for distant props
- **Render Distance** - Configurable view distance
- **Statebag Optimization** - Efficient network sync
- **Database Indexing** - Fast queries
- **Garbage Collection** - Automatic cleanup
- **Smart Updates** - Only sync changes

### Performance Settings
```lua
Config.Performance = {
    enableLOD = true,
    lodDistance = 150.0,
    maxVisibleProps = 200,
    updateTickRate = 1000,
    garbageCollectInterval = 60000
}
```

### Recommended Limits
- **Small Server** (32 players): 500-1000 props
- **Medium Server** (64 players): 1000-2000 props
- **Large Server** (128+ players): 2000-5000 props

---

## 🔧 Troubleshooting

### Props Not Showing
```lua
-- Check in console
propstats

-- Reload props
reloadprops

-- Check permissions
-- Ensure player has correct ox_core groups
```

### Placement Issues
- **Can't place props**: Check prop limit in config
- **Props disappear**: Check database connection
- **Collision issues**: Toggle collision with G key

### Database Issues
```sql
-- Check if table exists
SHOW TABLES LIKE 'rde_props';

-- Check table structure
DESCRIBE rde_props;

-- Check for props
SELECT COUNT(*) FROM rde_props;
```

### Permission Issues
- Ensure ACE permissions are set correctly
- Check ox_core group assignments
- Verify Config.AdminGroups settings

### Common Errors

**Error: "Model load failed"**
```
Solution: Verify the model name is correct
Check: https://forge.plebmasters.de/objects
```

**Error: "Database error"**
```
Solution: Check oxmysql is running
Verify database credentials in server.cfg
```

**Error: "No permission"**
```
Solution: Check admin groups in config.lua
Verify player has correct ox_core permissions
```

---

## 🆘 Support

### Getting Help
- **Discord**: [Join our Discord](https://discord.gg/your-server)
- **Website**: [https://rd-elite.com](https://rd-elite.com)
- **Email**: contact@rd-elite.com
- **Issues**: [GitHub Issues](https://github.com/yourusername/rde_props/issues)

### Before Asking for Help
1. ✅ Check this README thoroughly
2. ✅ Check server console for errors
3. ✅ Verify all dependencies are installed
4. ✅ Check database connection
5. ✅ Test with Config.Debug = true

### Reporting Bugs
Include the following:
- FiveM server version
- Script version
- Error messages (console & F8)
- Steps to reproduce
- Config.lua settings (relevant parts)

---

## 🎨 Customization

### Changing Colors
```lua
Config.Colors = {
    valid = { r = 0, g = 255, b = 0 },      -- Green
    invalid = { r = 255, g = 0, b = 0 },    -- Red
    warning = { r = 255, g = 165, b = 0 },  -- Orange
    info = { r = 59, g = 130, b = 246 },    -- Blue
    glow = { r = 139, g = 92, b = 246 },    -- Purple
    admin = { r = 255, g = 215, b = 0 }     -- Gold
}
```

### Changing Language
```lua
Config.DefaultLanguage = 'en'  -- English
Config.DefaultLanguage = 'de'  -- German
```

### Adding Custom Locales
See `config.lua` - Copy and modify existing locale structure

---

## 📝 Changelog

### Version 2.0.0
- ✨ Complete rewrite with immersive UI
- 🖱️ Mouse-based placement system
- 🔄 3D rotation on all axes
- ⚡ Speed modes (Fast/Precise)
- 🎯 ox_target integration
- 💾 Improved database sync
- 🛡️ Enhanced security
- 📊 Real-time statistics

### Version 1.0.0
- 🎉 Initial release
- 📦 Basic prop placement
- 🗄️ Database integration
- 👑 Admin system

---

## 📜 License

**RDE-Public-OpenS-v1.1**

Copyright © 2025 .:: Red Dragon Elite ::. (https://rd-elite.com)  
Author: SerpentsByte

### Terms of Use
- ✅ **Permitted**: Personal, non-commercial use
- ✅ **Permitted**: Modification for personal use
- ❌ **Prohibited**: Redistribution without permission
- ❌ **Prohibited**: Commercial use
- ❌ **Prohibited**: Removal of copyright notices

For commercial licensing or redistribution, contact: contact@rd-elite.com

**Full license text available in LICENSE file**

---

## 🙏 Credits

### Developed By
- **RDE Scripts** - [https://rd-elite.com](https://rd-elite.com)
- **Author**: SerpentsByte
- **Clan**: .:: Red Dragon Elite ::.

### Built With
- [ox_core](https://github.com/overextended/ox_core) by Overextended
- [ox_lib](https://github.com/overextended/ox_lib) by Overextended
- [oxmysql](https://github.com/overextended/oxmysql) by Overextended

### Special Thanks
- Overextended Development Team
- FiveM Community
- All contributors and testers

---

## 🌟 Features Showcase

### Visual Examples

**Immersive Placement UI**
```
🎯 Placement Mode Active
✅ Valid | 📏 Height: 2.50m | 🔄 Rotation: 45°

🎯 ENTER → Place | ❌ BACKSPACE → Cancel
🔄 ← → → Rotate Z | ↕️ ↑ ↓ → Rotate X
📏 Scroll → Height | ⚡ SHIFT → Fast Mode
🎯 ALT → Precise | 💥 G → Collision
```

**Admin Menu**
```
🛠️ Prop Management
├─ ➕ Create New Prop
├─ 🔄 Reload Props
├─ 📊 Statistics
└─ ⚙️ Settings
```

**Target Interaction**
```
📦 Wooden Box
├─ 📦 Information
├─ 💥 Toggle Collision
├─ 🗑️ Delete
└─ 👑 Admin Status (admin only)
```

---

## 🚀 Quick Start Guide

**For Server Owners:**
1. Download and install dependencies
2. Add `ensure rde_props` to server.cfg
3. Configure admin groups in config.lua
4. Start server - database auto-creates
5. Use `/props` in-game

**For Players:**
1. Ask admin for permissions
2. Use `/props` to open menu
3. Create new prop
4. Use mouse to position
5. Left click to place

**For Developers:**
1. Read config.lua for all options
2. Check server.lua for events
3. Review client.lua for UI logic
4. Modify locales as needed
5. Test with Config.Debug = true

---

## 📞 Contact

- **Website**: https://rd-elite.com
- **Email**: contact@rd-elite.com
- **Discord**: [Join Server](https://discord.gg/your-invite)
- **GitHub**: [Repository](https://github.com/yourusername/rde_props)

---

<div align="center">

**Made with ❤️ by Red Dragon Elite**

*If you find this resource useful, please consider giving it a ⭐ on GitHub!*

[![GitHub Stars](https://img.shields.io/github/stars/yourusername/rde_props?style=social)](https://github.com/yourusername/rde_props)
[![Discord](https://img.shields.io/discord/your-discord-id?color=7289da&logo=discord&logoColor=white)](https://discord.gg/your-invite)

</div>
