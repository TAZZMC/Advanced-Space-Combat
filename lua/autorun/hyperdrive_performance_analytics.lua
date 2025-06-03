-- Enhanced Hyperdrive System - Performance Analytics v2.2.1
-- Advanced performance tracking and optimization

print("[Hyperdrive] Loading Performance Analytics System v2.2.1...")

-- Initialize analytics namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Analytics = HYPERDRIVE.Analytics or {}

-- Analytics configuration
HYPERDRIVE.Analytics.Config = {
    EnableAnalytics = true,
    SampleRate = 2, -- Samples per second
    MaxSamples = 200,
    PerformanceTargets = {
        MinFPS = 60,
        MaxEntityCount = 400,
        MaxMemoryUsage = 80, -- Percentage
        OptimalTickRate = 66
    }
}

-- Analytics data storage
HYPERDRIVE.Analytics.Data = {
    PerformanceSamples = {},
    OptimizationSuggestions = {},
    BenchmarkResults = {},
    SystemLoad = {},
    LastAnalysis = 0
}

-- Performance sampling
function HYPERDRIVE.Analytics.CollectSample()
    local sample = {
        timestamp = CurTime(),
        frameTime = engine.TickInterval(),
        entityCount = #ents.GetAll(),
        playerCount = #player.GetAll(),
        memoryUsage = collectgarbage("count"),
        tickRate = 1 / engine.TickInterval()
    }
    
    -- Collect hyperdrive-specific metrics
    sample.hyperdriveEntities = {
        total = 0,
        shipCores = #ents.FindByClass("ship_core"),
        engines = #ents.FindByClass("hyperdrive_engine") + #ents.FindByClass("hyperdrive_master_engine"),
        weapons = 0,
        shields = #ents.FindByClass("asc_shield_generator") + #ents.FindByClass("hyperdrive_shield_generator")
    }
    
    -- Count weapons
    local weaponClasses = {"asc_pulse_cannon", "asc_plasma_cannon", "asc_railgun", "hyperdrive_beam_weapon", "hyperdrive_torpedo_launcher"}
    for _, class in ipairs(weaponClasses) do
        sample.hyperdriveEntities.weapons = sample.hyperdriveEntities.weapons + #ents.FindByClass(class)
    end
    
    sample.hyperdriveEntities.total = sample.hyperdriveEntities.shipCores + sample.hyperdriveEntities.engines + 
                                     sample.hyperdriveEntities.weapons + sample.hyperdriveEntities.shields
    
    return sample
end

-- Add sample to analytics
function HYPERDRIVE.Analytics.AddSample()
    if not HYPERDRIVE.Analytics.Config.EnableAnalytics then return end
    
    local sample = HYPERDRIVE.Analytics.CollectSample()
    table.insert(HYPERDRIVE.Analytics.Data.PerformanceSamples, sample)
    
    -- Limit sample count
    local maxSamples = HYPERDRIVE.Analytics.Config.MaxSamples
    if #HYPERDRIVE.Analytics.Data.PerformanceSamples > maxSamples then
        table.remove(HYPERDRIVE.Analytics.Data.PerformanceSamples, 1)
    end
    
    -- Analyze performance periodically
    if CurTime() - HYPERDRIVE.Analytics.Data.LastAnalysis > 30 then
        HYPERDRIVE.Analytics.AnalyzePerformance()
        HYPERDRIVE.Analytics.Data.LastAnalysis = CurTime()
    end
end

-- Performance analysis
function HYPERDRIVE.Analytics.AnalyzePerformance()
    local samples = HYPERDRIVE.Analytics.Data.PerformanceSamples
    if #samples < 10 then return end
    
    -- Calculate averages
    local avgFrameTime = 0
    local avgEntityCount = 0
    local avgMemoryUsage = 0
    local avgTickRate = 0
    local avgHyperdriveEntities = 0
    
    for _, sample in ipairs(samples) do
        avgFrameTime = avgFrameTime + sample.frameTime
        avgEntityCount = avgEntityCount + sample.entityCount
        avgMemoryUsage = avgMemoryUsage + sample.memoryUsage
        avgTickRate = avgTickRate + sample.tickRate
        avgHyperdriveEntities = avgHyperdriveEntities + sample.hyperdriveEntities.total
    end
    
    local sampleCount = #samples
    avgFrameTime = avgFrameTime / sampleCount
    avgEntityCount = avgEntityCount / sampleCount
    avgMemoryUsage = avgMemoryUsage / sampleCount
    avgTickRate = avgTickRate / sampleCount
    avgHyperdriveEntities = avgHyperdriveEntities / sampleCount
    
    -- Generate optimization suggestions
    local suggestions = {}
    local targets = HYPERDRIVE.Analytics.Config.PerformanceTargets
    
    if avgTickRate < targets.OptimalTickRate then
        table.insert(suggestions, {
            type = "PERFORMANCE",
            priority = "HIGH",
            message = "Server tick rate below optimal (" .. math.floor(avgTickRate) .. " Hz). Consider reducing entity count or optimizing scripts.",
            recommendation = "Remove unused entities or increase server performance."
        })
    end
    
    if avgEntityCount > targets.MaxEntityCount then
        table.insert(suggestions, {
            type = "ENTITIES",
            priority = "MEDIUM",
            message = "High entity count (" .. math.floor(avgEntityCount) .. "). Performance may be affected.",
            recommendation = "Use cleanup tools or limit entity spawning."
        })
    end
    
    if avgHyperdriveEntities > 100 then
        table.insert(suggestions, {
            type = "HYPERDRIVE",
            priority = "MEDIUM",
            message = "High number of hyperdrive entities (" .. math.floor(avgHyperdriveEntities) .. ").",
            recommendation = "Consider consolidating ships or removing unused components."
        })
    end
    
    -- Store suggestions
    HYPERDRIVE.Analytics.Data.OptimizationSuggestions = suggestions
    
    -- Store benchmark results
    HYPERDRIVE.Analytics.Data.BenchmarkResults = {
        averageFrameTime = avgFrameTime,
        averageEntityCount = avgEntityCount,
        averageMemoryUsage = avgMemoryUsage,
        averageTickRate = avgTickRate,
        averageHyperdriveEntities = avgHyperdriveEntities,
        performanceScore = HYPERDRIVE.Analytics.CalculatePerformanceScore(avgTickRate, avgEntityCount, avgMemoryUsage),
        timestamp = CurTime()
    }
end

-- Calculate performance score (0-100)
function HYPERDRIVE.Analytics.CalculatePerformanceScore(tickRate, entityCount, memoryUsage)
    local targets = HYPERDRIVE.Analytics.Config.PerformanceTargets
    
    -- Tick rate score (40% weight)
    local tickScore = math.min(100, (tickRate / targets.OptimalTickRate) * 100) * 0.4
    
    -- Entity count score (30% weight)
    local entityScore = math.max(0, 100 - ((entityCount / targets.MaxEntityCount) * 100)) * 0.3
    
    -- Memory score (30% weight)
    local memoryScore = math.max(0, 100 - ((memoryUsage / 1024) / 10)) * 0.3 -- Rough memory calculation
    
    return math.floor(tickScore + entityScore + memoryScore)
end

-- Get analytics report
function HYPERDRIVE.Analytics.GetReport()
    local data = HYPERDRIVE.Analytics.Data
    local benchmark = data.BenchmarkResults
    
    if not benchmark then return "No analytics data available" end
    
    local report = {
        "=== Hyperdrive Performance Analytics ===",
        "Analysis Time: " .. os.date("%H:%M:%S", benchmark.timestamp),
        "Performance Score: " .. benchmark.performanceScore .. "/100",
        "",
        "=== Averages (Last " .. #data.PerformanceSamples .. " samples) ===",
        "Tick Rate: " .. math.floor(benchmark.averageTickRate) .. " Hz",
        "Entity Count: " .. math.floor(benchmark.averageEntityCount),
        "Memory Usage: " .. math.floor(benchmark.averageMemoryUsage) .. " KB",
        "Hyperdrive Entities: " .. math.floor(benchmark.averageHyperdriveEntities),
        ""
    }
    
    -- Add optimization suggestions
    if #data.OptimizationSuggestions > 0 then
        table.insert(report, "=== Optimization Suggestions ===")
        for _, suggestion in ipairs(data.OptimizationSuggestions) do
            table.insert(report, "[" .. suggestion.priority .. "] " .. suggestion.message)
            table.insert(report, "  → " .. suggestion.recommendation)
        end
    else
        table.insert(report, "=== Performance Status ===")
        table.insert(report, "No optimization suggestions - performance is good!")
    end
    
    return table.concat(report, "\n")
end

-- Server-side functionality
if SERVER then
    -- Start analytics sampling
    timer.Create("HyperdriveAnalyticsSampling", 1 / HYPERDRIVE.Analytics.Config.SampleRate, 0, function()
        HYPERDRIVE.Analytics.AddSample()
    end)
    
    -- Console command for analytics report
    concommand.Add("hyperdrive_analytics_report", function(ply, cmd, args)
        local target = IsValid(ply) and ply or nil
        local report = HYPERDRIVE.Analytics.GetReport()
        
        if target then
            for _, line in ipairs(string.Split(report, "\n")) do
                target:ChatPrint(line)
            end
        else
            print(report)
        end
    end)
    
    -- Console command to reset analytics
    concommand.Add("hyperdrive_analytics_reset", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        
        HYPERDRIVE.Analytics.Data.PerformanceSamples = {}
        HYPERDRIVE.Analytics.Data.OptimizationSuggestions = {}
        HYPERDRIVE.Analytics.Data.BenchmarkResults = {}
        
        local message = "Analytics data reset"
        if IsValid(ply) then
            ply:ChatPrint("[Analytics] " .. message)
        else
            print("[Analytics] " .. message)
        end
    end)
    
    -- Console command to toggle analytics
    concommand.Add("hyperdrive_analytics_toggle", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        
        HYPERDRIVE.Analytics.Config.EnableAnalytics = not HYPERDRIVE.Analytics.Config.EnableAnalytics
        local status = HYPERDRIVE.Analytics.Config.EnableAnalytics and "enabled" or "disabled"
        
        if IsValid(ply) then
            ply:ChatPrint("[Analytics] Performance analytics " .. status)
        else
            print("[Analytics] Performance analytics " .. status)
        end
    end)
end

print("[Hyperdrive] Performance Analytics System v2.2.1 loaded successfully!")
