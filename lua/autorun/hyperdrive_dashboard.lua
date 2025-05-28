-- Hyperdrive Real-Time Dashboard System
-- Comprehensive real-time monitoring dashboard with live metrics and visualization

if CLIENT then return end

-- Initialize dashboard system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Dashboard = HYPERDRIVE.Dashboard or {}

print("[Hyperdrive] Real-time dashboard system loading...")

-- Dashboard configuration
HYPERDRIVE.Dashboard.Config = {
    EnableDashboard = true,         -- Enable dashboard system
    UpdateInterval = 2,             -- Dashboard update interval (seconds)
    MaxDataPoints = 100,            -- Maximum data points for charts
    EnableRealTimeAlerts = true,    -- Enable real-time alerts
    EnableMetricsExport = true,     -- Enable metrics export
    DashboardPort = 8080,           -- Dashboard web port (if web interface)
    EnableWebInterface = false,     -- Enable web-based dashboard
    AlertThresholds = {
        performanceScore = 70,
        memoryUsage = 100000,
        networkUsage = 500000,
        errorRate = 0.05,
    }
}

-- Dashboard state
HYPERDRIVE.Dashboard.State = {
    activeDashboards = {},
    realtimeData = {},
    alertHistory = {},
    connectedClients = {},
    lastUpdate = 0,
    dataStreams = {},
}

-- Network strings for dashboard
util.AddNetworkString("hyperdrive_dashboard_open")
util.AddNetworkString("hyperdrive_dashboard_update")
util.AddNetworkString("hyperdrive_dashboard_command")
util.AddNetworkString("hyperdrive_dashboard_alert")

-- Function to get dashboard configuration
local function GetDashConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("Dashboard", key, HYPERDRIVE.Dashboard.Config[key] or default)
    end
    return HYPERDRIVE.Dashboard.Config[key] or default
end

-- Collect comprehensive system data
function HYPERDRIVE.Dashboard.CollectSystemData()
    local data = {
        timestamp = CurTime(),
        serverTime = os.time(),
        
        -- Server information
        server = {
            name = GetHostName(),
            map = game.GetMap(),
            players = #player.GetAll(),
            maxPlayers = game.MaxPlayers(),
            uptime = CurTime(),
        },
        
        -- System metrics
        system = {
            memoryUsage = collectgarbage("count"),
            frameTime = engine.TickInterval(),
            tickRate = 1 / engine.TickInterval(),
            entityCount = #ents.GetAll(),
        },
        
        -- Hyperdrive metrics
        hyperdrive = {
            engines = {},
            totalEngines = 0,
            activeJumps = 0,
            totalJumps = 0,
            successRate = 0,
            averageJumpTime = 0,
        },
        
        -- Integration status
        integrations = {},
        
        -- Performance data
        performance = {},
        
        -- Network data
        network = {},
        
        -- Error data
        errors = {},
        
        -- Optimization data
        optimization = {},
        
        -- Monitoring data
        monitoring = {},
    }
    
    -- Collect hyperdrive engine data
    local engines = ents.FindByClass("hyperdrive_*")
    for _, engine in ipairs(engines) do
        if IsValid(engine) and string.find(engine:GetClass(), "engine") then
            local engineData = {
                entIndex = engine:EntIndex(),
                class = engine:GetClass(),
                position = engine:GetPos(),
                energy = engine.GetEnergy and engine:GetEnergy() or 0,
                maxEnergy = engine.GetMaxEnergy and engine:GetMaxEnergy() or 1000,
                charging = engine.GetCharging and engine:GetCharging() or false,
                cooldown = engine.GetCooldown and engine:GetCooldown() or 0,
                isJumping = engine.IsJumping and engine:IsJumping() or false,
                owner = engine.GetOwner and IsValid(engine:GetOwner()) and engine:GetOwner():Nick() or "Unknown",
                health = "unknown"
            }
            
            -- Get ship classification if available
            if HYPERDRIVE.ShipDetection and HYPERDRIVE.ShipDetection.DetectAndClassifyShip then
                local detection = HYPERDRIVE.ShipDetection.DetectAndClassifyShip(engine)
                engineData.shipType = detection.shipType.name
                engineData.entityCount = detection.composition.totalEntities
                engineData.mass = detection.composition.totalMass
            end
            
            -- Get health status from monitoring
            if HYPERDRIVE.Monitoring and HYPERDRIVE.Monitoring.State.monitoredEngines then
                local monitoredEngine = HYPERDRIVE.Monitoring.State.monitoredEngines[engine:EntIndex()]
                if monitoredEngine then
                    engineData.health = monitoredEngine.health
                    engineData.issues = monitoredEngine.issues
                end
            end
            
            table.insert(data.hyperdrive.engines, engineData)
            
            if engineData.isJumping then
                data.hyperdrive.activeJumps = data.hyperdrive.activeJumps + 1
            end
        end
    end
    
    data.hyperdrive.totalEngines = #data.hyperdrive.engines
    
    -- Collect integration status
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.CheckIntegrations then
        data.integrations = HYPERDRIVE.EnhancedConfig.CheckIntegrations()
    end
    
    -- Collect performance data
    if HYPERDRIVE.Performance and HYPERDRIVE.Performance.GetStatistics then
        data.performance = HYPERDRIVE.Performance.GetStatistics()
        data.hyperdrive.totalJumps = data.performance.totalJumps or 0
        data.hyperdrive.averageJumpTime = data.performance.averageJumpTime or 0
    end
    
    -- Collect network data
    if HYPERDRIVE.Network and HYPERDRIVE.Network.GetStatistics then
        data.network = HYPERDRIVE.Network.GetStatistics()
    end
    
    -- Collect error data
    if HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.GetStatistics then
        data.errors = HYPERDRIVE.ErrorRecovery.GetStatistics()
        if data.errors.totalErrors > 0 then
            data.hyperdrive.successRate = (data.errors.totalErrors - (data.errors.totalErrors - data.errors.recoveredErrors)) / data.errors.totalErrors
        else
            data.hyperdrive.successRate = 1.0
        end
    end
    
    -- Collect optimization data
    if HYPERDRIVE.Optimization and HYPERDRIVE.Optimization.GetStatus then
        data.optimization = HYPERDRIVE.Optimization.GetStatus()
    end
    
    -- Collect monitoring data
    if HYPERDRIVE.Monitoring and HYPERDRIVE.Monitoring.State then
        data.monitoring = {
            systemHealth = HYPERDRIVE.Monitoring.State.systemHealth,
            monitoredEngines = table.Count(HYPERDRIVE.Monitoring.State.monitoredEngines),
            activeAlerts = table.Count(HYPERDRIVE.Monitoring.State.activeAlerts),
            alertHistory = #HYPERDRIVE.Monitoring.State.alertHistory,
        }
    end
    
    return data
end

-- Update real-time data streams
function HYPERDRIVE.Dashboard.UpdateDataStreams()
    local currentData = HYPERDRIVE.Dashboard.CollectSystemData()
    
    -- Store in real-time data
    table.insert(HYPERDRIVE.Dashboard.State.realtimeData, currentData)
    
    -- Limit data points
    local maxDataPoints = GetDashConfig("MaxDataPoints", 100)
    while #HYPERDRIVE.Dashboard.State.realtimeData > maxDataPoints do
        table.remove(HYPERDRIVE.Dashboard.State.realtimeData, 1)
    end
    
    -- Check for alert conditions
    HYPERDRIVE.Dashboard.CheckAlertConditions(currentData)
    
    -- Send updates to connected clients
    HYPERDRIVE.Dashboard.BroadcastUpdate(currentData)
    
    HYPERDRIVE.Dashboard.State.lastUpdate = CurTime()
    
    return currentData
end

-- Check for alert conditions
function HYPERDRIVE.Dashboard.CheckAlertConditions(data)
    if not GetDashConfig("EnableRealTimeAlerts", true) then return end
    
    local alerts = {}
    local thresholds = GetDashConfig("AlertThresholds", {})
    
    -- Check performance score
    if data.optimization.currentPerformance and 
       data.optimization.currentPerformance < (thresholds.performanceScore or 70) then
        table.insert(alerts, {
            type = "performance",
            severity = "warning",
            message = "Performance score below threshold",
            value = data.optimization.currentPerformance,
            threshold = thresholds.performanceScore
        })
    end
    
    -- Check memory usage
    if data.system.memoryUsage > (thresholds.memoryUsage or 100000) then
        table.insert(alerts, {
            type = "memory",
            severity = "warning",
            message = "High memory usage detected",
            value = data.system.memoryUsage,
            threshold = thresholds.memoryUsage
        })
    end
    
    -- Check network usage
    if data.network.bandwidthUsage and 
       data.network.bandwidthUsage > (thresholds.networkUsage or 500000) then
        table.insert(alerts, {
            type = "network",
            severity = "warning",
            message = "High network usage detected",
            value = data.network.bandwidthUsage,
            threshold = thresholds.networkUsage
        })
    end
    
    -- Check error rate
    if data.errors.totalErrors and data.errors.totalErrors > 0 then
        local errorRate = (data.errors.totalErrors - data.errors.recoveredErrors) / data.errors.totalErrors
        if errorRate > (thresholds.errorRate or 0.05) then
            table.insert(alerts, {
                type = "errors",
                severity = "critical",
                message = "High error rate detected",
                value = errorRate,
                threshold = thresholds.errorRate
            })
        end
    end
    
    -- Check for critical engine issues
    for _, engine in ipairs(data.hyperdrive.engines) do
        if engine.health == "critical" then
            table.insert(alerts, {
                type = "engine",
                severity = "critical",
                message = "Critical engine health: " .. engine.owner,
                engineId = engine.entIndex,
                issues = engine.issues
            })
        end
    end
    
    -- Store and broadcast alerts
    for _, alert in ipairs(alerts) do
        table.insert(HYPERDRIVE.Dashboard.State.alertHistory, {
            alert = alert,
            timestamp = CurTime()
        })
        
        -- Send to monitoring system
        if HYPERDRIVE.Monitoring and HYPERDRIVE.Monitoring.SendAlert then
            local level = alert.severity == "critical" and HYPERDRIVE.Monitoring.AlertLevels.CRITICAL or 
                         HYPERDRIVE.Monitoring.AlertLevels.WARNING
            HYPERDRIVE.Monitoring.SendAlert("Dashboard: " .. alert.message, level, alert.engineId, alert)
        end
        
        -- Broadcast to dashboard clients
        net.Start("hyperdrive_dashboard_alert")
        net.WriteTable(alert)
        net.Broadcast()
    end
    
    -- Limit alert history
    local maxAlerts = 1000
    while #HYPERDRIVE.Dashboard.State.alertHistory > maxAlerts do
        table.remove(HYPERDRIVE.Dashboard.State.alertHistory, 1)
    end
end

-- Broadcast update to connected clients
function HYPERDRIVE.Dashboard.BroadcastUpdate(data)
    local connectedClients = {}
    
    for ply, _ in pairs(HYPERDRIVE.Dashboard.State.connectedClients) do
        if IsValid(ply) then
            table.insert(connectedClients, ply)
        else
            HYPERDRIVE.Dashboard.State.connectedClients[ply] = nil
        end
    end
    
    if #connectedClients > 0 then
        -- Create lightweight update data
        local updateData = {
            timestamp = data.timestamp,
            server = data.server,
            system = data.system,
            hyperdrive = {
                totalEngines = data.hyperdrive.totalEngines,
                activeJumps = data.hyperdrive.activeJumps,
                successRate = data.hyperdrive.successRate,
                averageJumpTime = data.hyperdrive.averageJumpTime,
            },
            performance = {
                currentPerformance = data.optimization.currentPerformance or 0,
                memoryUsage = data.system.memoryUsage,
                networkUsage = data.network.bandwidthUsage or 0,
            },
            monitoring = data.monitoring,
        }
        
        net.Start("hyperdrive_dashboard_update")
        net.WriteTable(updateData)
        net.Send(connectedClients)
    end
end

-- Open dashboard for player
function HYPERDRIVE.Dashboard.OpenDashboard(ply)
    if not IsValid(ply) or not GetDashConfig("EnableDashboard", true) then return end
    
    -- Add to connected clients
    HYPERDRIVE.Dashboard.State.connectedClients[ply] = CurTime()
    
    -- Send initial data
    local currentData = HYPERDRIVE.Dashboard.CollectSystemData()
    
    net.Start("hyperdrive_dashboard_open")
    net.WriteTable(currentData)
    net.Send(ply)
    
    print("[Hyperdrive Dashboard] Dashboard opened for " .. ply:Nick())
end

-- Generate dashboard report
function HYPERDRIVE.Dashboard.GenerateReport(timeframe)
    timeframe = timeframe or 3600 -- 1 hour default
    
    local report = {
        timeframe = timeframe,
        generatedAt = CurTime(),
        summary = {},
        charts = {},
        alerts = {},
        recommendations = {},
    }
    
    -- Get recent data
    local recentData = {}
    local currentTime = CurTime()
    
    for _, dataPoint in ipairs(HYPERDRIVE.Dashboard.State.realtimeData) do
        if currentTime - dataPoint.timestamp <= timeframe then
            table.insert(recentData, dataPoint)
        end
    end
    
    if #recentData == 0 then
        return report
    end
    
    -- Calculate summary statistics
    local totalJumps = 0
    local totalMemory = 0
    local totalNetwork = 0
    local performanceSum = 0
    local validPerformancePoints = 0
    
    for _, data in ipairs(recentData) do
        totalJumps = totalJumps + (data.hyperdrive.totalJumps or 0)
        totalMemory = totalMemory + data.system.memoryUsage
        totalNetwork = totalNetwork + (data.network.bandwidthUsage or 0)
        
        if data.optimization.currentPerformance then
            performanceSum = performanceSum + data.optimization.currentPerformance
            validPerformancePoints = validPerformancePoints + 1
        end
    end
    
    report.summary = {
        dataPoints = #recentData,
        averageJumps = totalJumps / #recentData,
        averageMemory = totalMemory / #recentData,
        averageNetwork = totalNetwork / #recentData,
        averagePerformance = validPerformancePoints > 0 and (performanceSum / validPerformancePoints) or 0,
        peakMemory = 0,
        peakNetwork = 0,
    }
    
    -- Find peaks
    for _, data in ipairs(recentData) do
        report.summary.peakMemory = math.max(report.summary.peakMemory, data.system.memoryUsage)
        report.summary.peakNetwork = math.max(report.summary.peakNetwork, data.network.bandwidthUsage or 0)
    end
    
    -- Get recent alerts
    for _, alertEntry in ipairs(HYPERDRIVE.Dashboard.State.alertHistory) do
        if currentTime - alertEntry.timestamp <= timeframe then
            table.insert(report.alerts, alertEntry)
        end
    end
    
    -- Generate recommendations based on data
    if report.summary.averagePerformance < 70 then
        table.insert(report.recommendations, "Consider optimizing system performance - average score below 70")
    end
    
    if report.summary.peakMemory > 150000 then
        table.insert(report.recommendations, "Peak memory usage exceeded 150MB - consider memory optimization")
    end
    
    if #report.alerts > 10 then
        table.insert(report.recommendations, "High alert frequency detected - investigate system issues")
    end
    
    return report
end

-- Dashboard update timer
timer.Create("HyperdriveDashboardUpdate", GetDashConfig("UpdateInterval", 2), 0, function()
    if GetDashConfig("EnableDashboard", true) then
        HYPERDRIVE.Dashboard.UpdateDataStreams()
    end
end)

-- Console commands for dashboard
concommand.Add("hyperdrive_dashboard", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    HYPERDRIVE.Dashboard.OpenDashboard(ply)
    ply:ChatPrint("[Hyperdrive] Dashboard opened")
end)

concommand.Add("hyperdrive_dashboard_report", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local timeframe = tonumber(args[1]) or 3600
    local report = HYPERDRIVE.Dashboard.GenerateReport(timeframe)
    
    ply:ChatPrint("[Hyperdrive Dashboard] Report (last " .. timeframe .. "s):")
    ply:ChatPrint("  • Data Points: " .. report.summary.dataPoints)
    ply:ChatPrint("  • Average Performance: " .. string.format("%.1f", report.summary.averagePerformance))
    ply:ChatPrint("  • Average Memory: " .. string.format("%.1fMB", report.summary.averageMemory / 1024))
    ply:ChatPrint("  • Peak Memory: " .. string.format("%.1fMB", report.summary.peakMemory / 1024))
    ply:ChatPrint("  • Alerts: " .. #report.alerts)
    
    if #report.recommendations > 0 then
        ply:ChatPrint("  • Recommendations:")
        for _, rec in ipairs(report.recommendations) do
            ply:ChatPrint("    - " .. rec)
        end
    end
end)

print("[Hyperdrive] Real-time dashboard system loaded")
