# Hyperdrive System - Configuration Guide

## Table of Contents
1. [Admin Panel Overview](#admin-panel-overview)
2. [Core Settings](#core-settings)
3. [Integration Configuration](#integration-configuration)
4. [Performance Settings](#performance-settings)
5. [Security Configuration](#security-configuration)
6. [Effect Settings](#effect-settings)
7. [Network Configuration](#network-configuration)
8. [Console Commands](#console-commands)
9. [Server Configuration](#server-configuration)
10. [Troubleshooting Config Issues](#troubleshooting-config-issues)

## Admin Panel Overview

### Accessing the Admin Panel
- **In-Game**: Open spawn menu → Utilities → Hyperdrive Admin Panel
- **Console**: Type `hyperdrive_admin` in console
- **Requires**: Admin privileges on the server

### Panel Sections
- **Core Settings**: Basic system configuration
- **Integrations**: Enable/disable addon integrations
- **Performance**: Optimization and quality settings
- **Security**: Access control and anti-griefing
- **Effects**: Visual and audio configuration
- **Network**: Communication optimization
- **Status**: System health monitoring

## Core Settings

### Basic Configuration
```lua
HYPERDRIVE.Core.Config = {
    MaxActiveEngines = 100,        -- Maximum engines allowed
    UpdateRate = 0.1,              -- Update frequency (seconds)
    EffectQuality = 1.0,           -- Effect quality multiplier
    NetworkOptimization = true,     -- Enable network optimization
    RelativisticEffects = true,     -- Enable physics simulation
    GravitationalLensing = true,    -- Enable gravitational effects
    QuantumTunneling = false        -- Experimental quantum effects
}
```

### Energy System
```lua
EnergyDecay = 0.001,              -- Energy decay rate
CapacitorCharging = true,         -- Gradual energy buildup
PowerSurges = true,               -- Random power fluctuations
```

### Safety Systems
```lua
CollisionAvoidance = true,        -- Prevent collision jumps
EmergencyShutdown = true,         -- Auto-shutdown on errors
RedundantSystems = true,          -- Backup system activation
```

### Admin Panel Controls
- **Max Active Engines**: Slider (10-200)
- **Update Rate**: Slider (0.05-1.0 seconds)
- **Effect Quality**: Slider (0.1-3.0)
- **Enable Physics**: Checkbox for relativistic effects
- **Safety Systems**: Toggle emergency features

## Integration Configuration

### SpaceCombat2 Settings
```lua
HYPERDRIVE.EnhancedConfig.SpaceCombat2 = {
    Enabled = true,                     -- Enable SC2 integration
    UseGyropodMovement = true,          -- Use gyropod for movement
    UseShipCore = true,                 -- Use ship core detection
    OverrideGravity = true,             -- Override gravity in hyperspace
    OptimizedMovement = true,           -- Use optimized movement
    GyropodSearchRadius = 2000,         -- Gyropod search range
    ShipCoreSearchRadius = 1500,        -- Ship core search range
    GravityOverrideDuration = 5         -- Gravity override time
}
```

### Spacebuild 3 Settings
```lua
HYPERDRIVE.EnhancedConfig.Spacebuild3 = {
    Enabled = true,                     -- Enable SB3 integration
    RequireResources = true,            -- Require SB3 resources
    ResourceMultiplier = 1.0,           -- Resource consumption rate
    LifeSupportRequired = true,         -- Require life support
    EnvironmentalHazards = true,        -- Consider environment
    PowerConsumption = 100,             -- Power per jump
    OxygenConsumption = 50,             -- Oxygen per jump
    CoolantConsumption = 25             -- Coolant per jump
}
```

### Wiremod Settings
```lua
HYPERDRIVE.EnhancedConfig.Wiremod = {
    Enabled = true,                     -- Enable Wiremod support
    AutoWireInputs = true,              -- Auto-create wire inputs
    AutoWireOutputs = true,             -- Auto-create wire outputs
    UpdateRate = 0.5,                   -- Wire update frequency
    EnableAdvancedIO = true             -- Enable advanced I/O
}
```

### CAP Integration Settings
```lua
HYPERDRIVE.EnhancedConfig.CAP = {
    Enabled = true,                     -- Enable CAP integration
    UseStargateNetwork = true,          -- Use Stargate network
    RespectShields = true,              -- Respect shield protection
    ShareEnergyWithStargates = true,    -- Share energy systems
    PreventConflicts = true,            -- Prevent system conflicts
    UseStargateAddresses = true         -- Enable address navigation
}
```

### Admin Panel Integration Controls
- **Integration Status**: Shows which addons are detected
- **Enable/Disable Toggles**: For each integration
- **Configuration Sliders**: For integration-specific settings
- **Test Buttons**: To verify integration functionality

## Performance Settings

### Quality Configuration
```lua
HYPERDRIVE.Effects.Config = {
    ParticleCount = 1.0,               -- Particle density multiplier
    EffectRange = 2000,                -- Maximum effect visibility
    LODSystem = true,                  -- Level of detail system
    MaxActiveEffects = 20,             -- Maximum concurrent effects
    EffectCulling = true,              -- Distance-based culling
    DynamicQuality = true              -- Auto-adjust quality
}
```

### Optimization Settings
```lua
HYPERDRIVE.Performance = {
    EntityUpdateRate = 0.1,            -- Entity update frequency
    NetworkUpdateRate = 0.5,           -- Network sync frequency
    EffectUpdateRate = 0.05,           -- Effect update frequency
    GarbageCollection = true,          -- Auto cleanup
    MemoryOptimization = true,         -- Memory management
    CPUOptimization = true             -- CPU usage optimization
}
```

### Admin Panel Performance Controls
- **Effect Quality**: Master quality slider
- **Particle Count**: Particle density control
- **Update Rates**: Frequency sliders for different systems
- **Optimization Toggles**: Enable/disable optimization features
- **Performance Monitor**: Real-time performance metrics

## Security Configuration

### Access Control
```lua
HYPERDRIVE.Security.Config = {
    EnableOwnership = true,            -- Enable entity ownership
    AdminOverride = true,              -- Allow admin override
    GuestAccess = false,               -- Allow guest usage
    RequirePermission = true,          -- Require explicit permission
    LogAllActions = true,              -- Log security events
    AntiGrief = true                   -- Enable anti-griefing
}
```

### Access Levels
```lua
HYPERDRIVE.Security.AccessLevels = {
    OWNER = 4,      -- Full control
    ADMIN = 3,      -- Administrative access
    TRUSTED = 2,    -- Trusted user access
    USER = 1,       -- Basic user access
    GUEST = 0       -- Read-only access
}
```

### Protection Settings
```lua
DestinationValidation = true,         -- Validate jump destinations
EntityProtection = true,              -- Protect owned entities
RateLimit = 5,                        -- Max jumps per minute
BlacklistEnabled = true,              -- Enable destination blacklist
WhitelistMode = false                 -- Whitelist-only mode
```

### Admin Panel Security Controls
- **Access Level Settings**: Configure permission levels
- **Protection Toggles**: Enable/disable protection features
- **Rate Limiting**: Configure usage limits
- **Blacklist Management**: Add/remove blocked destinations
- **Audit Log Viewer**: Review security events

## Effect Settings

### Visual Effects
```lua
HYPERDRIVE.Effects.Visual = {
    HDRLighting = true,                -- High dynamic range lighting
    VolumetricEffects = true,          -- 3D volumetric effects
    MotionBlur = true,                 -- Motion blur during jumps
    ChromaticAberration = true,        -- Color distortion effects
    ScreenDistortion = true,           -- Screen warping effects
    CameraShake = true,                -- Camera shake intensity
    ParticleComplexity = 2.0           -- Particle system complexity
}
```

### Audio Effects
```lua
HYPERDRIVE.Effects.Audio = {
    DopplerEffect = true,              -- Doppler shift simulation
    SpatialAudio = true,               -- 3D positional audio
    DynamicVolume = true,              -- Distance-based volume
    EchoEffects = true,                -- Hyperspace echo
    FrequencyShift = true,             -- Frequency modulation
    AudioQuality = 1.0                 -- Audio quality multiplier
}
```

### Stargate 4-Stage Effects
```lua
HYPERDRIVE.Stargate.Config.StageSystem = {
    EnableFourStageTravel = true,      -- Enable 4-stage system
    InitiationDuration = 3.0,          -- Stage 1 duration
    WindowOpeningDuration = 2.0,       -- Stage 2 duration
    HyperspaceTravelDuration = 5.0,    -- Stage 3 duration
    ExitStabilizationDuration = 2.0,   -- Stage 4 duration
    VisualIntensity = 1.0,             -- Effect intensity
    AudioEnabled = true,               -- Stage audio effects
    ParticleComplexity = 1.5           -- Stage particle complexity
}
```

### Admin Panel Effect Controls
- **Visual Quality Sliders**: Control individual effect types
- **Audio Settings**: Configure sound effects
- **Stargate Controls**: 4-stage travel configuration
- **Preview Buttons**: Test effects in real-time
- **Reset to Defaults**: Restore default settings

## Network Configuration

### Network Optimization
```lua
HYPERDRIVE.Network.Config = {
    CompressionEnabled = true,         -- Enable data compression
    DeltaCompression = true,           -- Send only changes
    RelevanceFiltering = true,         -- Filter by relevance
    BatchUpdates = true,               -- Batch network messages
    MaxPacketSize = 1024,              -- Maximum packet size
    UpdateThreshold = 0.1              -- Minimum change threshold
}
```

### Message Priorities
```lua
MessagePriorities = {
    jump_start = "HIGH",               -- Jump initiation
    jump_complete = "HIGH",            -- Jump completion
    status_update = "NORMAL",          -- Status updates
    effect_trigger = "LOW",            -- Visual effects
    debug_info = "LOWEST"              -- Debug information
}
```

### Admin Panel Network Controls
- **Compression Settings**: Configure data compression
- **Update Rates**: Network synchronization frequency
- **Priority Settings**: Message priority configuration
- **Bandwidth Monitor**: Network usage display
- **Connection Status**: Client connection health

## Console Commands

### Basic Commands
```
hyperdrive_admin                      -- Open admin panel
hyperdrive_debug <0|1>               -- Toggle debug mode
hyperdrive_reload                    -- Reload configuration
hyperdrive_status                    -- Show system status
hyperdrive_version                   -- Show version info
```

### Configuration Commands
```
hyperdrive_config_get <category> <key>           -- Get config value
hyperdrive_config_set <category> <key> <value>   -- Set config value
hyperdrive_config_reset <category>               -- Reset category
hyperdrive_config_save                           -- Save configuration
hyperdrive_config_load                           -- Load configuration
```

### Performance Commands
```
hyperdrive_performance               -- Show performance stats
hyperdrive_optimize <0|1>           -- Toggle optimization
hyperdrive_effects_quality <0.1-3.0> -- Set effect quality
hyperdrive_max_engines <number>      -- Set max engines
```

### Security Commands
```
hyperdrive_security_status           -- Show security status
hyperdrive_access_level <player> <level> -- Set player access
hyperdrive_blacklist_add <coordinates>    -- Add to blacklist
hyperdrive_blacklist_remove <coordinates> -- Remove from blacklist
hyperdrive_audit_log                 -- Show audit log
```

### Debug Commands
```
hyperdrive_debug_entities            -- List all hyperdrive entities
hyperdrive_debug_integrations        -- Show integration status
hyperdrive_debug_network             -- Show network statistics
hyperdrive_debug_effects             -- Show active effects
hyperdrive_test_jump <coordinates>   -- Test jump functionality
```

## Server Configuration

### Server.cfg Settings
```
// Hyperdrive System Configuration
hyperdrive_max_engines 100          // Maximum engines per server
hyperdrive_effect_quality 1.0       // Default effect quality
hyperdrive_network_rate 0.5          // Network update rate
hyperdrive_security_enabled 1       // Enable security system
hyperdrive_debug_mode 0              // Debug mode (0=off, 1=on)
```

### Performance Recommendations
```
// High Performance Servers
hyperdrive_max_engines 50
hyperdrive_effect_quality 0.5
hyperdrive_network_rate 1.0

// High Quality Servers
hyperdrive_max_engines 200
hyperdrive_effect_quality 2.0
hyperdrive_network_rate 0.1
```

### Integration Server Settings
```
// SpaceCombat2 Servers
hyperdrive_sc2_enabled 1
hyperdrive_sc2_gyropod_movement 1

// Spacebuild Servers
hyperdrive_sb3_enabled 1
hyperdrive_sb3_require_resources 1

// Roleplay Servers
hyperdrive_stargate_enabled 1
hyperdrive_stargate_four_stage 1
```

## Troubleshooting Config Issues

### Common Configuration Problems

#### Settings Not Saving
**Cause**: Insufficient file permissions
**Solution**: 
- Check server file permissions
- Ensure data folder is writable
- Run `hyperdrive_config_save` manually

#### Integration Not Loading
**Cause**: Missing dependencies or incorrect settings
**Solution**:
- Verify required addons are installed
- Check integration status in admin panel
- Restart server after addon installation

#### Performance Issues
**Cause**: Settings too high for server hardware
**Solution**:
- Reduce effect quality
- Lower max active engines
- Increase update rates
- Enable optimization features

#### Network Problems
**Cause**: Network settings incompatible with server
**Solution**:
- Adjust network update rates
- Enable compression
- Check bandwidth limits
- Verify client-server sync

### Configuration Validation
```lua
-- Validate configuration on startup
function HYPERDRIVE.ValidateConfig()
    -- Check for invalid values
    -- Correct out-of-range settings
    -- Report configuration issues
    -- Apply safe defaults
end
```

### Reset to Defaults
```
hyperdrive_config_reset all         -- Reset all settings
hyperdrive_config_reset core        -- Reset core settings only
hyperdrive_config_reset integrations -- Reset integration settings
hyperdrive_config_reset performance  -- Reset performance settings
```

---

This configuration guide provides comprehensive information for server administrators to properly configure and optimize the Hyperdrive System for their specific needs and server environment.
