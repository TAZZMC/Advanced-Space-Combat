-- Hyperdrive CAP Integration Monitoring System
-- Advanced monitoring and analytics for Carter Addon Pack integration

if CLIENT then return end

-- Initialize monitoring system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.CAP = HYPERDRIVE.CAP or {}
HYPERDRIVE.CAP.Monitoring = HYPERDRIVE.CAP.Monitoring or {}

print("[Hyperdrive] CAP Integration Monitoring System loading...")

-- Monitoring configuration
HYPERDRIVE.CAP.Monitoring.Config = {
    EnableMonitoring = true,
    MonitoringInterval = 30,        -- seconds
    AlertThresholds = {
        LowEnergy = 1000,           -- Alert when energy sources below this
        HighConflicts = 5,          -- Alert when conflicts exceed this
        ShieldFailures = 3,         -- Alert when shield failures exceed this
        NetworkErrors = 10          -- Alert when network errors exceed this
    },
    RetentionPeriod = 3600,         -- Keep data for 1 hour
    MaxLogEntries = 1000
}

-- Monitoring state
HYPERDRIVE.CAP.Monitoring.State = {
    isActive = false,
    lastUpdate = 0,
    metrics = {
        stargateOperations = 0,
        energyTransfers = 0,
        shieldInteractions = 0,
        conflictsPrevented = 0,
        networkQueries = 0,
        errors = 0
    },
    alerts = {},
    history = {},
    performance = {
        averageResponseTime = 0,
        peakResponseTime = 0,
        totalOperations = 0
    }
}

-- Alert levels
HYPERDRIVE.CAP.Monitoring.AlertLevels = {
    INFO = 1,
    WARNING = 2,
    ERROR = 3,
    CRITICAL = 4
}

-- Start monitoring system
function HYPERDRIVE.CAP.Monitoring.Start()
    if HYPERDRIVE.CAP.Monitoring.State.isActive then return end
    
    HYPERDRIVE.CAP.Monitoring.State.isActive = true
    
    -- Create monitoring timer
    timer.Create("HyperdriveCAP_Monitoring", 
                HYPERDRIVE.CAP.Monitoring.Config.MonitoringInterval, 
                0, 
                HYPERDRIVE.CAP.Monitoring.Update)
    
    print("[Hyperdrive CAP Monitoring] Monitoring system started")
end

-- Stop monitoring system
function HYPERDRIVE.CAP.Monitoring.Stop()
    if not HYPERDRIVE.CAP.Monitoring.State.isActive then return end
    
    HYPERDRIVE.CAP.Monitoring.State.isActive = false
    timer.Remove("HyperdriveCAP_Monitoring")
    
    print("[Hyperdrive CAP Monitoring] Monitoring system stopped")
end

-- Main monitoring update function
function HYPERDRIVE.CAP.Monitoring.Update()
    if not HYPERDRIVE.CAP.Monitoring.Config.EnableMonitoring then return end
    
    local startTime = SysTime()
    
    -- Monitor CAP framework status
    HYPERDRIVE.CAP.Monitoring.CheckFrameworkStatus()
    
    -- Monitor entity states
    HYPERDRIVE.CAP.Monitoring.CheckEntityStates()
    
    -- Monitor energy systems
    HYPERDRIVE.CAP.Monitoring.CheckEnergySystems()
    
    -- Monitor network health
    HYPERDRIVE.CAP.Monitoring.CheckNetworkHealth()
    
    -- Check for conflicts
    HYPERDRIVE.CAP.Monitoring.CheckConflicts()
    
    -- Update performance metrics
    local duration = SysTime() - startTime
    HYPERDRIVE.CAP.Monitoring.UpdatePerformanceMetrics(duration)
    
    -- Clean up old data
    HYPERDRIVE.CAP.Monitoring.CleanupOldData()
    
    HYPERDRIVE.CAP.Monitoring.State.lastUpdate = CurTime()
end

-- Check CAP framework status
function HYPERDRIVE.CAP.Monitoring.CheckFrameworkStatus()
    local isLoaded, status, details = HYPERDRIVE.CAP.IsCAP_Loaded()
    
    if not isLoaded then
        HYPERDRIVE.CAP.Monitoring.CreateAlert(
            HYPERDRIVE.CAP.Monitoring.AlertLevels.ERROR,
            "CAP Framework Unavailable",
            "CAP framework is not loaded or not functioning: " .. status
        )
    end
    
    -- Record framework status
    HYPERDRIVE.CAP.Monitoring.RecordMetric("framework_status", {
        loaded = isLoaded,
        status = status,
        details = details
    })
end

-- Check entity states
function HYPERDRIVE.CAP.Monitoring.CheckEntityStates()
    local stargateCount = #ents.FindByClass("stargate_*")
    local shieldCount = #ents.FindByClass("shield*")
    local dhd_count = #ents.FindByClass("dhd_*")
    
    -- Check for active Stargates
    local activeStargates = 0
    local diallingStargates = 0
    
    for _, stargate in ipairs(ents.FindByClass("stargate_*")) do
        if IsValid(stargate) and stargate.IsStargate then
            if StarGate.IsStargateOpen(stargate) then
                activeStargates = activeStargates + 1
            end
            if StarGate.IsStargateDialling(stargate) then
                diallingStargates = diallingStargates + 1
            end
        end
    end
    
    -- Record entity metrics
    HYPERDRIVE.CAP.Monitoring.RecordMetric("entity_counts", {
        stargates = stargateCount,
        shields = shieldCount,
        dhds = dhd_count,
        active_stargates = activeStargates,
        dialling_stargates = diallingStargates
    })
    
    -- Alert on unusual activity
    if activeStargates > 10 then
        HYPERDRIVE.CAP.Monitoring.CreateAlert(
            HYPERDRIVE.CAP.Monitoring.AlertLevels.WARNING,
            "High Stargate Activity",
            "Unusually high number of active Stargates: " .. activeStargates
        )
    end
end

-- Check energy systems
function HYPERDRIVE.CAP.Monitoring.CheckEnergySystems()
    local totalEnergy = 0
    local energySources = 0
    local lowEnergySources = 0
    
    -- Check ZPMs
    for _, zpm in ipairs(ents.FindByClass("zpm*")) do
        if IsValid(zpm) then
            energySources = energySources + 1
            local energy = zpm:GetNWInt("energy", 0)
            totalEnergy = totalEnergy + energy
            
            if energy < HYPERDRIVE.CAP.Monitoring.Config.AlertThresholds.LowEnergy then
                lowEnergySources = lowEnergySources + 1
            end
        end
    end
    
    -- Check Naquadah generators
    for _, gen in ipairs(ents.FindByClass("naquadah_generator")) do
        if IsValid(gen) then
            energySources = energySources + 1
            local energy = gen.GetEnergy and gen:GetEnergy() or 0
            totalEnergy = totalEnergy + energy
            
            if energy < HYPERDRIVE.CAP.Monitoring.Config.AlertThresholds.LowEnergy then
                lowEnergySources = lowEnergySources + 1
            end
        end
    end
    
    -- Record energy metrics
    HYPERDRIVE.CAP.Monitoring.RecordMetric("energy_systems", {
        total_energy = totalEnergy,
        energy_sources = energySources,
        low_energy_sources = lowEnergySources,
        average_energy = energySources > 0 and (totalEnergy / energySources) or 0
    })
    
    -- Alert on low energy
    if lowEnergySources > 0 then
        HYPERDRIVE.CAP.Monitoring.CreateAlert(
            HYPERDRIVE.CAP.Monitoring.AlertLevels.WARNING,
            "Low Energy Sources",
            lowEnergySources .. " energy sources below threshold"
        )
    end
end

-- Check network health
function HYPERDRIVE.CAP.Monitoring.CheckNetworkHealth()
    local destinations = HYPERDRIVE.CAP.GetStargateDestinations()
    local networkErrors = 0
    
    -- Test a few random destinations
    local testCount = math.min(3, #destinations)
    for i = 1, testCount do
        local dest = destinations[math.random(#destinations)]
        if dest and dest.address then
            local resolved = HYPERDRIVE.CAP.ResolveStargateAddress(dest.address)
            if not resolved then
                networkErrors = networkErrors + 1
            end
        end
    end
    
    -- Record network metrics
    HYPERDRIVE.CAP.Monitoring.RecordMetric("network_health", {
        total_destinations = #destinations,
        tested_destinations = testCount,
        network_errors = networkErrors,
        error_rate = testCount > 0 and (networkErrors / testCount) or 0
    })
    
    -- Alert on network issues
    if networkErrors >= HYPERDRIVE.CAP.Monitoring.Config.AlertThresholds.NetworkErrors then
        HYPERDRIVE.CAP.Monitoring.CreateAlert(
            HYPERDRIVE.CAP.Monitoring.AlertLevels.ERROR,
            "Network Health Issues",
            "High number of network errors: " .. networkErrors
        )
    end
end

-- Check for conflicts
function HYPERDRIVE.CAP.Monitoring.CheckConflicts()
    local totalConflicts = 0
    local shieldConflicts = 0
    local stargateConflicts = 0
    
    -- Sample some positions for conflict checking
    local testPositions = {
        Vector(0, 0, 0),
        Vector(1000, 1000, 0),
        Vector(-1000, -1000, 0),
        Vector(0, 0, 1000)
    }
    
    for _, pos in ipairs(testPositions) do
        -- Check shield conflicts
        if HYPERDRIVE.CAP.IsPositionShielded(pos) then
            shieldConflicts = shieldConflicts + 1
            totalConflicts = totalConflicts + 1
        end
        
        -- Check Stargate conflicts (create temporary engine for testing)
        local testEnt = ents.Create("prop_physics")
        if IsValid(testEnt) then
            testEnt:SetPos(pos)
            testEnt:Spawn()
            
            local hasConflicts, conflicts = HYPERDRIVE.CAP.CheckStargateConflicts(testEnt, pos + Vector(100, 0, 0))
            if hasConflicts then
                stargateConflicts = stargateConflicts + #conflicts
                totalConflicts = totalConflicts + #conflicts
            end
            
            testEnt:Remove()
        end
    end
    
    -- Record conflict metrics
    HYPERDRIVE.CAP.Monitoring.RecordMetric("conflicts", {
        total_conflicts = totalConflicts,
        shield_conflicts = shieldConflicts,
        stargate_conflicts = stargateConflicts,
        test_positions = #testPositions
    })
end

-- Create an alert
function HYPERDRIVE.CAP.Monitoring.CreateAlert(level, title, message)
    local alert = {
        level = level,
        title = title,
        message = message,
        timestamp = CurTime(),
        id = #HYPERDRIVE.CAP.Monitoring.State.alerts + 1
    }
    
    table.insert(HYPERDRIVE.CAP.Monitoring.State.alerts, alert)
    
    -- Log to console based on level
    local levelNames = {"INFO", "WARNING", "ERROR", "CRITICAL"}
    local levelName = levelNames[level] or "UNKNOWN"
    
    print("[Hyperdrive CAP Monitoring] " .. levelName .. ": " .. title .. " - " .. message)
    
    -- Notify admins for critical alerts
    if level >= HYPERDRIVE.CAP.Monitoring.AlertLevels.ERROR then
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:IsAdmin() then
                ply:ChatPrint("[Hyperdrive CAP] " .. levelName .. ": " .. title)
            end
        end
    end
end

-- Record a metric
function HYPERDRIVE.CAP.Monitoring.RecordMetric(name, data)
    local entry = {
        name = name,
        data = data,
        timestamp = CurTime()
    }
    
    table.insert(HYPERDRIVE.CAP.Monitoring.State.history, entry)
end

-- Update performance metrics
function HYPERDRIVE.CAP.Monitoring.UpdatePerformanceMetrics(duration)
    local perf = HYPERDRIVE.CAP.Monitoring.State.performance
    
    perf.totalOperations = perf.totalOperations + 1
    perf.averageResponseTime = ((perf.averageResponseTime * (perf.totalOperations - 1)) + duration) / perf.totalOperations
    
    if duration > perf.peakResponseTime then
        perf.peakResponseTime = duration
    end
end

-- Clean up old data
function HYPERDRIVE.CAP.Monitoring.CleanupOldData()
    local cutoffTime = CurTime() - HYPERDRIVE.CAP.Monitoring.Config.RetentionPeriod
    
    -- Clean up alerts
    for i = #HYPERDRIVE.CAP.Monitoring.State.alerts, 1, -1 do
        if HYPERDRIVE.CAP.Monitoring.State.alerts[i].timestamp < cutoffTime then
            table.remove(HYPERDRIVE.CAP.Monitoring.State.alerts, i)
        end
    end
    
    -- Clean up history
    for i = #HYPERDRIVE.CAP.Monitoring.State.history, 1, -1 do
        if HYPERDRIVE.CAP.Monitoring.State.history[i].timestamp < cutoffTime then
            table.remove(HYPERDRIVE.CAP.Monitoring.State.history, i)
        end
    end
    
    -- Limit total entries
    while #HYPERDRIVE.CAP.Monitoring.State.history > HYPERDRIVE.CAP.Monitoring.Config.MaxLogEntries do
        table.remove(HYPERDRIVE.CAP.Monitoring.State.history, 1)
    end
end

-- Console commands
concommand.Add("hyperdrive_cap_monitoring_start", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end
    HYPERDRIVE.CAP.Monitoring.Start()
end)

concommand.Add("hyperdrive_cap_monitoring_stop", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end
    HYPERDRIVE.CAP.Monitoring.Stop()
end)

concommand.Add("hyperdrive_cap_monitoring_status", function(ply, cmd, args)
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then target:ChatPrint(msg) else print(msg) end
    end
    
    local state = HYPERDRIVE.CAP.Monitoring.State
    
    sendMessage("[Hyperdrive CAP Monitoring] Status:")
    sendMessage("  • Active: " .. (state.isActive and "Yes" or "No"))
    sendMessage("  • Last Update: " .. (CurTime() - state.lastUpdate) .. "s ago")
    sendMessage("  • Total Operations: " .. state.performance.totalOperations)
    sendMessage("  • Average Response: " .. string.format("%.3f", state.performance.averageResponseTime) .. "s")
    sendMessage("  • Peak Response: " .. string.format("%.3f", state.performance.peakResponseTime) .. "s")
    sendMessage("  • Active Alerts: " .. #state.alerts)
    sendMessage("  • History Entries: " .. #state.history)
end)

-- Auto-start monitoring
timer.Simple(5, function()
    if HYPERDRIVE.CAP.Monitoring.Config.EnableMonitoring then
        HYPERDRIVE.CAP.Monitoring.Start()
    end
end)

print("[Hyperdrive] CAP Integration Monitoring System loaded successfully")
