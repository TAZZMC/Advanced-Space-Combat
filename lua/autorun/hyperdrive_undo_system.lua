-- Enhanced Hyperdrive System - Undo System Integration v5.1.0
-- Comprehensive undo support for all hyperdrive entities
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Hyperdrive Undo] Undo System v5.1.0 - Ultimate Edition Initializing...")

-- Initialize undo namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Undo = HYPERDRIVE.Undo or {}

-- Undo system configuration
HYPERDRIVE.Undo.Config = {
    -- Undo Settings
    EnableUndo = true,
    EnableCleanup = true,
    EnableGroupUndo = true,
    EnableSmartUndo = true,
    
    -- Undo Limits
    MaxUndoEntries = 50,
    UndoTimeout = 300, -- 5 minutes
    CleanupInterval = 60, -- 1 minute
    
    -- Entity Categories
    EntityCategories = {
        "ship_core",
        "hyperdrive_engine",
        "hyperdrive_master_engine",
        "hyperdrive_computer",
        "hyperdrive_pulse_cannon",
        "hyperdrive_beam_weapon",
        "hyperdrive_torpedo_launcher",
        "hyperdrive_railgun",
        "hyperdrive_plasma_cannon",
        "hyperdrive_flight_console",
        "hyperdrive_docking_pad",
        "hyperdrive_shuttle",
        "hyperdrive_shield_generator"
    }
}

-- Undo tracking
HYPERDRIVE.Undo.PlayerUndos = {} -- Track undo entries per player
HYPERDRIVE.Undo.EntityGroups = {} -- Track entity groups for group undo
HYPERDRIVE.Undo.CleanupTimer = nil

-- Enhanced undo functions
function HYPERDRIVE.Undo.CreateUndoEntry(player, entity, entityName, description)
    if not HYPERDRIVE.Undo.Config.EnableUndo then return end
    if not IsValid(player) or not IsValid(entity) then return end
    
    local steamID = player:SteamID()
    
    -- Initialize player undo tracking
    if not HYPERDRIVE.Undo.PlayerUndos[steamID] then
        HYPERDRIVE.Undo.PlayerUndos[steamID] = {}
    end
    
    -- Create undo entry
    local undoEntry = {
        entity = entity,
        entityName = entityName or entity:GetClass(),
        description = description or "Hyperdrive Entity",
        timestamp = CurTime(),
        entIndex = entity:EntIndex(),
        position = entity:GetPos(),
        angles = entity:GetAngles(),
        class = entity:GetClass()
    }
    
    -- Add to player's undo list
    table.insert(HYPERDRIVE.Undo.PlayerUndos[steamID], undoEntry)
    
    -- Limit undo entries
    local maxEntries = HYPERDRIVE.Undo.Config.MaxUndoEntries
    if #HYPERDRIVE.Undo.PlayerUndos[steamID] > maxEntries then
        table.remove(HYPERDRIVE.Undo.PlayerUndos[steamID], 1)
    end
    
    -- Set undo ID on entity for cleanup
    entity.UndoID = #HYPERDRIVE.Undo.PlayerUndos[steamID]
    entity.UndoPlayer = steamID
    
    print("[Hyperdrive Undo] Created undo entry for " .. entityName .. " (Player: " .. player:Name() .. ")")
end

function HYPERDRIVE.Undo.CreateGroupUndo(player, entities, groupName, description)
    if not HYPERDRIVE.Undo.Config.EnableGroupUndo then return end
    if not IsValid(player) or not entities or #entities == 0 then return end
    
    local steamID = player:SteamID()
    local groupID = steamID .. "_" .. CurTime()
    
    -- Create group entry
    HYPERDRIVE.Undo.EntityGroups[groupID] = {
        player = steamID,
        entities = {},
        groupName = groupName or "Hyperdrive Group",
        description = description or "Group of hyperdrive entities",
        timestamp = CurTime()
    }
    
    -- Add entities to group
    for _, entity in ipairs(entities) do
        if IsValid(entity) then
            table.insert(HYPERDRIVE.Undo.EntityGroups[groupID].entities, {
                entity = entity,
                entIndex = entity:EntIndex(),
                class = entity:GetClass()
            })
            
            -- Mark entity as part of group
            entity.UndoGroupID = groupID
        end
    end
    
    print("[Hyperdrive Undo] Created group undo for " .. #entities .. " entities (Player: " .. player:Name() .. ")")
end

function HYPERDRIVE.Undo.RemoveEntity(entity)
    if not IsValid(entity) then return end
    
    local steamID = entity.UndoPlayer
    if not steamID or not HYPERDRIVE.Undo.PlayerUndos[steamID] then return end
    
    -- Remove from player's undo list
    for i, undoEntry in ipairs(HYPERDRIVE.Undo.PlayerUndos[steamID]) do
        if undoEntry.entIndex == entity:EntIndex() then
            table.remove(HYPERDRIVE.Undo.PlayerUndos[steamID], i)
            break
        end
    end
    
    -- Remove from group if applicable
    if entity.UndoGroupID then
        local group = HYPERDRIVE.Undo.EntityGroups[entity.UndoGroupID]
        if group then
            for i, groupEntity in ipairs(group.entities) do
                if groupEntity.entIndex == entity:EntIndex() then
                    table.remove(group.entities, i)
                    break
                end
            end
            
            -- Remove empty groups
            if #group.entities == 0 then
                HYPERDRIVE.Undo.EntityGroups[entity.UndoGroupID] = nil
            end
        end
    end
end

function HYPERDRIVE.Undo.UndoLastEntity(player)
    if not IsValid(player) then return false end
    
    local steamID = player:SteamID()
    local undoList = HYPERDRIVE.Undo.PlayerUndos[steamID]
    
    if not undoList or #undoList == 0 then
        player:ChatPrint("[Hyperdrive Undo] No entities to undo")
        return false
    end
    
    -- Get last entity
    local lastEntry = undoList[#undoList]
    if IsValid(lastEntry.entity) then
        local entityName = lastEntry.entityName
        lastEntry.entity:Remove()
        table.remove(undoList, #undoList)
        
        player:ChatPrint("[Hyperdrive Undo] Undone: " .. entityName)
        return true
    else
        -- Entity already removed, clean up entry
        table.remove(undoList, #undoList)
        return HYPERDRIVE.Undo.UndoLastEntity(player) -- Try next entity
    end
end

function HYPERDRIVE.Undo.UndoGroup(player, groupID)
    if not IsValid(player) then return false end
    
    local group = HYPERDRIVE.Undo.EntityGroups[groupID]
    if not group or group.player ~= player:SteamID() then
        player:ChatPrint("[Hyperdrive Undo] Group not found or not owned by you")
        return false
    end
    
    local removedCount = 0
    
    -- Remove all entities in group
    for _, groupEntity in ipairs(group.entities) do
        if IsValid(groupEntity.entity) then
            groupEntity.entity:Remove()
            removedCount = removedCount + 1
        end
    end
    
    -- Remove group
    HYPERDRIVE.Undo.EntityGroups[groupID] = nil
    
    player:ChatPrint("[Hyperdrive Undo] Undone group: " .. group.groupName .. " (" .. removedCount .. " entities)")
    return true
end

function HYPERDRIVE.Undo.CleanupExpiredEntries()
    if not HYPERDRIVE.Undo.Config.EnableCleanup then return end
    
    local currentTime = CurTime()
    local timeout = HYPERDRIVE.Undo.Config.UndoTimeout
    local cleanedCount = 0
    
    -- Clean up player undo entries
    for steamID, undoList in pairs(HYPERDRIVE.Undo.PlayerUndos) do
        for i = #undoList, 1, -1 do
            local entry = undoList[i]
            if currentTime - entry.timestamp > timeout or not IsValid(entry.entity) then
                table.remove(undoList, i)
                cleanedCount = cleanedCount + 1
            end
        end
        
        -- Remove empty lists
        if #undoList == 0 then
            HYPERDRIVE.Undo.PlayerUndos[steamID] = nil
        end
    end
    
    -- Clean up group entries
    for groupID, group in pairs(HYPERDRIVE.Undo.EntityGroups) do
        if currentTime - group.timestamp > timeout then
            HYPERDRIVE.Undo.EntityGroups[groupID] = nil
            cleanedCount = cleanedCount + 1
        else
            -- Clean up invalid entities in groups
            for i = #group.entities, 1, -1 do
                if not IsValid(group.entities[i].entity) then
                    table.remove(group.entities, i)
                end
            end
            
            -- Remove empty groups
            if #group.entities == 0 then
                HYPERDRIVE.Undo.EntityGroups[groupID] = nil
            end
        end
    end
    
    if cleanedCount > 0 then
        print("[Hyperdrive Undo] Cleaned up " .. cleanedCount .. " expired undo entries")
    end
end

function HYPERDRIVE.Undo.GetPlayerUndoCount(player)
    if not IsValid(player) then return 0 end
    
    local steamID = player:SteamID()
    local undoList = HYPERDRIVE.Undo.PlayerUndos[steamID]
    
    return undoList and #undoList or 0
end

function HYPERDRIVE.Undo.GetPlayerUndoList(player)
    if not IsValid(player) then return {} end
    
    local steamID = player:SteamID()
    local undoList = HYPERDRIVE.Undo.PlayerUndos[steamID]
    
    if not undoList then return {} end
    
    local result = {}
    for i, entry in ipairs(undoList) do
        table.insert(result, {
            index = i,
            entityName = entry.entityName,
            description = entry.description,
            timestamp = entry.timestamp,
            valid = IsValid(entry.entity)
        })
    end
    
    return result
end

-- Console commands
if SERVER then
    -- Undo last entity
    concommand.Add("hyperdrive_undo", function(ply, cmd, args)
        if not IsValid(ply) then return end
        HYPERDRIVE.Undo.UndoLastEntity(ply)
    end)
    
    -- Show undo list
    concommand.Add("hyperdrive_undo_list", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local undoList = HYPERDRIVE.Undo.GetPlayerUndoList(ply)
        if #undoList == 0 then
            ply:ChatPrint("[Hyperdrive Undo] No entities in undo list")
            return
        end
        
        ply:ChatPrint("[Hyperdrive Undo] === UNDO LIST ===")
        for _, entry in ipairs(undoList) do
            local status = entry.valid and "Valid" or "Removed"
            local timeAgo = math.floor(CurTime() - entry.timestamp)
            ply:ChatPrint(entry.index .. ". " .. entry.entityName .. " (" .. status .. ", " .. timeAgo .. "s ago)")
        end
    end)
    
    -- Clear undo list
    concommand.Add("hyperdrive_undo_clear", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local steamID = ply:SteamID()
        HYPERDRIVE.Undo.PlayerUndos[steamID] = {}
        ply:ChatPrint("[Hyperdrive Undo] Undo list cleared")
    end)
end

-- Start cleanup timer
if SERVER then
    HYPERDRIVE.Undo.CleanupTimer = timer.Create("HyperdriveUndoCleanup", HYPERDRIVE.Undo.Config.CleanupInterval, 0, function()
        HYPERDRIVE.Undo.CleanupExpiredEntries()
    end)
end

print("[Hyperdrive Undo] Undo System loaded successfully!")
