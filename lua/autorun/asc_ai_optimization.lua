-- Advanced Space Combat - AI System Optimization v1.0.0
-- Optimizes ARIA-4 AI system for better performance and memory management

print("[Advanced Space Combat] AI System Optimization v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.AIOptimization = ASC.AIOptimization or {}

-- AI optimization configuration
ASC.AIOptimization.Config = {
    -- Memory management
    MaxConversationHistory = 50, -- Limit conversation history per player
    MaxUserProfiles = 100, -- Maximum user profiles to keep
    ProfileCleanupInterval = 300, -- Clean old profiles every 5 minutes
    ConversationCleanupAge = 3600, -- Remove conversations older than 1 hour
    
    -- Performance optimization
    MaxProcessingTime = 0.01, -- 10ms max per AI query
    QueryCacheSize = 200, -- Cache common queries
    ResponseCacheTimeout = 300, -- Cache responses for 5 minutes
    BatchProcessing = true, -- Process multiple queries in batches
    
    -- Rate limiting
    MaxQueriesPerPlayer = 10, -- Per minute
    GlobalQueryLimit = 100, -- Per minute across all players
    CooldownPeriod = 2, -- Seconds between queries per player
    
    -- Quality settings
    EnableAdvancedNLP = true,
    EnableContextAnalysis = true,
    EnableLearning = true,
    EnableProactiveAssistance = false -- Disabled for performance
}

-- AI optimization state
ASC.AIOptimization.State = {
    QueryCache = {},
    ResponseCache = {},
    PlayerCooldowns = {},
    QueryCounts = {},
    LastCleanup = 0,
    ProcessingQueue = {},
    
    -- Statistics
    QueriesProcessed = 0,
    CacheHits = 0,
    CacheMisses = 0,
    MemoryFreed = 0
}

-- Initialize AI optimization
function ASC.AIOptimization.Initialize()
    print("[Advanced Space Combat] Initializing AI optimization...")
    
    -- Set up cleanup timers
    ASC.AIOptimization.SetupCleanupTimers()
    
    -- Optimize existing AI functions
    ASC.AIOptimization.OptimizeAIFunctions()
    
    -- Set up performance monitoring
    ASC.AIOptimization.SetupMonitoring()
    
    print("[Advanced Space Combat] AI optimization initialized")
end

-- Set up cleanup timers
function ASC.AIOptimization.SetupCleanupTimers()
    -- Profile cleanup timer
    timer.Create("ASC_AI_ProfileCleanup", ASC.AIOptimization.Config.ProfileCleanupInterval, 0, function()
        ASC.AIOptimization.CleanupUserProfiles()
    end)
    
    -- Conversation cleanup timer
    timer.Create("ASC_AI_ConversationCleanup", 60, 0, function()
        ASC.AIOptimization.CleanupConversations()
    end)
    
    -- Cache cleanup timer
    timer.Create("ASC_AI_CacheCleanup", 300, 0, function()
        ASC.AIOptimization.CleanupCaches()
    end)
end

-- Clean up old user profiles
function ASC.AIOptimization.CleanupUserProfiles()
    if not ASC.AI or not ASC.AI.UserProfiles then return end
    
    local currentTime = CurTime()
    local cleaned = 0
    local memoryBefore = collectgarbage("count")
    
    -- Remove profiles for players who haven't been seen recently
    for steamID, profile in pairs(ASC.AI.UserProfiles) do
        local lastSeen = profile.lastSeen or 0
        
        if currentTime - lastSeen > ASC.AIOptimization.Config.ConversationCleanupAge then
            ASC.AI.UserProfiles[steamID] = nil
            cleaned = cleaned + 1
        end
    end
    
    -- Limit total profiles
    local profileCount = table.Count(ASC.AI.UserProfiles)
    if profileCount > ASC.AIOptimization.Config.MaxUserProfiles then
        -- Remove oldest profiles
        local profiles = {}
        for steamID, profile in pairs(ASC.AI.UserProfiles) do
            table.insert(profiles, {steamID = steamID, lastSeen = profile.lastSeen or 0})
        end
        
        table.sort(profiles, function(a, b) return a.lastSeen < b.lastSeen end)
        
        local toRemove = profileCount - ASC.AIOptimization.Config.MaxUserProfiles
        for i = 1, toRemove do
            ASC.AI.UserProfiles[profiles[i].steamID] = nil
            cleaned = cleaned + 1
        end
    end
    
    local memoryAfter = collectgarbage("count")
    local memoryFreed = memoryBefore - memoryAfter
    ASC.AIOptimization.State.MemoryFreed = ASC.AIOptimization.State.MemoryFreed + memoryFreed
    
    if cleaned > 0 then
        print("[Advanced Space Combat] AI Profile cleanup: " .. cleaned .. " profiles removed, " .. 
              string.format("%.2f", memoryFreed) .. " KB freed")
    end
end

-- Clean up old conversations
function ASC.AIOptimization.CleanupConversations()
    if not ASC.AI or not ASC.AI.ConversationHistory then return end
    
    local currentTime = CurTime()
    local cleaned = 0
    
    for steamID, history in pairs(ASC.AI.ConversationHistory) do
        if #history > ASC.AIOptimization.Config.MaxConversationHistory then
            -- Remove oldest conversations
            local toRemove = #history - ASC.AIOptimization.Config.MaxConversationHistory
            for i = 1, toRemove do
                table.remove(history, 1)
                cleaned = cleaned + 1
            end
        end
        
        -- Remove old conversations
        for i = #history, 1, -1 do
            local conversation = history[i]
            if conversation.timestamp and currentTime - conversation.timestamp > ASC.AIOptimization.Config.ConversationCleanupAge then
                table.remove(history, i)
                cleaned = cleaned + 1
            end
        end
    end
    
    if cleaned > 0 then
        print("[Advanced Space Combat] AI Conversation cleanup: " .. cleaned .. " conversations removed")
    end
end

-- Clean up caches
function ASC.AIOptimization.CleanupCaches()
    local currentTime = CurTime()
    local cleaned = 0
    
    -- Clean response cache
    for query, data in pairs(ASC.AIOptimization.State.ResponseCache) do
        if currentTime - data.timestamp > ASC.AIOptimization.Config.ResponseCacheTimeout then
            ASC.AIOptimization.State.ResponseCache[query] = nil
            cleaned = cleaned + 1
        end
    end
    
    -- Limit cache size
    local cacheSize = table.Count(ASC.AIOptimization.State.ResponseCache)
    if cacheSize > ASC.AIOptimization.Config.QueryCacheSize then
        -- Remove oldest entries
        local entries = {}
        for query, data in pairs(ASC.AIOptimization.State.ResponseCache) do
            table.insert(entries, {query = query, timestamp = data.timestamp})
        end
        
        table.sort(entries, function(a, b) return a.timestamp < b.timestamp end)
        
        local toRemove = cacheSize - ASC.AIOptimization.Config.QueryCacheSize
        for i = 1, toRemove do
            ASC.AIOptimization.State.ResponseCache[entries[i].query] = nil
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        print("[Advanced Space Combat] AI Cache cleanup: " .. cleaned .. " entries removed")
    end
end

-- Check if player can make query (rate limiting)
function ASC.AIOptimization.CanPlayerQuery(player)
    if not IsValid(player) then return false end
    
    local steamID = player:SteamID()
    local currentTime = CurTime()
    
    -- Check cooldown
    local lastQuery = ASC.AIOptimization.State.PlayerCooldowns[steamID] or 0
    if currentTime - lastQuery < ASC.AIOptimization.Config.CooldownPeriod then
        return false, "Please wait before asking another question"
    end
    
    -- Check rate limit
    local queryCount = ASC.AIOptimization.State.QueryCounts[steamID] or 0
    if queryCount >= ASC.AIOptimization.Config.MaxQueriesPerPlayer then
        return false, "Query limit reached. Please wait a minute"
    end
    
    return true
end

-- Record player query
function ASC.AIOptimization.RecordPlayerQuery(player)
    if not IsValid(player) then return end
    
    local steamID = player:SteamID()
    local currentTime = CurTime()
    
    ASC.AIOptimization.State.PlayerCooldowns[steamID] = currentTime
    ASC.AIOptimization.State.QueryCounts[steamID] = (ASC.AIOptimization.State.QueryCounts[steamID] or 0) + 1
    ASC.AIOptimization.State.QueriesProcessed = ASC.AIOptimization.State.QueriesProcessed + 1
end

-- Get cached response
function ASC.AIOptimization.GetCachedResponse(query)
    local normalizedQuery = string.lower(string.Trim(query))
    local cached = ASC.AIOptimization.State.ResponseCache[normalizedQuery]
    
    if cached and CurTime() - cached.timestamp < ASC.AIOptimization.Config.ResponseCacheTimeout then
        ASC.AIOptimization.State.CacheHits = ASC.AIOptimization.State.CacheHits + 1
        return cached.response
    end
    
    ASC.AIOptimization.State.CacheMisses = ASC.AIOptimization.State.CacheMisses + 1
    return nil
end

-- Cache response
function ASC.AIOptimization.CacheResponse(query, response)
    local normalizedQuery = string.lower(string.Trim(query))
    
    ASC.AIOptimization.State.ResponseCache[normalizedQuery] = {
        response = response,
        timestamp = CurTime()
    }
end

-- Optimize AI functions
function ASC.AIOptimization.OptimizeAIFunctions()
    if not ASC.AI then return end
    
    -- Wrap ProcessQuery with optimization
    if ASC.AI.ProcessQuery then
        local originalProcessQuery = ASC.AI.ProcessQuery
        
        ASC.AI.ProcessQuery = function(player, query)
            -- Check rate limiting
            local canQuery, reason = ASC.AIOptimization.CanPlayerQuery(player)
            if not canQuery then
                if IsValid(player) then
                    player:ChatPrint("[ARIA-4] " .. reason)
                end
                return
            end
            
            -- Check cache first
            local cachedResponse = ASC.AIOptimization.GetCachedResponse(query)
            if cachedResponse then
                if IsValid(player) then
                    player:ChatPrint(cachedResponse)
                end
                ASC.AIOptimization.RecordPlayerQuery(player)
                return
            end
            
            -- Process query with timeout
            local startTime = SysTime()
            
            -- Record query
            ASC.AIOptimization.RecordPlayerQuery(player)
            
            -- Call original function
            local response = originalProcessQuery(player, query)
            
            local processingTime = SysTime() - startTime
            
            -- Cache response if processing was successful
            if response then
                ASC.AIOptimization.CacheResponse(query, response)
            end
            
            -- Log performance
            if processingTime > ASC.AIOptimization.Config.MaxProcessingTime then
                print("[Advanced Space Combat] AI Query took " .. string.format("%.3f", processingTime) .. "s (slow)")
            end
            
            return response
        end
    end
    
    print("[Advanced Space Combat] AI functions optimized")
end

-- Set up performance monitoring
function ASC.AIOptimization.SetupMonitoring()
    -- Reset query counts every minute
    timer.Create("ASC_AI_QueryReset", 60, 0, function()
        ASC.AIOptimization.State.QueryCounts = {}
    end)
end

-- Get optimization statistics
function ASC.AIOptimization.GetStatistics()
    local stats = {
        "=== AI Optimization Statistics ===",
        "Queries Processed: " .. ASC.AIOptimization.State.QueriesProcessed,
        "Cache Hits: " .. ASC.AIOptimization.State.CacheHits,
        "Cache Misses: " .. ASC.AIOptimization.State.CacheMisses,
        "Cache Hit Rate: " .. string.format("%.1f", (ASC.AIOptimization.State.CacheHits / math.max(1, ASC.AIOptimization.State.CacheHits + ASC.AIOptimization.State.CacheMisses)) * 100) .. "%",
        "Memory Freed: " .. string.format("%.2f", ASC.AIOptimization.State.MemoryFreed) .. " KB",
        "Active Profiles: " .. (ASC.AI and ASC.AI.UserProfiles and table.Count(ASC.AI.UserProfiles) or 0),
        "Cached Responses: " .. table.Count(ASC.AIOptimization.State.ResponseCache)
    }
    
    return stats
end

-- Console command for AI optimization stats
concommand.Add("asc_ai_optimization_stats", function(ply, cmd, args)
    local stats = ASC.AIOptimization.GetStatistics()
    
    if IsValid(ply) then
        for _, line in ipairs(stats) do
            ply:ChatPrint(line)
        end
    else
        for _, line in ipairs(stats) do
            print(line)
        end
    end
end, nil, "Show AI optimization statistics")

-- Initialize on load
timer.Simple(1, function()
    ASC.AIOptimization.Initialize()
end)

print("[Advanced Space Combat] AI System Optimization loaded successfully!")
