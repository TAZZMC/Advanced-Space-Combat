-- Advanced Space Combat - System Integration and Monitoring v1.0.0
-- Integrates all optimization systems and provides comprehensive monitoring

print("[Advanced Space Combat] System Integration and Monitoring v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.SystemIntegration = ASC.SystemIntegration or {}

-- System integration configuration
ASC.SystemIntegration.Config = {
    -- Monitoring
    MonitoringInterval = 5, -- seconds
    PerformanceLogInterval = 60, -- seconds
    AlertThresholds = {
        MemoryUsage = 400, -- MB
        FPS = 30,
        NetworkLoad = 0.8,
        EntityCount = 800
    },
    
    -- Auto-optimization
    EnableAutoOptimization = true,
    OptimizationCooldown = 30, -- seconds between optimizations
    
    -- Integration settings
    EnableAllOptimizations = true,
    EnablePerformanceAlerts = true,
    EnableAutoQualityAdjustment = true
}

-- System integration state
ASC.SystemIntegration.State = {
    LastOptimization = 0,
    LastPerformanceLog = 0,
    SystemHealth = "Good",
    ActiveAlerts = {},
    
    -- System status
    Systems = {
        Performance = { status = "Unknown", lastCheck = 0 },
        AI = { status = "Unknown", lastCheck = 0 },
        Theme = { status = "Unknown", lastCheck = 0 },
        Network = { status = "Unknown", lastCheck = 0 },
        Branding = { status = "Unknown", lastCheck = 0 }
    },
    
    -- Statistics
    OptimizationsPerformed = 0,
    AlertsTriggered = 0,
    SystemUptime = 0
}

-- Initialize system integration
function ASC.SystemIntegration.Initialize()
    print("[Advanced Space Combat] Initializing system integration...")
    
    -- Set up monitoring
    ASC.SystemIntegration.SetupMonitoring()
    
    -- Set up auto-optimization
    ASC.SystemIntegration.SetupAutoOptimization()
    
    -- Verify all systems
    ASC.SystemIntegration.VerifyAllSystems()
    
    -- Set up console commands
    ASC.SystemIntegration.SetupConsoleCommands()
    
    ASC.SystemIntegration.State.SystemUptime = CurTime()
    
    print("[Advanced Space Combat] System integration initialized")
end

-- Set up monitoring
function ASC.SystemIntegration.SetupMonitoring()
    -- Regular system monitoring
    timer.Create("ASC_SystemMonitoring", ASC.SystemIntegration.Config.MonitoringInterval, 0, function()
        ASC.SystemIntegration.MonitorSystems()
    end)
    
    -- Performance logging
    timer.Create("ASC_PerformanceLogging", ASC.SystemIntegration.Config.PerformanceLogInterval, 0, function()
        ASC.SystemIntegration.LogPerformance()
    end)
end

-- Set up auto-optimization
function ASC.SystemIntegration.SetupAutoOptimization()
    if not ASC.SystemIntegration.Config.EnableAutoOptimization then return end
    
    timer.Create("ASC_AutoOptimization", 10, 0, function()
        ASC.SystemIntegration.AutoOptimize()
    end)
end

-- Monitor all systems
function ASC.SystemIntegration.MonitorSystems()
    local currentTime = CurTime()
    local state = ASC.SystemIntegration.State
    
    -- Check each system
    ASC.SystemIntegration.CheckPerformanceSystem()
    ASC.SystemIntegration.CheckAISystem()
    ASC.SystemIntegration.CheckThemeSystem()
    ASC.SystemIntegration.CheckNetworkSystem()
    ASC.SystemIntegration.CheckBrandingSystem()
    
    -- Update overall system health
    ASC.SystemIntegration.UpdateSystemHealth()
    
    -- Check for alerts
    ASC.SystemIntegration.CheckAlerts()
end

-- Check performance system
function ASC.SystemIntegration.CheckPerformanceSystem()
    local status = "Good"
    
    if ASC.Performance and ASC.Performance.State then
        local perfState = ASC.Performance.State
        
        if perfState.MemoryUsage > ASC.SystemIntegration.Config.AlertThresholds.MemoryUsage then
            status = "Warning"
        elseif perfState.AverageFPS < ASC.SystemIntegration.Config.AlertThresholds.FPS then
            status = "Warning"
        elseif perfState.PerformanceLevel == "Poor" then
            status = "Critical"
        end
    else
        status = "Offline"
    end
    
    ASC.SystemIntegration.State.Systems.Performance = {
        status = status,
        lastCheck = CurTime()
    }
end

-- Check AI system
function ASC.SystemIntegration.CheckAISystem()
    local status = "Good"
    
    if ASC.AIOptimization and ASC.AIOptimization.State then
        local aiState = ASC.AIOptimization.State
        
        -- Check cache hit rate
        local hitRate = aiState.CacheHits / math.max(1, aiState.CacheHits + aiState.CacheMisses)
        if hitRate < 0.5 then
            status = "Warning"
        end
        
        -- Check if AI system is responding
        if not ASC.AI or not ASC.AI.ProcessQuery then
            status = "Critical"
        end
    else
        status = "Offline"
    end
    
    ASC.SystemIntegration.State.Systems.AI = {
        status = status,
        lastCheck = CurTime()
    }
end

-- Check theme system
function ASC.SystemIntegration.CheckThemeSystem()
    local status = "Good"
    
    if CLIENT and ASC.ThemeOptimization and ASC.ThemeOptimization.State then
        local themeState = ASC.ThemeOptimization.State
        
        if themeState.CurrentQuality == "Disabled" then
            status = "Warning"
        elseif themeState.MemoryUsage > 150 then
            status = "Warning"
        end
    else
        status = "Offline"
    end
    
    ASC.SystemIntegration.State.Systems.Theme = {
        status = status,
        lastCheck = CurTime()
    }
end

-- Check network system
function ASC.SystemIntegration.CheckNetworkSystem()
    local status = "Good"
    
    if ASC.NetworkOptimization and ASC.NetworkOptimization.State then
        local netState = ASC.NetworkOptimization.State
        
        if netState.NetworkLoad > ASC.SystemIntegration.Config.AlertThresholds.NetworkLoad then
            status = "Warning"
        elseif #netState.BatchQueue > 50 then
            status = "Warning"
        end
    else
        status = "Offline"
    end
    
    ASC.SystemIntegration.State.Systems.Network = {
        status = status,
        lastCheck = CurTime()
    }
end

-- Check branding system
function ASC.SystemIntegration.CheckBrandingSystem()
    local status = "Good"
    
    if ASC.BrandingVerification then
        local issues = ASC.BrandingVerification.VerifyBranding()
        if #issues > 0 then
            status = "Warning"
        end
    else
        status = "Offline"
    end
    
    ASC.SystemIntegration.State.Systems.Branding = {
        status = status,
        lastCheck = CurTime()
    }
end

-- Update overall system health
function ASC.SystemIntegration.UpdateSystemHealth()
    local systems = ASC.SystemIntegration.State.Systems
    local criticalCount = 0
    local warningCount = 0
    local offlineCount = 0
    
    for _, system in pairs(systems) do
        if system.status == "Critical" then
            criticalCount = criticalCount + 1
        elseif system.status == "Warning" then
            warningCount = warningCount + 1
        elseif system.status == "Offline" then
            offlineCount = offlineCount + 1
        end
    end
    
    if criticalCount > 0 then
        ASC.SystemIntegration.State.SystemHealth = "Critical"
    elseif warningCount > 1 or offlineCount > 1 then
        ASC.SystemIntegration.State.SystemHealth = "Warning"
    elseif warningCount > 0 or offlineCount > 0 then
        ASC.SystemIntegration.State.SystemHealth = "Caution"
    else
        ASC.SystemIntegration.State.SystemHealth = "Good"
    end
end

-- Check for alerts
function ASC.SystemIntegration.CheckAlerts()
    if not ASC.SystemIntegration.Config.EnablePerformanceAlerts then return end
    
    local config = ASC.SystemIntegration.Config
    local alerts = {}
    
    -- Memory usage alert
    if ASC.Performance and ASC.Performance.State.MemoryUsage > config.AlertThresholds.MemoryUsage then
        table.insert(alerts, {
            type = "MemoryUsage",
            message = "High memory usage: " .. ASC.Performance.State.MemoryUsage .. " MB",
            severity = "Warning"
        })
    end
    
    -- FPS alert
    if CLIENT and ASC.Performance and ASC.Performance.State.AverageFPS < config.AlertThresholds.FPS then
        table.insert(alerts, {
            type = "LowFPS",
            message = "Low FPS: " .. math.floor(ASC.Performance.State.AverageFPS),
            severity = "Warning"
        })
    end
    
    -- Entity count alert
    local entityCount = #ents.GetAll()
    if entityCount > config.AlertThresholds.EntityCount then
        table.insert(alerts, {
            type = "EntityCount",
            message = "High entity count: " .. entityCount,
            severity = "Warning"
        })
    end
    
    -- Process new alerts
    for _, alert in ipairs(alerts) do
        ASC.SystemIntegration.TriggerAlert(alert)
    end
end

-- Trigger alert
function ASC.SystemIntegration.TriggerAlert(alert)
    local alertKey = alert.type
    
    -- Check if this alert is already active
    if ASC.SystemIntegration.State.ActiveAlerts[alertKey] then return end
    
    -- Add to active alerts
    ASC.SystemIntegration.State.ActiveAlerts[alertKey] = {
        alert = alert,
        timestamp = CurTime()
    }
    
    ASC.SystemIntegration.State.AlertsTriggered = ASC.SystemIntegration.State.AlertsTriggered + 1
    
    print("[Advanced Space Combat] ALERT: " .. alert.message)
end

-- Auto-optimize systems
function ASC.SystemIntegration.AutoOptimize()
    local currentTime = CurTime()
    local state = ASC.SystemIntegration.State
    local config = ASC.SystemIntegration.Config
    
    -- Check cooldown
    if currentTime - state.LastOptimization < config.OptimizationCooldown then return end
    
    -- Check if optimization is needed
    if state.SystemHealth == "Good" then return end
    
    print("[Advanced Space Combat] Auto-optimization triggered - System health: " .. state.SystemHealth)
    
    -- Perform optimizations
    local optimized = false
    
    -- Memory optimization
    if ASC.Performance and ASC.Performance.State.MemoryUsage > 300 then
        if ASC.Performance.TriggerMemoryCleanup then
            ASC.Performance.TriggerMemoryCleanup()
            optimized = true
        end
    end
    
    -- AI optimization
    if ASC.AIOptimization and ASC.AIOptimization.CleanupUserProfiles then
        ASC.AIOptimization.CleanupUserProfiles()
        optimized = true
    end
    
    -- Theme optimization
    if CLIENT and ASC.ThemeOptimization and ASC.ThemeOptimization.ForceCleanup then
        ASC.ThemeOptimization.ForceCleanup()
        optimized = true
    end
    
    -- Network optimization
    if ASC.NetworkOptimization and ASC.NetworkOptimization.ProcessBatchQueue then
        ASC.NetworkOptimization.ProcessBatchQueue()
        optimized = true
    end
    
    if optimized then
        state.LastOptimization = currentTime
        state.OptimizationsPerformed = state.OptimizationsPerformed + 1
        print("[Advanced Space Combat] Auto-optimization completed")
    end
end

-- Verify all systems
function ASC.SystemIntegration.VerifyAllSystems()
    local systems = {
        "ASC.Performance",
        "ASC.AIOptimization", 
        "ASC.NetworkOptimization",
        "ASC.BrandingVerification"
    }
    
    if CLIENT then
        table.insert(systems, "ASC.ThemeOptimization")
    end
    
    print("[Advanced Space Combat] Verifying system integration...")
    
    for _, systemName in ipairs(systems) do
        local system = ASC.SystemIntegration.GetSystemByName(systemName)
        if system then
            print("[Advanced Space Combat] ✅ " .. systemName .. " - Available")
        else
            print("[Advanced Space Combat] ❌ " .. systemName .. " - Not Available")
        end
    end
end

-- Get system by name
function ASC.SystemIntegration.GetSystemByName(name)
    local parts = string.Split(name, ".")
    local current = _G
    
    for _, part in ipairs(parts) do
        if current[part] then
            current = current[part]
        else
            return nil
        end
    end
    
    return current
end

-- Get comprehensive system status
function ASC.SystemIntegration.GetSystemStatus()
    local state = ASC.SystemIntegration.State
    local uptime = CurTime() - state.SystemUptime
    
    local status = {
        "=== Advanced Space Combat System Status ===",
        "Overall Health: " .. state.SystemHealth,
        "System Uptime: " .. string.format("%.1f", uptime) .. " seconds",
        "Optimizations Performed: " .. state.OptimizationsPerformed,
        "Alerts Triggered: " .. state.AlertsTriggered,
        "",
        "Individual Systems:"
    }
    
    for systemName, system in pairs(state.Systems) do
        local statusIcon = "❓"
        if system.status == "Good" then statusIcon = "✅"
        elseif system.status == "Warning" then statusIcon = "⚠️"
        elseif system.status == "Critical" then statusIcon = "❌"
        elseif system.status == "Offline" then statusIcon = "🔴"
        end
        
        table.insert(status, statusIcon .. " " .. systemName .. ": " .. system.status)
    end
    
    if #state.ActiveAlerts > 0 then
        table.insert(status, "")
        table.insert(status, "Active Alerts:")
        for alertType, alertData in pairs(state.ActiveAlerts) do
            table.insert(status, "⚠️ " .. alertData.alert.message)
        end
    end
    
    return status
end

-- Set up console commands
function ASC.SystemIntegration.SetupConsoleCommands()
    concommand.Add("asc_system_status", function(ply, cmd, args)
        local status = ASC.SystemIntegration.GetSystemStatus()
        
        if IsValid(ply) then
            for _, line in ipairs(status) do
                ply:ChatPrint(line)
            end
        else
            for _, line in ipairs(status) do
                print(line)
            end
        end
    end, nil, "Show comprehensive system status")
    
    concommand.Add("asc_force_optimize", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then
            ply:ChatPrint("[Advanced Space Combat] Admin only command")
            return
        end
        
        ASC.SystemIntegration.State.LastOptimization = 0 -- Reset cooldown
        ASC.SystemIntegration.AutoOptimize()
        
        local msg = "[Advanced Space Combat] Force optimization completed"
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    end, nil, "Force system optimization (Admin only)")
end

-- Initialize on load
timer.Simple(3, function()
    ASC.SystemIntegration.Initialize()
end)

print("[Advanced Space Combat] System Integration and Monitoring loaded successfully!")
