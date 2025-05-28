# Hyperdrive Addon Developer Guide

This guide provides detailed information for developers who want to understand, modify, or extend the Hyperdrive addon.

## Architecture Overview

### Core Systems

#### 1. Hyperdrive Master Engine (`lua/entities/hyperdrive_master_engine/`)
- **Purpose**: Primary hyperdrive engine with all features integrated
- **Key Functions**: `StartJumpMaster()`, `ExecuteJumpMaster()`, `CanOperateMaster()`
- **Features**: Wiremod integration, efficiency bonuses, conflict detection

#### 2. Hyperdrive Computer (`lua/entities/hyperdrive_computer/`)
- **Purpose**: Central control system for navigation and fleet coordination
- **Key Functions**: `ExecuteFleetJump()`, `ExecuteManualJump()`, `AutoLinkEngines()`
- **Features**: Waypoint management, planet detection, safety checks

#### 3. Hyperspace Dimension System (`lua/autorun/server/hyperdrive_hyperspace_dimension.lua`)
- **Purpose**: Creates separate dimension for hyperspace travel
- **Key Functions**: `StartHyperspaceTravel()`, `EndHyperspaceTravel()`, `CreateHyperspaceArea()`
- **Features**: Entity transportation, physics modification, boundary creation

#### 4. Integration Systems
- **Wiremod** (`lua/autorun/hyperdrive_wiremod.lua`)
- **Spacebuild** (`lua/autorun/hyperdrive_spacebuild.lua`)
- **Stargate** (`lua/autorun/hyperdrive_stargate.lua`)

### File Structure

```
hyperdrive-addon/
├── lua/
│   ├── entities/
│   │   ├── hyperdrive_master_engine/
│   │   │   ├── init.lua              # Server-side engine logic
│   │   │   ├── cl_init.lua           # Client-side engine rendering
│   │   │   └── shared.lua            # Shared entity setup
│   │   └── hyperdrive_computer/
│   │       ├── init.lua              # Server-side computer logic
│   │       ├── cl_init.lua           # Client-side interface
│   │       └── shared.lua            # Shared computer setup
│   ├── autorun/
│   │   ├── hyperdrive_init.lua       # Core initialization
│   │   ├── hyperdrive_wiremod.lua    # Wiremod integration
│   │   ├── hyperdrive_spacebuild.lua # Spacebuild integration
│   │   ├── hyperdrive_stargate.lua   # Stargate integration
│   │   ├── hyperdrive_debug_test.lua # Debug and testing tools
│   │   ├── client/
│   │   │   ├── hyperdrive_hyperspace_window.lua  # Visual effects
│   │   │   ├── hyperdrive_visual_config.lua      # Effect configuration
│   │   │   └── hyperdrive_effects.lua            # Particle effects
│   │   └── server/
│   │       └── hyperdrive_hyperspace_dimension.lua # Hyperspace system
│   └── weapons/ (if any)
├── materials/ (textures and materials)
├── models/ (3D models)
├── sound/ (sound effects)
├── README.md
├── DEVELOPER_GUIDE.md
└── addon.txt
```

## Key APIs and Functions

### Hyperdrive Master Engine API

```lua
-- Core Functions
engine:StartJumpMaster()                    -- Initiate jump sequence
engine:ExecuteJumpMaster()                  -- Execute the actual jump
engine:CanOperateMaster()                   -- Check if engine can operate
engine:SetDestinationPos(vector)           -- Set jump destination
engine:GetEfficiencyRating()               -- Get engine efficiency

-- Integration Functions
engine:InitializeWiremod()                 -- Setup Wiremod integration
engine:InitializeSpacebuild()              -- Setup Spacebuild integration
engine:InitializeStargate()                -- Setup Stargate integration
```

### Hyperdrive Computer API

```lua
-- Fleet Management
computer:ExecuteFleetJump(destination)     -- Coordinate multiple engines
computer:AutoLinkEngines()                 -- Find and link nearby engines
computer:GetEngineStatus()                 -- Get status of linked engines

-- Navigation
computer:SaveWaypoint(name, position)      -- Save navigation waypoint
computer:LoadWaypoint(name)                -- Load saved waypoint
computer:CalculateJumpCost(dest, engine)   -- Calculate energy cost

-- Planet Detection
computer:ScanForPlanets()                  -- Scan for nearby planets
computer:AutoLinkAllPlanets()              -- Auto-link detected planets
computer:QuickJumpToPlanet(name, engine)   -- Quick jump to planet
```

### Hyperspace Dimension API

```lua
-- Core Functions
HYPERDRIVE.HyperspaceDimension.StartHyperspaceTravel(engine, destination, time)
HYPERDRIVE.HyperspaceDimension.EndHyperspaceTravel(travelId)
HYPERDRIVE.HyperspaceDimension.EmergencyExit(player)

-- Utility Functions
HYPERDRIVE.HyperspaceDimension.IsPlayerInHyperspace(player)
HYPERDRIVE.HyperspaceDimension.GetActiveCount()
HYPERDRIVE.HyperspaceDimension.GetHyperspaceEntityCount()
```

## Development Patterns

### 1. Entity Creation Pattern

```lua
-- Entity initialization
function ENT:Initialize()
    if SERVER then
        -- Server-side setup
        self:SetModel("models/your_model.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        
        -- Initialize integration systems
        self:InitializeWiremod()
        self:InitializeSpacebuild()
    end
end
```

### 2. Integration Pattern

```lua
-- Check for addon presence
if WireLib then
    -- Wiremod integration code
    self.Inputs = WireLib.CreateInputs(self, {"Input1", "Input2"})
    self.Outputs = WireLib.CreateOutputs(self, {"Output1", "Output2"})
end

-- Integration function
function ENT:InitializeWiremod()
    if not WireLib then return end
    -- Setup wire inputs/outputs
end
```

### 3. Network Communication Pattern

```lua
-- Server-side
util.AddNetworkString("hyperdrive_message")

net.Start("hyperdrive_message")
net.WriteString("data")
net.Send(player)

-- Client-side
net.Receive("hyperdrive_message", function()
    local data = net.ReadString()
    -- Handle received data
end)
```

## Adding New Features

### 1. Adding a New Engine Type

1. **Create entity folder**: `lua/entities/your_engine_name/`
2. **Implement base functions**:
   ```lua
   function ENT:StartJump()
   function ENT:SetDestinationPos(pos)
   function ENT:GetEnergy()
   function ENT:SetEnergy(amount)
   ```
3. **Add to computer detection**:
   ```lua
   -- In hyperdrive_computer/init.lua
   if ent:GetClass() == "your_engine_name" then
       -- Handle your engine
   end
   ```

### 2. Adding New Integration

1. **Create integration file**: `lua/autorun/hyperdrive_your_addon.lua`
2. **Check for addon presence**:
   ```lua
   if not YourAddon then return end
   ```
3. **Add to master engine**:
   ```lua
   function ENT:InitializeYourAddon()
       if not YourAddon then return end
       -- Integration code
   end
   ```

### 3. Adding Visual Effects

1. **Create client file**: `lua/autorun/client/hyperdrive_your_effect.lua`
2. **Use effect patterns**:
   ```lua
   function CreateYourEffect(pos, intensity)
       local emitter = ParticleEmitter(pos)
       -- Particle creation code
       emitter:Finish()
   end
   ```

## Debugging and Testing

### Debug System

The addon includes a comprehensive debug system:

```lua
-- Enable debug mode
concommand.Add("hyperdrive_debug_test", function(ply)
    -- System status check
end)

-- Force exit hyperspace
concommand.Add("hyperdrive_debug_force_exit", function(ply)
    -- Emergency exit all travels
end)
```

### Testing Checklist

1. **Basic Functionality**
   - [ ] Engine spawns and initializes
   - [ ] Computer links to engine
   - [ ] Jump executes successfully
   - [ ] Entities transport correctly

2. **Hyperspace Dimension**
   - [ ] Hyperspace area creates
   - [ ] Players can move in hyperspace
   - [ ] Exit works correctly
   - [ ] Cleanup completes

3. **Integration Testing**
   - [ ] Wiremod inputs/outputs work
   - [ ] Spacebuild planets detected
   - [ ] Stargate integration functions

### Performance Considerations

1. **Entity Limits**: Keep entity searches under 1000 units radius
2. **Timer Management**: Clean up timers properly to prevent leaks
3. **Network Traffic**: Minimize network messages, batch when possible
4. **Memory Usage**: Clear references when entities are removed

## Common Issues and Solutions

### 1. Entities Not Transporting
- Check `IsValid(entity)` before transportation
- Verify entity is within search radius
- Ensure proper offset calculations

### 2. Timer Leaks
- Always use unique timer names
- Remove timers in cleanup functions
- Check entity validity in timer callbacks

### 3. Network Errors
- Verify network strings are added on server
- Check data types match read/write operations
- Handle client-side errors gracefully

## Contributing Guidelines

1. **Code Style**: Follow existing patterns and naming conventions
2. **Documentation**: Comment complex functions and algorithms
3. **Testing**: Test all changes thoroughly before submission
4. **Compatibility**: Ensure changes don't break existing functionality
5. **Performance**: Consider impact on server performance

## Advanced Topics

### Custom Physics in Hyperspace

```lua
function HYPERDRIVE.Hyperspace.ApplyCustomPhysics(ent)
    if ent:IsPlayer() then
        ent:SetGravity(0.5)  -- Reduced gravity
    elseif ent:GetPhysicsObject():IsValid() then
        local phys = ent:GetPhysicsObject()
        phys:EnableGravity(false)
        phys:SetMaterial("ice")  -- Low friction
    end
end
```

### Dynamic Hyperspace Areas

```lua
function CreateDynamicHyperspaceArea(center, entities)
    local bounds = CalculateEntityBounds(entities)
    local size = math.max(bounds.x, bounds.y, bounds.z) * 2
    return CreateHyperspaceArea(center, size)
end
```

This developer guide provides the foundation for understanding and extending the Hyperdrive addon. For specific implementation details, refer to the source code and inline comments.
