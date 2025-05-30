# Enhanced Hyperdrive System v2.1.0 - API Reference

This document provides comprehensive API documentation for developers working with the Enhanced Hyperdrive System with modern UI framework and CAP integration.

## 🏗️ Core Architecture

### Global Namespace
All hyperdrive functionality is contained within the `HYPERDRIVE` global table:

```lua
HYPERDRIVE = {
    Version = "2.1.0",
    Core = {},           -- Core hyperdrive functionality
    ShipCore = {},       -- Ship core management
    CAP = {},           -- CAP (Carter Addon Pack) integration
    Shields = {},       -- Advanced shield systems
    HullDamage = {},    -- Hull damage system
    SB3Resources = {}, -- Spacebuild 3 integration
    Wire = {},          -- Wiremod integration
    Config = {},        -- Configuration system
    Effects = {},       -- Visual effects
    UI = {},            -- Modern UI framework
    Stargate = {},      -- 4-stage Stargate hyperdrive
    Performance = {},   -- Performance optimization
    SystemStatus = {}   -- System status tracking
}
```

## 🎨 Modern UI Framework API

### UI Theme System
The modern UI framework provides a comprehensive theming system:

```lua
-- Access theme colors
local color = HYPERDRIVE.UI.GetColor("Primary", 200) -- Color with custom alpha
local font = HYPERDRIVE.UI.GetFont("Title")
local spacing = HYPERDRIVE.UI.GetSpacing("Medium")

-- Draw modern UI components
HYPERDRIVE.UI.DrawModernPanel(x, y, w, h, "Primary", 12)
HYPERDRIVE.UI.DrawModernButton(x, y, w, h, "Click Me", isHovered, isPressed, "Accent")
HYPERDRIVE.UI.DrawProgressBar(x, y, w, h, value, maxValue, "Success", true)
HYPERDRIVE.UI.DrawNotification(x, y, w, h, "Message", "info", 255)
```

### Animation System
Create smooth animations for UI elements:

```lua
-- Create animation
HYPERDRIVE.UI.CreateAnimation("fadeIn", 0, 255, 0.5, HYPERDRIVE.UI.Theme.Animation.Easing.EaseOut)

-- Get current animation value
local alpha = HYPERDRIVE.UI.GetAnimationValue("fadeIn")

-- Update animations (called automatically)
HYPERDRIVE.UI.UpdateAnimations()
```

### Entity Selector Interface
Open the modern entity selector:

```lua
-- Open entity selector with callback
HYPERDRIVE.EntitySelector.Open(function(selectedEntity)
    print("Selected: " .. selectedEntity:GetClass())
end)

-- Close entity selector
HYPERDRIVE.EntitySelector.Close()
```

## 🚢 Ship Core API

### Core Management Functions

#### `HYPERDRIVE.ShipCore.RegisterCore(core)`
Registers a ship core entity with the system.
- **Parameters**: `core` (Entity) - Ship core entity
- **Returns**: `boolean` - Success status

#### `HYPERDRIVE.ShipCore.GetShipByCore(core)`
Retrieves ship object associated with a core.
- **Parameters**: `core` (Entity) - Ship core entity
- **Returns**: `table` - Ship object or nil

#### `HYPERDRIVE.ShipCore.GetShipByEntity(entity)`
Finds ship containing the specified entity.
- **Parameters**: `entity` (Entity) - Any entity on the ship
- **Returns**: `table` - Ship object or nil

#### `HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness(core)`
Ensures only one core exists per ship.
- **Parameters**: `core` (Entity) - Ship core to validate
- **Returns**: `boolean, string` - Valid status and message

### Ship Object Methods

#### `ship:GetEntities()`
Returns all entities belonging to the ship.
- **Returns**: `table` - Array of entities

#### `ship:GetPlayers()`
Returns all players currently on the ship.
- **Returns**: `table` - Array of player entities

#### `ship:GetCenter()`
Calculates the geometric center of the ship.
- **Returns**: `Vector` - Center position

#### `ship:GetMass()`
Calculates total mass of all ship entities.
- **Returns**: `number` - Total mass

#### `ship:GetShipType()`
Determines ship classification based on size and composition.
- **Returns**: `string` - Ship type ("Small", "Medium", "Large", "Capital")

## 🚀 Hyperdrive Engine API

### Engine Control Functions

#### `engine:StartCharging()`
Initiates hyperdrive charging sequence.
- **Returns**: `boolean, string` - Success status and message

#### `engine:StartJump()`
Begins hyperdrive jump to destination.
- **Returns**: `boolean, string` - Success status and message

#### `engine:AbortJump(reason)`
Cancels current hyperdrive operation.
- **Parameters**: `reason` (string) - Reason for abort
- **Returns**: `boolean` - Success status

#### `engine:SetDestinationPos(pos)`
Sets jump destination coordinates.
- **Parameters**: `pos` (Vector) - Destination position
- **Returns**: `boolean` - Success status

#### `engine:CanJump()`
Checks if engine is ready for hyperdrive jump.
- **Returns**: `boolean` - Ready status

### Engine State Functions

#### `engine:GetEnergy()`
Returns current energy level.
- **Returns**: `number` - Energy amount

#### `engine:GetEnergyPercent()`
Returns energy as percentage of maximum.
- **Returns**: `number` - Percentage (0-100)

#### `engine:GetCharging()`
Returns charging status.
- **Returns**: `boolean` - Is charging

#### `engine:GetJumpReady()`
Returns jump ready status.
- **Returns**: `boolean` - Ready to jump

#### `engine:GetCooldownRemaining()`
Returns remaining cooldown time.
- **Returns**: `number` - Seconds remaining

## 🛡️ CAP Integration API

### CAP Detection Functions

#### `HYPERDRIVE.CAP.Available`
Boolean indicating if CAP is installed and available.

#### `HYPERDRIVE.CAP.Detection.version`
String containing detected CAP version.

#### `HYPERDRIVE.CAP.GetEntityCategory(class)`
Determines if entity class belongs to CAP.
- **Parameters**: `class` (string) - Entity class name
- **Returns**: `string` - CAP category or nil

### CAP Shield Integration

#### `HYPERDRIVE.CAP.Shields.FindShields(ship)`
Locates all CAP shields on a ship.
- **Parameters**: `ship` (table) - Ship object
- **Returns**: `table` - Array of shield entities

#### `HYPERDRIVE.CAP.Shields.GetStatus(core, ship)`
Retrieves comprehensive shield status.
- **Parameters**:
  - `core` (Entity) - Ship core
  - `ship` (table) - Ship object
- **Returns**: `table` - Shield status information

#### `HYPERDRIVE.CAP.Shields.ActivateForHyperdrive(core, ship, mode)`
Activates CAP shields for hyperdrive operation.
- **Parameters**:
  - `core` (Entity) - Ship core
  - `ship` (table) - Ship object
  - `mode` (string) - Activation mode
- **Returns**: `boolean` - Success status

### CAP Energy Integration

#### `HYPERDRIVE.CAP.Resources.FindEnergySources(ship)`
Locates all CAP energy sources on ship.
- **Parameters**: `ship` (table) - Ship object
- **Returns**: `table` - Array of energy entities

#### `HYPERDRIVE.CAP.Resources.GetTotalEnergy(ship)`
Calculates total available CAP energy.
- **Parameters**: `ship` (table) - Ship object
- **Returns**: `number` - Total energy amount

#### `HYPERDRIVE.CAP.Resources.ConsumeEnergy(ship, amount)`
Consumes energy from CAP sources.
- **Parameters**:
  - `ship` (table) - Ship object
  - `amount` (number) - Energy to consume
- **Returns**: `boolean` - Success status

## 🛡️ Shield System API

### Shield Management

#### `HYPERDRIVE.Shields.CreateShield(core, ship)`
Creates shield system for ship.
- **Parameters**:
  - `core` (Entity) - Ship core
  - `ship` (table) - Ship object
- **Returns**: `table, string` - Shield object and message

#### `HYPERDRIVE.Shields.GetShieldStatus(core)`
Retrieves current shield status.
- **Parameters**: `core` (Entity) - Ship core
- **Returns**: `table` - Shield status data

#### `HYPERDRIVE.Shields.ActivateShield(core, ship)`
Activates ship shields.
- **Parameters**:
  - `core` (Entity) - Ship core
  - `ship` (table) - Ship object
- **Returns**: `boolean` - Success status

#### `HYPERDRIVE.Shields.DeactivateShield(core)`
Deactivates ship shields.
- **Parameters**: `core` (Entity) - Ship core
- **Returns**: `boolean` - Success status

## 🔧 Hull Damage API

### Hull Management

#### `HYPERDRIVE.HullDamage.CreateHullSystem(ship, core)`
Initializes hull damage system for ship.
- **Parameters**:
  - `ship` (table) - Ship object
  - `core` (Entity) - Ship core
- **Returns**: `table, string` - Hull system and message

#### `HYPERDRIVE.HullDamage.GetHullStatus(core)`
Retrieves current hull status.
- **Parameters**: `core` (Entity) - Ship core
- **Returns**: `table` - Hull status data

#### `HYPERDRIVE.HullDamage.DamageHull(core, amount, source)`
Applies damage to ship hull.
- **Parameters**:
  - `core` (Entity) - Ship core
  - `amount` (number) - Damage amount
  - `source` (string) - Damage source
- **Returns**: `boolean` - Success status

#### `HYPERDRIVE.HullDamage.RepairHull(core, amount)`
Repairs ship hull damage.
- **Parameters**:
  - `core` (Entity) - Ship core
  - `amount` (number) - Repair amount
- **Returns**: `boolean` - Success status

## 📦 Resource System API

### Spacebuild 3 Integration

#### `HYPERDRIVE.SB3Resources.InitializeCoreStorage(core)`
Sets up resource storage for ship core.
- **Parameters**: `core` (Entity) - Ship core
- **Returns**: `boolean` - Success status

#### `HYPERDRIVE.SB3Resources.GetCoreStorage(core)`
Retrieves core resource storage data.
- **Parameters**: `core` (Entity) - Ship core
- **Returns**: `table` - Storage information

#### `HYPERDRIVE.SB3Resources.GetResourceAmount(core, type)`
Gets amount of specific resource.
- **Parameters**:
  - `core` (Entity) - Ship core
  - `type` (string) - Resource type
- **Returns**: `number` - Resource amount

#### `HYPERDRIVE.SB3Resources.ConsumeResource(core, type, amount)`
Consumes specified amount of resource.
- **Parameters**:
  - `core` (Entity) - Ship core
  - `type` (string) - Resource type
  - `amount` (number) - Amount to consume
- **Returns**: `boolean` - Success status

#### `HYPERDRIVE.SB3Resources.DistributeResources(core)`
Distributes resources to ship entities.
- **Parameters**: `core` (Entity) - Ship core
- **Returns**: `boolean` - Success status

## 🔌 Wiremod Integration API

### Wire Functions

#### `HYPERDRIVE.Wire.Initialize(entity)`
Sets up Wiremod support for entity.
- **Parameters**: `entity` (Entity) - Entity to initialize
- **Returns**: `boolean` - Success status

#### `HYPERDRIVE.Wire.TriggerInput(entity, name, value)`
Handles wire input trigger.
- **Parameters**:
  - `entity` (Entity) - Target entity
  - `name` (string) - Input name
  - `value` (any) - Input value

#### `HYPERDRIVE.Wire.UpdateOutputs(entity)`
Updates all wire outputs for entity.
- **Parameters**: `entity` (Entity) - Entity to update

### Wire Definitions

Wire input/output definitions are stored in `HYPERDRIVE.Wire.Definitions[class]`:

```lua
HYPERDRIVE.Wire.Definitions = {
    hyperdrive_engine = {
        inputs = {"Jump [NORMAL]", "SetDestination [VECTOR]", ...},
        outputs = {"Energy [NORMAL]", "Charging [NORMAL]", ...}
    },
    ship_core = {
        inputs = {"SetShipName [STRING]", "RepairHull [NORMAL]", ...},
        outputs = {"CoreState [NORMAL]", "HullIntegrity [NORMAL]", ...}
    }
}
```

## ⚙️ Configuration API

### Configuration Management

#### `HYPERDRIVE.EnhancedConfig.Get(category, key)`
Retrieves configuration value.
- **Parameters**:
  - `category` (string) - Configuration category
  - `key` (string) - Configuration key
- **Returns**: `any` - Configuration value

#### `HYPERDRIVE.EnhancedConfig.Set(category, key, value)`
Sets configuration value.
- **Parameters**:
  - `category` (string) - Configuration category
  - `key` (string) - Configuration key
  - `value` (any) - New value

#### `HYPERDRIVE.EnhancedConfig.RegisterIntegration(name, data)`
Registers addon integration.
- **Parameters**:
  - `name` (string) - Integration name
  - `data` (table) - Integration data

## 🎨 Effects API

### Visual Effects

#### `HYPERDRIVE.Effects.CreateJumpEffect(entity, destination)`
Creates hyperdrive jump visual effect.
- **Parameters**:
  - `entity` (Entity) - Source entity
  - `destination` (Vector) - Jump destination

#### `HYPERDRIVE.Effects.CreateChargeEffect(entity)`
Creates hyperdrive charging effect.
- **Parameters**: `entity` (Entity) - Charging entity

#### `HYPERDRIVE.Effects.CreateStargateEffect(entity, stage)`
Creates Stargate-style hyperdrive effect.
- **Parameters**:
  - `entity` (Entity) - Source entity
  - `stage` (string) - Effect stage ("charge", "window", "travel", "exit")

## 🔍 Event Hooks

### Custom Hooks

The system provides several custom hooks for integration:

#### `HyperdriveJumpStart`
Called when hyperdrive jump begins.
- **Parameters**: `entity, destination, ship`

#### `HyperdriveJumpComplete`
Called when hyperdrive jump completes.
- **Parameters**: `entity, destination, ship`

#### `HyperdriveChargeStart`
Called when hyperdrive charging begins.
- **Parameters**: `entity, ship`

#### `ShipCoreRegistered`
Called when ship core is registered.
- **Parameters**: `core, ship`

#### `CAPIntegrationEnabled`
Called when CAP integration activates.
- **Parameters**: `core, capData`

## 📝 Usage Examples

### Basic Hyperdrive Control
```lua
-- Get hyperdrive engine
local engine = ents.FindByClass("hyperdrive_engine")[1]

-- Set destination and jump
engine:SetDestinationPos(Vector(1000, 0, 0))
if engine:CanJump() then
    engine:StartJump()
end
```

### Ship Core Management
```lua
-- Get ship core
local core = ents.FindByClass("ship_core")[1]

-- Get ship information
local ship = HYPERDRIVE.ShipCore.GetShipByCore(core)
if ship then
    print("Ship has " .. #ship:GetEntities() .. " entities")
    print("Ship center: " .. tostring(ship:GetCenter()))
end
```

### CAP Integration Check
```lua
-- Check if CAP is available
if HYPERDRIVE.CAP.Available then
    print("CAP version: " .. HYPERDRIVE.CAP.Detection.version)

    -- Find CAP shields on ship
    local shields = HYPERDRIVE.CAP.Shields.FindShields(ship)
    print("Found " .. #shields .. " CAP shields")
end
```

This API reference provides the foundation for developing with the Enhanced Hyperdrive System. For additional examples and advanced usage, refer to the source code and community resources.
