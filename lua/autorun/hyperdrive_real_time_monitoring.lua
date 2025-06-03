-- Enhanced Hyperdrive System - Real-Time Monitoring v2.2.1
-- Advanced real-time system monitoring and analytics

print("[Hyperdrive] Loading Real-Time Monitoring System v2.2.1...")

-- Initialize monitoring namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.RealTime = HYPERDRIVE.RealTime or {}

-- Monitoring configuration
HYPERDRIVE.RealTime.Config = {
    EnableMonitoring = true,
    UpdateFrequency = 1, -- Updates per second
    MaxHistoryEntries = 100,
    AlertThresholds = {
        HighCPU = 80,
        HighMemory = 85,
        LowFPS = 30,
        HighEntityCount = 500
    }
}

-- Monitoring data storage
HYPERDRIVE.RealTime.Data = {
    SystemMetrics = {},
    EntityCounts = {},
    PerformanceHistory = {},
    ActiveAlerts = {},
    LastUpdate = 0
}

-- Performance metrics collection
function HYPERDRIVE.RealTime.CollectMetrics()
    local metrics = {
        timestamp = CurTime(),
        serverTime = os.time(),
        tickRate = 1 / engine.TickInterval(),
        entityCount = #ents.GetAll(),
        playerCount = #player.GetAll()
    }
    
    -- Collect entity type counts
    metrics.entityTypes = {
        shipCores = #ents.FindByClass("ship_core"),
        engines = #ents.FindByClass("hyperdrive_engine") + #ents.FindByClass("hyperdrive_master_engine"),
        weapons = #ents.FindByClass("asc_pulse_cannon") + #ents.FindByClass("asc_plasma_cannon") + 
                 #ents.FindByClass("asc_railgun") + #ents.FindByClass("hyperdrive_beam_weapon") + 
                 #ents.FindByClass("hyperdrive_torpedo_launcher"),
        shields = #ents.FindByClass("asc_shield_generator") + #ents.FindByClass("hyperdrive_shield_generator"),
        flightConsoles = #ents.FindByClass("hyperdrive_flight_console"),
        dockingPads = #ents.FindByClass("hyperdrive_docking_pad"),
        shuttles = #ents.FindByClass("hyperdrive_shuttle")
    }
    
    -- System health checks
    metrics.systemHealth = {
        hyperdriveCore = HYPERDRIVE.Core ~= nil,
        shipCoreSystem = HYPERDRIVE.ShipCore ~= nil,
        shieldSystem = HYPERDRIVE.Shields ~= nil,
        weaponSystem = HYPERDRIVE.Weapons ~= nil,
        flightSystem = HYPERDRIVE.Flight ~= nil,
        dockingSystem = HYPERDRIVE.DockingPad ~= nil,
        aiSystem = HYPERDRIVE.ChatAI ~= nil
    }
    
    return metrics
end

-- Update monitoring data
function HYPERDRIVE.RealTime.UpdateMonitoring()
    if not HYPERDRIVE.RealTime.Config.EnableMonitoring then return end
    
    local metrics = HYPERDRIVE.RealTime.CollectMetrics()
    
    -- Store current metrics
    HYPERDRIVE.RealTime.Data.SystemMetrics = metrics
    HYPERDRIVE.RealTime.Data.LastUpdate = CurTime()
    
    -- Add to history
    table.insert(HYPERDRIVE.RealTime.Data.PerformanceHistory, metrics)
    
    -- Limit history size
    local maxEntries = HYPERDRIVE.RealTime.Config.MaxHistoryEntries
    if #HYPERDRIVE.RealTime.Data.PerformanceHistory > maxEntries then
        table.remove(HYPERDRIVE.RealTime.Data.PerformanceHistory, 1)
    end
    
    -- Check for alerts
    HYPERDRIVE.RealTime.CheckAlerts(metrics)
    
    -- Broadcast to clients if needed
    if SERVER then
        HYPERDRIVE.RealTime.BroadcastMetrics(metrics)
    end
end

-- Alert system
function HYPERDRIVE.RealTime.CheckAlerts(metrics)
    local alerts = {}
    local thresholds = HYPERDRIVE.RealTime.Config.AlertThresholds
    
    -- Check entity count
    if metrics.entityCount > thresholds.HighEntityCount then
        table.insert(alerts, {
            type = "HIGH_ENTITY_COUNT",
            severity = "WARNING",
            message = "High entity count: " .. metrics.entityCount,
            timestamp = CurTime()
        })
    end
    
    -- Check tick rate
    if metrics.tickRate < 60 then
        table.insert(alerts, {
            type = "LOW_TICKRATE",
            severity = "WARNING",
            message = "Low server tick rate: " .. math.floor(metrics.tickRate),
            timestamp = CurTime()
        })
    end
    
    -- Check system health
    for system, healthy in pairs(metrics.systemHealth) do
        if not healthy then
            table.insert(alerts, {
                type = "SYSTEM_FAILURE",
                severity = "ERROR",
                message = "System failure: " .. system,
                timestamp = CurTime()
            })
        end
    end
    
    -- Store active alerts
    HYPERDRIVE.RealTime.Data.ActiveAlerts = alerts
    
    -- Notify admins of critical alerts
    if SERVER then
        for _, alert in ipairs(alerts) do
            if alert.severity == "ERROR" then
                for _, ply in ipairs(player.GetAll()) do
                    if ply:IsAdmin() then
                        ply:ChatPrint("[HYPERDRIVE ALERT] " .. alert.message)
                    end
                end
            end
        end
    end
end

-- Get monitoring summary
function HYPERDRIVE.RealTime.GetSummary()
    local data = HYPERDRIVE.RealTime.Data
    local metrics = data.SystemMetrics
    
    if not metrics then return "No monitoring data available" end
    
    local summary = {
        "=== Hyperdrive Real-Time Monitoring ===",
        "Last Update: " .. os.date("%H:%M:%S", metrics.serverTime),
        "Server Tick Rate: " .. math.floor(metrics.tickRate) .. " Hz",
        "Total Entities: " .. metrics.entityCount,
        "Players: " .. metrics.playerCount,
        "",
        "=== Entity Counts ===",
        "Ship Cores: " .. metrics.entityTypes.shipCores,
        "Engines: " .. metrics.entityTypes.engines,
        "Weapons: " .. metrics.entityTypes.weapons,
        "Shields: " .. metrics.entityTypes.shields,
        "Flight Consoles: " .. metrics.entityTypes.flightConsoles,
        "Docking Pads: " .. metrics.entityTypes.dockingPads,
        "Shuttles: " .. metrics.entityTypes.shuttles,
        "",
        "=== System Health ===",
        "Core System: " .. (metrics.systemHealth.hyperdriveCore and "OK" or "FAILED"),
        "Ship Core System: " .. (metrics.systemHealth.shipCoreSystem and "OK" or "FAILED"),
        "Shield System: " .. (metrics.systemHealth.shieldSystem and "OK" or "FAILED"),
        "Weapon System: " .. (metrics.systemHealth.weaponSystem and "OK" or "FAILED"),
        "Flight System: " .. (metrics.systemHealth.flightSystem and "OK" or "FAILED"),
        "Docking System: " .. (metrics.systemHealth.dockingSystem and "OK" or "FAILED"),
        "AI System: " .. (metrics.systemHealth.aiSystem and "OK" or "FAILED")
    }
    
    -- Add alerts
    if #data.ActiveAlerts > 0 then
        table.insert(summary, "")
        table.insert(summary, "=== Active Alerts ===")
        for _, alert in ipairs(data.ActiveAlerts) do
            table.insert(summary, "[" .. alert.severity .. "] " .. alert.message)
        end
    end
    
    return table.concat(summary, "\n")
end

-- Server-side functionality
if SERVER then
    -- Network strings for client communication
    util.AddNetworkString("HyperdriveMonitoringData")
    util.AddNetworkString("HyperdriveMonitoringRequest")
    
    -- Broadcast metrics to clients
    function HYPERDRIVE.RealTime.BroadcastMetrics(metrics)
        net.Start("HyperdriveMonitoringData")
        net.WriteTable(metrics)
        net.Broadcast()
    end
    
    -- Handle client requests
    net.Receive("HyperdriveMonitoringRequest", function(len, ply)
        if not ply:IsAdmin() then return end
        
        net.Start("HyperdriveMonitoringData")
        net.WriteTable(HYPERDRIVE.RealTime.Data.SystemMetrics or {})
        net.Send(ply)
    end)
    
    -- Start monitoring timer
    timer.Create("HyperdriveRealTimeMonitoring", 1 / HYPERDRIVE.RealTime.Config.UpdateFrequency, 0, function()
        HYPERDRIVE.RealTime.UpdateMonitoring()
    end)
    
    -- Console command for monitoring status
    concommand.Add("hyperdrive_monitoring_status", function(ply, cmd, args)
        local target = IsValid(ply) and ply or nil
        local summary = HYPERDRIVE.RealTime.GetSummary()
        
        if target then
            for _, line in ipairs(string.Split(summary, "\n")) do
                target:ChatPrint(line)
            end
        else
            print(summary)
        end
    end)
    
    -- Console command to toggle monitoring
    concommand.Add("hyperdrive_monitoring_toggle", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        
        HYPERDRIVE.RealTime.Config.EnableMonitoring = not HYPERDRIVE.RealTime.Config.EnableMonitoring
        local status = HYPERDRIVE.RealTime.Config.EnableMonitoring and "enabled" or "disabled"
        
        if IsValid(ply) then
            ply:ChatPrint("[Monitoring] Real-time monitoring " .. status)
        else
            print("[Monitoring] Real-time monitoring " .. status)
        end
    end)
    
elseif CLIENT then
    -- Client-side monitoring data
    HYPERDRIVE.RealTime.ClientData = {}
    
    -- Receive monitoring data from server
    net.Receive("HyperdriveMonitoringData", function()
        HYPERDRIVE.RealTime.ClientData = net.ReadTable()
    end)
    
    -- Request monitoring data from server
    function HYPERDRIVE.RealTime.RequestData()
        net.Start("HyperdriveMonitoringRequest")
        net.SendToServer()
    end
    
    -- Client console command
    concommand.Add("hyperdrive_monitoring_request", function()
        HYPERDRIVE.RealTime.RequestData()
    end)
end

print("[Hyperdrive] Real-Time Monitoring System v2.2.1 loaded successfully!")
