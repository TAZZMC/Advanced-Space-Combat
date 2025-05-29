# 🖥️ Computer-Controlled Master Engine Guide

## 🎯 **Overview**

The Hyperdrive Computer can now fully control Master Engines, including the enhanced 4-stage Stargate travel system! This provides centralized control, automation capabilities, and advanced monitoring of your hyperdrive systems.

## 🚀 **Quick Setup Guide**

### **Step 1: Spawn the Components**
1. **Spawn a Hyperdrive Computer** from the entities menu
2. **Spawn a Master Engine** nearby (within 2000 units)
3. **Place them on your ship** or in your base

### **Step 2: Link Computer to Master Engine**
**Method A: Automatic Linking**
- The computer automatically finds and links to nearby master engines
- Wait a few seconds after spawning both entities

**Method B: Manual Linking**
- Look at the computer and type: **`hyperdrive_computer_link_master`**
- This forces an immediate scan for master engines

**Method C: Wiremod Linking**
- Wire the master engine to the computer's **"ControlMasterEngine"** input
- This gives you precise control over which engine to use

### **Step 3: Control the Master Engine**
- Use console commands, wiremod, or the computer interface
- Set destinations and initiate 4-stage travel remotely

## 🎮 **Console Commands**

### **Essential Commands**
```
hyperdrive_computer_link_master     - Link computer to nearby master engine
hyperdrive_computer_4stage X Y Z    - Start 4-stage travel to coordinates
hyperdrive_computer_status          - Check master engine control status
hyperdrive_computer_abort           - Emergency abort current jump
```

### **Usage Examples**
```
hyperdrive_computer_4stage 1000 500 200    - Jump to coordinates (1000, 500, 200)
hyperdrive_computer_4stage                 - Jump to engine's current destination
```

## 🔌 **Wiremod Integration**

### **Key Inputs**
- **`ControlMasterEngine [ENTITY]`** - Wire a specific master engine to control
- **`SetMasterDestination [VECTOR]`** - Set destination coordinates
- **`Start4StageJump`** - Initiate 4-stage Stargate travel
- **`StartMasterJump`** - Start jump (auto-selects 4-stage if available)
- **`AbortMasterJump`** - Emergency abort
- **`CheckMasterStatus`** - Update status information

### **Key Outputs**
- **`ControlledMasterEngine [ENTITY]`** - Currently controlled engine
- **`MasterEngineStatus [STRING]`** - Engine status ("READY", "CHARGING", etc.)
- **`MasterEngineEnergy`** - Current energy level
- **`MasterEngineReady`** - 1 if ready to jump, 0 if not
- **`FourStageAvailable`** - 1 if 4-stage system available
- **`FourStageActive`** - 1 if 4-stage jump in progress
- **`CurrentStage`** - Current stage (1-4) during 4-stage travel
- **`StageProgress`** - Progress through current stage (0-1)
- **`MasterEfficiencyRating`** - Engine efficiency multiplier
- **`MasterIntegrations [STRING]`** - Active integrations (Wiremod,Spacebuild,Stargate)

## 🌟 **4-Stage Travel Control**

### **Initiating 4-Stage Travel**
1. **Set Destination**: Use wiremod, commands, or interface
2. **Start Jump**: Use `Start4StageJump` input or `hyperdrive_computer_4stage` command
3. **Monitor Progress**: Watch the stage outputs and HUD

### **Stage Monitoring**
The computer provides real-time monitoring of the 4-stage process:
- **Stage 1**: Initiation/Charging (4 seconds)
- **Stage 2**: Window Opening (3 seconds)
- **Stage 3**: Hyperspace Travel (variable based on distance)
- **Stage 4**: Exit/Stabilization (5 seconds)

### **Progress Tracking**
- **`CurrentStage`** output shows which stage (1-4)
- **`StageProgress`** output shows completion (0.0 to 1.0)
- **`FourStageActive`** output indicates if jump is in progress

## 🔧 **Advanced Features**

### **Automatic Engine Management**
- **Auto-Discovery**: Computer automatically finds nearby master engines
- **Health Monitoring**: Continuously checks engine status
- **Connection Validation**: Ensures engine is still valid and nearby
- **Automatic Reconnection**: Re-links if connection is lost

### **Enhanced Status Reporting**
The computer provides detailed status information:
- Engine operational status and error reasons
- Energy levels and efficiency ratings
- Integration status (Wiremod, Spacebuild, Stargate)
- 4-stage system availability and progress
- Cooldown timers and charging status

### **Safety Features**
- **Range Validation**: Ensures engine is within control range (3000 units)
- **Status Checking**: Verifies engine can operate before starting jumps
- **Emergency Abort**: Immediate jump cancellation capability
- **Connection Monitoring**: Automatic disconnection if engine becomes invalid

## 🎯 **Usage Scenarios**

### **Basic Ship Control**
1. Place computer and master engine on your ship
2. Use `hyperdrive_computer_4stage X Y Z` to travel
3. Enjoy the full 4-stage Stargate experience

### **Automated Systems**
1. Wire up the computer inputs/outputs
2. Create automated jump sequences
3. Monitor progress with stage outputs
4. Build complex navigation systems

### **Fleet Command**
1. Use multiple computers for different ships
2. Coordinate jumps with wiremod logic
3. Monitor entire fleet status
4. Execute synchronized 4-stage travel

### **Base Operations**
1. Set up computer as central control station
2. Control multiple master engines
3. Create jump scheduling systems
4. Monitor all hyperdrive operations

## 🔍 **Troubleshooting**

### **"No master engine under control"**
**Solutions:**
- Use `hyperdrive_computer_link_master` to link manually
- Check that master engine is within 2000 units
- Verify master engine is spawned and functional
- Wire the engine directly to `ControlMasterEngine` input

### **"4-stage travel system not available"**
**Solutions:**
- Ensure Stargate integration is loaded
- Check that 4-stage system is enabled in config
- Verify master engine has proper integrations

### **"Engine cannot operate"**
**Check:**
- Engine has sufficient energy
- Engine is not on cooldown
- Destination is set and valid
- Engine is not already charging

### **Connection Lost**
**Causes:**
- Engine moved too far away (>3000 units)
- Engine was removed or destroyed
- Engine class changed (shouldn't happen)

**Solutions:**
- Move computer closer to engine
- Respawn the engine if destroyed
- Use `hyperdrive_computer_link_master` to reconnect

## 🎉 **Benefits of Computer Control**

### **Centralized Management**
- ✅ Control multiple engines from one location
- ✅ Monitor all systems from single interface
- ✅ Coordinate complex jump sequences
- ✅ Automate routine operations

### **Enhanced Monitoring**
- ✅ Real-time status updates
- ✅ 4-stage progress tracking
- ✅ Integration status reporting
- ✅ Performance metrics

### **Automation Capabilities**
- ✅ Wiremod integration for complex logic
- ✅ Automated jump sequences
- ✅ Conditional jump execution
- ✅ Fleet coordination systems

### **Safety & Reliability**
- ✅ Automatic health monitoring
- ✅ Emergency abort capabilities
- ✅ Connection validation
- ✅ Error reporting and recovery

## 🌟 **Summary**

The Computer-Controlled Master Engine system provides:
- **Full remote control** of master engines
- **Complete 4-stage travel integration** with progress monitoring
- **Advanced wiremod capabilities** for automation
- **Comprehensive status reporting** and health monitoring
- **Safety features** and error handling
- **Easy-to-use console commands** for quick operation

Whether you're building a simple ship or a complex automated system, the computer gives you complete control over your hyperdrive operations while maintaining the full authentic Stargate 4-stage travel experience! 🚀
