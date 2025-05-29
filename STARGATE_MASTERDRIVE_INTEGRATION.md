# Stargate 4-Stage Travel Integration with Master Drive

## Overview

The 4-stage Stargate hyperdrive travel system has been successfully integrated into the Master Drive engine, providing enhanced visual effects, sounds, and functionality for **ALL** master engines. No Stargate technology is required - the system works with any master engine and provides additional bonuses when Stargate technology is detected.

## Integration Features

### 🚀 **Master Engine Integration**

The master engine (`hyperdrive_master_engine`) now automatically uses the 4-stage travel system for **ALL** jumps:

1. **Universal Compatibility**: Works with any master engine, no technology requirements
2. **Automatic Enhancement**: Detects and applies Stargate technology bonuses when available
3. **Fallback System**: Falls back to standard travel if 4-stage system fails
4. **Entity Transport**: Uses optimized entity detection for ship movement
5. **Bonus Integration**: Enhanced effects and efficiency when Stargate tech is present

### ⭐ **4-Stage Travel Process**

When **ANY** master engine performs a jump:

#### **Stage 1: Initiation/Charging (3 seconds)**
- **Visual**: Enhanced charging effects with master engine particles
- **Audio**: Technology-specific charging sounds
- **Function**: Energy buildup, coordinate calculation, resource verification

#### **Stage 2: Hyperspace Window Opening (2 seconds)**
- **Visual**: Blue/purple swirling energy tunnel with master effects
- **Audio**: Portal opening and dimensional tear sounds
- **Function**: Creates hyperspace window for travel

#### **Stage 3: Hyperspace Travel (Variable)**
- **Visual**: Stretched starlines and dimensional visuals
- **Audio**: Ambient hyperspace sounds
- **Function**: Actual travel through hyperspace dimension

#### **Stage 4: Exit/Stabilization (1.5 + 2 seconds)**
- **Visual**: Bright exit flash with system stabilization
- **Audio**: Exit sounds and system stabilization
- **Function**: Exit hyperspace and stabilize systems

### 🎨 **Enhanced Visual Effects**

The master jump effect (`hyperdrive_master_jump`) now supports different effect types:

- **Magnitude 1**: Standard origin effect
- **Magnitude 2**: Standard destination effect
- **Magnitude 3**: Stargate initiation effect
- **Magnitude 4**: Stargate window opening effect
- **Magnitude 5**: Stargate exit effect

Each effect type has:
- Unique particle systems
- Technology-scaled visuals
- Stage-appropriate sounds
- Dynamic lighting
- Screen shake effects

### 🔧 **Technical Implementation**

#### **Master Engine Changes**
```lua
-- Enhanced jump execution with 4-stage integration
function ENT:ExecuteJumpMaster()
    -- Apply Stargate energy cost calculation
    if self.IntegrationData.stargate.active and HYPERDRIVE.Stargate.CalculateEnergyCost then
        energyCost = HYPERDRIVE.Stargate.CalculateEnergyCost(self, self:GetPos(), destination, distance)
    end

    -- Check for 4-stage travel system
    if self.IntegrationData.stargate.active and HYPERDRIVE.Stargate.StartFourStageTravel then
        local entitiesToMove = self:GetEntitiesToTransport()
        local success, message = HYPERDRIVE.Stargate.StartFourStageTravel(self, destination, entitiesToMove)
        if success then return end -- Use 4-stage system
    end

    -- Fallback to standard travel
end
```

#### **Effect Integration**
```lua
-- Enhanced effects for each stage
function HYPERDRIVE.Stargate.CreateInitiationEffects(pos, techBonus)
    -- Standard Stargate effect
    util.Effect("hyperdrive_sg_charge", effectData)

    -- Master engine effect
    local masterEffectData = EffectData()
    masterEffectData:SetMagnitude(3) -- Stargate initiation
    util.Effect("hyperdrive_master_jump", masterEffectData)
end
```

### 🎮 **Console Commands**

#### **Master Engine Commands**
```
hyperdrive_4stage
```
- **Access**: All players
- **Function**: Initiates 4-stage travel with any master engine
- **Usage**: Look at a master engine and run the command

```
hyperdrive_master_sg_test
```
- **Access**: Admin only
- **Function**: Advanced testing of 4-stage Stargate travel with detailed feedback
- **Usage**: Look at a master engine and run the command

```
hyperdrive_master_status
```
- **Access**: All players
- **Function**: Shows comprehensive status of master engine including all integrations
- **Usage**: Look at a master engine and run the command

#### **Existing Stargate Commands**
- `hyperdrive_sg_status` - Check Stargate integration status
- `hyperdrive_sg_network` - View Stargate network coordinates
- `hyperdrive_sg_config` - View Stargate configuration (admin)
- `hyperdrive_sg_test_4stage` - Test 4-stage system (admin)

#### **Client-Side Commands**
- `hyperdrive_sg_client_config` - View client-side Stargate configuration
- `hyperdrive_sg_toggle_overlay` - Toggle hyperspace overlay effects

### 🔄 **Compatibility**

The integration maintains full compatibility with:

- **Standard Hyperdrive**: Works without Stargate technology
- **Spacebuild Integration**: Enhanced transport range and effects
- **Wiremod Integration**: All wire inputs/outputs functional
- **CAP Integration**: Full Carter Addon Pack support
- **SC2 Integration**: Space Combat 2 optimized movement

### 📊 **Performance Benefits**

1. **Efficiency Scaling**: Effects scale with master engine efficiency
2. **Technology Bonuses**: Ancient, Ori, Asgard technology bonuses
3. **Resource Optimization**: ZPM power bonuses, naquadah consumption
4. **Network Optimization**: Batch entity movement when available

### 🛠️ **Configuration**

The 4-stage system can be configured in `HYPERDRIVE.Stargate.Config.StageSystem`:

```lua
StageSystem = {
    EnableFourStageTravel = true,   -- Enable/disable 4-stage system
    InitiationDuration = 3.0,       -- Stage 1 duration
    WindowOpenDuration = 2.0,       -- Stage 2 duration
    ExitDuration = 1.5,             -- Stage 4 duration
    StabilizationTime = 2.0,        -- Additional stabilization time
    -- Effect toggles for each stage
    InitiationEffects = true,
    WindowEffects = true,
    TravelEffects = true,
    ExitEffects = true,
}
```

## Usage Instructions

1. **Setup**: Place a master hyperdrive engine anywhere (no special requirements!)
2. **Set Destination**: Use the engine interface to set your destination
3. **Initiate Travel**: Use `hyperdrive_4stage` command or normal jump controls
4. **Experience**: Enjoy the enhanced 4-stage travel experience!
5. **Optional Enhancement**: Place near Stargate technology for additional bonuses

The system works with **ANY** master engine and automatically provides enhanced effects when Stargate technology is nearby, while maintaining full compatibility with all existing systems.

## 🎨 **Enhanced User Interface Features**

### **Real-Time Stage Progress Display**
- **HUD Integration**: Stage progress appears in the existing hyperdrive HUD
- **Stage Indicators**: Shows current stage (1-4) with progress bar
- **Technology Display**: Shows Stargate technology level and efficiency
- **Status Updates**: Real-time status updates during travel

### **Visual Enhancements**
- **Stage-Specific Effects**: Each stage has unique visual effects
- **Master Effect Integration**: Enhanced effects scale with technology level
- **Hyperspace Overlay**: Immersive hyperspace tunnel visuals
- **Screen Effects**: Color modification and distortion during travel

### **Audio Feedback**
- **Stage Notifications**: Audio cues for each stage transition
- **Technology-Specific Sounds**: Different sounds based on tech level
- **Chat Notifications**: Detailed stage descriptions in chat
- **Completion Alerts**: Audio and visual feedback on completion

### **Network Optimization**
- **Efficient Updates**: Only sends updates to nearby players
- **Bandwidth Optimization**: Compressed stage data transmission
- **Range-Based**: UI updates within 2000 units, effects within 1500 units
- **Performance Scaling**: Effects scale based on client settings

## 🔧 **Advanced Configuration**

### **Stage System Settings**
```lua
HYPERDRIVE.Stargate.Config.StageSystem = {
    EnableFourStageTravel = true,
    InitiationDuration = 3.0,
    WindowOpenDuration = 2.0,
    ExitDuration = 1.5,
    StabilizationTime = 2.0,
    -- Enable/disable individual stage effects
    InitiationEffects = true,
    WindowEffects = true,
    TravelEffects = true,
    ExitEffects = true,
}
```

### **Client-Side Settings**
```lua
HYPERDRIVE.Stargate.Client.Config = {
    ShowStageNotifications = true,
    StarlineIntensity = 1.0,
    HyperspaceOverlay = true,
    DimensionalEffects = true,
    ScreenEffects = true
}
```
