-- Advanced Space Combat - Entity Spawning System v5.1.0
-- Comprehensive entity spawning and management system
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Advanced Space Combat] Entity Spawning System v5.1.0 - Ultimate Edition Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.EntitySpawning = ASC.EntitySpawning or {}

-- Entity spawning configuration
ASC.EntitySpawning.Config = {
    -- Default spawn settings
    DefaultHeight = 10,
    DefaultAngleOffset = 180,
    MaxSpawnDistance = 5000,
    
    -- Auto-linking settings
    AutoLinkRange = 2000,
    AutoLinkEnabled = true,
    
    -- Spawn limits per player
    SpawnLimits = {
        ship_core = 5,
        hyperdrive_engine = 20,
        hyperdrive_master_engine = 5,
        asc_pulse_cannon = 10,
        asc_railgun = 10,
        asc_plasma_cannon = 10,
        asc_beam_weapon = 10,
        asc_torpedo_launcher = 10,
        asc_shield_generator = 5,
        asc_flight_console = 5,
        asc_docking_pad = 3,
        asc_shuttle = 5
    }
}

-- Entity spawn tracking
ASC.EntitySpawning.PlayerSpawnCounts = {}

-- Get player spawn count for entity type
function ASC.EntitySpawning.GetPlayerSpawnCount(player, entityClass)
    local steamID = player:SteamID()
    if not ASC.EntitySpawning.PlayerSpawnCounts[steamID] then
        ASC.EntitySpawning.PlayerSpawnCounts[steamID] = {}
    end
    
    return ASC.EntitySpawning.PlayerSpawnCounts[steamID][entityClass] or 0
end

-- Increment player spawn count
function ASC.EntitySpawning.IncrementSpawnCount(player, entityClass)
    local steamID = player:SteamID()
    if not ASC.EntitySpawning.PlayerSpawnCounts[steamID] then
        ASC.EntitySpawning.PlayerSpawnCounts[steamID] = {}
    end
    
    ASC.EntitySpawning.PlayerSpawnCounts[steamID][entityClass] = 
        (ASC.EntitySpawning.PlayerSpawnCounts[steamID][entityClass] or 0) + 1
end

-- Check spawn limits
function ASC.EntitySpawning.CanPlayerSpawn(player, entityClass)
    local limit = ASC.EntitySpawning.Config.SpawnLimits[entityClass]
    if not limit then return true end -- No limit set
    
    local currentCount = ASC.EntitySpawning.GetPlayerSpawnCount(player, entityClass)
    return currentCount < limit
end

-- Spawn entity function
function ASC.EntitySpawning.SpawnEntity(player, entityClass, position, angle)
    if not IsValid(player) then return nil end
    
    -- Check if entity class exists
    if not scripted_ents.GetStored()[entityClass] then
        player:ChatPrint("[ASC] Error: Entity class '" .. entityClass .. "' not found!")
        return nil
    end
    
    -- Check spawn limits
    if not ASC.EntitySpawning.CanPlayerSpawn(player, entityClass) then
        local limit = ASC.EntitySpawning.Config.SpawnLimits[entityClass]
        player:ChatPrint("[ASC] Spawn limit reached for " .. entityClass .. " (limit: " .. limit .. ")")
        return nil
    end
    
    -- Create entity
    local entity = ents.Create(entityClass)
    if not IsValid(entity) then
        player:ChatPrint("[ASC] Error: Failed to create entity '" .. entityClass .. "'!")
        return nil
    end
    
    -- Set position and angle
    if position then
        entity:SetPos(position)
    else
        -- Use player's aim position
        local trace = player:GetEyeTrace()
        if trace.Hit then
            entity:SetPos(trace.HitPos + trace.HitNormal * ASC.EntitySpawning.Config.DefaultHeight)
        else
            entity:SetPos(player:GetPos() + player:GetForward() * 100)
        end
    end
    
    if angle then
        entity:SetAngles(angle)
    else
        entity:SetAngles(Angle(0, player:EyeAngles().y + ASC.EntitySpawning.Config.DefaultAngleOffset, 0))
    end
    
    -- Set owner
    if entity.CPPISetOwner then
        entity:CPPISetOwner(player)
    else
        entity:SetOwner(player)
    end
    
    -- Spawn and activate
    entity:Spawn()
    entity:Activate()
    
    -- Increment spawn count
    ASC.EntitySpawning.IncrementSpawnCount(player, entityClass)
    
    -- Auto-link to ship core if enabled
    if ASC.EntitySpawning.Config.AutoLinkEnabled then
        ASC.EntitySpawning.AutoLinkToShipCore(entity, player)
    end
    
    -- Notify player
    local entityName = entity.PrintName or entityClass
    player:ChatPrint("[ASC] Spawned: " .. entityName)
    
    return entity
end

-- Auto-link entity to nearest ship core
function ASC.EntitySpawning.AutoLinkToShipCore(entity, player)
    if not IsValid(entity) or not IsValid(player) then return end
    
    -- Find nearest ship core owned by player
    local nearestCore = nil
    local nearestDistance = ASC.EntitySpawning.Config.AutoLinkRange
    
    for _, ent in ipairs(ents.FindByClass("ship_core")) do
        if IsValid(ent) then
            local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetOwner()
            if IsValid(owner) and owner == player then
                local distance = entity:GetPos():Distance(ent:GetPos())
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestCore = ent
                end
            end
        end
    end
    
    -- Link to ship core if found
    if IsValid(nearestCore) then
        if entity.LinkToShipCore then
            entity:LinkToShipCore(nearestCore)
        elseif nearestCore.AddComponent then
            nearestCore:AddComponent(entity)
        end
        
        player:ChatPrint("[ASC] Auto-linked to ship core (" .. math.floor(nearestDistance) .. " units away)")
    end
end

-- Console command: asc_spawn_entity
concommand.Add("asc_spawn_entity", function(player, cmd, args)
    if not IsValid(player) then return end
    
    if #args < 1 then
        player:ChatPrint("[ASC] Usage: asc_spawn_entity <entity_class>")
        return
    end
    
    local entityClass = args[1]
    ASC.EntitySpawning.SpawnEntity(player, entityClass)
end)

-- Console command: asc_spawn_at
concommand.Add("asc_spawn_at", function(player, cmd, args)
    if not IsValid(player) then return end
    
    if #args < 4 then
        player:ChatPrint("[ASC] Usage: asc_spawn_at <entity_class> <x> <y> <z>")
        return
    end
    
    local entityClass = args[1]
    local x = tonumber(args[2])
    local y = tonumber(args[3])
    local z = tonumber(args[4])
    
    if not x or not y or not z then
        player:ChatPrint("[ASC] Error: Invalid coordinates!")
        return
    end
    
    local position = Vector(x, y, z)
    ASC.EntitySpawning.SpawnEntity(player, entityClass, position)
end)

-- Console command: asc_spawn_limits
concommand.Add("asc_spawn_limits", function(player, cmd, args)
    if not IsValid(player) then return end
    
    player:ChatPrint("[ASC] Current spawn limits:")
    
    for entityClass, limit in pairs(ASC.EntitySpawning.Config.SpawnLimits) do
        local current = ASC.EntitySpawning.GetPlayerSpawnCount(player, entityClass)
        player:ChatPrint("• " .. entityClass .. ": " .. current .. "/" .. limit)
    end
end)

-- Console command: asc_auto_link
concommand.Add("asc_auto_link", function(player, cmd, args)
    if not IsValid(player) then return end
    
    if #args > 0 then
        local enabled = tobool(args[1])
        ASC.EntitySpawning.Config.AutoLinkEnabled = enabled
        player:ChatPrint("[ASC] Auto-linking " .. (enabled and "enabled" or "disabled"))
    else
        player:ChatPrint("[ASC] Auto-linking is " .. (ASC.EntitySpawning.Config.AutoLinkEnabled and "enabled" or "disabled"))
    end
end)

-- Console command: asc_cleanup_entities
concommand.Add("asc_cleanup_entities", function(player, cmd, args)
    if not IsValid(player) then return end
    
    local entityClasses = {
        "ship_core", "hyperdrive_engine", "hyperdrive_master_engine", "hyperdrive_computer",
        "asc_pulse_cannon", "asc_beam_weapon", "asc_plasma_cannon", "asc_torpedo_launcher", "asc_railgun",
        "asc_shield_generator", "asc_flight_console", "asc_docking_pad", "asc_shuttle"
    }
    
    local cleaned = 0
    
    for _, entityClass in ipairs(entityClasses) do
        for _, ent in ipairs(ents.FindByClass(entityClass)) do
            if IsValid(ent) then
                local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetOwner()
                if IsValid(owner) and owner == player then
                    ent:Remove()
                    cleaned = cleaned + 1
                end
            end
        end
    end
    
    -- Reset spawn counts
    ASC.EntitySpawning.PlayerSpawnCounts[player:SteamID()] = {}
    
    player:ChatPrint("[ASC] Cleaned up " .. cleaned .. " entities")
end)

-- Entity removal tracking
hook.Add("EntityRemoved", "ASC_EntityRemovalTracking", function(entity)
    if not IsValid(entity) then return end
    
    local entityClass = entity:GetClass()
    local owner = entity.CPPIGetOwner and entity:CPPIGetOwner() or entity:GetOwner()
    
    if IsValid(owner) and ASC.EntitySpawning.Config.SpawnLimits[entityClass] then
        local steamID = owner:SteamID()
        if ASC.EntitySpawning.PlayerSpawnCounts[steamID] and 
           ASC.EntitySpawning.PlayerSpawnCounts[steamID][entityClass] then
            ASC.EntitySpawning.PlayerSpawnCounts[steamID][entityClass] = 
                math.max(0, ASC.EntitySpawning.PlayerSpawnCounts[steamID][entityClass] - 1)
        end
    end
end)

print("[Advanced Space Combat] Entity Spawning System v3.0.0 - Loaded successfully!")
