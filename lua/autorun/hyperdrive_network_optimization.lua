-- Hyperdrive Network Optimization System
-- Advanced networking optimizations for large ship movements and data synchronization

if CLIENT then return end

-- Initialize network optimization system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Network = HYPERDRIVE.Network or {}

print("[Hyperdrive] Network optimization system loading...")

-- Network optimization configuration
HYPERDRIVE.Network.Config = {
    EnableOptimization = true,      -- Enable network optimizations
    BatchSize = 32,                 -- Entities per network batch
    BatchDelay = 0.005,             -- Delay between batches (seconds)
    CompressionLevel = 6,           -- Data compression level (1-9)
    PrioritySystem = true,          -- Enable priority-based updates
    DeltaCompression = true,        -- Enable delta compression
    AdaptiveBatching = true,        -- Adaptive batch sizing
    NetworkPrediction = true,       -- Enable client-side prediction
    MaxBandwidth = 1000000,         -- Max bandwidth per second (bytes)
}

-- Network state tracking
HYPERDRIVE.Network.State = {
    activeBatches = {},
    bandwidthUsage = 0,
    lastBandwidthReset = 0,
    compressionStats = {
        totalBytes = 0,
        compressedBytes = 0,
        compressionRatio = 0
    },
    priorityQueue = {},
    deltaStates = {},
}

-- Network strings for optimized communication
util.AddNetworkString("hyperdrive_batch_movement")
util.AddNetworkString("hyperdrive_delta_update")
util.AddNetworkString("hyperdrive_priority_sync")
util.AddNetworkString("hyperdrive_compression_data")

-- Function to get network configuration
local function GetNetConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("Network", key, HYPERDRIVE.Network.Config[key] or default)
    end
    return HYPERDRIVE.Network.Config[key] or default
end

-- Compress data using LZ4 or similar algorithm
function HYPERDRIVE.Network.CompressData(data)
    if not GetNetConfig("DeltaCompression", true) then
        return data, #data
    end
    
    -- Simple compression simulation (in real implementation, use util.Compress)
    local compressed = util.Compress(data) or data
    local originalSize = #data
    local compressedSize = #compressed
    
    -- Update compression statistics
    local stats = HYPERDRIVE.Network.State.compressionStats
    stats.totalBytes = stats.totalBytes + originalSize
    stats.compressedBytes = stats.compressedBytes + compressedSize
    stats.compressionRatio = stats.compressedBytes / stats.totalBytes
    
    return compressed, compressedSize
end

-- Calculate entity movement priority
function HYPERDRIVE.Network.CalculatePriority(entity, player)
    if not IsValid(entity) or not IsValid(player) then return 0 end
    
    local priority = 100 -- Base priority
    local distance = entity:GetPos():Distance(player:GetPos())
    
    -- Distance-based priority (closer = higher priority)
    priority = priority - (distance / 100)
    
    -- Entity type priority
    if entity:IsPlayer() then
        priority = priority + 50 -- Players are high priority
    elseif entity:IsVehicle() then
        priority = priority + 30 -- Vehicles are medium-high priority
    elseif entity:GetClass():find("hyperdrive") then
        priority = priority + 40 -- Hyperdrive engines are high priority
    end
    
    -- Visibility priority
    local trace = util.TraceLine({
        start = player:EyePos(),
        endpos = entity:GetPos(),
        filter = {player, entity}
    })
    
    if not trace.Hit then
        priority = priority + 20 -- Visible entities get priority boost
    end
    
    return math.max(0, priority)
end

-- Create delta state for entity
function HYPERDRIVE.Network.CreateDeltaState(entity)
    if not IsValid(entity) then return nil end
    
    return {
        position = entity:GetPos(),
        angles = entity:GetAngles(),
        velocity = entity:GetPhysicsObject():IsValid() and entity:GetPhysicsObject():GetVelocity() or Vector(0,0,0),
        timestamp = CurTime()
    }
end

-- Calculate delta between states
function HYPERDRIVE.Network.CalculateDelta(oldState, newState)
    if not oldState or not newState then return newState end
    
    local delta = {}
    local threshold = 1.0 -- Minimum change threshold
    
    -- Position delta
    if oldState.position:Distance(newState.position) > threshold then
        delta.position = newState.position
    end
    
    -- Angle delta
    local angleDiff = math.abs(oldState.angles.p - newState.angles.p) +
                     math.abs(oldState.angles.y - newState.angles.y) +
                     math.abs(oldState.angles.r - newState.angles.r)
    
    if angleDiff > 1.0 then
        delta.angles = newState.angles
    end
    
    -- Velocity delta
    if oldState.velocity:Distance(newState.velocity) > threshold then
        delta.velocity = newState.velocity
    end
    
    delta.timestamp = newState.timestamp
    return delta
end

-- Optimized batch movement system
function HYPERDRIVE.Network.BatchMoveEntities(entities, destination, enginePos, players)
    if not GetNetConfig("EnableOptimization", true) then
        return false
    end
    
    players = players or player.GetAll()
    local batchSize = GetNetConfig("BatchSize", 32)
    local batchDelay = GetNetConfig("BatchDelay", 0.005)
    
    -- Adaptive batch sizing based on entity count and network load
    if GetNetConfig("AdaptiveBatching", true) then
        local networkLoad = HYPERDRIVE.Network.State.bandwidthUsage / GetNetConfig("MaxBandwidth", 1000000)
        if networkLoad > 0.8 then
            batchSize = math.max(8, batchSize / 2) -- Reduce batch size under high load
        elseif networkLoad < 0.3 then
            batchSize = math.min(64, batchSize * 1.5) -- Increase batch size under low load
        end
    end
    
    -- Create priority-sorted entity list for each player
    local playerBatches = {}
    
    for _, ply in ipairs(players) do
        if IsValid(ply) then
            local prioritizedEntities = {}
            
            for _, ent in ipairs(entities) do
                if IsValid(ent) then
                    local priority = HYPERDRIVE.Network.CalculatePriority(ent, ply)
                    table.insert(prioritizedEntities, {entity = ent, priority = priority})
                end
            end
            
            -- Sort by priority (highest first)
            table.sort(prioritizedEntities, function(a, b) return a.priority > b.priority end)
            
            playerBatches[ply] = prioritizedEntities
        end
    end
    
    -- Process batches
    local totalBatches = math.ceil(#entities / batchSize)
    
    for batchIndex = 1, totalBatches do
        timer.Simple(batchDelay * (batchIndex - 1), function()
            local startIdx = (batchIndex - 1) * batchSize + 1
            local endIdx = math.min(batchIndex * batchSize, #entities)
            
            -- Prepare batch data for each player
            for ply, prioritizedEntities in pairs(playerBatches) do
                if IsValid(ply) then
                    local batchData = {}
                    
                    for i = startIdx, math.min(endIdx, #prioritizedEntities) do
                        local entData = prioritizedEntities[i]
                        local ent = entData.entity
                        
                        if IsValid(ent) then
                            local offset = ent:GetPos() - enginePos
                            local newPos = destination + offset
                            
                            -- Create delta state
                            local oldState = HYPERDRIVE.Network.State.deltaStates[ent:EntIndex()]
                            local newState = HYPERDRIVE.Network.CreateDeltaState(ent)
                            newState.position = newPos
                            
                            local delta = HYPERDRIVE.Network.CalculateDelta(oldState, newState)
                            
                            if delta and (delta.position or delta.angles or delta.velocity) then
                                table.insert(batchData, {
                                    entIndex = ent:EntIndex(),
                                    delta = delta,
                                    priority = entData.priority
                                })
                                
                                -- Store new state
                                HYPERDRIVE.Network.State.deltaStates[ent:EntIndex()] = newState
                            end
                        end
                    end
                    
                    -- Send batch if not empty
                    if #batchData > 0 then
                        HYPERDRIVE.Network.SendBatchUpdate(ply, batchData)
                    end
                end
            end
        end)
    end
    
    return true
end

-- Send optimized batch update to client
function HYPERDRIVE.Network.SendBatchUpdate(player, batchData)
    if not IsValid(player) or #batchData == 0 then return end
    
    -- Compress batch data
    local serializedData = util.TableToJSON(batchData)
    local compressedData, compressedSize = HYPERDRIVE.Network.CompressData(serializedData)
    
    -- Check bandwidth limits
    local currentTime = CurTime()
    if currentTime - HYPERDRIVE.Network.State.lastBandwidthReset > 1.0 then
        HYPERDRIVE.Network.State.bandwidthUsage = 0
        HYPERDRIVE.Network.State.lastBandwidthReset = currentTime
    end
    
    local maxBandwidth = GetNetConfig("MaxBandwidth", 1000000)
    if HYPERDRIVE.Network.State.bandwidthUsage + compressedSize > maxBandwidth then
        -- Queue for later transmission
        table.insert(HYPERDRIVE.Network.State.priorityQueue, {
            player = player,
            data = compressedData,
            size = compressedSize,
            timestamp = currentTime
        })
        return
    end
    
    -- Send batch update
    net.Start("hyperdrive_batch_movement")
    net.WriteUInt(compressedSize, 32)
    net.WriteData(compressedData, compressedSize)
    net.Send(player)
    
    -- Update bandwidth usage
    HYPERDRIVE.Network.State.bandwidthUsage = HYPERDRIVE.Network.State.bandwidthUsage + compressedSize
end

-- Process priority queue
function HYPERDRIVE.Network.ProcessPriorityQueue()
    local queue = HYPERDRIVE.Network.State.priorityQueue
    local maxBandwidth = GetNetConfig("MaxBandwidth", 1000000)
    local currentTime = CurTime()
    
    -- Reset bandwidth counter every second
    if currentTime - HYPERDRIVE.Network.State.lastBandwidthReset > 1.0 then
        HYPERDRIVE.Network.State.bandwidthUsage = 0
        HYPERDRIVE.Network.State.lastBandwidthReset = currentTime
    end
    
    -- Process queue items
    for i = #queue, 1, -1 do
        local item = queue[i]
        
        -- Remove stale items (older than 5 seconds)
        if currentTime - item.timestamp > 5.0 then
            table.remove(queue, i)
            continue
        end
        
        -- Check if we can send this item
        if HYPERDRIVE.Network.State.bandwidthUsage + item.size <= maxBandwidth then
            if IsValid(item.player) then
                net.Start("hyperdrive_batch_movement")
                net.WriteUInt(item.size, 32)
                net.WriteData(item.data, item.size)
                net.Send(item.player)
                
                HYPERDRIVE.Network.State.bandwidthUsage = HYPERDRIVE.Network.State.bandwidthUsage + item.size
            end
            
            table.remove(queue, i)
        end
    end
end

-- Network statistics
function HYPERDRIVE.Network.GetStatistics()
    local stats = HYPERDRIVE.Network.State.compressionStats
    
    return {
        compressionRatio = stats.compressionRatio,
        totalBytes = stats.totalBytes,
        compressedBytes = stats.compressedBytes,
        bandwidthUsage = HYPERDRIVE.Network.State.bandwidthUsage,
        queueSize = #HYPERDRIVE.Network.State.priorityQueue,
        deltaStates = table.Count(HYPERDRIVE.Network.State.deltaStates)
    }
end

-- Cleanup old delta states
function HYPERDRIVE.Network.CleanupDeltaStates()
    local currentTime = CurTime()
    local maxAge = 30 -- 30 seconds
    
    for entIndex, state in pairs(HYPERDRIVE.Network.State.deltaStates) do
        if currentTime - state.timestamp > maxAge then
            HYPERDRIVE.Network.State.deltaStates[entIndex] = nil
        end
    end
end

-- Timer for processing priority queue and cleanup
timer.Create("HyperdriveNetworkOptimization", 0.1, 0, function()
    HYPERDRIVE.Network.ProcessPriorityQueue()
end)

timer.Create("HyperdriveNetworkCleanup", 30, 0, function()
    HYPERDRIVE.Network.CleanupDeltaStates()
end)

-- Console commands for network management
concommand.Add("hyperdrive_network_stats", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local stats = HYPERDRIVE.Network.GetStatistics()
    
    ply:ChatPrint("[Hyperdrive Network] Statistics:")
    ply:ChatPrint("  • Compression Ratio: " .. string.format("%.2f%%", stats.compressionRatio * 100))
    ply:ChatPrint("  • Total Bytes: " .. string.format("%.2fKB", stats.totalBytes / 1024))
    ply:ChatPrint("  • Compressed Bytes: " .. string.format("%.2fKB", stats.compressedBytes / 1024))
    ply:ChatPrint("  • Bandwidth Usage: " .. string.format("%.2f%%", (stats.bandwidthUsage / GetNetConfig("MaxBandwidth", 1000000)) * 100))
    ply:ChatPrint("  • Queue Size: " .. stats.queueSize)
    ply:ChatPrint("  • Delta States: " .. stats.deltaStates)
end)

concommand.Add("hyperdrive_network_reset", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    -- Reset network state
    HYPERDRIVE.Network.State = {
        activeBatches = {},
        bandwidthUsage = 0,
        lastBandwidthReset = CurTime(),
        compressionStats = {
            totalBytes = 0,
            compressedBytes = 0,
            compressionRatio = 0
        },
        priorityQueue = {},
        deltaStates = {},
    }
    
    if IsValid(ply) then
        ply:ChatPrint("[Hyperdrive] Network state reset")
    else
        print("[Hyperdrive] Network state reset")
    end
end)

print("[Hyperdrive] Network optimization system loaded")
