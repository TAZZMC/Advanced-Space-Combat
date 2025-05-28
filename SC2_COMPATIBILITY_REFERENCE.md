# Space Combat 2 Compatibility Reference

This document provides a comprehensive reference for integrating with Space Combat 2 (SC2) gamemode, including all known methods, metamethods, and best practices.

## SC2 Entity Metamethods

### GetProtector()
**Purpose**: Returns the ship core that protects an entity
**Usage**: `local shipCore = entity:GetProtector()`
**Returns**: Ship core entity or `nil` if unprotected
**Source**: `spacecombat2/sv_main.lua#L341`

```lua
-- Check if entity has a ship core
if entity.GetProtector and type(entity.GetProtector) == "function" then
    local protector = entity:GetProtector()
    if IsValid(protector) then
        -- Entity is protected by this ship core
        print("Entity protected by: " .. protector:GetClass())
    end
end
```

**Best Practices**:
- Always check if the method exists before calling
- Verify the returned entity is valid
- Use this for accurate ship membership detection
- More reliable than proximity-based detection

## SC2 Global Functions

### SC_HasGenericPodLink()
**Purpose**: Checks if an entity has generic pod link connectivity
**Usage**: `local hasLink = SC_HasGenericPodLink(entity)`
**Returns**: Boolean indicating connectivity

### SC_GetEnvironment()
**Purpose**: Gets environment information for a position
**Usage**: `local env = SC_GetEnvironment(position)`
**Returns**: Environment table with space/atmosphere data

```lua
if SC_GetEnvironment and type(SC_GetEnvironment) == "function" then
    local env = SC_GetEnvironment(pos)
    if env then
        local inSpace = env.space or false
        local hasAtmosphere = env.atmosphere or false
        local gravity = env.gravity or 1.0
    end
end
```

## SC2 Entity Classes

### sc_gyropod
**Purpose**: Main ship movement and physics entity
**Key Methods**:
- `SetTargetPosition(vector)` - Set target position for movement
- `MoveTo(vector)` - Move to specific position
- `SetPosOptimized(vector)` - Optimized position setting
- `OnTeleport(position, velocity)` - Teleportation notification

```lua
local gyropod = ents.FindByClass("sc_gyropod")[1]
if IsValid(gyropod) then
    -- Use SC2's optimized movement
    if gyropod.SetTargetPosition then
        gyropod:SetTargetPosition(newPos)
    elseif gyropod.MoveTo then
        gyropod:MoveTo(newPos)
    end
end
```

### sc_ship_core
**Purpose**: Central ship management entity
**Key Methods**:
- `GetAttachedEntities()` - Get all entities attached to ship
- `GetPlayersInShip()` - Get all players in the ship
- `OnShipMoved(position)` - Notification of ship movement

```lua
local shipCore = entity:GetProtector()
if IsValid(shipCore) then
    -- Get all ship entities
    if shipCore.GetAttachedEntities then
        local entities = shipCore:GetAttachedEntities()
        for _, ent in ipairs(entities) do
            -- Process ship entities
        end
    end
    
    -- Get players in ship
    if shipCore.GetPlayersInShip then
        local players = shipCore:GetPlayersInShip()
        for _, ply in ipairs(players) do
            -- Process players
        end
    end
end
```

## Integration Patterns

### Entity Detection
**Recommended Approach**: Use GetProtector() for ship membership

```lua
function GetShipEntities(referenceEntity)
    local entities = {}
    local shipCore = referenceEntity:GetProtector()
    
    if IsValid(shipCore) then
        -- Method 1: Use ship core's entity list
        if shipCore.GetAttachedEntities then
            entities = shipCore:GetAttachedEntities()
        else
            -- Method 2: Find entities with same protector
            local nearbyEnts = ents.FindInSphere(shipCore:GetPos(), 2000)
            for _, ent in ipairs(nearbyEnts) do
                local entCore = ent:GetProtector()
                if IsValid(entCore) and entCore == shipCore then
                    table.insert(entities, ent)
                end
            end
        end
    end
    
    return entities
end
```

### Ship Movement
**Recommended Approach**: Use gyropod for movement, notify ship core

```lua
function MoveShipSC2(engine, destination)
    -- Find gyropod using GetProtector
    local shipCore = engine:GetProtector()
    local gyropod = nil
    
    if IsValid(shipCore) then
        local nearbyEnts = ents.FindInSphere(shipCore:GetPos(), 2000)
        for _, ent in ipairs(nearbyEnts) do
            if ent:GetClass() == "sc_gyropod" then
                local entCore = ent:GetProtector()
                if IsValid(entCore) and entCore == shipCore then
                    gyropod = ent
                    break
                end
            end
        end
    end
    
    if IsValid(gyropod) then
        -- Calculate gyropod position
        local offset = destination - engine:GetPos()
        local newGyropodPos = gyropod:GetPos() + offset
        
        -- Use SC2 movement methods
        if gyropod.SetTargetPosition then
            gyropod:SetTargetPosition(newGyropodPos)
        elseif gyropod.MoveTo then
            gyropod:MoveTo(newGyropodPos)
        else
            gyropod:SetPos(newGyropodPos)
        end
        
        -- Notify ship core
        if shipCore.OnShipMoved then
            shipCore:OnShipMoved(destination)
        end
        
        return true
    end
    
    return false
end
```

### Gravity Management
**Recommended Approach**: Integrate with SC2 environment system

```lua
function OverrideGravitySC2(player, override)
    if override then
        -- Get environment info
        local env = SC_GetEnvironment and SC_GetEnvironment(player:GetPos())
        local gravity = 0.5 -- Hyperspace gravity
        
        if env and env.space then
            gravity = gravity * 0.5 -- Even less in space
        end
        
        player.HyperdriveGravityOverride = true
        player:SetGravity(gravity)
    else
        -- Restore SC2 gravity
        player.HyperdriveGravityOverride = nil
        -- Let SC2 handle gravity restoration
    end
end
```

## Capability Detection

### Runtime Detection
```lua
function DetectSC2Capabilities()
    local capabilities = {}
    
    -- Check gamemode
    capabilities.gamemode = GAMEMODE and GAMEMODE.Name == "Space Combat 2"
    
    -- Check GetProtector metamethod
    local testEnt = ents.Create("prop_physics")
    if IsValid(testEnt) then
        capabilities.getProtector = testEnt.GetProtector and 
                                   type(testEnt.GetProtector) == "function"
        testEnt:Remove()
    end
    
    -- Check global functions
    capabilities.genericPodLink = SC_HasGenericPodLink and 
                                 type(SC_HasGenericPodLink) == "function"
    capabilities.environment = SC_GetEnvironment and 
                              type(SC_GetEnvironment) == "function"
    
    -- Check for SC2 entities
    capabilities.entities = #ents.FindByClass("sc_*") > 0
    
    return capabilities
end
```

## Best Practices

### 1. Always Check Method Existence
```lua
if entity.MethodName and type(entity.MethodName) == "function" then
    entity:MethodName()
end
```

### 2. Use GetProtector for Ship Membership
- More accurate than proximity detection
- Handles complex ship structures
- Respects SC2's protection system

### 3. Integrate with Gyropod System
- Use gyropod for ship movement
- Notify gyropod of teleportation
- Preserve velocity states when possible

### 4. Respect SC2 Environment System
- Use SC_GetEnvironment for space detection
- Adjust gravity based on environment
- Consider atmosphere and pressure

### 5. Graceful Degradation
- Provide fallbacks for missing methods
- Work on non-SC2 servers
- Log capability detection results

## Console Commands

### hyperdrive_sc2_status
Shows detailed SC2 integration status including:
- Gamemode detection
- Capability availability
- Current entity counts
- Integration health

### hyperdrive_sc2_validate
Validates ship configuration for SC2 compatibility:
- GetProtector functionality
- Gyropod connectivity
- Entity protection coverage
- Configuration warnings

## Common Issues

### 1. Entities Not Moving
**Cause**: Ship teleports back to original position
**Solution**: Use gyropod movement instead of direct entity movement

### 2. Missed Entities
**Cause**: Using proximity detection instead of GetProtector
**Solution**: Use GetProtector to find ship core, then get attached entities

### 3. Gravity Issues
**Cause**: SC2 overrides gravity every tick
**Solution**: Use HyperdriveGravityOverride flag and integrate with SC2 system

### 4. Performance Problems
**Cause**: Large sphere searches and network overhead
**Solution**: Use ship core entity lists and batch movement

## Version Compatibility

This integration is designed to work with:
- Space Combat 2 (all versions with GetProtector support)
- Fallback compatibility for servers without SC2
- Forward compatibility with future SC2 updates

## References

- SC2 Repository: https://gitlab.com/TeamDiaspora/spacecombat2
- GetProtector Implementation: spacecombat2/sv_main.lua#L341
- Environment System: spacecombat2/gamemode/classes/environment.lua#L137
