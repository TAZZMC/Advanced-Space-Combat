-- Hyperdrive Simple Network System
-- Fallback network system that prevents reliable channel overflow

if CLIENT then return end

HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.SimpleNetwork = HYPERDRIVE.SimpleNetwork or {}

print("[Hyperdrive] Simple network system loading...")

-- Simple network configuration (very conservative)
HYPERDRIVE.SimpleNetwork.Config = {
    MaxEntitiesPerUpdate = 5,       -- Very small batches
    UpdateDelay = 1.0,              -- Long delays between updates
    MaxUpdatesPerSecond = 2,        -- Very low update rate
    MaxPacketSize = 512,            -- Small packets
    EnableRateLimit = true,         -- Always enable rate limiting
}

-- Network state
HYPERDRIVE.SimpleNetwork.State = {
    lastUpdateTime = {},
    updatesThisSecond = {},
    lastSecondReset = 0,
}

-- Check if we can send update to player
function HYPERDRIVE.SimpleNetwork.CanUpdate(player)
    if not IsValid(player) then return false end
    
    local currentTime = CurTime()
    local playerID = player:UserID()
    
    -- Reset counters every second
    if currentTime - HYPERDRIVE.SimpleNetwork.State.lastSecondReset > 1.0 then
        HYPERDRIVE.SimpleNetwork.State.updatesThisSecond = {}
        HYPERDRIVE.SimpleNetwork.State.lastSecondReset = currentTime
    end
    
    -- Check update rate limit
    local updates = HYPERDRIVE.SimpleNetwork.State.updatesThisSecond[playerID] or 0
    if updates >= HYPERDRIVE.SimpleNetwork.Config.MaxUpdatesPerSecond then
        return false
    end
    
    -- Check minimum delay
    local lastUpdate = HYPERDRIVE.SimpleNetwork.State.lastUpdateTime[playerID] or 0
    if currentTime - lastUpdate < HYPERDRIVE.SimpleNetwork.Config.UpdateDelay then
        return false
    end
    
    return true
end

-- Record update sent
function HYPERDRIVE.SimpleNetwork.RecordUpdate(player)
    if not IsValid(player) then return end
    
    local playerID = player:UserID()
    local currentTime = CurTime()
    
    HYPERDRIVE.SimpleNetwork.State.lastUpdateTime[playerID] = currentTime
    HYPERDRIVE.SimpleNetwork.State.updatesThisSecond[playerID] = (HYPERDRIVE.SimpleNetwork.State.updatesThisSecond[playerID] or 0) + 1
end

-- Simple entity movement (no batching, no compression)
function HYPERDRIVE.SimpleNetwork.MoveEntities(entities, destination, enginePos, players)
    if not entities or #entities == 0 then return end
    
    players = players or player.GetAll()
    local maxEntities = HYPERDRIVE.SimpleNetwork.Config.MaxEntitiesPerUpdate
    
    -- Process entities in very small groups with delays
    for i = 1, #entities, maxEntities do
        local delay = (i - 1) / maxEntities * HYPERDRIVE.SimpleNetwork.Config.UpdateDelay
        
        timer.Simple(delay, function()
            local endIdx = math.min(i + maxEntities - 1, #entities)
            local batch = {}
            
            for j = i, endIdx do
                local ent = entities[j]
                if IsValid(ent) then
                    local offset = ent:GetPos() - enginePos
                    local newPos = destination + offset
                    
                    table.insert(batch, {
                        entIndex = ent:EntIndex(),
                        position = newPos,
                        angles = ent:GetAngles()
                    })
                    
                    -- Move entity immediately on server
                    ent:SetPos(newPos)
                end
            end
            
            -- Send to players with rate limiting
            for _, ply in ipairs(players) do
                if IsValid(ply) and HYPERDRIVE.SimpleNetwork.CanUpdate(ply) then
                    HYPERDRIVE.SimpleNetwork.SendSimpleUpdate(ply, batch)
                end
            end
        end)
    end
end

-- Send simple update (no compression, minimal data)
function HYPERDRIVE.SimpleNetwork.SendSimpleUpdate(player, batch)
    if not IsValid(player) or not batch or #batch == 0 then return end
    
    -- Use existing network string or create simple one
    if not util.NetworkStringToID("hyperdrive_simple_move") then
        util.AddNetworkString("hyperdrive_simple_move")
    end
    
    -- Send very simple data
    net.Start("hyperdrive_simple_move")
    net.WriteUInt(#batch, 8) -- Max 255 entities
    
    for _, data in ipairs(batch) do
        net.WriteUInt(data.entIndex, 16) -- Entity index
        net.WriteVector(data.position)   -- New position
        -- Skip angles to reduce packet size
    end
    
    net.Send(player)
    
    -- Record update
    HYPERDRIVE.SimpleNetwork.RecordUpdate(player)
end

-- Simple jump effect (minimal network usage)
function HYPERDRIVE.SimpleNetwork.SendJumpEffect(position, players, effectType)
    players = players or player.GetAll()
    effectType = effectType or "simple"
    
    -- Use existing effect network string
    if util.NetworkStringToID("hyperdrive_effect") then
        for _, ply in ipairs(players) do
            if IsValid(ply) and HYPERDRIVE.SimpleNetwork.CanUpdate(ply) then
                net.Start("hyperdrive_effect")
                net.WriteVector(position)
                net.WriteString(effectType)
                net.WriteFloat(1.0) -- intensity
                net.Send(ply)
                
                HYPERDRIVE.SimpleNetwork.RecordUpdate(ply)
            end
        end
    end
end

-- Simple status update
function HYPERDRIVE.SimpleNetwork.SendStatusUpdate(entity, status, players)
    if not IsValid(entity) then return end
    
    players = players or player.GetAll()
    
    if util.NetworkStringToID("hyperdrive_status_update") then
        for _, ply in ipairs(players) do
            if IsValid(ply) and HYPERDRIVE.SimpleNetwork.CanUpdate(ply) then
                net.Start("hyperdrive_status_update")
                net.WriteEntity(entity)
                net.WriteString(status or "unknown")
                net.Send(ply)
                
                HYPERDRIVE.SimpleNetwork.RecordUpdate(ply)
            end
        end
    end
end

-- Emergency network shutdown
function HYPERDRIVE.SimpleNetwork.EmergencyShutdown()
    print("[Hyperdrive] Emergency network shutdown activated")
    
    -- Clear all timers
    for i = 1, 1000 do
        timer.Remove("HyperdriveNetwork_" .. i)
        timer.Remove("HyperdriveSimple_" .. i)
    end
    
    -- Reset state
    HYPERDRIVE.SimpleNetwork.State = {
        lastUpdateTime = {},
        updatesThisSecond = {},
        lastSecondReset = CurTime(),
    }
    
    -- Disable all network functions temporarily
    HYPERDRIVE.SimpleNetwork.Config.MaxUpdatesPerSecond = 1
    HYPERDRIVE.SimpleNetwork.Config.UpdateDelay = 2.0
    
    print("[Hyperdrive] Network functions severely limited to prevent overflow")
end

-- Console commands
concommand.Add("hyperdrive_network_emergency", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Hyperdrive] Admin access required!")
        return
    end
    
    HYPERDRIVE.SimpleNetwork.EmergencyShutdown()
    
    if IsValid(ply) then
        ply:ChatPrint("[Hyperdrive] Emergency network shutdown activated")
    else
        print("[Hyperdrive] Emergency network shutdown activated")
    end
end)

concommand.Add("hyperdrive_network_status", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local state = HYPERDRIVE.SimpleNetwork.State
    local config = HYPERDRIVE.SimpleNetwork.Config
    
    ply:ChatPrint("[Hyperdrive Simple Network] Status:")
    ply:ChatPrint("  • Max Updates/Second: " .. config.MaxUpdatesPerSecond)
    ply:ChatPrint("  • Update Delay: " .. config.UpdateDelay .. "s")
    ply:ChatPrint("  • Max Entities/Update: " .. config.MaxEntitiesPerUpdate)
    ply:ChatPrint("  • Active Players: " .. table.Count(state.lastUpdateTime))
end)

-- Override complex network functions if they exist
if HYPERDRIVE.Network then
    print("[Hyperdrive] Overriding complex network functions with simple versions")
    
    -- Override the complex batch movement
    HYPERDRIVE.Network.BatchMoveEntities = HYPERDRIVE.SimpleNetwork.MoveEntities
    HYPERDRIVE.Network.SendBatchUpdate = HYPERDRIVE.SimpleNetwork.SendSimpleUpdate
    
    -- Disable complex features
    if HYPERDRIVE.Network.Config then
        HYPERDRIVE.Network.Config.EnableOptimization = false
        HYPERDRIVE.Network.Config.BatchSize = 3
        HYPERDRIVE.Network.Config.BatchDelay = 1.0
        HYPERDRIVE.Network.Config.MaxBandwidth = 10000
    end
end

print("[Hyperdrive] Simple network system loaded - overflow protection active")
