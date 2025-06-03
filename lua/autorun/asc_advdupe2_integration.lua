-- Advanced Space Combat - AdvDupe2 Integration System
-- Comprehensive ship saving and loading with metadata preservation

print("[Advanced Space Combat] AdvDupe2 Integration v3.0.0 - Loading...")

-- Initialize ASC AdvDupe2 integration
ASC = ASC or {}
ASC.AdvDupe2 = ASC.AdvDupe2 or {}
ASC.AdvDupe2.Version = "3.0.0"

-- Configuration
ASC.AdvDupe2.Config = {
    -- Ship detection settings
    DefaultRadius = 2000,
    MaxRadius = 5000,
    MinComponents = 2,
    
    -- Saving settings
    SaveMetadata = true,
    PreserveWires = true,
    PreserveOwnership = true,
    
    -- File management
    MaxSavedShips = 50,
    AutoBackup = true,
    BackupInterval = 3600, -- 1 hour
    
    -- Integration settings
    RequireShipCore = true,
    SaveCAP = true,
    SaveWiremod = true
}

-- Check if AdvDupe2 is available
ASC.AdvDupe2.IsAvailable = function()
    return AdvDupe2 ~= nil and AdvDupe2.SaveDupe ~= nil
end

-- Get AdvDupe2 version
ASC.AdvDupe2.GetVersion = function()
    if not ASC.AdvDupe2.IsAvailable() then return "Not Available" end
    return AdvDupe2.Version or "Unknown"
end

-- Detect ship entities from ship core
ASC.AdvDupe2.DetectShipEntities = function(shipCore, radius)
    if not IsValid(shipCore) then return {} end
    
    local entities = {}
    local owner = nil
    if shipCore.CPPIGetOwner then
        owner = shipCore:CPPIGetOwner()
    else
        owner = shipCore:GetOwner()
    end
    local searchRadius = radius or ASC.AdvDupe2.Config.DefaultRadius
    
    for _, ent in ipairs(ents.FindInSphere(shipCore:GetPos(), searchRadius)) do
        if IsValid(ent) and ent ~= shipCore then
            local entOwner = nil
            if ent.CPPIGetOwner then
                entOwner = ent:CPPIGetOwner()
            else
                entOwner = ent:GetOwner()
            end
            if IsValid(owner) and IsValid(entOwner) and owner == entOwner then
                table.insert(entities, ent)
            end
        end
    end
    
    -- Always include the ship core
    table.insert(entities, shipCore)
    
    return entities
end

-- Create ship metadata
ASC.AdvDupe2.CreateShipMetadata = function(player, shipCore, entities, name, description)
    local metadata = {
        -- Basic information
        ship_name = name or "Unnamed Ship",
        description = description or "",
        version = ASC.AdvDupe2.Version,
        created = os.time(),
        
        -- Player information
        owner_steamid = player:SteamID(),
        owner_name = player:Name(),
        
        -- Ship information
        ship_core_class = shipCore:GetClass(),
        ship_core_pos = shipCore:GetPos(),
        component_count = #entities,
        
        -- Component analysis
        components = {},
        
        -- Performance data
        estimated_mass = 0,
        estimated_power = 0,
        weapon_count = 0,
        engine_count = 0,
        shield_count = 0
    }
    
    -- Analyze components
    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            local class = ent:GetClass()
            table.insert(metadata.components, {
                class = class,
                model = ent:GetModel(),
                position = ent:GetPos() - shipCore:GetPos(), -- Relative position
                angles = ent:GetAngles()
            })
            
            -- Count specific component types
            if string.find(class, "weapon") or string.find(class, "cannon") or string.find(class, "railgun") then
                metadata.weapon_count = metadata.weapon_count + 1
            elseif string.find(class, "engine") or string.find(class, "hyperdrive") then
                metadata.engine_count = metadata.engine_count + 1
            elseif string.find(class, "shield") or string.find(class, "barrier") then
                metadata.shield_count = metadata.shield_count + 1
            end
            
            -- Estimate mass and power
            metadata.estimated_mass = metadata.estimated_mass + (ent:GetPhysicsObject():IsValid() and ent:GetPhysicsObject():GetMass() or 100)
        end
    end
    
    -- CAP integration
    if ASC.AI and ASC.AI.CAP and ASC.AI.CAP.IsAvailable() then
        metadata.cap_entities = {}
        for _, ent in ipairs(entities) do
            local isCAP, category, component = ASC.AI.CAP.Utils.IsCAPEntity(ent)
            if isCAP then
                table.insert(metadata.cap_entities, {
                    class = ent:GetClass(),
                    category = category,
                    component = component
                })
            end
        end
        metadata.cap_count = #metadata.cap_entities
    end
    
    return metadata
end

-- Save ship with AdvDupe2
ASC.AdvDupe2.SaveShip = function(player, shipCore, name, description)
    if not IsValid(player) or not IsValid(shipCore) then
        return false, "Invalid player or ship core"
    end
    
    if not ASC.AdvDupe2.IsAvailable() then
        return false, "AdvDupe2 not available"
    end
    
    -- Detect ship entities
    local entities = ASC.AdvDupe2.DetectShipEntities(shipCore)
    
    if #entities < ASC.AdvDupe2.Config.MinComponents then
        return false, "Ship too small (minimum " .. ASC.AdvDupe2.Config.MinComponents .. " components)"
    end
    
    -- Create metadata
    local metadata = ASC.AdvDupe2.CreateShipMetadata(player, shipCore, entities, name, description)
    
    -- Save with AdvDupe2
    local success, error = pcall(function()
        return AdvDupe2.SaveDupe(player, entities, name, metadata)
    end)
    
    if success then
        -- Log the save
        ASC.AdvDupe2.LogShipSave(player, name, metadata)
        return true, "Ship saved successfully"
    else
        return false, "AdvDupe2 save failed: " .. tostring(error)
    end
end

-- Load ship with AdvDupe2
ASC.AdvDupe2.LoadShip = function(player, name, position, angles)
    if not IsValid(player) then
        return false, "Invalid player"
    end
    
    if not ASC.AdvDupe2.IsAvailable() then
        return false, "AdvDupe2 not available"
    end
    
    -- Load with AdvDupe2
    local success, error = pcall(function()
        return AdvDupe2.LoadDupe(player, name, position, angles)
    end)
    
    if success then
        -- Log the load
        ASC.AdvDupe2.LogShipLoad(player, name)
        return true, "Ship loaded successfully"
    else
        return false, "AdvDupe2 load failed: " .. tostring(error)
    end
end

-- Get saved ships list
ASC.AdvDupe2.GetSavedShips = function(player)
    if not IsValid(player) or not ASC.AdvDupe2.IsAvailable() then
        return {}
    end
    
    local ships = {}
    local success, dupes = pcall(function()
        return AdvDupe2.GetDupes(player)
    end)
    
    if success and dupes then
        for _, dupe in ipairs(dupes) do
            if dupe.metadata and dupe.metadata.version and string.find(dupe.metadata.version, "ASC") then
                table.insert(ships, {
                    name = dupe.name,
                    metadata = dupe.metadata,
                    size = dupe.size or 0,
                    created = dupe.created or 0
                })
            end
        end
    end
    
    return ships
end

-- Delete saved ship
ASC.AdvDupe2.DeleteShip = function(player, name)
    if not IsValid(player) or not ASC.AdvDupe2.IsAvailable() then
        return false, "Invalid player or AdvDupe2 not available"
    end
    
    local success, error = pcall(function()
        return AdvDupe2.DeleteDupe(player, name)
    end)
    
    if success then
        ASC.AdvDupe2.LogShipDelete(player, name)
        return true, "Ship deleted successfully"
    else
        return false, "Failed to delete ship: " .. tostring(error)
    end
end

-- Ship operation logging
ASC.AdvDupe2.ShipLog = {}

ASC.AdvDupe2.LogShipSave = function(player, name, metadata)
    table.insert(ASC.AdvDupe2.ShipLog, {
        action = "save",
        player = player:SteamID(),
        player_name = player:Name(),
        ship_name = name,
        timestamp = os.time(),
        metadata = metadata
    })
    
    -- Keep log manageable
    if #ASC.AdvDupe2.ShipLog > 1000 then
        table.remove(ASC.AdvDupe2.ShipLog, 1)
    end
end

ASC.AdvDupe2.LogShipLoad = function(player, name)
    table.insert(ASC.AdvDupe2.ShipLog, {
        action = "load",
        player = player:SteamID(),
        player_name = player:Name(),
        ship_name = name,
        timestamp = os.time()
    })
end

ASC.AdvDupe2.LogShipDelete = function(player, name)
    table.insert(ASC.AdvDupe2.ShipLog, {
        action = "delete",
        player = player:SteamID(),
        player_name = player:Name(),
        ship_name = name,
        timestamp = os.time()
    })
end

-- Console commands
if SERVER then
    concommand.Add("asc_save_ship", function(player, cmd, args)
        if not IsValid(player) then return end
        
        local trace = player:GetEyeTrace()
        if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "ship_core" then
            player:ChatPrint("[ASC] Look at a ship core to save the ship")
            return
        end
        
        local name = args[1] or "Unnamed Ship"
        local description = table.concat(args, " ", 2) or ""
        
        local success, message = ASC.AdvDupe2.SaveShip(player, trace.Entity, name, description)
        player:ChatPrint("[ASC] " .. message)
    end)
    
    concommand.Add("asc_load_ship", function(player, cmd, args)
        if not IsValid(player) then return end
        
        local name = args[1]
        if not name then
            player:ChatPrint("[ASC] Usage: asc_load_ship <name>")
            return
        end
        
        local position = player:GetPos() + player:GetAimVector() * 500
        local angles = player:GetAngles()
        
        local success, message = ASC.AdvDupe2.LoadShip(player, name, position, angles)
        player:ChatPrint("[ASC] " .. message)
    end)
    
    concommand.Add("asc_list_ships", function(player, cmd, args)
        if not IsValid(player) then return end
        
        local ships = ASC.AdvDupe2.GetSavedShips(player)
        
        if #ships == 0 then
            player:ChatPrint("[ASC] No saved ships found")
            return
        end
        
        player:ChatPrint("[ASC] Saved Ships:")
        for i, ship in ipairs(ships) do
            local info = ship.name
            if ship.metadata then
                info = info .. " (" .. ship.metadata.component_count .. " components)"
            end
            player:ChatPrint("  " .. i .. ". " .. info)
        end
    end)
end

-- Initialize integration
hook.Add("Initialize", "ASC_AdvDupe2_Initialize", function()
    if ASC.AdvDupe2.IsAvailable() then
        print("[Advanced Space Combat] AdvDupe2 integration active - Version: " .. ASC.AdvDupe2.GetVersion())
    else
        print("[Advanced Space Combat] AdvDupe2 not detected - Ship saving disabled")
    end
end)

print("[Advanced Space Combat] AdvDupe2 Integration loaded successfully")
