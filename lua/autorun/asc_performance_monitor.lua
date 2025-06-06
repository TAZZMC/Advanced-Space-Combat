-- Advanced Space Combat - Performance Monitor
-- Monitors and reports performance metrics

if not ASC then ASC = {} end

ASC.PerformanceMonitor = {
    Version = "1.0.0",
    Initialized = false,
    
    -- Configuration
    Config = {
        Enabled = true,
        SampleInterval = 1.0, -- Sample every second
        HistorySize = 300, -- Keep 5 minutes of history
        AlertThresholds = {
            FPS = 25, -- Alert if FPS drops below this
            Memory = 300, -- Alert if memory exceeds this (MB)
            EntityCount = 800, -- Alert if entity count exceeds this
            NetworkLatency = 200 -- Alert if network latency exceeds this (ms)
        },
        AutoOptimize = true, -- Automatically apply optimizations
        ReportInterval = 60 -- Generate reports every minute
    },
    
    -- Performance metrics
    Metrics = {
        FPS = {
            Current = 60,
            Average = 60,
            Min = 60,
            Max = 60,
            History = {}
        },
        Memory = {
            Current = 0,
            Average = 0,
            Min = 0,
            Max = 0,
            History = {}
        },
        EntityCount = {
            Current = 0,
            Average = 0,
            Min = 0,
            Max = 0,
            History = {}
        },
        NetworkLatency = {
            Current = 0,
            Average = 0,
            Min = 0,
            Max = 0,
            History = {}
        }
    },
    
    -- Performance state
    State = {
        LastSample = 0,
        LastReport = 0,
        AlertsTriggered = 0,
        OptimizationsApplied = 0,
        PerformanceLevel = "Good" -- Good, Fair, Poor, Critical
    },
    
    -- Optimization actions
    OptimizationActions = {
        ReduceUpdateRates = false,
        DisableEffects = false,
        LimitEntityUpdates = false,
        ForceGarbageCollection = false,
        ReduceNetworkUpdates = false
    }
}

-- Sample current performance metrics
function ASC.PerformanceMonitor.SampleMetrics()
    local currentTime = CurTime()
    
    -- FPS
    local fps = 1 / FrameTime()
    ASC.PerformanceMonitor.UpdateMetric("FPS", fps)
    
    -- Memory
    local memory = collectgarbage("count") / 1024 -- Convert to MB
    ASC.PerformanceMonitor.UpdateMetric("Memory", memory)
    
    -- Entity count
    local entityCount = #ents.GetAll()
    ASC.PerformanceMonitor.UpdateMetric("EntityCount", entityCount)
    
    -- Network latency (server only)
    if SERVER then
        local totalLatency = 0
        local playerCount = 0
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                totalLatency = totalLatency + ply:Ping()
                playerCount = playerCount + 1
            end
        end
        local avgLatency = playerCount > 0 and (totalLatency / playerCount) or 0
        ASC.PerformanceMonitor.UpdateMetric("NetworkLatency", avgLatency)
    end
    
    ASC.PerformanceMonitor.State.LastSample = currentTime
end

-- Update a specific metric
function ASC.PerformanceMonitor.UpdateMetric(metricName, value)
    local metric = ASC.PerformanceMonitor.Metrics[metricName]
    if not metric then return end
    
    -- Update current value
    metric.Current = value
    
    -- Update min/max
    if value < metric.Min or metric.Min == 0 then
        metric.Min = value
    end
    if value > metric.Max then
        metric.Max = value
    end
    
    -- Add to history
    table.insert(metric.History, {
        value = value,
        time = CurTime()
    })
    
    -- Limit history size
    while #metric.History > ASC.PerformanceMonitor.Config.HistorySize do
        table.remove(metric.History, 1)
    end
    
    -- Calculate average
    local total = 0
    for _, entry in ipairs(metric.History) do
        total = total + entry.value
    end
    metric.Average = #metric.History > 0 and (total / #metric.History) or value
end

-- Check for performance alerts
function ASC.PerformanceMonitor.CheckAlerts()
    local alerts = {}
    local thresholds = ASC.PerformanceMonitor.Config.AlertThresholds
    
    -- FPS alert
    if ASC.PerformanceMonitor.Metrics.FPS.Current < thresholds.FPS then
        table.insert(alerts, {
            type = "FPS",
            message = "Low FPS detected: " .. math.floor(ASC.PerformanceMonitor.Metrics.FPS.Current),
            severity = "High"
        })
    end
    
    -- Memory alert
    if ASC.PerformanceMonitor.Metrics.Memory.Current > thresholds.Memory then
        table.insert(alerts, {
            type = "Memory",
            message = "High memory usage: " .. string.format("%.1f", ASC.PerformanceMonitor.Metrics.Memory.Current) .. "MB",
            severity = "Medium"
        })
    end
    
    -- Entity count alert
    if ASC.PerformanceMonitor.Metrics.EntityCount.Current > thresholds.EntityCount then
        table.insert(alerts, {
            type = "EntityCount",
            message = "High entity count: " .. ASC.PerformanceMonitor.Metrics.EntityCount.Current,
            severity = "Medium"
        })
    end
    
    -- Network latency alert (server only)
    if SERVER and ASC.PerformanceMonitor.Metrics.NetworkLatency.Current > thresholds.NetworkLatency then
        table.insert(alerts, {
            type = "NetworkLatency",
            message = "High network latency: " .. math.floor(ASC.PerformanceMonitor.Metrics.NetworkLatency.Current) .. "ms",
            severity = "Low"
        })
    end
    
    -- Process alerts
    for _, alert in ipairs(alerts) do
        ASC.PerformanceMonitor.ProcessAlert(alert)
    end
    
    return alerts
end

-- Process a performance alert
function ASC.PerformanceMonitor.ProcessAlert(alert)
    ASC.PerformanceMonitor.State.AlertsTriggered = ASC.PerformanceMonitor.State.AlertsTriggered + 1
    
    print("[ASC Performance] ALERT: " .. alert.message .. " (Severity: " .. alert.severity .. ")")
    
    -- Apply automatic optimizations if enabled
    if ASC.PerformanceMonitor.Config.AutoOptimize then
        ASC.PerformanceMonitor.ApplyOptimizations(alert.type)
    end
end

-- Apply performance optimizations
function ASC.PerformanceMonitor.ApplyOptimizations(alertType)
    local actions = ASC.PerformanceMonitor.OptimizationActions
    
    if alertType == "FPS" then
        if not actions.ReduceUpdateRates then
            -- Reduce update rates in master scheduler
            if ASC and ASC.MasterScheduler then
                local config = ASC.Config and ASC.Config.MasterScheduler
                if config then
                    config.HighPriorityRate = math.min(config.HighPriorityRate * 1.5, 0.2)
                    config.MediumPriorityRate = math.min(config.MediumPriorityRate * 1.5, 1.0)
                    config.LowPriorityRate = math.min(config.LowPriorityRate * 1.5, 5.0)
                    config.MaxUpdatesPerFrame = math.max(config.MaxUpdatesPerFrame - 1, 2)
                end
            end
            actions.ReduceUpdateRates = true
            ASC.PerformanceMonitor.State.OptimizationsApplied = ASC.PerformanceMonitor.State.OptimizationsApplied + 1
            print("[ASC Performance] Applied optimization: Reduced update rates")
        end
    elseif alertType == "Memory" then
        if not actions.ForceGarbageCollection then
            -- Force garbage collection
            if ASC and ASC.MemoryOptimizer then
                ASC.MemoryOptimizer.PerformGC()
                ASC.MemoryOptimizer.CleanupCaches()
            else
                collectgarbage("collect")
            end
            actions.ForceGarbageCollection = true
            ASC.PerformanceMonitor.State.OptimizationsApplied = ASC.PerformanceMonitor.State.OptimizationsApplied + 1
            print("[ASC Performance] Applied optimization: Forced garbage collection")
        end
    elseif alertType == "EntityCount" then
        if not actions.LimitEntityUpdates then
            -- Limit entity updates
            actions.LimitEntityUpdates = true
            ASC.PerformanceMonitor.State.OptimizationsApplied = ASC.PerformanceMonitor.State.OptimizationsApplied + 1
            print("[ASC Performance] Applied optimization: Limited entity updates")
        end
    end
end

-- Determine overall performance level
function ASC.PerformanceMonitor.UpdatePerformanceLevel()
    local fps = ASC.PerformanceMonitor.Metrics.FPS.Current
    local memory = ASC.PerformanceMonitor.Metrics.Memory.Current
    local entities = ASC.PerformanceMonitor.Metrics.EntityCount.Current
    
    local score = 0
    
    -- FPS scoring
    if fps >= 50 then score = score + 3
    elseif fps >= 30 then score = score + 2
    elseif fps >= 20 then score = score + 1
    else score = score + 0 end
    
    -- Memory scoring
    if memory <= 150 then score = score + 3
    elseif memory <= 250 then score = score + 2
    elseif memory <= 350 then score = score + 1
    else score = score + 0 end
    
    -- Entity count scoring
    if entities <= 400 then score = score + 3
    elseif entities <= 600 then score = score + 2
    elseif entities <= 800 then score = score + 1
    else score = score + 0 end
    
    -- Determine level
    if score >= 8 then
        ASC.PerformanceMonitor.State.PerformanceLevel = "Good"
    elseif score >= 5 then
        ASC.PerformanceMonitor.State.PerformanceLevel = "Fair"
    elseif score >= 2 then
        ASC.PerformanceMonitor.State.PerformanceLevel = "Poor"
    else
        ASC.PerformanceMonitor.State.PerformanceLevel = "Critical"
    end
end

-- Main performance monitoring update
function ASC.PerformanceMonitor.Update()
    if not ASC.PerformanceMonitor.Config.Enabled then return end
    
    local currentTime = CurTime()
    
    -- Sample metrics
    if currentTime - ASC.PerformanceMonitor.State.LastSample >= ASC.PerformanceMonitor.Config.SampleInterval then
        ASC.PerformanceMonitor.SampleMetrics()
        ASC.PerformanceMonitor.UpdatePerformanceLevel()
        ASC.PerformanceMonitor.CheckAlerts()
    end
    
    -- Generate reports
    if currentTime - ASC.PerformanceMonitor.State.LastReport >= ASC.PerformanceMonitor.Config.ReportInterval then
        ASC.PerformanceMonitor.GenerateReport()
        ASC.PerformanceMonitor.State.LastReport = currentTime
    end
end

-- Generate performance report
function ASC.PerformanceMonitor.GenerateReport()
    local metrics = ASC.PerformanceMonitor.Metrics
    local state = ASC.PerformanceMonitor.State
    
    print("[ASC Performance] Performance Report:")
    print("  Overall Level: " .. state.PerformanceLevel)
    print("  FPS: " .. string.format("%.1f", metrics.FPS.Current) .. " (Avg: " .. string.format("%.1f", metrics.FPS.Average) .. ")")
    print("  Memory: " .. string.format("%.1f", metrics.Memory.Current) .. "MB (Avg: " .. string.format("%.1f", metrics.Memory.Average) .. "MB)")
    print("  Entities: " .. metrics.EntityCount.Current .. " (Avg: " .. math.floor(metrics.EntityCount.Average) .. ")")
    if SERVER then
        print("  Network Latency: " .. string.format("%.1f", metrics.NetworkLatency.Current) .. "ms (Avg: " .. string.format("%.1f", metrics.NetworkLatency.Average) .. "ms)")
    end
    print("  Alerts Triggered: " .. state.AlertsTriggered)
    print("  Optimizations Applied: " .. state.OptimizationsApplied)
end

-- Get performance statistics
function ASC.PerformanceMonitor.GetStats()
    return {
        Metrics = ASC.PerformanceMonitor.Metrics,
        State = ASC.PerformanceMonitor.State,
        OptimizationActions = ASC.PerformanceMonitor.OptimizationActions
    }
end

-- Initialize performance monitor
function ASC.PerformanceMonitor.Initialize()
    if ASC.PerformanceMonitor.Initialized then return end
    
    print("[ASC Performance] Initializing Performance Monitor...")
    
    -- Register with master scheduler
    timer.Simple(11, function()
        if ASC and ASC.MasterScheduler then
            ASC.MasterScheduler.RegisterTask("ASC_PerformanceMonitor", "Medium", function()
                ASC.PerformanceMonitor.Update()
            end, 1.0) -- 1 FPS for performance monitoring
        else
            -- Fallback timer if master scheduler not available
            timer.Create("ASC_PerformanceMonitor", 1, 0, function()
                ASC.PerformanceMonitor.Update()
            end)
        end
    end)
    
    ASC.PerformanceMonitor.Initialized = true
    print("[ASC Performance] Performance Monitor initialized successfully!")
end

-- Console command for performance stats
concommand.Add("asc_performance_report", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    ASC.PerformanceMonitor.GenerateReport()
end)

-- Initialize when ready
timer.Simple(3, function()
    ASC.PerformanceMonitor.Initialize()
end)

print("[Advanced Space Combat] Performance Monitor loaded successfully!")
