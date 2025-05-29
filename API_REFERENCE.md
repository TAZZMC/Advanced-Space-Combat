# Hyperdrive System - API Reference

## Table of Contents
1. [Core API](#core-api)
2. [Entity API](#entity-api)
3. [Integration API](#integration-api)
4. [Effects API](#effects-api)
5. [Security API](#security-api)
6. [Configuration API](#configuration-api)
7. [Event Hooks](#event-hooks)
8. [Wiremod API](#wiremod-api)
9. [Network API](#network-api)
10. [Utility Functions](#utility-functions)

## Core API

### HYPERDRIVE.Core

#### `HYPERDRIVE.Core.CalculateDistance(pos1, pos2, velocity)`
Calculates distance between two points with optional relativistic effects.

**Parameters:**
- `pos1` (Vector): Starting position
- `pos2` (Vector): Ending position  
- `velocity` (Number, optional): Relative velocity for relativistic calculation

**Returns:**
- `Number`: Calculated distance

**Example:**
```lua
local distance = HYPERDRIVE.Core.CalculateDistance(Vector(0,0,0), Vector(1000,0,0))
```

#### `HYPERDRIVE.Core.CalculateEnergyCost(distance)`
Calculates energy cost for a given distance.

**Parameters:**
- `distance` (Number): Travel distance

**Returns:**
- `Number`: Energy cost

#### `HYPERDRIVE.Core.ValidateDestination(pos)`
Validates if a destination is safe for travel.

**Parameters:**
- `pos` (Vector): Destination position

**Returns:**
- `Boolean`: Is destination valid
- `String`: Validation message

### HYPERDRIVE.Master

#### `HYPERDRIVE.Master.ClassifyEntity(ent)`
Classifies an entity and determines its capabilities.

**Parameters:**
- `ent` (Entity): Entity to classify

**Returns:**
- `Table`: Classification data including type, efficiency, integrations

**Example:**
```lua
local classification = HYPERDRIVE.Master.ClassifyEntity(engine)
print("Ship type:", classification.shipType.name)
print("Energy multiplier:", classification.shipType.energyMultiplier)
```

#### `HYPERDRIVE.Master.GetSystemStatus()`
Gets overall system status and health.

**Returns:**
- `Table`: System status including core, integrations, performance

## Entity API

### Engine Entities

#### `engine:SetDestinationPos(pos)`
Sets the destination for the hyperdrive engine.

**Parameters:**
- `pos` (Vector): Destination coordinates

**Returns:**
- `Boolean`: Success status
- `String`: Status message

#### `engine:StartJump()`
Initiates a hyperdrive jump.

**Returns:**
- `Boolean`: Jump initiated successfully
- `String`: Status message

#### `engine:GetEnergy()`
Gets current energy level.

**Returns:**
- `Number`: Current energy (0-1000)

#### `engine:SetEnergy(amount)`
Sets energy level.

**Parameters:**
- `amount` (Number): Energy amount

#### `engine:GetCharging()`
Gets charging status.

**Returns:**
- `Boolean`: Is charging

#### `engine:GetCooldown()`
Gets cooldown timer.

**Returns:**
- `Number`: Cooldown time remaining

### Computer Entities

#### `computer:LinkEngine(engine)`
Links an engine to the computer.

**Parameters:**
- `engine` (Entity): Engine to link

**Returns:**
- `Boolean`: Link successful

#### `computer:ExecuteFleetJump(destination)`
Executes a coordinated fleet jump.

**Parameters:**
- `destination` (Vector): Jump destination

**Returns:**
- `Boolean`: Fleet jump successful
- `String`: Status message

#### `computer:AddWaypoint(name, pos)`
Adds a waypoint to the computer.

**Parameters:**
- `name` (String): Waypoint name
- `pos` (Vector): Waypoint position

#### `computer:GetWaypoints()`
Gets all stored waypoints.

**Returns:**
- `Table`: Array of waypoint data

## Integration API

### SpaceCombat2 Integration

#### `HYPERDRIVE.SpaceCombat2.GetAttachedEntities(engine)`
Gets entities attached via ship core.

**Parameters:**
- `engine` (Entity): Engine entity

**Returns:**
- `Table`: Array of attached entities

#### `HYPERDRIVE.SpaceCombat2.OverrideGravity(player, override)`
Overrides gravity for SC2 players.

**Parameters:**
- `player` (Player): Player entity
- `override` (Boolean): Enable/disable override

### Spacebuild Integration

#### `HYPERDRIVE.Spacebuild.CheckResources(engine, requirements)`
Checks if required resources are available.

**Parameters:**
- `engine` (Entity): Engine entity
- `requirements` (Table): Resource requirements

**Returns:**
- `Boolean`: Resources available
- `Table`: Resource status

#### `HYPERDRIVE.Spacebuild.ConsumeResources(engine, requirements)`
Consumes resources for operation.

**Parameters:**
- `engine` (Entity): Engine entity
- `requirements` (Table): Resources to consume

**Returns:**
- `Boolean`: Consumption successful

### CAP Integration

#### `HYPERDRIVE.CAP.DetectCAPEntities(engine, radius)`
Detects CAP entities in radius.

**Parameters:**
- `engine` (Entity): Engine entity
- `radius` (Number): Search radius

**Returns:**
- `Table`: Categorized CAP entities

#### `HYPERDRIVE.CAP.IsCAP_Loaded()`
Checks if CAP is loaded and functional.

**Returns:**
- `Boolean`: CAP available
- `String`: Status message
- `Table`: CAP capabilities

## Effects API

### HYPERDRIVE.Effects

#### `HYPERDRIVE.Effects.CreateEffect(pos, effectType, intensity, data)`
Creates a visual effect at position.

**Parameters:**
- `pos` (Vector): Effect position
- `effectType` (String): Type of effect
- `intensity` (Number): Effect intensity (0-1)
- `data` (Table, optional): Additional effect data

**Example:**
```lua
HYPERDRIVE.Effects.CreateEffect(engine:GetPos(), "hyperdrive_charge", 1.0, {
    color = Color(0, 100, 255),
    duration = 3.0
})
```

#### `HYPERDRIVE.Effects.RegisterEffect(id, pos, effectType, duration)`
Registers an ongoing effect.

**Parameters:**
- `id` (String): Unique effect ID
- `pos` (Vector): Effect position
- `effectType` (String): Effect type
- `duration` (Number): Effect duration

#### `HYPERDRIVE.Effects.CreateAdvancedParticles(pos, effectType, intensity, data)`
Creates advanced particle effects.

**Parameters:**
- `pos` (Vector): Particle position
- `effectType` (String): Particle type
- `intensity` (Number): Particle intensity
- `data` (Table, optional): Particle configuration

### Stargate Effects

#### `HYPERDRIVE.Stargate.StartFourStageTravel(engine, destination, entities)`
Initiates 4-stage Stargate travel.

**Parameters:**
- `engine` (Entity): Engine entity
- `destination` (Vector): Travel destination
- `entities` (Table): Entities to transport

**Returns:**
- `Boolean`: Travel initiated
- `String`: Status message

## Security API

### HYPERDRIVE.Security

#### `HYPERDRIVE.Security.CheckAccess(player, entity, action)`
Checks if player has access to perform action.

**Parameters:**
- `player` (Player): Player entity
- `entity` (Entity): Target entity
- `action` (String): Action to perform

**Returns:**
- `Boolean`: Access granted
- `String`: Access level or denial reason

#### `HYPERDRIVE.Security.LogAction(player, action, details)`
Logs a security-relevant action.

**Parameters:**
- `player` (Player): Player performing action
- `action` (String): Action performed
- `details` (Table): Additional details

#### `HYPERDRIVE.Security.SetOwner(entity, player)`
Sets entity owner.

**Parameters:**
- `entity` (Entity): Entity to set owner for
- `player` (Player): New owner

## Configuration API

### HYPERDRIVE.EnhancedConfig

#### `HYPERDRIVE.EnhancedConfig.Get(category, key, default)`
Gets configuration value.

**Parameters:**
- `category` (String): Configuration category
- `key` (String): Configuration key
- `default` (Any): Default value if not found

**Returns:**
- `Any`: Configuration value

#### `HYPERDRIVE.EnhancedConfig.Set(category, key, value)`
Sets configuration value.

**Parameters:**
- `category` (String): Configuration category
- `key` (String): Configuration key
- `value` (Any): Value to set

#### `HYPERDRIVE.EnhancedConfig.RegisterIntegration(name, config)`
Registers a new integration.

**Parameters:**
- `name` (String): Integration name
- `config` (Table): Integration configuration

**Example:**
```lua
HYPERDRIVE.EnhancedConfig.RegisterIntegration("MyAddon", {
    name = "My Custom Addon",
    description = "Custom integration",
    version = "1.0.0",
    checkFunction = function() return MyAddon ~= nil end,
    validateFunction = function(ship) return true end,
    configCategories = {"EnableFeature", "FeaturePower"}
})
```

## Event Hooks

### Core Events

#### `HyperdriveJumpStart`
Called when a hyperdrive jump begins.

**Parameters:**
- `engine` (Entity): Engine performing jump
- `destination` (Vector): Jump destination
- `entities` (Table): Entities being transported

#### `HyperdriveJumpComplete`
Called when a hyperdrive jump completes.

**Parameters:**
- `engine` (Entity): Engine that performed jump
- `success` (Boolean): Jump success status
- `message` (String): Status message

#### `HyperdriveEntityDetected`
Called when ship detection finds an entity.

**Parameters:**
- `engine` (Entity): Detecting engine
- `entity` (Entity): Detected entity
- `classification` (Table): Entity classification

### Integration Events

#### `HyperdriveIntegrationLoaded`
Called when an integration is loaded.

**Parameters:**
- `integration` (String): Integration name
- `config` (Table): Integration configuration

#### `HyperdriveConfigChanged`
Called when configuration changes.

**Parameters:**
- `category` (String): Configuration category
- `key` (String): Configuration key
- `value` (Any): New value

### Security Events

#### `HyperdriveAccessDenied`
Called when access is denied.

**Parameters:**
- `player` (Player): Player denied access
- `entity` (Entity): Target entity
- `reason` (String): Denial reason

## Wiremod API

### Wire Inputs

#### Engine Inputs
- `Jump` - Trigger jump (1 = jump, 0 = no action)
- `SetDestinationX/Y/Z` - Set destination coordinates
- `SetDestination` - Set destination vector
- `Abort` - Abort current operation
- `SetEnergy` - Set energy level
- `AttachVehicle` - Attach vehicle entity

#### Computer Inputs
- `FleetJump` - Execute fleet jump
- `SetMode` - Set computer mode (1=Navigation, 2=Planets, 3=Status)
- `PowerToggle` - Toggle power state
- `ScanEngines` - Scan for nearby engines

### Wire Outputs

#### Engine Outputs
- `Energy` - Current energy level
- `EnergyPercent` - Energy as percentage
- `Charging` - Charging state
- `Cooldown` - Cooldown timer
- `JumpReady` - Ready to jump
- `Destination` - Current destination
- `Status` - Status string

#### Computer Outputs
- `Powered` - Power state
- `LinkedEngines` - Number of linked engines
- `OnlineEngines` - Number of online engines
- `FleetStatus` - Fleet status string

## Network API

### Network Messages

#### `hyperdrive_jump_start`
Sent when jump starts.

**Data:**
- Vector: Engine position
- Vector: Destination
- Float: Jump duration

#### `hyperdrive_effect`
Sent for visual effects.

**Data:**
- Vector: Effect position
- String: Effect type
- Float: Intensity
- Table: Effect data

#### `hyperdrive_status_update`
Sent for status updates.

**Data:**
- Entity: Target entity
- Table: Status data

## Utility Functions

### HYPERDRIVE Utilities

#### `HYPERDRIVE.GetDistance(pos1, pos2)`
Simple distance calculation.

#### `HYPERDRIVE.IsValidEntity(ent)`
Checks if entity is valid for hyperdrive operations.

#### `HYPERDRIVE.GetNearbyEntities(pos, radius, filter)`
Gets entities near position with optional filter.

#### `HYPERDRIVE.FormatTime(seconds)`
Formats time for display.

#### `HYPERDRIVE.FormatEnergy(energy)`
Formats energy for display.

#### `HYPERDRIVE.GenerateUniqueID()`
Generates unique identifier.

### Example Usage

```lua
-- Basic engine control
local engine = ents.Create("hyperdrive_engine")
engine:Spawn()
engine:SetDestinationPos(Vector(1000, 0, 0))
engine:SetEnergy(1000)
engine:StartJump()

-- Computer fleet management
local computer = ents.Create("hyperdrive_computer")
computer:Spawn()
computer:LinkEngine(engine)
computer:AddWaypoint("Home Base", Vector(0, 0, 0))
computer:ExecuteFleetJump(Vector(1000, 0, 0))

-- Custom integration
HYPERDRIVE.EnhancedConfig.RegisterIntegration("MyMod", {
    name = "My Mod Integration",
    checkFunction = function() return MyMod ~= nil end,
    entityHandler = function(entity)
        -- Handle entity detection
        if entity:GetClass() == "my_ship" then
            return {type = "custom", efficiency = 1.5}
        end
    end
})

-- Event handling
hook.Add("HyperdriveJumpStart", "MyHook", function(engine, destination)
    print("Jump started from", engine:GetPos(), "to", destination)
end)
```

---

This API reference provides comprehensive documentation for developers integrating with or extending the Hyperdrive System.
