# Hyperdrive Addon Technical Documentation

## System Architecture Deep Dive

### Core Data Flow

```
Player Input → Computer Interface → Engine Validation → Hyperspace System → Entity Transportation → Destination Arrival
```

### Entity Relationship Diagram

```
Hyperdrive Computer (1) ←→ (N) Hyperdrive Engines
        ↓
Hyperspace Dimension System
        ↓
Entity Transportation Manager
        ↓
Visual Effects System
```

## Hyperspace Dimension System

### Core Algorithm

```lua
function StartHyperspaceTravel(engine, destination, travelTime)
    1. Validate inputs (engine, destination)
    2. Generate unique travel ID
    3. Calculate hyperspace position (offset from origin)
    4. Create hyperspace area with boundaries
    5. Collect entities within ship radius
    6. Store original positions and states
    7. Transport entities to hyperspace
    8. Apply hyperspace physics
    9. Start travel timer
    10. Schedule automatic exit
end
```

### Entity Collection Logic

```lua
-- Search radius calculation
local baseRadius = 200
local enhancedRadius = baseRadius
if engine.IntegrationData.stargate.active then
    enhancedRadius = 400  -- Ancient tech bonus
elseif engine.IntegrationData.spacebuild.active then
    enhancedRadius = 300  -- Spacebuild bonus
end

-- Entity filtering
local validTypes = {
    "prop_physics", "prop_dynamic", 
    "hyperdrive_*", "life_support_*", "sb_*",
    "player", "vehicle"
}
```

### Hyperspace Physics

```lua
-- Applied to entities in hyperspace
Player: SetGravity(0.5)           -- Reduced gravity
Props:  EnableGravity(false)      -- Floating objects
        SetMaterial("ice")        -- Low friction
Vehicles: ModifyHandling(0.7)     -- Easier control
```

## Integration Systems

### Wiremod Integration

#### Input/Output Mapping

```lua
-- Master Engine Inputs
Inputs = {
    "Jump",              -- Trigger jump (0/1)
    "SetDestination",    -- Set destination vector
    "Abort",             -- Abort current operation
    "SetEnergy",         -- Set energy level
    "FleetJump",         -- Trigger fleet jump
    "SetMode",           -- Set operation mode
    "ScanEngines",       -- Scan for nearby engines
    "QuickJumpToPlanet", -- Quick jump to planet
    "EmergencyAbort"     -- Emergency abort
}

-- Master Engine Outputs
Outputs = {
    "Powered",           -- Engine powered status
    "LinkedEngines",     -- Number of linked engines
    "TotalEnergy",       -- Total fleet energy
    "FleetStatus",       -- Fleet readiness status
    "JumpCost",          -- Calculated jump cost
    "EstimatedTime",     -- Estimated travel time
    "PlanetsDetected",   -- Number of planets found
    "NearestPlanet"      -- Distance to nearest planet
}
```

#### Wire Update Logic

```lua
function ENT:TriggerWireOutputs()
    if not WireLib then return end
    
    WireLib.TriggerOutput(self, "Powered", self:GetPowered() and 1 or 0)
    WireLib.TriggerOutput(self, "LinkedEngines", #self.LinkedEngines)
    WireLib.TriggerOutput(self, "TotalEnergy", self:CalculateTotalEnergy())
    -- ... additional outputs
end
```

### Spacebuild Integration

#### Planet Detection Algorithm

```lua
function ScanForSpacebuildPlanets()
    local planets = {}
    local searchRadius = 50000  -- Large search area
    
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent.IsPlanet then
            local distance = LocalPlayer():GetPos():Distance(ent:GetPos())
            if distance <= searchRadius then
                table.insert(planets, {
                    entity = ent,
                    name = ent:GetPlanetName() or "Unknown Planet",
                    distance = distance,
                    position = ent:GetPos()
                })
            end
        end
    end
    
    -- Sort by distance
    table.sort(planets, function(a, b) return a.distance < b.distance end)
    return planets
end
```

### Stargate Integration

#### Technology Level System

```lua
-- Technology levels affect performance
TechLevels = {
    "basic",     -- Standard hyperdrive
    "advanced",  -- Improved efficiency
    "ancient"    -- Maximum capabilities
}

-- Ancient tech bonuses
if techLevel == "ancient" then
    energyCost = energyCost * 0.5      -- 50% energy reduction
    travelTime = travelTime * 0.7      -- 30% faster travel
    searchRadius = searchRadius * 2    -- Double search range
end
```

## Visual Effects System

### Effect Hierarchy

```
RenderScreenspaceEffects Hook
├── Hyperspace Window Animation
├── Color Modification
├── Motion Blur
├── Particle Effects
└── Screen Flash
```

### Performance Optimization

```lua
-- Effect intensity scaling
local maxIntensity = HYPERDRIVE.VisualConfig.Get("ScreenEffectsIntensity")
local actualIntensity = math.min(intensity, maxIntensity)

-- Conditional rendering
if HYPERDRIVE.VisualConfig.Get("EnableScreenEffects") then
    ApplyScreenEffects(actualIntensity)
end

-- Frame rate limiting
local lastUpdate = 0
local updateRate = HYPERDRIVE.VisualConfig.Get("EffectUpdateRate")
if CurTime() - lastUpdate > updateRate then
    UpdateEffects()
    lastUpdate = CurTime()
end
```

## Network Protocol

### Message Types

```lua
-- Network strings
util.AddNetworkString("hyperdrive_hyperspace_enter")
util.AddNetworkString("hyperdrive_hyperspace_exit")
util.AddNetworkString("hyperdrive_hyperspace_window")
util.AddNetworkString("hyperdrive_computer_update")
util.AddNetworkString("hyperdrive_engine_status")
```

### Data Structures

```lua
-- Hyperspace entry message
net.Start("hyperdrive_hyperspace_enter")
net.WriteVector(hyperspacePosition)    -- Where player is in hyperspace
net.WriteFloat(travelTime)             -- How long travel will take
net.WriteTable(shipEntities)           -- Entities in the ship
net.Send(player)

-- Computer update message
net.Start("hyperdrive_computer_update")
net.WriteTable({
    linkedEngines = engineData,
    waypoints = waypointData,
    planets = planetData,
    status = systemStatus
})
net.Send(player)
```

## Error Handling and Recovery

### Validation Chain

```lua
function ValidateJumpParameters(engine, destination)
    -- Engine validation
    if not IsValid(engine) then
        return false, "Invalid engine"
    end
    
    -- Destination validation
    if not destination or not isvector(destination) then
        return false, "Invalid destination"
    end
    
    -- Energy validation
    if engine:GetEnergy() < CalculateEnergyCost(engine, destination) then
        return false, "Insufficient energy"
    end
    
    -- Cooldown validation
    if engine:GetCooldown() > CurTime() then
        return false, "Engine on cooldown"
    end
    
    return true, "Validation passed"
end
```

### Recovery Mechanisms

```lua
-- Automatic cleanup on entity removal
function ENT:OnRemove()
    -- Clean up timers
    timer.Remove("HyperdriveCooldown_" .. self:EntIndex())
    timer.Remove("HyperdriveJump_" .. self:EntIndex())
    
    -- Clean up hyperspace travel
    if self.HyperspaceTravelId then
        HYPERDRIVE.HyperspaceDimension.EndHyperspaceTravel(self.HyperspaceTravelId)
    end
    
    -- Clean up wire connections
    if WireLib then
        WireLib.Remove(self)
    end
end
```

## Performance Metrics

### Benchmarking Data

```lua
-- Typical performance metrics
EntitySearchTime = 0.001 - 0.005 seconds  -- 1-5ms
HyperspaceCreation = 0.010 - 0.050 seconds -- 10-50ms
EntityTransportation = 0.005 - 0.020 seconds -- 5-20ms
EffectRendering = 0.002 - 0.008 seconds -- 2-8ms per frame

-- Memory usage
BaseMemoryUsage = ~50KB per engine
HyperspaceMemory = ~100KB per active travel
EffectMemory = ~25KB per active effect
```

### Optimization Strategies

```lua
-- Entity caching
local cachedEntities = {}
local lastCacheTime = 0
local cacheTimeout = 1 -- 1 second cache

function GetCachedEntities(pos, radius)
    if CurTime() - lastCacheTime > cacheTimeout then
        cachedEntities = ents.FindInSphere(pos, radius)
        lastCacheTime = CurTime()
    end
    return cachedEntities
end

-- Batch operations
function BatchUpdateEngines(engines, data)
    for _, engine in ipairs(engines) do
        engine:UpdateData(data)
    end
    -- Single network update instead of multiple
    net.Start("hyperdrive_batch_update")
    net.WriteTable(data)
    net.Broadcast()
end
```

## Security Considerations

### Input Validation

```lua
-- Sanitize user input
function SanitizeWaypointName(name)
    name = string.gsub(name, "[^%w%s%-_]", "") -- Remove special chars
    name = string.sub(name, 1, 32) -- Limit length
    return name
end

-- Validate coordinates
function ValidateCoordinates(pos)
    local maxCoord = 32768 -- GMod map limit
    return math.abs(pos.x) < maxCoord and 
           math.abs(pos.y) < maxCoord and 
           math.abs(pos.z) < maxCoord
end
```

### Permission System

```lua
-- Admin-only commands
function CheckAdminPermission(ply, command)
    if not ply:IsAdmin() then
        ply:ChatPrint("[Hyperdrive] Admin permission required for " .. command)
        return false
    end
    return true
end
```

## Future Development

### Planned Features

1. **Multi-dimensional Travel** - Travel between different map dimensions
2. **Hyperspace Encounters** - Random events during travel
3. **Advanced Fleet Coordination** - Formation flying and synchronized jumps
4. **Resource Management** - Fuel consumption and maintenance systems
5. **Hyperspace Stations** - Permanent structures in hyperspace

### Extension Points

```lua
-- Hook system for extensions
hook.Add("HyperdrivePreJump", "YourAddon", function(engine, destination)
    -- Modify jump parameters
    return destination, travelTime
end)

hook.Add("HyperdrivePostJump", "YourAddon", function(engine, destination)
    -- Post-jump actions
end)
```

This technical documentation provides deep implementation details for developers working on the Hyperdrive addon.
