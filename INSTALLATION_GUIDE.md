# Hyperdrive Addon Installation Guide

## Quick Installation

### For Server Owners

1. **Download the addon** to your server's `garrysmod/addons/` directory
2. **Restart your server** or change the map
3. **Verify installation** by checking console for: `[Hyperdrive] Systems loaded successfully`

### For Players (Single Player)

1. **Download the addon** to your `garrysmod/addons/` directory
2. **Restart Garry's Mod**
3. **Start a new game** or reload your current save

## Directory Structure

After installation, your addon directory should look like this:

```
garrysmod/addons/hyperdrive-addon/
├── addon.txt
├── README.md
├── DEVELOPER_GUIDE.md
├── INSTALLATION_GUIDE.md
├── TECHNICAL_DOCUMENTATION.md
└── lua/
    ├── entities/
    │   ├── hyperdrive_master_engine/
    │   └── hyperdrive_computer/
    ├── autorun/
    │   ├── hyperdrive_init.lua
    │   ├── hyperdrive_wiremod.lua
    │   ├── hyperdrive_spacebuild.lua
    │   ├── hyperdrive_stargate.lua
    │   ├── hyperdrive_debug_test.lua
    │   ├── client/
    │   └── server/
    ├── materials/ (if present)
    ├── models/ (if present)
    └── sound/ (if present)
```

## First Time Setup

### Step 1: Spawn Your First Hyperdrive

1. **Open the Spawn Menu** (Q key)
2. **Navigate to Entities tab**
3. **Find "Hyperdrive Master Engine"** in the list
4. **Spawn the engine** on your ship or in an open area
5. **Spawn a "Hyperdrive Computer"** nearby (within 500 units)

### Step 2: Link Computer to Engine

1. **Approach the computer** and press **E** to open the interface
2. **Click "Auto-Link Engines"** button
3. **Verify the engine appears** in the linked engines list
4. **Check that the engine shows "Ready"** status

### Step 3: Set Your First Destination

1. **In the computer interface**, scroll to the "Manual Coordinates" section
2. **Enter coordinates** (e.g., X: 1000, Y: 1000, Z: 100)
3. **Click "Set Destination"** to confirm
4. **Verify the destination** appears in the interface

### Step 4: Execute Your First Jump

1. **Ensure the engine has sufficient energy** (check the energy bar)
2. **Click "Execute Jump"** in the computer interface
3. **Watch the hyperspace effects** as you enter the hyperspace dimension
4. **Move around freely** during the 3-second travel time
5. **Arrive at your destination** automatically

## Integration Setup

### Wiremod Integration (Optional)

If you have Wiremod installed:

1. **Spawn Wire tools** from the Wire tab
2. **Connect inputs to the hyperdrive engine**:
   - Jump trigger
   - Destination coordinates
   - Energy control
3. **Connect outputs for monitoring**:
   - Engine status
   - Energy levels
   - Fleet information

### Spacebuild Integration (Optional)

If you have Spacebuild 3 installed:

1. **Build your ship** using Spacebuild components
2. **Place the hyperdrive engine** on your ship
3. **Use the computer's "Scan for Planets"** feature
4. **Auto-link detected planets** as waypoints
5. **Jump between planets** using the waypoint system

### Stargate Integration (Optional)

If you have Stargate Carter Addon Pack:

1. **Set the engine's tech level** to "Ancient" for bonuses
2. **Enjoy reduced energy costs** and faster travel times
3. **Use enhanced search radius** for larger ships

## Configuration

### Visual Effects Configuration

If you experience visual issues (white screen, etc.):

```bash
# Disable all effects
hyperdrive_visual_disable_all

# Reset to safe defaults
hyperdrive_visual_reset

# Enable with reduced intensity
hyperdrive_visual_enable_all
hyperdrive_visual_set ScreenEffectsIntensity 0.3
hyperdrive_visual_set FlashIntensity 0.2
```

### Performance Configuration

For servers with many players:

```bash
# Reduce effect update rate
hyperdrive_visual_set EffectUpdateRate 0.2

# Limit particle count
hyperdrive_visual_set MaxParticles 250

# Disable expensive effects
hyperdrive_visual_set EnableMotionBlur false
```

## Troubleshooting Installation

### Common Issues

#### "Addon not loading"
- **Check file permissions** - ensure the addon folder is readable
- **Verify addon.txt** - make sure the addon.txt file is present and valid
- **Check console** - look for error messages during startup

#### "Entities not spawning"
- **Restart the server/game** after installation
- **Check for conflicting addons** that might override entity spawning
- **Verify lua files** are in the correct directories

#### "Computer can't find engine"
- **Check distance** - computer and engine must be within 500 units
- **Ensure both entities are valid** - respawn if necessary
- **Try manual linking** instead of auto-link

#### "White screen during jumps"
- **Run the fix command**: `hyperdrive_debug_fix_white_screen`
- **Disable visual effects**: `hyperdrive_visual_disable_all`
- **Update graphics drivers** if the issue persists

### Debug Commands

Use these commands to diagnose issues:

```bash
# Test system status
hyperdrive_debug_test

# Check hyperspace status
hyperdrive_debug_status

# Force exit if stuck
hyperdrive_debug_force_exit

# Emergency player exit
hyperdrive_emergency_exit
```

## Server Configuration

### For Dedicated Servers

Add these to your `server.cfg` if needed:

```
# Allow addon downloads
sv_allowdownload 1
sv_allowupload 1

# Increase entity limits if needed
sbox_maxprops 1000
sbox_maxragdolls 100

# Performance settings
sv_hibernate_think 1
```

### Workshop Integration

If distributing via Steam Workshop:

1. **Create addon.txt** with proper information
2. **Test thoroughly** on a clean server
3. **Include all required files** in the addon
4. **Add clear description** and screenshots

## Verification

After installation, verify everything works:

1. **✓ Entities spawn correctly**
2. **✓ Computer interface opens**
3. **✓ Engine linking works**
4. **✓ Jumps execute successfully**
5. **✓ Hyperspace dimension functions**
6. **✓ Visual effects display properly**
7. **✓ Integration addons work (if installed)**

## Getting Help

If you encounter issues:

1. **Check this guide** for common solutions
2. **Use debug commands** to gather information
3. **Check console output** for error messages
4. **Verify addon compatibility** with other installed addons
5. **Test on a clean server** to isolate issues

## Uninstallation

To remove the addon:

1. **Stop the server** or exit Garry's Mod
2. **Delete the addon folder** from `garrysmod/addons/`
3. **Remove any saved data** from `garrysmod/data/` if desired
4. **Restart the server/game**

The addon is designed to clean up after itself, but you may want to manually remove any saved waypoints or configuration files if desired.

## Next Steps

Once installed and working:

1. **Read the README.md** for feature overview
2. **Check DEVELOPER_GUIDE.md** if you want to modify the addon
3. **Experiment with integrations** if you have compatible addons
4. **Build awesome ships** and explore the galaxy!

Enjoy your hyperdrive adventures!
