-- Advanced Space Combat - Performance Optimization System v3.0.0
-- Based on 2024-2025 GMod performance best practices and research

print("[Advanced Space Combat] Performance Optimization System v3.0.0 - Ultimate Edition Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.Performance = ASC.Performance or {}

-- Performance configuration based on latest research
ASC.Performance.Config = {
    -- Entity optimization (Research-based values)
    MaxEntityUpdateDistance = 1500, -- Reduced for better performance
    EntityUpdateInterval = 0.05, -- Faster updates for responsiveness
    MaxSimultaneousEffects = 25, -- Reduced for stability
    EntityLODSystem = true, -- Enable Level of Detail system

    -- Network optimization (2024 standards)
    NetworkUpdateRate = 30, -- Increased for better sync
    MaxNetworkEntities = 50, -- Reduced for stability
    NetworkCompressionLevel = 6, -- Balanced compression
    NetworkBatching = true, -- Enable message batching
    NetworkPrediction = true, -- Enable client prediction

    -- Rendering optimization (Modern standards)
    MaxRenderDistance = 3000, -- Reduced for performance
    LODDistances = {
        High = 500,    -- High detail close up
        Medium = 1500, -- Medium detail mid-range
        Low = 3000     -- Low detail far away
    },
    CullingEnabled = true, -- Enable frustum culling
    OcclusionCulling = true, -- Enable occlusion culling

    -- Memory management (Aggressive cleanup)
    GarbageCollectionInterval = 15, -- More frequent cleanup
    MaxMemoryUsage = 256, -- Reduced limit
    EntityCleanupThreshold = 500, -- Lower threshold
    ConversationHistoryLimit = 50, -- Limit AI conversation history
    UserProfileCleanupInterval = 300, -- Clean old profiles

    -- Performance monitoring (Enhanced)
    EnablePerformanceMonitoring = true,
    PerformanceLogInterval = 30, -- More frequent logging
    FPSThresholds = {
        Excellent = 120,
        Good = 60,
        Acceptable = 30,
        Poor = 15,
        Critical = 10
    },

    -- Adaptive quality system
    AdaptiveQuality = true,
    QualityAdjustmentThreshold = 5, -- Seconds before adjusting
    AutoOptimization = true
}

-- Enhanced performance state tracking
ASC.Performance.State = {
    LastGarbageCollection = 0,
    LastPerformanceLog = 0,
    LastProfileCleanup = 0,
    EntityCount = 0,
    MemoryUsage = 0,
    AverageFPS = 60,
    PerformanceLevel = "Good",
    QualityLevel = "High",
    NetworkLatency = 0,
    ServerLoad = 0,

    -- Performance history for trend analysis
    PerformanceHistory = {},
    MemoryHistory = {},
    FPSHistory = {},

    -- Optimization flags
    LODEnabled = true,
    CullingEnabled = true,
    EffectsReduced = false,
    NetworkOptimized = false,

    -- Statistics
    TotalOptimizations = 0,
    MemoryFreed = 0,
    EntitiesOptimized = 0
}

-- Initialize performance optimization
function ASC.Performance.Initialize()
    print("[Advanced Space Combat] Initializing performance optimization...")
    
    -- Set up performance monitoring
    ASC.Performance.SetupMonitoring()
    
    -- Optimize entity updates
    ASC.Performance.OptimizeEntityUpdates()
    
    -- Set up memory management
    ASC.Performance.SetupMemoryManagement()
    
    -- Configure network optimization
    ASC.Performance.ConfigureNetworking()
    
    print("[Advanced Space Combat] Performance optimization initialized")
end

-- Set up performance monitoring
function ASC.Performance.SetupMonitoring()
    if not ASC.Performance.Config.EnablePerformanceMonitoring then return end
    
    -- Monitor performance every second
    timer.Create("ASC_PerformanceMonitor", 1, 0, function()
        ASC.Performance.UpdatePerformanceMetrics()
        ASC.Performance.CheckPerformanceThresholds()
    end)
    
    -- Log performance data periodically
    timer.Create("ASC_PerformanceLogger", ASC.Performance.Config.PerformanceLogInterval, 0, function()
        ASC.Performance.LogPerformanceData()
    end)
end

-- Update performance metrics
function ASC.Performance.UpdatePerformanceMetrics()
    local state = ASC.Performance.State
    
    -- Update entity count
    state.EntityCount = #ents.GetAll()
    
    -- Update memory usage
    state.MemoryUsage = math.floor(collectgarbage("count") / 1024) -- Convert to MB
    
    -- Update FPS (client only)
    if CLIENT then
        local fps = math.floor(1 / FrameTime())
        state.AverageFPS = (state.AverageFPS * 0.9) + (fps * 0.1) -- Smooth average
    end
    
    -- Determine performance level
    local thresholds = ASC.Performance.Config.FPSThresholds
    if state.AverageFPS >= thresholds.Good then
        state.PerformanceLevel = "Good"
    elseif state.AverageFPS >= thresholds.Acceptable then
        state.PerformanceLevel = "Acceptable"
    else
        state.PerformanceLevel = "Poor"
    end
end

-- Check performance thresholds and take action
function ASC.Performance.CheckPerformanceThresholds()
    local state = ASC.Performance.State
    local config = ASC.Performance.Config
    
    -- Check memory usage
    if state.MemoryUsage > config.MaxMemoryUsage then
        ASC.Performance.TriggerMemoryCleanup()
    end
    
    -- Check entity count
    if state.EntityCount > config.EntityCleanupThreshold then
        ASC.Performance.CleanupOldEntities()
    end
    
    -- Adjust quality based on performance
    if state.PerformanceLevel == "Poor" then
        ASC.Performance.ReduceQuality()
    elseif state.PerformanceLevel == "Good" then
        ASC.Performance.RestoreQuality()
    end
end

-- Optimize entity updates
function ASC.Performance.OptimizeEntityUpdates()
    -- Override entity Think functions for ASC entities
    local originalThink = {}
    
    -- Store original Think functions
    for _, class in ipairs({"ship_core", "hyperdrive_engine", "asc_weapon_base"}) do
        local entTable = scripted_ents.GetStored(class)
        if entTable and entTable.t.Think then
            originalThink[class] = entTable.t.Think
            
            -- Replace with optimized version
            entTable.t.Think = function(self)
                -- Distance-based update optimization
                local players = player.GetAll()
                local shouldUpdate = false
                
                for _, ply in ipairs(players) do
                    if IsValid(ply) and self:GetPos():Distance(ply:GetPos()) < ASC.Performance.Config.MaxEntityUpdateDistance then
                        shouldUpdate = true
                        break
                    end
                end
                
                if shouldUpdate then
                    -- Call original Think function
                    if originalThink[class] then
                        originalThink[class](self)
                    end
                end
                
                -- Set next think based on distance
                self:NextThink(CurTime() + ASC.Performance.Config.EntityUpdateInterval)
                return true
            end
        end
    end
end

-- Set up memory management
function ASC.Performance.SetupMemoryManagement()
    local interval = ASC.Performance.Config.GarbageCollectionInterval or 15
    timer.Create("ASC_MemoryManager", interval, 0, function()
        ASC.Performance.TriggerMemoryCleanup()
    end)
end

-- Trigger memory cleanup
function ASC.Performance.TriggerMemoryCleanup()
    local beforeMemory = collectgarbage("count")
    
    -- Force garbage collection
    collectgarbage("collect")
    
    -- Clean up ASC-specific data
    ASC.Performance.CleanupASCData()
    
    local afterMemory = collectgarbage("count")
    local freed = math.floor((beforeMemory - afterMemory) / 1024) -- Convert to MB
    
    if freed > 0 then
        print("[Advanced Space Combat] Memory cleanup freed " .. freed .. " MB")
    end
    
    ASC.Performance.State.LastGarbageCollection = CurTime()
end

-- Clean up ASC-specific data
function ASC.Performance.CleanupASCData()
    -- Clean up old conversation history
    if ASC.AI and ASC.AI.ConversationHistory then
        for playerID, history in pairs(ASC.AI.ConversationHistory) do
            if #history > 50 then -- Keep only last 50 messages
                local newHistory = {}
                for i = #history - 49, #history do
                    table.insert(newHistory, history[i])
                end
                ASC.AI.ConversationHistory[playerID] = newHistory
            end
        end
    end
    
    -- Clean up old effect data
    if ASC.Effects and ASC.Effects.ActiveEffects then
        for i = #ASC.Effects.ActiveEffects, 1, -1 do
            local effect = ASC.Effects.ActiveEffects[i]
            if not IsValid(effect.entity) or CurTime() - effect.startTime > 30 then
                table.remove(ASC.Effects.ActiveEffects, i)
            end
        end
    end
end

-- Clean up old entities
function ASC.Performance.CleanupOldEntities()
    local cleaned = 0
    
    -- Remove invalid or old ASC entities
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:GetClass():find("asc_") then
            -- Check if entity is orphaned or too old
            if not IsValid(ent:GetOwner()) and (ent.CreationTime and CurTime() - ent.CreationTime > 3600) then
                ent:Remove()
                cleaned = cleaned + 1
            end
        end
    end
    
    if cleaned > 0 then
        print("[Advanced Space Combat] Cleaned up " .. cleaned .. " old entities")
    end
end

-- Reduce quality for better performance
function ASC.Performance.ReduceQuality()
    -- Reduce particle effects
    if ASC.ComprehensiveTheme then
        ASC.ComprehensiveTheme.Config.EnableParticleEffects = false
        ASC.ComprehensiveTheme.Config.EnableAnimations = false
    end
    
    -- Reduce effect quality
    if ASC.Effects then
        ASC.Effects.Config.EffectQuality = "Low"
        ASC.Effects.Config.MaxParticles = 25
    end
end

-- Restore quality when performance improves
function ASC.Performance.RestoreQuality()
    -- Restore particle effects
    if ASC.ComprehensiveTheme then
        ASC.ComprehensiveTheme.Config.EnableParticleEffects = true
        ASC.ComprehensiveTheme.Config.EnableAnimations = true
    end
    
    -- Restore effect quality
    if ASC.Effects then
        ASC.Effects.Config.EffectQuality = "High"
        ASC.Effects.Config.MaxParticles = 100
    end
end

-- Configure network optimization
function ASC.Performance.ConfigureNetworking()
    if SERVER then
        -- Set network update rates
        RunConsoleCommand("sv_maxrate", "0") -- No rate limit
        RunConsoleCommand("sv_minrate", "20000")
        RunConsoleCommand("sv_maxupdaterate", tostring(ASC.Performance.Config.NetworkUpdateRate))
        RunConsoleCommand("sv_minupdaterate", "10")
    end
end

-- Log performance data
function ASC.Performance.LogPerformanceData()
    local state = ASC.Performance.State
    
    print("[Advanced Space Combat] Performance Report:")
    print("• Entities: " .. state.EntityCount)
    print("• Memory: " .. state.MemoryUsage .. " MB")
    print("• Performance Level: " .. state.PerformanceLevel)
    
    if CLIENT then
        print("• Average FPS: " .. math.floor(state.AverageFPS))
    end
    
    ASC.Performance.State.LastPerformanceLog = CurTime()
end

-- Console commands for performance management
concommand.Add("asc_performance_report", function(ply, cmd, args)
    ASC.Performance.LogPerformanceData()
    
    if IsValid(ply) then
        ply:ChatPrint("[Advanced Space Combat] Performance report logged to console")
    end
end, nil, "Show performance report")

concommand.Add("asc_performance_cleanup", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Advanced Space Combat] Admin only command")
        return
    end
    
    ASC.Performance.TriggerMemoryCleanup()
    ASC.Performance.CleanupOldEntities()
    
    local msg = "[Advanced Space Combat] Performance cleanup completed"
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end, nil, "Force performance cleanup (Admin only)")

concommand.Add("asc_performance_optimize", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Advanced Space Combat] Admin only command")
        return
    end
    
    ASC.Performance.ReduceQuality()
    
    local msg = "[Advanced Space Combat] Performance optimization applied"
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end, nil, "Apply performance optimizations (Admin only)")

-- Initialize on both client and server
hook.Add("Initialize", "ASC_Performance_Init", function()
    timer.Simple(1, function()
        ASC.Performance.Initialize()
    end)
end)

print("[Advanced Space Combat] Performance Optimization System loaded successfully!")
