# Space Combat 2 & Spacebuild 3 Integration Guide

This guide explains the enhanced hyperdrive addon integration with Space Combat 2 (SC2) and Spacebuild 3 (SB3) gamemodes, addressing the issues mentioned by the SC2 developer.

## Overview of Improvements

### 1. Enhanced Entity Detection
- **Problem Solved**: The original `ents.FindInSphere()` method missed many attached entities
- **Solution**: Uses ship core to get attached entities and players directly
- **Fallback**: Constraint system for non-SC2/SB3 environments

### 2. Optimized Ship Movement
- **Problem Solved**: Basic `SetPos()`/`SetAngles()` caused network lag
- **Solution**: Integrates with SC2 gyropod system for optimized movement
- **Fallback**: Enhanced batch movement with velocity clearing

### 3. Gravity Override System
- **Problem Solved**: SC2/SB3 override player gravity every tick
- **Solution**: Proper integration with gamemode gravity systems
- **Features**: Temporary override during hyperspace travel

### 4. Gyropod Integration
- **Problem Solved**: Ships teleporting back to original location
- **Solution**: Tells gyropod about new location using SC2 methods
- **Methods**: `SetTargetPosition()`, `MoveTo()`, or direct `SetPos()`

## Configuration

### Enhanced Configuration System
The addon now includes a comprehensive configuration system accessible via console commands:

```lua
-- View all configuration categories
hyperdrive_config_show

-- View Space Combat 2 settings
hyperdrive_config_show SpaceCombat2

-- Change a setting (admin only)
hyperdrive_config_set SpaceCombat2 UseGyropodMovement true

-- Check integration status
hyperdrive_integration_status

-- Reset to defaults
hyperdrive_config_reset
```

### Key Configuration Options

#### Space Combat 2 Integration
- `UseGyropodMovement`: Use SC2 gyropod for ship movement
- `UseShipCore`: Use ship core for entity detection
- `OverrideGravity`: Override SC2 gravity during jumps
- `OptimizedMovement`: Use optimized SetPos/SetAngles method
- `GyropodSearchRadius`: Radius to search for gyropods (default: 2000)
- `ShipCoreSearchRadius`: Radius to search for ship cores (default: 1500)

#### Spacebuild 3 Integration
- `UseShipCore`: Use ship core for entity detection
- `OverrideGravity`: Override SB3 gravity during jumps
- `RequireLifeSupport`: Require life support for jumps
- `RequirePower`: Require power for operation

## How It Works

### Entity Detection Process
1. **Ship Core Method** (Primary): Uses `shipCore:GetAttachedEntities()` and `shipCore:GetPlayersInShip()`
2. **Constraint System** (Fallback): Uses `constraint.GetAllConstrainedEntities()`
3. **Sphere Search** (Last Resort): Enhanced `ents.FindInSphere()` with SC2/SB3 entity filtering

### Movement Optimization
1. **Gyropod Integration**: Finds connected gyropod and uses its movement system
2. **Batch Movement**: Groups entity movements to reduce network overhead
3. **Velocity Clearing**: Prevents physics issues after teleportation
4. **Optimized Methods**: Uses `SetPosOptimized()` when available

### Gravity Management
1. **Detection**: Automatically detects SC2/SB3 gamemode
2. **Override**: Temporarily overrides gravity during hyperspace travel
3. **Restoration**: Restores gamemode gravity after configurable delay
4. **Integration**: Works with existing gamemode gravity systems

## Technical Details

### SC2 GetProtector Metamethod Integration
The system uses SC2's `GetProtector` metamethod for reliable ship core detection:

```lua
-- Check if entity has a ship core using GetProtector
local function HasShipCore(ent)
    if ent.GetProtector and type(ent.GetProtector) == "function" then
        local protector = ent:GetProtector()
        return IsValid(protector)
    end
    return false
end

-- Get ship core directly from entity
local function GetShipCoreFromProtector(ent)
    if ent.GetProtector and type(ent.GetProtector) == "function" then
        local protector = ent:GetProtector()
        if IsValid(protector) and protector:GetClass() == "sc_ship_core" then
            return protector
        end
    end
    return nil
end
```

### SC2 Gyropod Integration
The system integrates with SC2's gyropod in the following ways:

```lua
-- Find gyropod connected to ship using GetProtector
local shipCore = GetShipCoreFromProtector(engine)
local gyropod = HYPERDRIVE.SpaceCombat2.FindGyropod(engine)

-- Use gyropod's movement system
if gyropod.SetTargetPosition then
    gyropod:SetTargetPosition(newPosition)
elseif gyropod.MoveTo then
    gyropod:MoveTo(newPosition)
else
    gyropod:SetPos(newPosition) -- Fallback
end
```

### Ship Core Entity Detection
```lua
-- Get all attached entities using GetProtector method
local shipCore = GetShipCoreFromProtector(engine)
if IsValid(shipCore) then
    -- Use ship core's attached entities list
    if shipCore.GetAttachedEntities then
        local entities = shipCore:GetAttachedEntities()
        -- Process entities...
    end

    -- Find entities by checking their protector
    local nearbyEnts = ents.FindInSphere(shipCore:GetPos(), searchRadius)
    for _, ent in ipairs(nearbyEnts) do
        local entCore = GetShipCoreFromProtector(ent)
        if IsValid(entCore) and entCore == shipCore then
            -- Entity belongs to this ship
            table.insert(entities, ent)
        end
    end
end
```

### Gravity Override System
```lua
-- Override gravity during hyperspace
HYPERDRIVE.SpaceCombat2.OverrideGravity(player, true)

-- Restore after delay
timer.Simple(5, function()
    HYPERDRIVE.SpaceCombat2.OverrideGravity(player, false)
end)
```

## Compatibility

### Space Combat 2
- **Automatic Detection**: Detects SC2 gamemode automatically
- **Gyropod Support**: Full integration with gyropod movement system
- **Gravity Override**: Respects SC2's gravity system
- **Entity Detection**: Uses ship core for accurate entity lists

### Spacebuild 3
- **CAF Framework Integration**: Full compatibility with Spacebuild 3's Common Addon Framework
- **Resource Distribution 3 (RD3)**: Integration with the resource distribution system
- **Life Support Systems**: Air exchangers, climate control, gravity control integration
- **Power Management**: Energy generation, storage, and consumption tracking
- **Environment Systems**: Space/atmosphere detection and terraforming support
- **Resource Management**: Gas, liquid, and energy resource handling
- **Entity Categories**: Comprehensive support for all SB3 entity types

#### Spacebuild 3 Entity Support
Based on the official Spacebuild repository, the system supports:

**Life Support Systems:**
- `base_air_exchanger` - Oxygen generation and air recycling
- `base_climate_control` - Temperature and atmosphere control
- `base_gravity_control` - Artificial gravity systems
- `base_cube_environment` - Environment control blocks
- `base_sb_environment` - Spacebuild environment systems

**Power Systems:**
- `generator_energy_fusion` - Fusion power generation
- `generator_energy_solar` - Solar power generation
- `generator_energy_wind` - Wind power generation
- `storage_energy` - Energy storage systems

**Resource Systems:**
- `storage_gas` - Gas storage containers
- `storage_liquid_water` - Water storage systems
- `generator_gas_o2h_water` - Oxygen/hydrogen generation
- `generator_ramscoop` - Resource collection systems

**Resource Distribution (RD3):**
- `rd_pump` - Resource pumps
- `rd_ent_valve` - Entity valves
- `resource_node` - Resource distribution nodes

#### SB3 Validation Commands
```lua
hyperdrive_sb3_validate    -- Comprehensive ship validation
hyperdrive_sb3_status      -- CAF framework status
hyperdrive_sb3_resources   -- Resource availability check
```

#### SB3 Configuration Options
```lua
-- Enable/disable SB3 integration
hyperdrive_config_set Spacebuild3 Enabled true

-- CAF framework usage
hyperdrive_config_set Spacebuild3 UseCAFFramework true

-- Life support requirements
hyperdrive_config_set Spacebuild3 RequireLifeSupport true
hyperdrive_config_set Spacebuild3 RequirePower true

-- Resource distribution
hyperdrive_config_set Spacebuild3 CheckResourceDistribution true
hyperdrive_config_set Spacebuild3 UseRD3System true

-- Environment systems
hyperdrive_config_set Spacebuild3 CheckEnvironmentSystems true
hyperdrive_config_set Spacebuild3 OverrideGravity true
```

## Carter Addon Pack (CAP) Integration

### Overview
Advanced integration with Carter Addon Pack (CAP) Stargate systems, based on the official CAP repository (https://github.com/RafaelDeJongh/cap), providing:
- **Stargate Network Integration** - Use Stargate addresses for navigation destinations
- **Shield System Respect** - Proper interaction with CAP shield systems
- **Energy System Integration** - Share energy between hyperdrive and Stargate systems
- **Conflict Prevention** - Prevent interference with active Stargate operations
- **Transportation Compatibility** - Integration with rings and transporters

### CAP Entity Support
Based on the official CAP repository, the system supports:

**Stargate Systems:**
- `stargate_atlantis` - Atlantis-style stargates
- `stargate_milkyway` - Milky Way stargates
- `stargate_universe` - Universe stargates
- `stargate_supergate` - Supergate systems

**Shield Systems:**
- `shield` - Basic shield generators
- `shield_core_*` - Advanced shield cores (Goa'uld, Asgard, Atlantis)

**Energy Systems:**
- `zpm` - Zero Point Modules
- `naquadah_generator` - Naquadah generators
- `potentia` - Ancient power sources

**Transportation:**
- `rings_*` - Ring transporters (Ancient, Goa'uld, Ori)
- `transporter` - Asgard transporters

### CAP Validation Commands
```lua
hyperdrive_cap_validate      -- Comprehensive CAP compatibility check
hyperdrive_cap_status        -- CAP framework status
hyperdrive_cap_destinations  -- Available Stargate destinations
```

### CAP Configuration Options
```lua
-- Enable/disable CAP integration
hyperdrive_config_set CAP Enabled true

-- Stargate network integration
hyperdrive_config_set CAP UseStargateNetwork true
hyperdrive_config_set CAP UseStargateAddresses true

-- Shield system integration
hyperdrive_config_set CAP RespectShields true
hyperdrive_config_set CAP UseStargateProtection true

-- Energy system integration
hyperdrive_config_set CAP ShareEnergyWithStargates true
hyperdrive_config_set CAP RequireStargateEnergy false

-- Conflict prevention
hyperdrive_config_set CAP PreventConflicts true
hyperdrive_config_set CAP CheckStargateStatus true
```

### Fallback Support
- **Non-SC2/SB3**: Works on any gamemode with fallback methods
- **Partial Integration**: Gracefully handles missing components
- **Configuration**: Can disable specific features if not needed

## Performance Benefits

### Network Optimization
- **Reduced Packets**: Batch movement reduces network traffic
- **Optimized Methods**: Uses gamemode-specific optimized functions
- **Velocity Clearing**: Prevents physics calculation overhead

### Entity Detection
- **Accurate Lists**: Ship core provides complete entity lists
- **Reduced Searches**: Eliminates need for large sphere searches
- **Smart Filtering**: Only includes relevant entities

### Memory Usage
- **Efficient Storage**: Minimal memory overhead
- **Cleanup**: Proper cleanup of temporary data
- **Caching**: Caches frequently accessed data

## Troubleshooting

### Common Issues
1. **Entities Not Moving**: Check if ship core is properly connected
2. **Gravity Issues**: Verify gravity override is enabled in config
3. **Performance Problems**: Ensure optimized movement is enabled
4. **Detection Failures**: Check search radius settings

### Debug Commands
```lua
-- Enable debug logging
hyperdrive_config_set Debug LogSC2Integration true
hyperdrive_config_set Debug LogMovement true
hyperdrive_config_set Debug LogEntityDetection true

-- Check integration status
hyperdrive_integration_status
hyperdrive_sc2_status      -- Detailed SC2 integration status

-- View current configuration
hyperdrive_config_show SpaceCombat2

-- Validate ship configuration
hyperdrive_sc2_validate    -- For Space Combat 2 ships
hyperdrive_sb3_validate    -- For Spacebuild 3 ships

-- Run integration tests
hyperdrive_test_all        -- Run all integration tests
hyperdrive_test_single SC2_Detection  -- Run specific test
hyperdrive_test_single GetProtector_Method  -- Test GetProtector functionality
```

### Testing and Validation

#### Comprehensive Testing System
The addon includes a comprehensive testing system to validate all integrations:

```lua
-- Run all integration tests
hyperdrive_test_all

-- Available individual tests:
hyperdrive_test_single SC2_Detection     -- Test SC2 detection
hyperdrive_test_single SB3_Detection     -- Test SB3 detection
hyperdrive_test_single Entity_Detection  -- Test entity detection
hyperdrive_test_single Movement_Systems  -- Test movement systems
hyperdrive_test_single Gravity_Systems   -- Test gravity systems
hyperdrive_test_single Configuration     -- Test config system
```

#### Ship Validation Commands
Validate your ship's configuration for optimal performance:

**Space Combat 2 Ships:**
```lua
hyperdrive_sc2_validate
```
This checks for:
- Ship core presence
- Gyropod connectivity
- Attached entities count
- Ship mass calculation
- Configuration issues

**Spacebuild 3 Ships:**
```lua
hyperdrive_sb3_validate
```
This checks for:
- Ship core presence
- Life support status
- Power/oxygen/coolant levels
- Attached entities count
- Environment detection
- Configuration issues

### Console Output
The system provides detailed console output when developer mode is enabled:
```
developer 1
```

## Advanced Features

### Performance Optimization System
The addon includes a comprehensive performance optimization system:

**Features:**
- Entity caching for improved detection speed
- Batch movement for large ships (reduces network overhead)
- Memory optimization and garbage collection
- Performance profiling and metrics

**Commands:**
```lua
hyperdrive_perf_stats     -- View performance statistics
hyperdrive_perf_clear     -- Clear performance metrics (admin)
```

### Ship Detection and Classification
Advanced ship detection automatically classifies ships and optimizes performance:

**Ship Classes:**
- Fighter (≤10 entities) - 0.8x energy cost
- Corvette (≤25 entities) - 1.0x energy cost
- Frigate (≤50 entities) - 1.2x energy cost
- Destroyer (≤100 entities) - 1.5x energy cost
- Cruiser (≤200 entities) - 2.0x energy cost
- Battleship (≤400 entities) - 3.0x energy cost
- Dreadnought (≤800 entities) - 4.0x energy cost
- Titan (≤1600 entities) - 6.0x energy cost
- Megastructure (>1600 entities) - 10.0x energy cost

**Commands:**
```lua
hyperdrive_ship_analyze    -- Detailed ship analysis
hyperdrive_ship_classify   -- Quick ship classification
```

### Enhanced User Interface
Advanced UI system for ship management:

**Features:**
- Real-time ship status monitoring
- Performance metrics display
- Integration status indicators
- Command logging and history
- Ship diagnostics interface

**Usage:**
- Hold **Shift + Use** on hyperdrive engine for advanced UI
- `hyperdrive_ui_open` - Open UI via console
- `hyperdrive_ui_close` - Close UI
- `hyperdrive_ui_status` - View UI status

### Monitoring and Alerting System
Comprehensive monitoring system for fleet management:

**Features:**
- Real-time health monitoring
- Automatic alert generation
- Performance tracking
- Jump failure detection
- System-wide status reporting

**Alert Levels:**
- **Info** - General information
- **Warning** - Non-critical issues
- **Error** - Serious problems
- **Critical** - Immediate attention required

**Commands:**
```lua
hyperdrive_monitoring_status  -- System health overview
hyperdrive_monitoring_alerts  -- View active alerts
```

### Integration Testing Suite
Comprehensive testing system for validation:

**Test Categories:**
- Gamemode detection (SC2/SB3)
- Entity detection systems
- Movement optimization
- Gravity override systems
- Configuration management
- GetProtector metamethod functionality

**Commands:**
```lua
hyperdrive_test_all           -- Run all tests
hyperdrive_test_single <test> -- Run specific test
```

### Network Optimization System
Advanced networking for large ship movements:

**Features:**
- Priority-based entity updates
- Delta compression for reduced bandwidth
- Adaptive batch sizing based on network load
- Client-side prediction support
- Bandwidth throttling and queue management

**Commands:**
```lua
hyperdrive_network_stats      -- View network statistics
hyperdrive_network_reset      -- Reset network state (admin)
```

### Error Recovery System
Comprehensive error handling and automatic recovery:

**Features:**
- Automatic state backup before operations
- Intelligent retry mechanisms with exponential backoff
- Detailed error logging with stack traces
- Admin notification for critical errors
- Automatic recovery from common failure scenarios

**Commands:**
```lua
hyperdrive_error_stats        -- View error statistics
hyperdrive_error_log [count]  -- View recent errors (admin)
```

### Admin Panel System
Comprehensive administration interface:

**Features:**
- Real-time system monitoring
- Emergency stop capabilities
- Remote engine control
- Mass operations support
- System override controls
- Detailed action logging

**Commands:**
```lua
hyperdrive_admin_panel        -- Open admin panel
hyperdrive_admin_emergency_stop -- Emergency stop all engines
hyperdrive_admin_status       -- System overview
hyperdrive_admin_log [count]  -- View admin action log
```

## Performance Benefits

### Network Optimization
- **Batch Movement**: Groups entity updates to reduce network packets
- **Optimized Methods**: Uses gamemode-specific optimized functions
- **Smart Caching**: Reduces redundant entity searches
- **Velocity Management**: Prevents physics calculation overhead

### Memory Management
- **Entity Caching**: Intelligent caching with automatic cleanup
- **Garbage Collection**: Automatic memory optimization
- **Resource Monitoring**: Tracks and optimizes memory usage

### CPU Optimization
- **Efficient Detection**: Ship core-based detection vs. sphere searches
- **Performance Profiling**: Identifies and optimizes bottlenecks
- **Adaptive Strategies**: Automatically selects best movement method

## Credits

This integration was developed based on feedback from the Space Combat 2 developer, addressing specific issues with:
- Entity detection using ship cores
- Gyropod integration for optimized movement
- Gravity override systems for SC2/SB3 compatibility
- Network optimization for large ship movements

The implementation follows SC2's optimized movement patterns and integrates seamlessly with both SC2 and SB3 systems while maintaining backward compatibility with other gamemodes.

**Additional Features:**
- Advanced ship classification and optimization
- Comprehensive performance monitoring
- Real-time health checking and alerting
- Enhanced user interface for ship management
- Extensive testing and validation framework

## Additional Documentation

### SC2 Compatibility Reference
For detailed information about Space Combat 2 integration, including all available methods, metamethods, and best practices, see:
**[SC2_COMPATIBILITY_REFERENCE.md](SC2_COMPATIBILITY_REFERENCE.md)**

This comprehensive reference covers:
- Complete GetProtector() metamethod documentation
- All SC2 entity classes and their methods
- Integration patterns and best practices
- Capability detection and runtime checks
- Common issues and solutions
- Version compatibility information
