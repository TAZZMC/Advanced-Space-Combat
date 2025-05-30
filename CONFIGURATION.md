# Enhanced Hyperdrive System - Configuration Guide

This guide covers all configuration options available in the Enhanced Hyperdrive System v2.1.0.

## 🎛️ Configuration Access

### Q Menu Configuration
1. Open the **Q Menu** (default: Q key)
2. Navigate to **Options** → **Enhanced Hyperdrive**
3. Adjust settings in the configuration panel

### Console Commands
```lua
-- View current configuration
hyperdrive_config_show

-- Set specific values
hyperdrive_config_set <category> <key> <value>

-- Reset to defaults
hyperdrive_config_reset

-- Check integration status
hyperdrive_integration_status
```

### Admin Panel
Administrators can access advanced configuration through:
1. **Admin Panel**: `hyperdrive_admin_panel` command
2. **Server Console**: Direct configuration editing
3. **Config Files**: Manual file editing (advanced users)

## ⚙️ Core Configuration Categories

### 1. Core System Settings

#### Ship Core Requirements
```lua
Core = {
    RequireShipCore = true,              -- Require ship core for hyperdrive operation
    AllowMultipleCores = false,          -- Allow multiple cores per ship
    AutoDetectShips = true,              -- Automatically detect ship structures
    ShipDetectionRange = 2000,           -- Maximum detection range
    UpdateInterval = 1.0,                -- Core update frequency (seconds)
    EnableShipNaming = true,             -- Allow custom ship names
    ValidateShipNames = true,            -- Validate ship name uniqueness
    MaxShipNameLength = 32,              -- Maximum ship name length
    MinShipNameLength = 3                -- Minimum ship name length
}
```

#### Energy System
```lua
Energy = {
    DefaultMaxEnergy = 1000,             -- Default maximum energy
    EnergyConsumptionRate = 100,         -- Energy consumption per jump
    EnergyRechargeRate = 50,             -- Energy recharge per second
    RequireEnergyForJump = true,         -- Require energy for hyperdrive
    EmergencyEnergyReserve = 100,        -- Reserve energy for emergencies
    EnergyEfficiencyMode = "balanced"    -- "efficient", "balanced", "powerful"
}
```

#### Cooldown System
```lua
Cooldown = {
    DefaultCooldown = 30,                -- Default cooldown time (seconds)
    CooldownScaling = "linear",          -- "linear", "exponential", "logarithmic"
    MinimumCooldown = 5,                 -- Minimum cooldown time
    MaximumCooldown = 300,               -- Maximum cooldown time
    EmergencyJumpCooldown = 60           -- Cooldown after emergency jump
}
```

### 2. CAP Integration Settings

#### Core CAP Settings
```lua
CAP = {
    EnableCAPIntegration = true,         -- Master CAP integration toggle
    PreferCAPSystems = true,             -- Prefer CAP over built-in systems
    AutoDetectCAP = true,                -- Automatically detect CAP installation
    CAPDetectionRange = 2000,            -- Range for CAP entity detection
    CAPUpdateInterval = 2.0,             -- CAP system update frequency
    RequireCAPForStargate = false        -- Require CAP for Stargate features
}
```

#### Shield Integration
```lua
CAP = {
    UseCAPShields = true,                -- Use CAP bubble shields
    PreferCAPShields = true,             -- Prefer CAP shields over built-in
    AutoDetectCAPShields = true,         -- Auto-detect CAP shields
    IntegrateWithCAPResources = true,    -- Integrate with CAP resource system
    ShieldActivationDelay = 2.0,         -- Delay before shield activation
    ShieldRechargeRate = 5.0,            -- Shield recharge rate
    UseShieldFrequencies = true,         -- Use CAP shield frequencies
    IntegrateShieldPower = true          -- Integrate shield power systems
}
```

#### Energy Integration
```lua
CAP = {
    UseCAPEnergy = true,                 -- Use CAP energy sources
    ShareEnergyWithStargates = true,     -- Share energy with Stargate network
    UseCAPEnergyTypes = true,            -- Use CAP-specific energy types
    CAPEnergyPriority = "high",          -- "low", "medium", "high"
    AutoProvisionCAP = true,             -- Auto-provision CAP entities
    ShareResourceStorage = true          -- Share resource storage with CAP
}
```

#### Stargate Integration
```lua
CAP = {
    IntegrateWithStargates = true,       -- Enable Stargate integration
    UseStargateNetwork = true,           -- Use Stargate network for travel
    PreventStargateConflicts = true,     -- Prevent conflicts with Stargate addon
    UseStargateAddresses = true,         -- Use 6-symbol address system
    IntegrateWithDHD = true,             -- Integrate with Dial Home Device
    CheckStargateStatus = true,          -- Check Stargate operational status
    UseStargateProtection = true,        -- Use Stargate iris protection
    RequireStargateEnergy = false        -- Require Stargate energy for operation
}
```

#### Effects Integration
```lua
CAP = {
    UseCAPEffects = true,                -- Use CAP visual effects
    UseStargateEffects = true,           -- Use Stargate-style effects
    UseShieldEffects = true,             -- Use CAP shield effects
    UseTransportEffects = true,          -- Use CAP transport effects
    CAPEffectsEnabled = true             -- Master CAP effects toggle
}
```

### 3. Shield System Configuration

#### Shield Settings
```lua
Shields = {
    EnableShields = true,                -- Enable shield system
    AutoActivateShields = true,          -- Auto-activate during hyperdrive
    ShieldActivationDelay = 1.0,         -- Delay before activation
    ShieldRechargeRate = 10.0,           -- Shield recharge per second
    ShieldMaxStrength = 100,             -- Maximum shield strength
    ShieldEfficiency = 0.8,              -- Shield energy efficiency
    AllowShieldOverload = true,          -- Allow shield overload states
    ShieldOverloadThreshold = 120,       -- Overload threshold percentage
    ShieldCooldownAfterOverload = 30     -- Cooldown after overload
}
```

#### Shield Types
```lua
Shields = {
    DefaultShieldType = "energy",        -- "energy", "particle", "hybrid"
    AllowShieldTypeChanges = true,       -- Allow runtime shield type changes
    ShieldTypeEffectiveness = {          -- Effectiveness against damage types
        energy = {kinetic = 0.8, energy = 1.0, explosive = 0.6},
        particle = {kinetic = 1.0, energy = 0.7, explosive = 0.9},
        hybrid = {kinetic = 0.9, energy = 0.9, explosive = 0.8}
    }
}
```

### 4. Hull Damage System

#### Hull Settings
```lua
HullDamage = {
    EnableHullDamage = true,             -- Enable hull damage system
    HullIntegrityThreshold = 25,         -- Critical hull threshold
    EmergencyThreshold = 10,             -- Emergency hull threshold
    AutoRepairEnabled = true,            -- Enable automatic hull repair
    AutoRepairRate = 1.0,                -- Hull repair per second
    AutoRepairThreshold = 50,            -- Start auto-repair below this %
    HullRepairCost = 10,                 -- Energy cost per hull point
    AllowEmergencyRepair = true,         -- Allow emergency repair systems
    EmergencyRepairAmount = 25,          -- Emergency repair amount
    EmergencyRepairCooldown = 60         -- Emergency repair cooldown
}
```

#### Damage Calculation
```lua
HullDamage = {
    DamageCalculationMode = "realistic",  -- "simple", "realistic", "advanced"
    DamageResistance = 1.0,              -- Global damage resistance multiplier
    CriticalDamageMultiplier = 2.0,      -- Multiplier for critical hits
    HullMaterialFactor = 1.0,            -- Material-based damage modification
    StructuralIntegrityFactor = 0.8,     -- Structural integrity influence
    RepairDifficultyScaling = "linear"   -- "linear", "exponential"
}
```

### 5. Resource System Configuration

#### Spacebuild 3 Integration
```lua
SB3Resources = {
    EnableSB3Integration = true,         -- Enable Spacebuild 3 integration
    AutoProvisionEnabled = true,         -- Auto-provision newly welded entities
    WeldDetectionEnabled = true,         -- Enable weld detection system
    AutoProvisionDelay = 0.5,            -- Delay before auto-provisioning
    ResourceDistributionRate = 100,      -- Distribution rate per second
    ResourceCollectionRate = 50,         -- Collection rate per second
    EmergencyModeThreshold = 10,         -- Emergency mode trigger threshold
    SurplusCollectionThreshold = 90,     -- Collect surplus above this %
    SurplusRetentionLevel = 80,          -- Retain this % when collecting
    EnableRDIntegration = true,          -- Resource Distribution integration
    EnableLS2Integration = true          -- Life Support 2 integration
}
```

#### Resource Types
```lua
SB3Resources = {
    DefaultCapacities = {                -- Default resource capacities
        energy = 1000,
        oxygen = 500,
        coolant = 300,
        fuel = 400,
        water = 200,
        nitrogen = 150
    },
    TransferRates = {                    -- Resource transfer rates (per second)
        energy = 200,
        oxygen = 100,
        coolant = 80,
        fuel = 60,
        water = 40,
        nitrogen = 30
    },
    CriticalLevels = {                   -- Critical resource levels (%)
        energy = 15,
        oxygen = 20,
        coolant = 25,
        fuel = 10,
        water = 30,
        nitrogen = 35
    }
}
```

### 6. Visual Effects Configuration

#### Effect Settings
```lua
Effects = {
    EnableVisualEffects = true,          -- Master effects toggle
    EffectQuality = "high",              -- "low", "medium", "high", "ultra"
    ParticleCount = 100,                 -- Maximum particles per effect
    EffectRange = 1000,                  -- Maximum effect visibility range
    EffectDuration = 5.0,                -- Default effect duration
    UseShipBasedEffects = true,          -- Effects around ship vs. player HUD
    EnableSoundEffects = true,           -- Enable sound effects
    SoundVolume = 0.8,                   -- Sound effect volume (0-1)
    Use3DSound = true                    -- Use 3D positional audio
}
```

#### Stargate Effects
```lua
Effects = {
    EnableStargateEffects = true,        -- Enable 4-stage Stargate effects
    StargateEffectStages = {
        charge = {duration = 3.0, intensity = 0.8},
        window = {duration = 2.0, intensity = 1.0},
        travel = {duration = 4.0, intensity = 0.6},
        exit = {duration = 1.5, intensity = 1.2}
    },
    StargateEffectColors = {
        primary = Color(100, 150, 255),
        secondary = Color(200, 100, 255),
        accent = Color(255, 255, 255)
    }
}
```

### 7. Performance Configuration

#### Update Intervals
```lua
Performance = {
    CoreUpdateInterval = 1.0,            -- Ship core update frequency
    EngineUpdateInterval = 0.5,          -- Engine update frequency
    ShieldUpdateInterval = 0.2,          -- Shield update frequency
    HullUpdateInterval = 2.0,            -- Hull damage update frequency
    ResourceUpdateInterval = 1.0,        -- Resource system update frequency
    CAPUpdateInterval = 2.0,             -- CAP integration update frequency
    EffectUpdateInterval = 0.1           -- Visual effect update frequency
}
```

#### Network Optimization
```lua
Performance = {
    EnableNetworkOptimization = true,    -- Enable network optimizations
    NetworkUpdateRate = 10,              -- Network updates per second
    MaxNetworkEntities = 100,            -- Maximum entities per network update
    UseCompressedNetworking = true,      -- Use compressed network data
    BatchNetworkUpdates = true,          -- Batch multiple updates
    NetworkPriority = "balanced"         -- "performance", "balanced", "quality"
}
```

#### Memory Management
```lua
Performance = {
    EnableMemoryOptimization = true,     -- Enable memory optimizations
    GarbageCollectionInterval = 30,      -- Garbage collection frequency
    CacheSize = 1000,                    -- Maximum cache entries
    PreloadResources = true,             -- Preload common resources
    UnloadUnusedResources = true,        -- Unload unused resources
    MemoryUsageLimit = 100               -- Memory usage limit (MB)
}
```

### 8. Security and Permissions

#### Access Control
```lua
Security = {
    EnablePermissionSystem = true,       -- Enable permission checks
    RequireAdminForConfig = true,        -- Require admin for configuration
    AllowPlayerShipNaming = true,        -- Allow players to name ships
    RestrictHyperdriveUsage = false,     -- Restrict hyperdrive to specific groups
    LogSecurityEvents = true,            -- Log security-related events
    EnableAntiGrief = true,              -- Enable anti-grief measures
    MaxShipsPerPlayer = 5,               -- Maximum ships per player
    RequireShipOwnership = false         -- Require ship ownership for control
}
```

#### Validation
```lua
Security = {
    ValidateDestinations = true,         -- Validate jump destinations
    PreventWorldBoundaryJumps = true,    -- Prevent jumps outside world
    MaxJumpDistance = 50000,             -- Maximum jump distance
    MinJumpDistance = 100,               -- Minimum jump distance
    ValidateShipIntegrity = true,        -- Validate ship before jump
    RequireMinimumHull = 25,             -- Minimum hull for jump
    PreventOverlappingJumps = true       -- Prevent overlapping destinations
}
```

## 🔧 Advanced Configuration

### Custom Configuration Files
Advanced users can create custom configuration files in:
```
garrysmod/data/hyperdrive/config/
```

### Environment-Specific Settings
```lua
-- Server-specific overrides
if SERVER then
    HYPERDRIVE.Config.Performance.NetworkOptimization = true
end

-- Client-specific overrides
if CLIENT then
    HYPERDRIVE.Config.Effects.EffectQuality = "medium"
end
```

### Integration-Specific Configuration
```lua
-- CAP-specific settings when CAP is detected
if HYPERDRIVE.CAP.Available then
    HYPERDRIVE.Config.CAP.PreferCAPSystems = true
    HYPERDRIVE.Config.Effects.EnableStargateEffects = true
end

-- Spacebuild-specific settings
if CAF then
    HYPERDRIVE.Config.SB3Resources.EnableSB3Integration = true
end
```

## 📊 Configuration Validation

The system automatically validates configuration values and provides warnings for invalid settings:

- **Range Validation**: Numeric values are clamped to valid ranges
- **Type Validation**: Values are checked for correct data types
- **Dependency Validation**: Related settings are checked for consistency
- **Performance Validation**: Settings are validated for performance impact

## 🔄 Configuration Persistence

Configuration changes are automatically saved and persist across:
- Server restarts
- Map changes
- Addon reloads
- Game sessions

## 🛠️ Troubleshooting Configuration

### Common Issues
1. **Settings Not Saving**: Check file permissions in data directory
2. **Performance Issues**: Reduce update intervals and effect quality
3. **Integration Problems**: Verify addon dependencies and versions
4. **Network Issues**: Enable network optimization features

### Reset Configuration
To reset all settings to defaults:
```lua
hyperdrive_config_reset
```

Or delete the configuration file:
```
garrysmod/data/hyperdrive/config.txt
```

This comprehensive configuration guide covers all aspects of customizing the Enhanced Hyperdrive System to meet your specific needs and server requirements.
