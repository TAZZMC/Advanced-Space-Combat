# 🚀 Hyperdrive 4-Stage Travel System - User Guide

## 🎯 **Quick Start Guide**

### **Step 1: Spawn a Master Engine**
1. Open your **Spawn Menu** (Q key)
2. Go to **Entities** tab
3. Find **"Hyperdrive Master Engine"**
4. Spawn it on your ship or vehicle

### **Step 2: Set Your Destination**
**Method A: Using the Interface**
1. **Right-click** (Use key) on the Master Engine
2. The hyperdrive interface will open
3. **Left-click** on the map to set destination
4. Click **"Set Destination"** button

**Method B: Using Console Commands**
1. Look at the Master Engine
2. Type in console: `hyperdrive_set_dest X Y Z` (replace with coordinates)
3. Example: `hyperdrive_set_dest 1000 500 200`

### **Step 3: Initiate 4-Stage Travel**
**Method A: Simple Command (Recommended)**
1. Look at the Master Engine
2. Type in console: `hyperdrive_4stage`
3. Watch the amazing 4-stage sequence!

**Method B: Using the Interface**
1. Right-click on the Master Engine
2. Click **"Start Jump"** button
3. The system will automatically use 4-stage travel

## 🎮 **Console Commands Reference**

### **For All Players**
```
hyperdrive_4stage              - Start 4-stage travel (look at engine)
hyperdrive_master_status       - Check engine status and capabilities
hyperdrive_set_dest X Y Z      - Set destination coordinates
hyperdrive_abort              - Emergency abort current jump
```

### **For Admins Only**
```
hyperdrive_master_sg_test     - Test 4-stage system with debug info
hyperdrive_debug_stargate     - Toggle Stargate debug mode
hyperdrive_reload_config      - Reload configuration settings
```

## 🌟 **The 4-Stage Experience**

### **Stage 1: Initiation (4 seconds)**
**What You'll See:**
- Energy surges building up in 5 steps
- Console messages: "Hyperdrive powering up..."
- "Onboard computers calculating navigation paths..."
- "Building energy to rip open hyperspace window..."
- "Checking spatial charts for gravitational anomalies..."

**What's Happening:**
- Engine builds energy to tear open hyperspace
- Navigation computer calculates safe route
- System checks for gravitational hazards

### **Stage 2: Window Opening (3 seconds)**
**What You'll See:**
- Blue/purple swirling energy tunnel appears
- Rippling energy effects around the window
- Console messages: "Tearing a hole in normal space..."
- "Accessing higher-dimensional hyperspace realm..."
- "Hyperspace window stabilizing..."

**What's Happening:**
- Hyperdrive tears hole in normal space-time
- Access to higher-dimensional hyperspace opens
- Window stabilizes for safe entry

### **Stage 3: Hyperspace Travel (Variable)**
**What You'll See:**
- Stretched starlines (relativistic effects)
- Abstract dimensional tunnel visuals
- Console messages: "Entering hyperspace..."
- "Traveling at incredible speeds through higher dimensions..."
- For long jumps: "Initiating intergalactic hyperspace jump..."

**What's Happening:**
- Ship travels through hyperspace dimension
- No time dilation effects experienced
- Navigation avoids gravitational wells
- Travel time based on distance and technology

### **Stage 4: Exit & Stabilization (5 seconds)**
**What You'll See:**
- Bright flash of light upon exit
- Shimmer effects as ship materializes
- Hyperspace window collapses behind ship
- Console messages: "Emerging from hyperspace..."
- "Hyperspace window collapsing behind ship..."
- "Normal space physics resuming..."
- "Normal space physics fully restored."

**What's Happening:**
- Ship exits hyperspace into normal space
- Hyperspace window closes automatically
- Normal physics and systems stabilize
- Jump sequence completes successfully

## ⚡ **Energy & Requirements**

### **Basic Requirements**
- ✅ **Master Engine** - Any hyperdrive master engine
- ✅ **Energy** - Sufficient power for the jump distance
- ✅ **Destination** - Valid coordinates set
- ✅ **No Cooldown** - Engine not on cooldown

### **Energy Costs**
- **Base Cost**: Distance × 0.1 EU
- **Master Engine Bonus**: 20% efficiency (reduces cost)
- **Stargate Tech Bonus**: Up to 50% reduction with Ancient tech
- **Example**: 1000 unit jump = ~80 EU (with bonuses)

### **Technology Bonuses**
**No Stargate Tech (Standard Mode):**
- ✅ Full 4-stage experience available
- ✅ Standard energy costs and effects
- ✅ All visual and audio effects

**With Stargate Technology (Enhanced Mode):**
- ✅ **Ancient Tech**: 50% energy reduction, enhanced effects
- ✅ **Asgard Tech**: 40% energy reduction, blue effects
- ✅ **Ori Tech**: 35% energy reduction, orange effects
- ✅ **Goa'uld Tech**: 25% energy reduction, gold effects

## 🔧 **Troubleshooting**

### **"4-stage travel system is disabled"**
**Solution**: Admin needs to enable it in config
```
hyperdrive_reload_config  (admin command)
```

### **"Engine cannot operate"**
**Possible Issues:**
- ❌ **Low Energy**: Recharge the engine
- ❌ **No Destination**: Set a destination first
- ❌ **On Cooldown**: Wait for cooldown to finish
- ❌ **Engine Damaged**: Repair or respawn engine

### **"No destination set"**
**Solutions:**
1. Use engine interface to set destination
2. Use console: `hyperdrive_set_dest X Y Z`
3. Look at target location and use: `hyperdrive_set_dest_here`

### **"Jump failed"**
**Possible Causes:**
- ❌ **Destination too close** (< 100 units)
- ❌ **Destination too far** (> 100,000 units)
- ❌ **Invalid coordinates** (outside map bounds)
- ❌ **Insufficient energy** for the distance

## 🎯 **Pro Tips**

### **For Best Experience**
1. **Use in Space**: Works best in open areas
2. **Build Ships**: Attach to vehicles for ship travel
3. **Watch the Show**: Don't skip the 4-stage sequence!
4. **Use Stargate Tech**: Place Stargate entities nearby for bonuses

### **For Ship Builders**
1. **Central Placement**: Put engine in center of ship
2. **Power Integration**: Connect to Spacebuild power systems
3. **Wiremod Control**: Wire up for automated control
4. **Multiple Engines**: Use computer for fleet jumps

### **For Admins**
1. **Test First**: Use `hyperdrive_master_sg_test` to verify setup
2. **Monitor Performance**: Check console for debug info
3. **Configure Settings**: Adjust timings in config files
4. **Player Education**: Share this guide with players

## 🌟 **Advanced Features**

### **Fleet Coordination**
- Use **Hyperdrive Computer** to coordinate multiple engines
- Synchronized jumps with staggered timing
- Fleet-wide energy management

### **Wiremod Integration**
- **Input**: Jump trigger, destination coordinates
- **Output**: Status, energy level, stage progress
- **Automation**: Fully automated jump sequences

### **Spacebuild Integration**
- **Power Systems**: Connect to SB3 power networks
- **Life Support**: Oxygen and atmosphere management
- **Ship Detection**: Automatic ship boundary detection

## 🎉 **Enjoy Your Journey!**

The 4-stage Stargate hyperdrive system provides the most authentic Stargate travel experience in Garry's Mod. Whether you're exploring space, building massive ships, or just enjoying the spectacular visual effects, the system works seamlessly with or without Stargate technology.

**Remember**: The journey is just as important as the destination! 🌟
