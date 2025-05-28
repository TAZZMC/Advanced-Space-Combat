-- Hyperdrive System Health and Diagnostics
-- Comprehensive system health monitoring, diagnostics, and automated maintenance

if CLIENT then return end

-- Initialize system health
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.SystemHealth = HYPERDRIVE.SystemHealth or {}

print("[Hyperdrive] System health and diagnostics loading...")

-- Health check configuration
HYPERDRIVE.SystemHealth.Config = {
    EnableHealthChecks = true,      -- Enable health monitoring
    HealthCheckInterval = 30,       -- Health check interval (seconds)
    AutoMaintenance = true,         -- Enable automatic maintenance
    MaintenanceInterval = 3600,     -- Maintenance interval (1 hour)
    DiagnosticDepth = "full",       -- Diagnostic depth (basic/full/deep)
    AlertOnIssues = true,           -- Alert on health issues
    AutoRepair = true,              -- Enable automatic repair
    HealthThresholds = {
        critical = 30,              -- Critical health threshold
        warning = 60,               -- Warning health threshold
        good = 80,                  -- Good health threshold
    }
}

-- Health state
HYPERDRIVE.SystemHealth.State = {
    overallHealth = 100,
    lastHealthCheck = 0,
    lastMaintenance = 0,
    healthHistory = {},
    diagnosticResults = {},
    maintenanceLog = {},
    systemIssues = {},
    repairActions = {},
}

-- Health check categories
HYPERDRIVE.SystemHealth.Categories = {
    CORE_SYSTEM = "core_system",
    INTEGRATIONS = "integrations",
    PERFORMANCE = "performance",
    NETWORK = "network",
    ERROR_RECOVERY = "error_recovery",
    MONITORING = "monitoring",
    CONFIGURATION = "configuration",
    DATA_INTEGRITY = "data_integrity",
}

-- Function to get health configuration
local function GetHealthConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("SystemHealth", key, HYPERDRIVE.SystemHealth.Config[key] or default)
    end
    return HYPERDRIVE.SystemHealth.Config[key] or default
end

-- Perform comprehensive system health check
function HYPERDRIVE.SystemHealth.PerformHealthCheck()
    if not GetHealthConfig("EnableHealthChecks", true) then return end
    
    local startTime = SysTime()
    local healthResults = {}
    local overallScore = 0
    local totalCategories = 0
    
    -- Core system health
    local coreHealth = HYPERDRIVE.SystemHealth.CheckCoreSystem()
    healthResults[HYPERDRIVE.SystemHealth.Categories.CORE_SYSTEM] = coreHealth
    overallScore = overallScore + coreHealth.score
    totalCategories = totalCategories + 1
    
    -- Integration health
    local integrationHealth = HYPERDRIVE.SystemHealth.CheckIntegrations()
    healthResults[HYPERDRIVE.SystemHealth.Categories.INTEGRATIONS] = integrationHealth
    overallScore = overallScore + integrationHealth.score
    totalCategories = totalCategories + 1
    
    -- Performance health
    local performanceHealth = HYPERDRIVE.SystemHealth.CheckPerformance()
    healthResults[HYPERDRIVE.SystemHealth.Categories.PERFORMANCE] = performanceHealth
    overallScore = overallScore + performanceHealth.score
    totalCategories = totalCategories + 1
    
    -- Network health
    local networkHealth = HYPERDRIVE.SystemHealth.CheckNetwork()
    healthResults[HYPERDRIVE.SystemHealth.Categories.NETWORK] = networkHealth
    overallScore = overallScore + networkHealth.score
    totalCategories = totalCategories + 1
    
    -- Error recovery health
    local errorHealth = HYPERDRIVE.SystemHealth.CheckErrorRecovery()
    healthResults[HYPERDRIVE.SystemHealth.Categories.ERROR_RECOVERY] = errorHealth
    overallScore = overallScore + errorHealth.score
    totalCategories = totalCategories + 1
    
    -- Configuration health
    local configHealth = HYPERDRIVE.SystemHealth.CheckConfiguration()
    healthResults[HYPERDRIVE.SystemHealth.Categories.CONFIGURATION] = configHealth
    overallScore = overallScore + configHealth.score
    totalCategories = totalCategories + 1
    
    -- Calculate overall health
    local overallHealth = totalCategories > 0 and (overallScore / totalCategories) or 0
    
    -- Store health results
    local healthCheck = {
        timestamp = CurTime(),
        overallHealth = overallHealth,
        categories = healthResults,
        duration = SysTime() - startTime,
        issues = {},
        recommendations = {}
    }
    
    -- Collect issues and recommendations
    for category, result in pairs(healthResults) do
        for _, issue in ipairs(result.issues) do
            table.insert(healthCheck.issues, {category = category, issue = issue})
        end
        for _, rec in ipairs(result.recommendations) do
            table.insert(healthCheck.recommendations, {category = category, recommendation = rec})
        end
    end
    
    -- Store in history
    table.insert(HYPERDRIVE.SystemHealth.State.healthHistory, healthCheck)
    
    -- Limit history
    local maxHistory = 100
    while #HYPERDRIVE.SystemHealth.State.healthHistory > maxHistory do
        table.remove(HYPERDRIVE.SystemHealth.State.healthHistory, 1)
    end
    
    HYPERDRIVE.SystemHealth.State.overallHealth = overallHealth
    HYPERDRIVE.SystemHealth.State.lastHealthCheck = CurTime()
    HYPERDRIVE.SystemHealth.State.systemIssues = healthCheck.issues
    
    -- Send alerts if health is poor
    if GetHealthConfig("AlertOnIssues", true) then
        HYPERDRIVE.SystemHealth.ProcessHealthAlerts(healthCheck)
    end
    
    -- Attempt automatic repairs
    if GetHealthConfig("AutoRepair", true) then
        HYPERDRIVE.SystemHealth.AttemptAutoRepair(healthCheck)
    end
    
    return healthCheck
end

-- Check core system health
function HYPERDRIVE.SystemHealth.CheckCoreSystem()
    local result = {score = 100, issues = {}, recommendations = {}}
    
    -- Check if core systems are loaded
    if not HYPERDRIVE then
        result.score = result.score - 50
        table.insert(result.issues, "Core HYPERDRIVE table not found")
    end
    
    -- Check hyperdrive engines
    local engines = ents.FindByClass("hyperdrive_*")
    local workingEngines = 0
    
    for _, engine in ipairs(engines) do
        if IsValid(engine) and string.find(engine:GetClass(), "engine") then
            workingEngines = workingEngines + 1
            
            -- Check engine health
            if engine.GetEnergy and engine:GetEnergy() < 0 then
                result.score = result.score - 5
                table.insert(result.issues, "Engine with negative energy detected")
            end
        end
    end
    
    if #engines == 0 then
        result.score = result.score - 20
        table.insert(result.issues, "No hyperdrive engines found")
        table.insert(result.recommendations, "Deploy hyperdrive engines for testing")
    end
    
    return result
end

-- Check integration health
function HYPERDRIVE.SystemHealth.CheckIntegrations()
    local result = {score = 100, issues = {}, recommendations = {}}
    
    -- Check Space Combat 2 integration
    if HYPERDRIVE.SpaceCombat2 then
        local sc2Status = HYPERDRIVE.SpaceCombat2.IsSpaceCombat2Loaded and HYPERDRIVE.SpaceCombat2.IsSpaceCombat2Loaded()
        if not sc2Status then
            result.score = result.score - 10
            table.insert(result.issues, "SC2 integration loaded but SC2 not detected")
        end
    end
    
    -- Check configuration system
    if not HYPERDRIVE.EnhancedConfig then
        result.score = result.score - 15
        table.insert(result.issues, "Enhanced configuration system not loaded")
        table.insert(result.recommendations, "Verify configuration system files")
    end
    
    -- Check performance system
    if not HYPERDRIVE.Performance then
        result.score = result.score - 10
        table.insert(result.issues, "Performance optimization system not loaded")
    end
    
    return result
end

-- Check performance health
function HYPERDRIVE.SystemHealth.CheckPerformance()
    local result = {score = 100, issues = {}, recommendations = {}}
    
    -- Check memory usage
    local memoryUsage = collectgarbage("count")
    if memoryUsage > 200000 then -- 200MB
        result.score = result.score - 20
        table.insert(result.issues, "High memory usage: " .. string.format("%.1fMB", memoryUsage / 1024))
        table.insert(result.recommendations, "Consider memory optimization or garbage collection")
    elseif memoryUsage > 100000 then -- 100MB
        result.score = result.score - 10
        table.insert(result.issues, "Elevated memory usage: " .. string.format("%.1fMB", memoryUsage / 1024))
    end
    
    -- Check frame time
    local frameTime = engine.TickInterval()
    if frameTime > 0.025 then -- Below 40 FPS
        result.score = result.score - 15
        table.insert(result.issues, "Poor server performance: " .. string.format("%.1fms", frameTime * 1000))
        table.insert(result.recommendations, "Investigate server performance issues")
    end
    
    -- Check entity count
    local entityCount = #ents.GetAll()
    if entityCount > 4000 then
        result.score = result.score - 10
        table.insert(result.issues, "High entity count: " .. entityCount)
        table.insert(result.recommendations, "Consider entity cleanup or optimization")
    end
    
    return result
end

-- Check network health
function HYPERDRIVE.SystemHealth.CheckNetwork()
    local result = {score = 100, issues = {}, recommendations = {}}
    
    if HYPERDRIVE.Network then
        local stats = HYPERDRIVE.Network.GetStatistics and HYPERDRIVE.Network.GetStatistics()
        if stats then
            -- Check bandwidth usage
            if stats.bandwidthUsage > 1000000 then -- 1MB/s
                result.score = result.score - 15
                table.insert(result.issues, "High bandwidth usage: " .. string.format("%.1fKB/s", stats.bandwidthUsage / 1024))
                table.insert(result.recommendations, "Enable network optimization or reduce batch sizes")
            end
            
            -- Check queue size
            if stats.queueSize > 100 then
                result.score = result.score - 10
                table.insert(result.issues, "Large network queue: " .. stats.queueSize)
                table.insert(result.recommendations, "Increase network processing capacity")
            end
        end
    else
        result.score = result.score - 5
        table.insert(result.issues, "Network optimization system not available")
    end
    
    return result
end

-- Check error recovery health
function HYPERDRIVE.SystemHealth.CheckErrorRecovery()
    local result = {score = 100, issues = {}, recommendations = {}}
    
    if HYPERDRIVE.ErrorRecovery then
        local stats = HYPERDRIVE.ErrorRecovery.GetStatistics and HYPERDRIVE.ErrorRecovery.GetStatistics()
        if stats then
            -- Check error rate
            if stats.totalErrors > 0 then
                local errorRate = (stats.totalErrors - stats.recoveredErrors) / stats.totalErrors
                if errorRate > 0.1 then -- 10% error rate
                    result.score = result.score - 20
                    table.insert(result.issues, "High error rate: " .. string.format("%.1f%%", errorRate * 100))
                    table.insert(result.recommendations, "Investigate error causes and improve error handling")
                elseif errorRate > 0.05 then -- 5% error rate
                    result.score = result.score - 10
                    table.insert(result.issues, "Elevated error rate: " .. string.format("%.1f%%", errorRate * 100))
                end
            end
            
            -- Check critical errors
            if stats.criticalErrors > 5 then
                result.score = result.score - 15
                table.insert(result.issues, "Multiple critical errors: " .. stats.criticalErrors)
                table.insert(result.recommendations, "Review critical error logs immediately")
            end
        end
    else
        result.score = result.score - 10
        table.insert(result.issues, "Error recovery system not available")
        table.insert(result.recommendations, "Enable error recovery system for better reliability")
    end
    
    return result
end

-- Check configuration health
function HYPERDRIVE.SystemHealth.CheckConfiguration()
    local result = {score = 100, issues = {}, recommendations = {}}
    
    if HYPERDRIVE.EnhancedConfig then
        -- Check for missing critical configurations
        local criticalConfigs = {
            {"Performance", "EnableProfiling"},
            {"Monitoring", "EnableMonitoring"},
            {"ErrorRecovery", "EnableRecovery"}
        }
        
        for _, config in ipairs(criticalConfigs) do
            local value = HYPERDRIVE.EnhancedConfig.Get and HYPERDRIVE.EnhancedConfig.Get(config[1], config[2])
            if value == nil then
                result.score = result.score - 5
                table.insert(result.issues, "Missing configuration: " .. config[1] .. "." .. config[2])
            end
        end
    else
        result.score = result.score - 20
        table.insert(result.issues, "Configuration system not available")
        table.insert(result.recommendations, "Load enhanced configuration system")
    end
    
    return result
end

-- Process health alerts
function HYPERDRIVE.SystemHealth.ProcessHealthAlerts(healthCheck)
    local thresholds = GetHealthConfig("HealthThresholds", {})
    
    if healthCheck.overallHealth < (thresholds.critical or 30) then
        if HYPERDRIVE.Monitoring and HYPERDRIVE.Monitoring.SendAlert then
            HYPERDRIVE.Monitoring.SendAlert("Critical system health: " .. string.format("%.1f%%", healthCheck.overallHealth),
                HYPERDRIVE.Monitoring.AlertLevels.CRITICAL, nil, {healthCheck = healthCheck})
        end
    elseif healthCheck.overallHealth < (thresholds.warning or 60) then
        if HYPERDRIVE.Monitoring and HYPERDRIVE.Monitoring.SendAlert then
            HYPERDRIVE.Monitoring.SendAlert("Poor system health: " .. string.format("%.1f%%", healthCheck.overallHealth),
                HYPERDRIVE.Monitoring.AlertLevels.WARNING, nil, {healthCheck = healthCheck})
        end
    end
end

-- Attempt automatic repair
function HYPERDRIVE.SystemHealth.AttemptAutoRepair(healthCheck)
    local repairActions = {}
    
    for _, issueData in ipairs(healthCheck.issues) do
        local issue = issueData.issue
        local category = issueData.category
        
        -- Memory cleanup
        if string.find(issue, "memory usage") then
            collectgarbage("collect")
            table.insert(repairActions, "Performed garbage collection")
        end
        
        -- Cache cleanup
        if string.find(issue, "cache") and HYPERDRIVE.Performance then
            if HYPERDRIVE.Performance.ClearCache then
                HYPERDRIVE.Performance.ClearCache()
                table.insert(repairActions, "Cleared performance cache")
            end
        end
        
        -- Network queue cleanup
        if string.find(issue, "network queue") and HYPERDRIVE.Network then
            if HYPERDRIVE.Network.State then
                HYPERDRIVE.Network.State.priorityQueue = {}
                table.insert(repairActions, "Cleared network queue")
            end
        end
    end
    
    if #repairActions > 0 then
        table.insert(HYPERDRIVE.SystemHealth.State.repairActions, {
            timestamp = CurTime(),
            actions = repairActions,
            healthBefore = healthCheck.overallHealth
        })
        
        print("[Hyperdrive System Health] Performed automatic repairs: " .. table.concat(repairActions, ", "))
    end
end

-- Perform system maintenance
function HYPERDRIVE.SystemHealth.PerformMaintenance()
    if not GetHealthConfig("AutoMaintenance", true) then return end
    
    local startTime = SysTime()
    local maintenanceActions = {}
    
    -- Garbage collection
    local memoryBefore = collectgarbage("count")
    collectgarbage("collect")
    local memoryAfter = collectgarbage("count")
    table.insert(maintenanceActions, string.format("Garbage collection: %.1fMB -> %.1fMB", 
        memoryBefore / 1024, memoryAfter / 1024))
    
    -- Clear old data
    if HYPERDRIVE.Performance and HYPERDRIVE.Performance.CleanupOldData then
        HYPERDRIVE.Performance.CleanupOldData()
        table.insert(maintenanceActions, "Cleaned performance data")
    end
    
    if HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.Cleanup then
        HYPERDRIVE.ErrorRecovery.Cleanup()
        table.insert(maintenanceActions, "Cleaned error recovery data")
    end
    
    if HYPERDRIVE.Analytics and HYPERDRIVE.Analytics.CleanupOldData then
        HYPERDRIVE.Analytics.CleanupOldData()
        table.insert(maintenanceActions, "Cleaned analytics data")
    end
    
    -- Log maintenance
    local maintenanceLog = {
        timestamp = CurTime(),
        duration = SysTime() - startTime,
        actions = maintenanceActions
    }
    
    table.insert(HYPERDRIVE.SystemHealth.State.maintenanceLog, maintenanceLog)
    
    -- Limit maintenance log
    local maxLogs = 50
    while #HYPERDRIVE.SystemHealth.State.maintenanceLog > maxLogs do
        table.remove(HYPERDRIVE.SystemHealth.State.maintenanceLog, 1)
    end
    
    HYPERDRIVE.SystemHealth.State.lastMaintenance = CurTime()
    
    print("[Hyperdrive System Health] Maintenance completed: " .. table.concat(maintenanceActions, ", "))
    
    return maintenanceLog
end

-- Get system health status
function HYPERDRIVE.SystemHealth.GetStatus()
    return {
        overallHealth = HYPERDRIVE.SystemHealth.State.overallHealth,
        lastHealthCheck = HYPERDRIVE.SystemHealth.State.lastHealthCheck,
        lastMaintenance = HYPERDRIVE.SystemHealth.State.lastMaintenance,
        activeIssues = #HYPERDRIVE.SystemHealth.State.systemIssues,
        healthHistory = #HYPERDRIVE.SystemHealth.State.healthHistory,
        maintenanceHistory = #HYPERDRIVE.SystemHealth.State.maintenanceLog,
        repairActions = #HYPERDRIVE.SystemHealth.State.repairActions,
    }
end

-- Health check timer
timer.Create("HyperdriveSystemHealthCheck", GetHealthConfig("HealthCheckInterval", 30), 0, function()
    HYPERDRIVE.SystemHealth.PerformHealthCheck()
end)

-- Maintenance timer
timer.Create("HyperdriveSystemMaintenance", GetHealthConfig("MaintenanceInterval", 3600), 0, function()
    HYPERDRIVE.SystemHealth.PerformMaintenance()
end)

-- Console commands for system health
concommand.Add("hyperdrive_health_check", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local healthCheck = HYPERDRIVE.SystemHealth.PerformHealthCheck()
    
    ply:ChatPrint("[Hyperdrive System Health] Health Check Results:")
    ply:ChatPrint("  • Overall Health: " .. string.format("%.1f%%", healthCheck.overallHealth))
    ply:ChatPrint("  • Issues Found: " .. #healthCheck.issues)
    ply:ChatPrint("  • Recommendations: " .. #healthCheck.recommendations)
    ply:ChatPrint("  • Check Duration: " .. string.format("%.3fs", healthCheck.duration))
    
    if #healthCheck.issues > 0 then
        ply:ChatPrint("  • Critical Issues:")
        for i, issueData in ipairs(healthCheck.issues) do
            if i <= 5 then
                ply:ChatPrint("    - " .. issueData.issue)
            end
        end
        if #healthCheck.issues > 5 then
            ply:ChatPrint("    ... and " .. (#healthCheck.issues - 5) .. " more")
        end
    end
end)

concommand.Add("hyperdrive_maintenance", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local maintenance = HYPERDRIVE.SystemHealth.PerformMaintenance()
    
    ply:ChatPrint("[Hyperdrive System Health] Maintenance completed:")
    ply:ChatPrint("  • Duration: " .. string.format("%.3fs", maintenance.duration))
    ply:ChatPrint("  • Actions: " .. #maintenance.actions)
    
    for _, action in ipairs(maintenance.actions) do
        ply:ChatPrint("    - " .. action)
    end
end)

print("[Hyperdrive] System health and diagnostics loaded")
