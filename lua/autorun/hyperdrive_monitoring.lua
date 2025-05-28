-- Hyperdrive Monitoring and Alerting System
-- Real-time monitoring, alerting, and health checking for hyperdrive systems

if CLIENT then return end

-- Initialize monitoring system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Monitoring = HYPERDRIVE.Monitoring or {}

print("[Hyperdrive] Monitoring and alerting system loading...")

-- Monitoring configuration
HYPERDRIVE.Monitoring.Config = {
    EnableMonitoring = true,        -- Enable monitoring system
    EnableAlerts = true,            -- Enable alert system
    HealthCheckInterval = 10,       -- Health check interval (seconds)
    AlertCooldown = 30,             -- Alert cooldown (seconds)
    MaxAlertHistory = 100,          -- Maximum alert history entries
    CriticalEnergyThreshold = 10,   -- Critical energy threshold (%)
    WarningEnergyThreshold = 25,    -- Warning energy threshold (%)
    MaxJumpFailures = 3,            -- Max jump failures before alert
    PerformanceThreshold = 5.0,     -- Performance threshold (seconds)
}

-- Monitoring state
HYPERDRIVE.Monitoring.State = {
    monitoredEngines = {},
    alertHistory = {},
    lastHealthCheck = 0,
    systemHealth = "unknown",
    activeAlerts = {},
}

-- Alert levels
HYPERDRIVE.Monitoring.AlertLevels = {
    INFO = {name = "Info", color = Color(100, 150, 255), priority = 1},
    WARNING = {name = "Warning", color = Color(255, 200, 0), priority = 2},
    ERROR = {name = "Error", color = Color(255, 100, 0), priority = 3},
    CRITICAL = {name = "Critical", color = Color(255, 0, 0), priority = 4},
}

-- Network strings for monitoring
util.AddNetworkString("hyperdrive_monitoring_alert")
util.AddNetworkString("hyperdrive_monitoring_status")

-- Function to get monitoring configuration
local function GetMonitoringConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("Monitoring", key, HYPERDRIVE.Monitoring.Config[key] or default)
    end
    return HYPERDRIVE.Monitoring.Config[key] or default
end

-- Register engine for monitoring
function HYPERDRIVE.Monitoring.RegisterEngine(engine)
    if not IsValid(engine) or not GetMonitoringConfig("EnableMonitoring", true) then return end
    
    local engineId = engine:EntIndex()
    HYPERDRIVE.Monitoring.State.monitoredEngines[engineId] = {
        engine = engine,
        registeredTime = CurTime(),
        lastHealthCheck = 0,
        jumpFailures = 0,
        lastJumpTime = 0,
        totalJumps = 0,
        averageJumpTime = 0,
        lastAlert = 0,
        health = "unknown"
    }
    
    HYPERDRIVE.Monitoring.SendAlert("Engine registered for monitoring", HYPERDRIVE.Monitoring.AlertLevels.INFO, engineId)
end

-- Unregister engine from monitoring
function HYPERDRIVE.Monitoring.UnregisterEngine(engine)
    if not IsValid(engine) then return end
    
    local engineId = engine:EntIndex()
    if HYPERDRIVE.Monitoring.State.monitoredEngines[engineId] then
        HYPERDRIVE.Monitoring.State.monitoredEngines[engineId] = nil
        HYPERDRIVE.Monitoring.SendAlert("Engine unregistered from monitoring", HYPERDRIVE.Monitoring.AlertLevels.INFO, engineId)
    end
end

-- Send alert
function HYPERDRIVE.Monitoring.SendAlert(message, level, engineId, data)
    if not GetMonitoringConfig("EnableAlerts", true) then return end
    
    local alert = {
        message = message,
        level = level,
        engineId = engineId,
        timestamp = CurTime(),
        data = data or {}
    }
    
    -- Check alert cooldown
    local engineData = HYPERDRIVE.Monitoring.State.monitoredEngines[engineId]
    if engineData then
        local cooldown = GetMonitoringConfig("AlertCooldown", 30)
        if CurTime() - engineData.lastAlert < cooldown and level.priority < 4 then
            return -- Skip non-critical alerts during cooldown
        end
        engineData.lastAlert = CurTime()
    end
    
    -- Add to alert history
    table.insert(HYPERDRIVE.Monitoring.State.alertHistory, alert)
    
    -- Limit alert history
    local maxHistory = GetMonitoringConfig("MaxAlertHistory", 100)
    while #HYPERDRIVE.Monitoring.State.alertHistory > maxHistory do
        table.remove(HYPERDRIVE.Monitoring.State.alertHistory, 1)
    end
    
    -- Add to active alerts for critical/error levels
    if level.priority >= 3 then
        HYPERDRIVE.Monitoring.State.activeAlerts[engineId] = alert
    end
    
    -- Send to clients
    net.Start("hyperdrive_monitoring_alert")
    net.WriteTable(alert)
    net.Broadcast()
    
    -- Console output for server
    local levelName = level.name:upper()
    print(string.format("[Hyperdrive Monitor] [%s] Engine %s: %s", levelName, engineId or "SYSTEM", message))
    
    -- Log to UI system if available
    if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
        HYPERDRIVE.UI.AddLogEntry(message, level.name:lower(), engineId)
    end
end

-- Perform health check on engine
function HYPERDRIVE.Monitoring.HealthCheckEngine(engineId, engineData)
    local engine = engineData.engine
    if not IsValid(engine) then
        HYPERDRIVE.Monitoring.UnregisterEngine(engine)
        return
    end
    
    local health = "healthy"
    local issues = {}
    
    -- Check energy levels
    if engine.GetEnergy then
        local energy = engine:GetEnergy()
        local maxEnergy = 1000 -- Should be configurable
        local energyPercent = (energy / maxEnergy) * 100
        
        if energyPercent < GetMonitoringConfig("CriticalEnergyThreshold", 10) then
            table.insert(issues, "Critical energy level: " .. math.floor(energyPercent) .. "%")
            health = "critical"
            HYPERDRIVE.Monitoring.SendAlert("Critical energy level", HYPERDRIVE.Monitoring.AlertLevels.CRITICAL, engineId, {energy = energyPercent})
        elseif energyPercent < GetMonitoringConfig("WarningEnergyThreshold", 25) then
            table.insert(issues, "Low energy level: " .. math.floor(energyPercent) .. "%")
            if health == "healthy" then health = "warning" end
            HYPERDRIVE.Monitoring.SendAlert("Low energy level", HYPERDRIVE.Monitoring.AlertLevels.WARNING, engineId, {energy = energyPercent})
        end
    end
    
    -- Check cooldown status
    if engine.GetCooldown and engine:GetCooldown() > CurTime() + 60 then
        table.insert(issues, "Extended cooldown period")
        if health == "healthy" then health = "warning" end
    end
    
    -- Check jump failures
    local maxFailures = GetMonitoringConfig("MaxJumpFailures", 3)
    if engineData.jumpFailures >= maxFailures then
        table.insert(issues, "Multiple jump failures: " .. engineData.jumpFailures)
        health = "error"
        HYPERDRIVE.Monitoring.SendAlert("Multiple jump failures detected", HYPERDRIVE.Monitoring.AlertLevels.ERROR, engineId, {failures = engineData.jumpFailures})
    end
    
    -- Check integration health
    if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.ValidateShipConfiguration then
        local isValid, validationIssues = HYPERDRIVE.SpaceCombat2.ValidateShipConfiguration(engine)
        if not isValid then
            for _, issue in ipairs(validationIssues) do
                table.insert(issues, "SC2: " .. issue)
            end
            if health == "healthy" then health = "warning" end
        end
    end
    
    if HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced and HYPERDRIVE.Spacebuild.Enhanced.ValidateShipConfiguration then
        local isValid, validationIssues = HYPERDRIVE.Spacebuild.Enhanced.ValidateShipConfiguration(engine)
        if not isValid then
            for _, issue in ipairs(validationIssues) do
                table.insert(issues, "SB3: " .. issue)
            end
            if health == "healthy" then health = "warning" end
        end
    end
    
    -- Update engine health
    engineData.health = health
    engineData.lastHealthCheck = CurTime()
    engineData.issues = issues
    
    return health, issues
end

-- Perform system-wide health check
function HYPERDRIVE.Monitoring.SystemHealthCheck()
    if not GetMonitoringConfig("EnableMonitoring", true) then return end
    
    local totalEngines = 0
    local healthyEngines = 0
    local warningEngines = 0
    local errorEngines = 0
    local criticalEngines = 0
    
    -- Check all monitored engines
    for engineId, engineData in pairs(HYPERDRIVE.Monitoring.State.monitoredEngines) do
        totalEngines = totalEngines + 1
        local health, issues = HYPERDRIVE.Monitoring.HealthCheckEngine(engineId, engineData)
        
        if health == "healthy" then
            healthyEngines = healthyEngines + 1
        elseif health == "warning" then
            warningEngines = warningEngines + 1
        elseif health == "error" then
            errorEngines = errorEngines + 1
        elseif health == "critical" then
            criticalEngines = criticalEngines + 1
        end
    end
    
    -- Determine overall system health
    local systemHealth = "healthy"
    if criticalEngines > 0 then
        systemHealth = "critical"
    elseif errorEngines > 0 then
        systemHealth = "error"
    elseif warningEngines > 0 then
        systemHealth = "warning"
    end
    
    HYPERDRIVE.Monitoring.State.systemHealth = systemHealth
    HYPERDRIVE.Monitoring.State.lastHealthCheck = CurTime()
    
    -- Send system status update
    local statusData = {
        systemHealth = systemHealth,
        totalEngines = totalEngines,
        healthyEngines = healthyEngines,
        warningEngines = warningEngines,
        errorEngines = errorEngines,
        criticalEngines = criticalEngines,
        timestamp = CurTime()
    }
    
    net.Start("hyperdrive_monitoring_status")
    net.WriteTable(statusData)
    net.Broadcast()
    
    -- Log system health changes
    if systemHealth ~= "healthy" then
        local message = string.format("System health: %s (%d/%d engines healthy)", systemHealth, healthyEngines, totalEngines)
        local level = HYPERDRIVE.Monitoring.AlertLevels.INFO
        if systemHealth == "critical" then
            level = HYPERDRIVE.Monitoring.AlertLevels.CRITICAL
        elseif systemHealth == "error" then
            level = HYPERDRIVE.Monitoring.AlertLevels.ERROR
        elseif systemHealth == "warning" then
            level = HYPERDRIVE.Monitoring.AlertLevels.WARNING
        end
        
        HYPERDRIVE.Monitoring.SendAlert(message, level, nil, statusData)
    end
end

-- Record jump attempt
function HYPERDRIVE.Monitoring.RecordJumpAttempt(engine, success, duration)
    if not IsValid(engine) then return end
    
    local engineId = engine:EntIndex()
    local engineData = HYPERDRIVE.Monitoring.State.monitoredEngines[engineId]
    if not engineData then return end
    
    engineData.totalJumps = engineData.totalJumps + 1
    engineData.lastJumpTime = CurTime()
    
    if success then
        -- Reset failure counter on success
        engineData.jumpFailures = 0
        
        -- Update average jump time
        if duration then
            if engineData.averageJumpTime == 0 then
                engineData.averageJumpTime = duration
            else
                engineData.averageJumpTime = (engineData.averageJumpTime + duration) / 2
            end
            
            -- Check for performance issues
            local threshold = GetMonitoringConfig("PerformanceThreshold", 5.0)
            if duration > threshold then
                HYPERDRIVE.Monitoring.SendAlert("Slow jump performance: " .. string.format("%.2fs", duration), 
                    HYPERDRIVE.Monitoring.AlertLevels.WARNING, engineId, {duration = duration})
            end
        end
        
        -- Clear active alert if it exists
        HYPERDRIVE.Monitoring.State.activeAlerts[engineId] = nil
    else
        -- Increment failure counter
        engineData.jumpFailures = engineData.jumpFailures + 1
        HYPERDRIVE.Monitoring.SendAlert("Jump failure #" .. engineData.jumpFailures, 
            HYPERDRIVE.Monitoring.AlertLevels.ERROR, engineId, {failures = engineData.jumpFailures})
    end
end

-- Health check timer
timer.Create("HyperdriveMonitoringHealthCheck", GetMonitoringConfig("HealthCheckInterval", 10), 0, function()
    HYPERDRIVE.Monitoring.SystemHealthCheck()
end)

-- Hook into engine creation to auto-register
hook.Add("OnEntityCreated", "HyperdriveMonitoringRegister", function(ent)
    timer.Simple(0.1, function()
        if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive") and string.find(ent:GetClass(), "engine") then
            HYPERDRIVE.Monitoring.RegisterEngine(ent)
        end
    end)
end)

-- Hook into engine removal to auto-unregister
hook.Add("EntityRemoved", "HyperdriveMonitoringUnregister", function(ent)
    if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive") and string.find(ent:GetClass(), "engine") then
        HYPERDRIVE.Monitoring.UnregisterEngine(ent)
    end
end)

-- Console commands for monitoring
concommand.Add("hyperdrive_monitoring_status", function(ply, cmd, args)
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    local state = HYPERDRIVE.Monitoring.State
    sendMessage("[Hyperdrive Monitoring] System Status:")
    sendMessage("  • System Health: " .. state.systemHealth)
    sendMessage("  • Monitored Engines: " .. table.Count(state.monitoredEngines))
    sendMessage("  • Active Alerts: " .. table.Count(state.activeAlerts))
    sendMessage("  • Alert History: " .. #state.alertHistory)
    sendMessage("  • Last Health Check: " .. string.format("%.1fs ago", CurTime() - state.lastHealthCheck))
end)

concommand.Add("hyperdrive_monitoring_alerts", function(ply, cmd, args)
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    sendMessage("[Hyperdrive Monitoring] Active Alerts:")
    local activeCount = 0
    for engineId, alert in pairs(HYPERDRIVE.Monitoring.State.activeAlerts) do
        activeCount = activeCount + 1
        sendMessage(string.format("  • Engine %s: %s (%s)", engineId, alert.message, alert.level.name))
    end
    
    if activeCount == 0 then
        sendMessage("  • No active alerts")
    end
end)

print("[Hyperdrive] Monitoring and alerting system loaded")
