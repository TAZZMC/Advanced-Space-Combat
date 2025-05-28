-- Hyperdrive Optimization Engine
-- Advanced optimization algorithms for dynamic performance tuning and resource management

if CLIENT then return end

-- Initialize optimization engine
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Optimization = HYPERDRIVE.Optimization or {}

print("[Hyperdrive] Optimization engine loading...")

-- Optimization configuration
HYPERDRIVE.Optimization.Config = {
    EnableOptimization = true,      -- Enable optimization engine
    AdaptiveOptimization = true,    -- Enable adaptive optimization
    OptimizationInterval = 60,      -- Optimization cycle interval (seconds)
    LearningRate = 0.1,             -- Machine learning rate
    PerformanceThreshold = 0.8,     -- Performance threshold for optimization
    ResourceMonitoring = true,      -- Enable resource monitoring
    PredictiveOptimization = true,  -- Enable predictive optimization
    AutoTuning = true,              -- Enable automatic parameter tuning
}

-- Optimization state
HYPERDRIVE.Optimization.State = {
    currentProfile = "balanced",
    optimizationHistory = {},
    performanceMetrics = {},
    resourceUsage = {},
    adaptiveParameters = {},
    learningData = {},
    optimizationCycles = 0,
    lastOptimization = 0,
}

-- Performance profiles
HYPERDRIVE.Optimization.Profiles = {
    performance = {
        name = "High Performance",
        description = "Optimized for maximum performance",
        parameters = {
            batchSize = 64,
            cacheSize = 1000,
            networkPriority = "high",
            memoryAggressive = true,
            compressionLevel = 3,
        }
    },
    balanced = {
        name = "Balanced",
        description = "Balanced performance and resource usage",
        parameters = {
            batchSize = 32,
            cacheSize = 500,
            networkPriority = "medium",
            memoryAggressive = false,
            compressionLevel = 6,
        }
    },
    efficiency = {
        name = "Resource Efficient",
        description = "Optimized for low resource usage",
        parameters = {
            batchSize = 16,
            cacheSize = 250,
            networkPriority = "low",
            memoryAggressive = false,
            compressionLevel = 9,
        }
    },
    custom = {
        name = "Custom",
        description = "User-defined optimization parameters",
        parameters = {}
    }
}

-- Function to get optimization configuration
local function GetOptConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("Optimization", key, HYPERDRIVE.Optimization.Config[key] or default)
    end
    return HYPERDRIVE.Optimization.Config[key] or default
end

-- Collect system performance metrics
function HYPERDRIVE.Optimization.CollectMetrics()
    local metrics = {
        timestamp = CurTime(),
        serverTime = os.time(),
        
        -- System metrics
        playerCount = #player.GetAll(),
        entityCount = #ents.GetAll(),
        hyperdriveEngines = #ents.FindByClass("hyperdrive_*"),
        
        -- Performance metrics
        frameTime = engine.TickInterval(),
        memoryUsage = collectgarbage("count"),
        
        -- Hyperdrive specific metrics
        jumpCount = 0,
        successRate = 0,
        averageJumpTime = 0,
        networkUsage = 0,
        errorRate = 0,
    }
    
    -- Get hyperdrive performance data
    if HYPERDRIVE.Performance and HYPERDRIVE.Performance.Metrics then
        local perfMetrics = HYPERDRIVE.Performance.Metrics
        metrics.jumpCount = perfMetrics.totalJumps or 0
        metrics.averageJumpTime = perfMetrics.averageJumpTime or 0
    end
    
    -- Get network statistics
    if HYPERDRIVE.Network and HYPERDRIVE.Network.GetStatistics then
        local netStats = HYPERDRIVE.Network.GetStatistics()
        metrics.networkUsage = netStats.bandwidthUsage or 0
    end
    
    -- Get error statistics
    if HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.GetStatistics then
        local errorStats = HYPERDRIVE.ErrorRecovery.GetStatistics()
        metrics.errorRate = errorStats.totalErrors > 0 and 
                           (errorStats.totalErrors - errorStats.recoveredErrors) / errorStats.totalErrors or 0
    end
    
    -- Calculate performance score
    metrics.performanceScore = HYPERDRIVE.Optimization.CalculatePerformanceScore(metrics)
    
    -- Store metrics
    table.insert(HYPERDRIVE.Optimization.State.performanceMetrics, metrics)
    
    -- Limit metrics history
    local maxHistory = 1000
    while #HYPERDRIVE.Optimization.State.performanceMetrics > maxHistory do
        table.remove(HYPERDRIVE.Optimization.State.performanceMetrics, 1)
    end
    
    return metrics
end

-- Calculate overall performance score
function HYPERDRIVE.Optimization.CalculatePerformanceScore(metrics)
    local score = 100
    
    -- Penalize high frame time
    if metrics.frameTime > 0.02 then -- 50 FPS threshold
        score = score - ((metrics.frameTime - 0.02) * 1000)
    end
    
    -- Penalize high memory usage
    if metrics.memoryUsage > 100000 then -- 100MB threshold
        score = score - ((metrics.memoryUsage - 100000) / 1000)
    end
    
    -- Penalize high error rate
    score = score - (metrics.errorRate * 50)
    
    -- Penalize high network usage
    if metrics.networkUsage > 500000 then -- 500KB/s threshold
        score = score - ((metrics.networkUsage - 500000) / 10000)
    end
    
    -- Bonus for successful jumps
    if metrics.jumpCount > 0 and metrics.successRate > 0.9 then
        score = score + 10
    end
    
    return math.max(0, math.min(100, score))
end

-- Analyze performance trends
function HYPERDRIVE.Optimization.AnalyzeTrends()
    local metrics = HYPERDRIVE.Optimization.State.performanceMetrics
    if #metrics < 10 then return nil end
    
    local recentMetrics = {}
    for i = math.max(1, #metrics - 20), #metrics do
        table.insert(recentMetrics, metrics[i])
    end
    
    local trends = {
        performanceScore = HYPERDRIVE.Optimization.CalculateTrend(recentMetrics, "performanceScore"),
        memoryUsage = HYPERDRIVE.Optimization.CalculateTrend(recentMetrics, "memoryUsage"),
        networkUsage = HYPERDRIVE.Optimization.CalculateTrend(recentMetrics, "networkUsage"),
        errorRate = HYPERDRIVE.Optimization.CalculateTrend(recentMetrics, "errorRate"),
        jumpTime = HYPERDRIVE.Optimization.CalculateTrend(recentMetrics, "averageJumpTime"),
    }
    
    return trends
end

-- Calculate trend for specific metric
function HYPERDRIVE.Optimization.CalculateTrend(metrics, field)
    if #metrics < 2 then return 0 end
    
    local values = {}
    for i, metric in ipairs(metrics) do
        table.insert(values, {x = i, y = metric[field] or 0})
    end
    
    -- Simple linear regression
    local n = #values
    local sumX, sumY, sumXY, sumX2 = 0, 0, 0, 0
    
    for _, point in ipairs(values) do
        sumX = sumX + point.x
        sumY = sumY + point.y
        sumXY = sumXY + (point.x * point.y)
        sumX2 = sumX2 + (point.x * point.x)
    end
    
    local slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
    return slope
end

-- Generate optimization recommendations
function HYPERDRIVE.Optimization.GenerateRecommendations()
    local trends = HYPERDRIVE.Optimization.AnalyzeTrends()
    if not trends then return {} end
    
    local recommendations = {}
    
    -- Performance score declining
    if trends.performanceScore < -0.5 then
        table.insert(recommendations, {
            type = "performance",
            severity = "high",
            message = "Performance score is declining",
            action = "Consider switching to efficiency profile or reducing batch sizes"
        })
    end
    
    -- Memory usage increasing
    if trends.memoryUsage > 1000 then
        table.insert(recommendations, {
            type = "memory",
            severity = "medium",
            message = "Memory usage is increasing",
            action = "Enable aggressive memory management or reduce cache sizes"
        })
    end
    
    -- Network usage increasing
    if trends.networkUsage > 10000 then
        table.insert(recommendations, {
            type = "network",
            severity = "medium",
            message = "Network usage is increasing",
            action = "Increase compression level or reduce batch sizes"
        })
    end
    
    -- Error rate increasing
    if trends.errorRate > 0.01 then
        table.insert(recommendations, {
            type = "reliability",
            severity = "high",
            message = "Error rate is increasing",
            action = "Check system logs and consider enabling more aggressive error recovery"
        })
    end
    
    -- Jump time increasing
    if trends.jumpTime > 0.1 then
        table.insert(recommendations, {
            type = "performance",
            severity = "medium",
            message = "Jump times are increasing",
            action = "Consider optimizing entity detection or reducing ship complexity"
        })
    end
    
    return recommendations
end

-- Apply optimization profile
function HYPERDRIVE.Optimization.ApplyProfile(profileName)
    local profile = HYPERDRIVE.Optimization.Profiles[profileName]
    if not profile then return false, "Profile not found" end
    
    local parameters = profile.parameters
    
    -- Apply performance parameters
    if HYPERDRIVE.Performance then
        if parameters.batchSize then
            HYPERDRIVE.Performance.Config.MaxEntitiesPerBatch = parameters.batchSize
        end
        if parameters.cacheSize then
            HYPERDRIVE.Performance.Config.MaxCacheEntries = parameters.cacheSize
        end
        if parameters.memoryAggressive ~= nil then
            HYPERDRIVE.Performance.Config.MemoryOptimization = parameters.memoryAggressive
        end
    end
    
    -- Apply network parameters
    if HYPERDRIVE.Network then
        if parameters.batchSize then
            HYPERDRIVE.Network.Config.BatchSize = parameters.batchSize
        end
        if parameters.compressionLevel then
            HYPERDRIVE.Network.Config.CompressionLevel = parameters.compressionLevel
        end
    end
    
    -- Update current profile
    HYPERDRIVE.Optimization.State.currentProfile = profileName
    
    -- Log optimization change
    if HYPERDRIVE.ErrorRecovery then
        HYPERDRIVE.ErrorRecovery.LogError("Applied optimization profile: " .. profile.name, 
            HYPERDRIVE.ErrorRecovery.Severity.LOW, {profile = profileName})
    end
    
    return true, "Applied profile: " .. profile.name
end

-- Adaptive optimization based on current conditions
function HYPERDRIVE.Optimization.AdaptiveOptimize()
    if not GetOptConfig("AdaptiveOptimization", true) then return end
    
    local currentMetrics = HYPERDRIVE.Optimization.CollectMetrics()
    local trends = HYPERDRIVE.Optimization.AnalyzeTrends()
    
    if not trends then return end
    
    local currentProfile = HYPERDRIVE.Optimization.State.currentProfile
    local shouldSwitch = false
    local newProfile = currentProfile
    
    -- Switch to efficiency profile if resources are constrained
    if currentMetrics.memoryUsage > 150000 or currentMetrics.networkUsage > 800000 then
        if currentProfile ~= "efficiency" then
            newProfile = "efficiency"
            shouldSwitch = true
        end
    -- Switch to performance profile if resources are abundant
    elseif currentMetrics.memoryUsage < 50000 and currentMetrics.networkUsage < 200000 and 
           currentMetrics.performanceScore > 80 then
        if currentProfile ~= "performance" then
            newProfile = "performance"
            shouldSwitch = true
        end
    -- Switch to balanced profile for moderate conditions
    elseif currentProfile == "efficiency" and currentMetrics.memoryUsage < 100000 then
        newProfile = "balanced"
        shouldSwitch = true
    end
    
    if shouldSwitch then
        local success, message = HYPERDRIVE.Optimization.ApplyProfile(newProfile)
        if success then
            print("[Hyperdrive Optimization] Switched to " .. newProfile .. " profile")
        end
    end
end

-- Run optimization cycle
function HYPERDRIVE.Optimization.RunOptimizationCycle()
    if not GetOptConfig("EnableOptimization", true) then return end
    
    local startTime = SysTime()
    
    -- Collect current metrics
    local metrics = HYPERDRIVE.Optimization.CollectMetrics()
    
    -- Run adaptive optimization
    HYPERDRIVE.Optimization.AdaptiveOptimize()
    
    -- Generate recommendations
    local recommendations = HYPERDRIVE.Optimization.GenerateRecommendations()
    
    -- Store optimization results
    local optimizationResult = {
        timestamp = CurTime(),
        metrics = metrics,
        recommendations = recommendations,
        profile = HYPERDRIVE.Optimization.State.currentProfile,
        duration = SysTime() - startTime
    }
    
    table.insert(HYPERDRIVE.Optimization.State.optimizationHistory, optimizationResult)
    
    -- Limit history
    local maxHistory = 100
    while #HYPERDRIVE.Optimization.State.optimizationHistory > maxHistory do
        table.remove(HYPERDRIVE.Optimization.State.optimizationHistory, 1)
    end
    
    HYPERDRIVE.Optimization.State.optimizationCycles = HYPERDRIVE.Optimization.State.optimizationCycles + 1
    HYPERDRIVE.Optimization.State.lastOptimization = CurTime()
    
    -- Send high-priority recommendations to monitoring system
    if HYPERDRIVE.Monitoring then
        for _, rec in ipairs(recommendations) do
            if rec.severity == "high" then
                HYPERDRIVE.Monitoring.SendAlert("Optimization: " .. rec.message, 
                    HYPERDRIVE.Monitoring.AlertLevels.WARNING, nil, rec)
            end
        end
    end
    
    return optimizationResult
end

-- Get optimization status
function HYPERDRIVE.Optimization.GetStatus()
    local recentMetrics = HYPERDRIVE.Optimization.State.performanceMetrics
    local currentMetrics = recentMetrics[#recentMetrics]
    
    return {
        enabled = GetOptConfig("EnableOptimization", true),
        currentProfile = HYPERDRIVE.Optimization.State.currentProfile,
        optimizationCycles = HYPERDRIVE.Optimization.State.optimizationCycles,
        lastOptimization = HYPERDRIVE.Optimization.State.lastOptimization,
        currentPerformance = currentMetrics and currentMetrics.performanceScore or 0,
        recommendations = #HYPERDRIVE.Optimization.State.optimizationHistory > 0 and 
                         HYPERDRIVE.Optimization.State.optimizationHistory[#HYPERDRIVE.Optimization.State.optimizationHistory].recommendations or {},
        trends = HYPERDRIVE.Optimization.AnalyzeTrends(),
    }
end

-- Optimization timer
timer.Create("HyperdriveOptimizationEngine", GetOptConfig("OptimizationInterval", 60), 0, function()
    HYPERDRIVE.Optimization.RunOptimizationCycle()
end)

-- Console commands for optimization
concommand.Add("hyperdrive_optimization_status", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local status = HYPERDRIVE.Optimization.GetStatus()
    
    ply:ChatPrint("[Hyperdrive Optimization] Status:")
    ply:ChatPrint("  • Enabled: " .. (status.enabled and "Yes" or "No"))
    ply:ChatPrint("  • Current Profile: " .. status.currentProfile)
    ply:ChatPrint("  • Optimization Cycles: " .. status.optimizationCycles)
    ply:ChatPrint("  • Performance Score: " .. string.format("%.1f", status.currentPerformance))
    ply:ChatPrint("  • Active Recommendations: " .. #status.recommendations)
    
    if #status.recommendations > 0 then
        ply:ChatPrint("  • Recent Recommendations:")
        for i, rec in ipairs(status.recommendations) do
            if i <= 3 then
                ply:ChatPrint("    - " .. rec.message)
            end
        end
    end
end)

concommand.Add("hyperdrive_optimization_profile", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    if #args < 1 then
        ply:ChatPrint("[Hyperdrive Optimization] Available profiles:")
        for name, profile in pairs(HYPERDRIVE.Optimization.Profiles) do
            ply:ChatPrint("  • " .. name .. ": " .. profile.description)
        end
        ply:ChatPrint("Current profile: " .. HYPERDRIVE.Optimization.State.currentProfile)
        return
    end
    
    local profileName = args[1]
    local success, message = HYPERDRIVE.Optimization.ApplyProfile(profileName)
    
    ply:ChatPrint("[Hyperdrive Optimization] " .. message)
end)

print("[Hyperdrive] Optimization engine loaded")
