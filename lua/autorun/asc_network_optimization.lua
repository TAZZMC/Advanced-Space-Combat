-- Advanced Space Combat - Network Optimization System v1.0.0
-- Advanced networking optimization based on 2024-2025 best practices

print("[Advanced Space Combat] Network Optimization System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.NetworkOptimization = ASC.NetworkOptimization or {}

-- Network optimization configuration
ASC.NetworkOptimization.Config = {
    -- Message batching
    EnableBatching = true,
    BatchSize = 10, -- Messages per batch
    BatchTimeout = 0.05, -- Max time to wait for batch
    MaxBatchSize = 32, -- Maximum messages in one batch
    
    -- Rate limiting
    MaxMessagesPerSecond = 50, -- Per player
    GlobalMessageLimit = 500, -- Server-wide per second
    BurstLimit = 10, -- Allow short bursts
    
    -- Compression
    EnableCompression = true,
    CompressionThreshold = 100, -- Bytes - compress if larger
    CompressionLevel = 6, -- 1-9, 6 is good balance
    
    -- Priority system
    EnablePriority = true,
    PriorityLevels = {
        Critical = 1,   -- Ship core updates, emergency
        High = 2,       -- Weapon firing, movement
        Normal = 3,     -- Status updates
        Low = 4         -- Chat, non-critical
    },
    
    -- Adaptive optimization
    EnableAdaptive = true,
    LatencyThreshold = 100, -- ms
    PacketLossThreshold = 0.05, -- 5%
    
    -- Entity networking
    MaxNetworkedEntities = 100,
    EntityUpdateDistance = 2000,
    EntityUpdateRate = 20, -- Hz
    DeltaCompression = true
}

-- Network optimization state
ASC.NetworkOptimization.State = {
    MessageQueue = {},
    BatchQueue = {},
    PlayerRates = {},
    GlobalMessageCount = 0,
    LastRateReset = 0,
    
    -- Statistics
    MessagesSent = 0,
    MessagesQueued = 0,
    BytesSent = 0,
    BytesCompressed = 0,
    CompressionRatio = 0,
    
    -- Performance tracking
    AverageLatency = 0,
    PacketLoss = 0,
    NetworkLoad = 0
}

-- Initialize network optimization
function ASC.NetworkOptimization.Initialize()
    print("[Advanced Space Combat] Initializing network optimization...")
    
    -- Set up message batching
    ASC.NetworkOptimization.SetupBatching()
    
    -- Set up rate limiting
    ASC.NetworkOptimization.SetupRateLimiting()
    
    -- Optimize existing network functions
    ASC.NetworkOptimization.OptimizeNetworkFunctions()
    
    -- Set up monitoring
    ASC.NetworkOptimization.SetupMonitoring()
    
    print("[Advanced Space Combat] Network optimization initialized")
end

-- Set up message batching
function ASC.NetworkOptimization.SetupBatching()
    if not ASC.NetworkOptimization.Config.EnableBatching then return end
    
    -- Process batch queue regularly
    timer.Create("ASC_NetworkBatching", ASC.NetworkOptimization.Config.BatchTimeout, 0, function()
        ASC.NetworkOptimization.ProcessBatchQueue()
    end)
end

-- Set up rate limiting
function ASC.NetworkOptimization.SetupRateLimiting()
    -- Reset rate counters every second
    timer.Create("ASC_NetworkRateReset", 1, 0, function()
        ASC.NetworkOptimization.ResetRateCounters()
    end)
end

-- Process batch queue
function ASC.NetworkOptimization.ProcessBatchQueue()
    local state = ASC.NetworkOptimization.State
    local config = ASC.NetworkOptimization.Config
    
    if #state.BatchQueue == 0 then return end
    
    -- Group messages by recipient
    local batches = {}
    
    for _, message in ipairs(state.BatchQueue) do
        local recipient = message.recipient or "broadcast"
        
        if not batches[recipient] then
            batches[recipient] = {}
        end
        
        table.insert(batches[recipient], message)
    end
    
    -- Send batches
    for recipient, messages in pairs(batches) do
        if #messages >= config.BatchSize or CurTime() - messages[1].timestamp > config.BatchTimeout then
            ASC.NetworkOptimization.SendBatch(recipient, messages)
        end
    end
    
    -- Clear processed messages
    state.BatchQueue = {}
end

-- Send batch of messages
function ASC.NetworkOptimization.SendBatch(recipient, messages)
    if #messages == 0 then return end
    
    local config = ASC.NetworkOptimization.Config
    local state = ASC.NetworkOptimization.State
    
    -- Prepare batch data
    local batchData = {
        messages = {},
        timestamp = CurTime(),
        count = #messages
    }
    
    for _, message in ipairs(messages) do
        table.insert(batchData.messages, {
            type = message.type,
            data = message.data,
            priority = message.priority or config.PriorityLevels.Normal
        })
    end
    
    -- Serialize and compress if needed
    local serialized = util.TableToJSON(batchData)
    local dataToSend = serialized
    local originalSize = #serialized
    
    if config.EnableCompression and originalSize > config.CompressionThreshold then
        dataToSend = util.Compress(serialized)
        local compressedSize = #dataToSend
        
        state.BytesCompressed = state.BytesCompressed + (originalSize - compressedSize)
        state.CompressionRatio = state.BytesCompressed / math.max(1, state.BytesSent)
    end
    
    -- Send the batch
    net.Start("ASC_NetworkBatch")
    net.WriteUInt(#dataToSend, 32)
    net.WriteData(dataToSend, #dataToSend)
    
    if recipient == "broadcast" then
        net.Broadcast()
    else
        net.Send(recipient)
    end
    
    -- Update statistics
    state.MessagesSent = state.MessagesSent + #messages
    state.BytesSent = state.BytesSent + #dataToSend
end

-- Queue message for batching
function ASC.NetworkOptimization.QueueMessage(messageType, data, recipient, priority)
    local state = ASC.NetworkOptimization.State
    local config = ASC.NetworkOptimization.Config
    
    -- Check rate limiting
    if not ASC.NetworkOptimization.CanSendMessage(recipient) then
        return false, "Rate limit exceeded"
    end
    
    local message = {
        type = messageType,
        data = data,
        recipient = recipient,
        priority = priority or config.PriorityLevels.Normal,
        timestamp = CurTime()
    }
    
    table.insert(state.BatchQueue, message)
    state.MessagesQueued = state.MessagesQueued + 1
    
    -- Send immediately if batch is full or high priority
    if #state.BatchQueue >= config.MaxBatchSize or priority == config.PriorityLevels.Critical then
        ASC.NetworkOptimization.ProcessBatchQueue()
    end
    
    return true
end

-- Check if message can be sent (rate limiting)
function ASC.NetworkOptimization.CanSendMessage(recipient)
    local state = ASC.NetworkOptimization.State
    local config = ASC.NetworkOptimization.Config
    local currentTime = CurTime()
    
    -- Check global rate limit
    if state.GlobalMessageCount >= config.GlobalMessageLimit then
        return false
    end
    
    -- Check per-player rate limit
    if recipient and IsValid(recipient) then
        local playerID = recipient:SteamID()
        local playerRate = state.PlayerRates[playerID] or 0
        
        if playerRate >= config.MaxMessagesPerSecond then
            return false
        end
        
        state.PlayerRates[playerID] = playerRate + 1
    end
    
    state.GlobalMessageCount = state.GlobalMessageCount + 1
    return true
end

-- Reset rate counters
function ASC.NetworkOptimization.ResetRateCounters()
    local state = ASC.NetworkOptimization.State
    
    state.PlayerRates = {}
    state.GlobalMessageCount = 0
    state.LastRateReset = CurTime()
end

-- Optimize existing network functions
function ASC.NetworkOptimization.OptimizeNetworkFunctions()
    -- Add network string for batching
    if SERVER then
        util.AddNetworkString("ASC_NetworkBatch")
    end
    
    -- Optimize HYPERDRIVE network functions if available
    if HYPERDRIVE and HYPERDRIVE.Network then
        ASC.NetworkOptimization.OptimizeHyperdriveNetwork()
    end
    
    print("[Advanced Space Combat] Network functions optimized")
end

-- Optimize HYPERDRIVE network functions
function ASC.NetworkOptimization.OptimizeHyperdriveNetwork()
    if not HYPERDRIVE.Network.SendBatchUpdate then return end
    
    local originalSendBatch = HYPERDRIVE.Network.SendBatchUpdate
    
    HYPERDRIVE.Network.SendBatchUpdate = function(player, batchData)
        -- Use optimized batching system
        return ASC.NetworkOptimization.QueueMessage("hyperdrive_batch", batchData, player, ASC.NetworkOptimization.Config.PriorityLevels.High)
    end
end

-- Set up monitoring
function ASC.NetworkOptimization.SetupMonitoring()
    -- Monitor network performance
    timer.Create("ASC_NetworkMonitoring", 5, 0, function()
        ASC.NetworkOptimization.UpdateNetworkMetrics()
    end)
end

-- Update network metrics
function ASC.NetworkOptimization.UpdateNetworkMetrics()
    local state = ASC.NetworkOptimization.State
    
    -- Calculate network load
    local messagesPerSecond = state.MessagesSent / math.max(1, CurTime() - state.LastRateReset)
    state.NetworkLoad = messagesPerSecond / ASC.NetworkOptimization.Config.GlobalMessageLimit
    
    -- Adaptive optimization based on performance
    if ASC.NetworkOptimization.Config.EnableAdaptive then
        ASC.NetworkOptimization.AdaptiveOptimization()
    end
end

-- Adaptive optimization
function ASC.NetworkOptimization.AdaptiveOptimization()
    local state = ASC.NetworkOptimization.State
    local config = ASC.NetworkOptimization.Config
    
    -- Reduce batch size if network is overloaded
    if state.NetworkLoad > 0.8 then
        config.BatchSize = math.max(5, config.BatchSize - 1)
        config.BatchTimeout = math.min(0.1, config.BatchTimeout + 0.01)
    elseif state.NetworkLoad < 0.3 then
        config.BatchSize = math.min(15, config.BatchSize + 1)
        config.BatchTimeout = math.max(0.02, config.BatchTimeout - 0.01)
    end
end

-- Get network statistics
function ASC.NetworkOptimization.GetStatistics()
    local state = ASC.NetworkOptimization.State
    local config = ASC.NetworkOptimization.Config
    
    local stats = {
        "=== Network Optimization Statistics ===",
        "Messages Sent: " .. state.MessagesSent,
        "Messages Queued: " .. state.MessagesQueued,
        "Bytes Sent: " .. string.format("%.2f", state.BytesSent / 1024) .. " KB",
        "Bytes Compressed: " .. string.format("%.2f", state.BytesCompressed / 1024) .. " KB",
        "Compression Ratio: " .. string.format("%.1f", state.CompressionRatio * 100) .. "%",
        "Network Load: " .. string.format("%.1f", state.NetworkLoad * 100) .. "%",
        "Current Batch Size: " .. config.BatchSize,
        "Current Batch Timeout: " .. string.format("%.3f", config.BatchTimeout) .. "s",
        "Queued Messages: " .. #state.BatchQueue
    }
    
    return stats
end

-- Console commands
concommand.Add("asc_network_stats", function(ply, cmd, args)
    local stats = ASC.NetworkOptimization.GetStatistics()
    
    if IsValid(ply) then
        for _, line in ipairs(stats) do
            ply:ChatPrint(line)
        end
    else
        for _, line in ipairs(stats) do
            print(line)
        end
    end
end, nil, "Show network optimization statistics")

concommand.Add("asc_network_flush", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Advanced Space Combat] Admin only command")
        return
    end
    
    ASC.NetworkOptimization.ProcessBatchQueue()
    
    local msg = "[Advanced Space Combat] Network queue flushed"
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end, nil, "Flush network message queue (Admin only)")

-- Initialize on load
timer.Simple(1, function()
    ASC.NetworkOptimization.Initialize()
end)

print("[Advanced Space Combat] Network Optimization System loaded successfully!")
