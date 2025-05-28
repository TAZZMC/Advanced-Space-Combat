-- Hyperdrive Destination Management System
if CLIENT then return end

HYPERDRIVE.Destinations = HYPERDRIVE.Destinations or {}

-- Predefined destinations for common maps
local function InitializeMapDestinations()
    local mapName = game.GetMap()
    
    -- Clear existing destinations
    HYPERDRIVE.Destinations = {}
    
    -- Add map-specific destinations
    if string.find(mapName, "gm_construct") then
        HYPERDRIVE.Destinations["Spawn"] = Vector(-47, -1137, -79)
        HYPERDRIVE.Destinations["Tower Top"] = Vector(978, 1434, 1096)
        HYPERDRIVE.Destinations["Underground"] = Vector(-1087, 756, -415)
        HYPERDRIVE.Destinations["Cliff"] = Vector(2893, -1027, 128)
    elseif string.find(mapName, "gm_flatgrass") then
        HYPERDRIVE.Destinations["Center"] = Vector(0, 0, 0)
        HYPERDRIVE.Destinations["North"] = Vector(0, 2000, 0)
        HYPERDRIVE.Destinations["South"] = Vector(0, -2000, 0)
        HYPERDRIVE.Destinations["East"] = Vector(2000, 0, 0)
        HYPERDRIVE.Destinations["West"] = Vector(-2000, 0, 0)
    elseif string.find(mapName, "gm_bigcity") then
        HYPERDRIVE.Destinations["City Center"] = Vector(0, 0, 100)
        HYPERDRIVE.Destinations["Skyscraper"] = Vector(1500, 1500, 500)
        HYPERDRIVE.Destinations["Harbor"] = Vector(-2000, 0, 50)
    else
        -- Generic destinations for unknown maps
        HYPERDRIVE.Destinations["Origin"] = Vector(0, 0, 100)
    end
    
    print("[Hyperdrive] Loaded " .. table.Count(HYPERDRIVE.Destinations) .. " destinations for " .. mapName)
end

-- Save destinations to file
local function SaveDestinations()
    local data = util.TableToJSON(HYPERDRIVE.Destinations)
    if not data then return false end
    
    file.CreateDir("hyperdrive")
    file.Write("hyperdrive/destinations_" .. game.GetMap() .. ".txt", data)
    return true
end

-- Load destinations from file
local function LoadDestinations()
    local fileName = "hyperdrive/destinations_" .. game.GetMap() .. ".txt"
    if not file.Exists(fileName, "DATA") then return false end
    
    local data = file.Read(fileName, "DATA")
    if not data then return false end
    
    local destinations = util.JSONToTable(data)
    if not destinations then return false end
    
    HYPERDRIVE.Destinations = destinations
    return true
end

-- Add a new destination
function HYPERDRIVE.AddDestination(name, pos, ply)
    if not name or not pos or not isvector(pos) then return false, "Invalid parameters" end
    if not HYPERDRIVE.IsValidDestination(pos) then return false, "Invalid destination position" end
    
    HYPERDRIVE.Destinations[name] = pos
    SaveDestinations()
    
    if IsValid(ply) then
        ply:ChatPrint("[Hyperdrive] Destination '" .. name .. "' added!")
    end
    
    print("[Hyperdrive] Destination '" .. name .. "' added by " .. (IsValid(ply) and ply:Nick() or "server"))
    return true, "Destination added"
end

-- Remove a destination
function HYPERDRIVE.RemoveDestination(name, ply)
    if not name or not HYPERDRIVE.Destinations[name] then return false, "Destination not found" end
    
    HYPERDRIVE.Destinations[name] = nil
    SaveDestinations()
    
    if IsValid(ply) then
        ply:ChatPrint("[Hyperdrive] Destination '" .. name .. "' removed!")
    end
    
    print("[Hyperdrive] Destination '" .. name .. "' removed by " .. (IsValid(ply) and ply:Nick() or "server"))
    return true, "Destination removed"
end

-- Get destination position by name
function HYPERDRIVE.GetDestination(name)
    return HYPERDRIVE.Destinations[name]
end

-- List all destinations
function HYPERDRIVE.ListDestinations()
    return HYPERDRIVE.Destinations
end

-- Console commands for destination management
concommand.Add("hyperdrive_add_destination", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    if #args < 1 then
        ply:ChatPrint("[Hyperdrive] Usage: hyperdrive_add_destination <name>")
        return
    end
    
    local name = args[1]
    local trace = ply:GetEyeTrace()
    
    if not trace.Hit then
        ply:ChatPrint("[Hyperdrive] Look at a valid location!")
        return
    end
    
    local pos = trace.HitPos + Vector(0, 0, 50)
    local success, message = HYPERDRIVE.AddDestination(name, pos, ply)
    
    if not success then
        ply:ChatPrint("[Hyperdrive] Error: " .. message)
    end
end)

concommand.Add("hyperdrive_remove_destination", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    if #args < 1 then
        ply:ChatPrint("[Hyperdrive] Usage: hyperdrive_remove_destination <name>")
        return
    end
    
    local name = args[1]
    local success, message = HYPERDRIVE.RemoveDestination(name, ply)
    
    if not success then
        ply:ChatPrint("[Hyperdrive] Error: " .. message)
    end
end)

concommand.Add("hyperdrive_list_destinations", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local destinations = HYPERDRIVE.ListDestinations()
    
    if table.Count(destinations) == 0 then
        ply:ChatPrint("[Hyperdrive] No destinations available")
        return
    end
    
    ply:ChatPrint("[Hyperdrive] Available destinations:")
    for name, pos in pairs(destinations) do
        local distance = ply:GetPos():Distance(pos)
        ply:ChatPrint("  • " .. name .. " (" .. HYPERDRIVE.FormatDistance(distance) .. ")")
    end
end)

concommand.Add("hyperdrive_goto", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    if #args < 1 then
        ply:ChatPrint("[Hyperdrive] Usage: hyperdrive_goto <destination>")
        return
    end
    
    local name = args[1]
    local pos = HYPERDRIVE.GetDestination(name)
    
    if not pos then
        ply:ChatPrint("[Hyperdrive] Destination '" .. name .. "' not found!")
        return
    end
    
    ply:SetPos(pos)
    ply:ChatPrint("[Hyperdrive] Teleported to " .. name)
end)

-- Network destination list to clients
util.AddNetworkString("hyperdrive_destinations")

local function SendDestinationsToClient(ply)
    net.Start("hyperdrive_destinations")
    net.WriteTable(HYPERDRIVE.Destinations)
    net.Send(ply)
end

-- Send destinations when player spawns
hook.Add("PlayerSpawn", "HyperdriveDestinations", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            SendDestinationsToClient(ply)
        end
    end)
end)

-- Initialize destinations on server start
hook.Add("Initialize", "HyperdriveDestinationsInit", function()
    timer.Simple(1, function()
        if not LoadDestinations() then
            InitializeMapDestinations()
            SaveDestinations()
        end
        
        print("[Hyperdrive] Destination system initialized")
    end)
end)

-- Refresh destinations for all players
local function RefreshDestinationsForAll()
    for _, ply in ipairs(player.GetAll()) do
        SendDestinationsToClient(ply)
    end
end

-- Hook for when destinations change
hook.Add("HyperdriveDestinationChanged", "RefreshClients", RefreshDestinationsForAll)
