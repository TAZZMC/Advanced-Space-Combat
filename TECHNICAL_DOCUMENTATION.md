# Hyperdrive System - Technical Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Core Systems](#core-systems)
3. [Entity Reference](#entity-reference)
4. [Integration Systems](#integration-systems)
5. [Effect Systems](#effect-systems)
6. [Network Protocol](#network-protocol)
7. [Configuration System](#configuration-system)
8. [Performance Optimization](#performance-optimization)
9. [Security Implementation](#security-implementation)
10. [API Reference](#api-reference)

## Architecture Overview

The Hyperdrive System follows a modular architecture with clear separation of concerns:

```
HYPERDRIVE (Global Namespace)
├── Core (Core functionality)
├── Master (Unified system management)
├── SpaceCombat2 (SC2 integration)
├── Spacebuild (SB3 integration)
├── CAP (Carter Addon Pack integration)
├── Stargate (Stargate systems)
├── Wire (Wiremod integration)
├── Effects (Visual effects)
├── Security (Access control)
├── Performance (Optimization)
└── EnhancedConfig (Configuration management)
```

### Key Design Principles
- **Modular Design**: Each integration is self-contained
- **Graceful Degradation**: System works without optional dependencies
- **Performance First**: Optimized for large-scale operations
- **Extensibility**: Easy to add new integrations and features

## Core Systems

### 1. Hyperdrive Core (`hyperdrive_core_v2.lua`)

The core system provides fundamental hyperdrive functionality:

```lua
HYPERDRIVE.Core.Config = {
    MaxActiveEngines = 100,
    UpdateRate = 0.1,
    EffectQuality = 1.0,
    NetworkOptimization = true,
    RelativisticEffects = true,
    GravitationalLensing = true,
    QuantumTunneling = false
}
```

**Key Functions:**
- `HYPERDRIVE.Core.CalculateDistance(pos1, pos2, velocity)` - Relativistic distance calculation
- `HYPERDRIVE.Core.ValidateDestination(pos)` - Destination safety checks
- `HYPERDRIVE.Core.CalculateEnergyCost(distance)` - Energy requirement calculation

### 2. Master System (`hyperdrive_master.lua`)

Unified management system that coordinates all subsystems:

```lua
HYPERDRIVE.Master.Config = {
    EnableCore = true,
    EnableAdvancedEffects = true,
    EnableSounds = true,
    EnableWiremod = true,
    EnableSpacebuild = true,
    EnableStargate = true,
    MaxActiveEngines = 50,
    EffectQuality = 1.0,
    NetworkUpdateRate = 0.5
}
```

**Key Functions:**
- `HYPERDRIVE.Master.ClassifyEntity(ent)` - Entity classification and capability detection
- `HYPERDRIVE.Master.CalculateEnergyCost(ent, startPos, endPos)` - Unified energy calculation
- `HYPERDRIVE.Master.GetFleetStatus(computer)` - Fleet management status
- `HYPERDRIVE.Master.GetSystemStatus()` - Overall system health

### 3. Ship Detection (`hyperdrive_ship_detection.lua`)

Intelligent ship detection and classification system:

```lua
-- Ship Types
HYPERDRIVE.ShipDetection.ShipTypes = {
    fighter = { energyMultiplier = 0.8, name = "Fighter" },
    corvette = { energyMultiplier = 1.0, name = "Corvette" },
    frigate = { energyMultiplier = 1.2, name = "Frigate" },
    destroyer = { energyMultiplier = 1.5, name = "Destroyer" },
    cruiser = { energyMultiplier = 2.0, name = "Cruiser" },
    battleship = { energyMultiplier = 3.0, name = "Battleship" },
    dreadnought = { energyMultiplier = 5.0, name = "Dreadnought" },
    station = { energyMultiplier = 10.0, name = "Space Station" }
}
```

## Entity Reference

### Engines

#### 1. Hyperdrive Engine (`hyperdrive_engine`)
**Purpose**: Standard FTL propulsion system
**Features**: Basic hyperdrive functionality with energy management

**Network Variables:**
- `Energy` (Float): Current energy level
- `Charging` (Bool): Charging state
- `Cooldown` (Float): Cooldown timer
- `Destination` (Vector): Target coordinates
- `JumpReady` (Bool): Ready to jump state

#### 2. Hyperdrive SB Engine (`hyperdrive_sb_engine`)
**Purpose**: Spacebuild 3 integrated engine
**Features**: Resource consumption, life support integration

**Additional Network Variables:**
- `PowerLevel` (Float): SB3 power consumption
- `OxygenLevel` (Float): Oxygen requirements
- `CoolantLevel` (Float): Coolant system status
- `Temperature` (Float): Engine temperature

#### 3. Hyperdrive SG Engine (`hyperdrive_sg_engine`)
**Purpose**: Stargate technology engine
**Features**: Stargate network integration, address-based navigation

**Additional Network Variables:**
- `TechLevel` (String): Stargate technology level
- `NaquadahLevel` (Float): Naquadah fuel level
- `ZPMPower` (Float): ZPM power level
- `GateAddress` (String): Stargate address

#### 4. Hyperdrive Master Engine (`hyperdrive_master_engine`)
**Purpose**: Advanced multi-system engine
**Features**: All integration systems combined

**Integration Data:**
```lua
self.IntegrationData = {
    wiremod = {active = false, inputs = 0, outputs = 0},
    spacebuild = {active = false, resources = {}, lifesupport = false},
    stargate = {active = false, techLevel = "tau_ri", hasGate = false}
}
```

### Control Systems

#### 1. Hyperdrive Computer (`hyperdrive_computer`)
**Purpose**: User-friendly control interface
**Features**: Automatic engine detection, waypoint management, fleet coordination

**Key Properties:**
- `LinkedEngines`: Array of connected engines
- `SavedWaypoints`: Stored navigation points
- `LocationHistory`: Travel history
- `DetectedPlanets`: Nearby celestial bodies
- `JumpQueue`: Queued jump operations

#### 2. Hyperdrive Wire Controller (`hyperdrive_wire_controller`)
**Purpose**: Wiremod automation controller
**Features**: Advanced wire I/O, automated operations

#### 3. Hyperdrive Beacon (`hyperdrive_beacon`)
**Purpose**: Navigation waypoint system
**Features**: Network-based navigation, efficiency bonuses

## Integration Systems

### SpaceCombat2 Integration

**File**: `hyperdrive_spacecombat2.lua`

**Key Features:**
- Ship core entity detection using `entity:GetProtector()`
- Gyropod movement integration
- Gravity override during hyperspace travel
- Optimized SetPos/SetAngles methods

**Configuration:**
```lua
HYPERDRIVE.EnhancedConfig.SpaceCombat2 = {
    Enabled = true,
    UseGyropodMovement = true,
    UseShipCore = true,
    OverrideGravity = true,
    OptimizedMovement = true,
    GyropodSearchRadius = 2000,
    ShipCoreSearchRadius = 1500,
    GravityOverrideDuration = 5
}
```

**Key Functions:**
- `HYPERDRIVE.SpaceCombat2.GetAttachedEntities(engine)` - Get ship entities via core
- `HYPERDRIVE.SpaceCombat2.EnhancedEntityDetection(engine, radius)` - Advanced detection
- `HYPERDRIVE.SpaceCombat2.OverrideGravity(player, override)` - Gravity control

### Spacebuild 3 Integration

**File**: `hyperdrive_spacebuild.lua`

**Key Features:**
- Resource consumption (power, oxygen, coolant)
- Life support system integration
- Environmental hazard protection
- Advanced ship classification

**Resource Requirements:**
```lua
HYPERDRIVE.Spacebuild.ResourceRequirements = {
    power = 100,        -- Power per jump
    oxygen = 50,        -- Oxygen consumption
    coolant = 25,       -- Coolant usage
    nitrogen = 10,      -- Nitrogen for life support
    hydrogen = 5        -- Hydrogen fuel
}
```

### Wiremod Integration

**File**: `hyperdrive_wiremod.lua`

**Wire Definitions:**
```lua
HYPERDRIVE.Wire.Definitions = {
    hyperdrive_engine = {
        inputs = {
            "Jump [NORMAL]",
            "SetDestinationX [NORMAL]",
            "SetDestinationY [NORMAL]", 
            "SetDestinationZ [NORMAL]",
            "SetDestination [VECTOR]",
            "Abort [NORMAL]",
            "SetEnergy [NORMAL]",
            "AttachVehicle [ENTITY]"
        },
        outputs = {
            "Energy [NORMAL]",
            "EnergyPercent [NORMAL]",
            "Charging [NORMAL]",
            "Cooldown [NORMAL]",
            "JumpReady [NORMAL]",
            "Destination [VECTOR]",
            "AttachedVehicle [ENTITY]",
            "Status [STRING]"
        }
    }
}
```

### CAP Integration

**File**: `hyperdrive_cap_integration.lua`

**Key Features:**
- Stargate network compatibility
- Shield system respect
- Energy sharing with Stargates
- Address-based navigation

**Entity Detection:**
```lua
local categorizedEntities = {
    stargates = {},
    shields = {},
    dhds = {},
    energySystems = {},
    transportation = {},
    other = {}
}
```

## Effect Systems

### Enhanced Effects V2

**File**: `autorun/client/hyperdrive_effects_v2.lua`

**Effect Configuration:**
```lua
HYPERDRIVE.Effects.Config = {
    ParticleCount = 1.0,
    EffectRange = 2000,
    LODSystem = true,
    QuantumFluctuations = true,
    SpaceTimeDistortion = true,
    EnergyResonance = true,
    GravitationalWaves = true,
    MaxActiveEffects = 20,
    EffectCulling = true,
    DynamicQuality = true
}
```

**Effect Types:**
- `hyperdrive_charge` - Engine charging effects
- `hyperdrive_jump` - Jump portal creation
- `hyperdrive_sg_charge` - Stargate charging
- `hyperdrive_sg_window` - Hyperspace window
- `hyperdrive_sg_starlines` - Hyperspace travel
- `hyperdrive_sg_jump` - Stargate exit

### Stargate 4-Stage Travel System

**File**: `hyperdrive_stargate.lua`

**Travel Stages:**
```lua
HYPERDRIVE.Stargate.TravelStages = {
    INITIATION = 1,           -- Energy buildup, coordinate calculation
    WINDOW_OPENING = 2,       -- Blue/purple swirling energy tunnel
    HYPERSPACE_TRAVEL = 3,    -- Stretched starlines, dimensional visuals
    EXIT_STABILIZATION = 4    -- Light flash, system stabilization
}
```

**Stage Configuration:**
```lua
HYPERDRIVE.Stargate.Config.StageSystem = {
    EnableFourStageTravel = true,
    InitiationDuration = 3.0,
    WindowOpeningDuration = 2.0,
    HyperspaceTravelDuration = 5.0,
    ExitStabilizationDuration = 2.0,
    VisualIntensity = 1.0,
    AudioEnabled = true,
    ParticleComplexity = 1.5
}
```

## Network Protocol

### Network Strings

**File**: `hyperdrive_network_strings.lua`

**Core Messages:**
- `hyperdrive_jump_start` - Jump initiation
- `hyperdrive_jump_complete` - Jump completion
- `hyperdrive_effect` - Visual effect triggers
- `hyperdrive_status_update` - Status synchronization
- `hyperdrive_hyperspace_enter` - Hyperspace entry
- `hyperdrive_hyperspace_exit` - Hyperspace exit

**Stargate Messages:**
- `hyperdrive_sg_stage_update` - 4-stage travel updates
- `hyperdrive_sg_window_open` - Window opening
- `hyperdrive_sg_starlines` - Hyperspace visuals
- `hyperdrive_sg_exit_flash` - Exit effects

### Data Optimization

**Compression Techniques:**
- Vector quantization for positions
- Bit packing for boolean flags
- Delta compression for status updates
- Selective updates based on relevance

## Configuration System

### Enhanced Configuration

**File**: `hyperdrive_config_enhanced.lua`

**Configuration Categories:**
```lua
HYPERDRIVE.EnhancedConfig = {
    SpaceCombat2 = { ... },
    Spacebuild3 = { ... },
    Wiremod = { ... },
    Stargate = { ... },
    CAP = { ... },
    Performance = { ... },
    Security = { ... },
    Effects = { ... },
    Audio = { ... },
    Network = { ... }
}
```

**Dynamic Configuration:**
- Runtime configuration changes
- Integration-specific settings
- Performance auto-adjustment
- User preference storage

## Performance Optimization

### Optimization Engine

**File**: `hyperdrive_optimization_engine.lua`

**Key Features:**
- Dynamic LOD system
- Effect culling based on distance
- Selective entity updates
- Network traffic optimization
- Memory management

**Performance Metrics:**
```lua
HYPERDRIVE.Performance.Metrics = {
    activeEngines = 0,
    activeEffects = 0,
    networkTraffic = 0,
    memoryUsage = 0,
    frameTime = 0,
    entityCount = 0
}
```

### Optimization Strategies

1. **Level of Detail (LOD)**
   - Distance-based effect quality
   - Particle count scaling
   - Update frequency adjustment

2. **Effect Culling**
   - Frustum culling for effects
   - Occlusion-based hiding
   - Maximum effect limits

3. **Network Optimization**
   - Delta compression
   - Relevance filtering
   - Batch updates

4. **Memory Management**
   - Object pooling for effects
   - Garbage collection optimization
   - Resource cleanup

## Security Implementation

### Security System

**File**: `hyperdrive_security.lua`

**Access Control:**
```lua
HYPERDRIVE.Security.AccessLevels = {
    OWNER = 4,      -- Full control
    ADMIN = 3,      -- Administrative access
    TRUSTED = 2,    -- Trusted user
    USER = 1,       -- Basic user
    GUEST = 0       -- Read-only
}
```

**Anti-Griefing Measures:**
- Destination validation
- Entity ownership checks
- Rate limiting
- Audit logging
- Emergency shutdown

**Security Features:**
- Owner-based permissions
- Admin override capabilities
- Blacklist/whitelist support
- Automatic threat detection
- Recovery mechanisms

## API Reference

### Core API Functions

```lua
-- Entity Management
HYPERDRIVE.GetNearbyEntities(pos, radius, filter)
HYPERDRIVE.ClassifyEntity(entity)
HYPERDRIVE.ValidateEntity(entity)

-- Navigation
HYPERDRIVE.CalculateDistance(pos1, pos2)
HYPERDRIVE.CalculateEnergyCost(distance)
HYPERDRIVE.ValidateDestination(pos)
HYPERDRIVE.FindOptimalRoute(start, end, waypoints)

-- Effects
HYPERDRIVE.Effects.CreateEffect(pos, type, intensity, data)
HYPERDRIVE.Effects.RegisterEffect(id, pos, type, duration)
HYPERDRIVE.Effects.UpdateEffects()

-- Integration
HYPERDRIVE.RegisterIntegration(name, config)
HYPERDRIVE.CheckIntegration(name)
HYPERDRIVE.EnableIntegration(name, enabled)

-- Security
HYPERDRIVE.Security.CheckAccess(player, entity, action)
HYPERDRIVE.Security.LogAction(player, action, details)
HYPERDRIVE.Security.ValidateOperation(operation)
```

### Event Hooks

```lua
-- Core Events
hook.Add("HyperdriveJumpStart", "YourHook", function(engine, destination) end)
hook.Add("HyperdriveJumpComplete", "YourHook", function(engine, success) end)
hook.Add("HyperdriveEntityDetected", "YourHook", function(engine, entity) end)

-- Integration Events
hook.Add("HyperdriveIntegrationLoaded", "YourHook", function(integration) end)
hook.Add("HyperdriveConfigChanged", "YourHook", function(category, key, value) end)

-- Security Events
hook.Add("HyperdriveAccessDenied", "YourHook", function(player, entity, reason) end)
hook.Add("HyperdriveSecurityAlert", "YourHook", function(alert) end)
```

### Custom Integration Example

```lua
-- Register custom integration
HYPERDRIVE.RegisterIntegration("MyAddon", {
    name = "My Custom Addon",
    version = "1.0.0",
    checkFunction = function()
        return MyAddon ~= nil
    end,
    initFunction = function()
        -- Initialize integration
    end,
    entityHandler = function(entity)
        -- Handle entity detection
    end
})
```

---

This technical documentation provides comprehensive coverage of the Hyperdrive System's architecture, implementation details, and API reference for developers and advanced users.
