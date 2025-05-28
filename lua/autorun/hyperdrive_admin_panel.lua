-- Hyperdrive Admin Panel System
-- Comprehensive administration interface for hyperdrive management

if CLIENT then return end

-- Initialize admin panel system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.AdminPanel = HYPERDRIVE.AdminPanel or {}

print("[Hyperdrive] Admin panel system loading...")

-- Admin panel configuration
HYPERDRIVE.AdminPanel.Config = {
    RequireAdmin = true,            -- Require admin access
    RequireSuperAdmin = false,      -- Require superadmin access
    LogAdminActions = true,         -- Log admin actions
    EnableRemoteControl = true,     -- Enable remote engine control
    EnableMassOperations = true,    -- Enable mass operations
    EnableSystemOverride = true,    -- Enable system overrides
    MaxBatchSize = 50,              -- Maximum batch operation size
}

-- Admin panel state
HYPERDRIVE.AdminPanel.State = {
    activeSessions = {},
    actionLog = {},
    remoteOperations = {},
    systemOverrides = {},
}

-- Network strings for admin panel
util.AddNetworkString("hyperdrive_admin_panel_open")
util.AddNetworkString("hyperdrive_admin_panel_data")
util.AddNetworkString("hyperdrive_admin_command")
util.AddNetworkString("hyperdrive_admin_response")

-- Function to check admin access
local function HasAdminAccess(ply)
    if not IsValid(ply) then return false end
    
    if HYPERDRIVE.AdminPanel.Config.RequireSuperAdmin then
        return ply:IsSuperAdmin()
    elseif HYPERDRIVE.AdminPanel.Config.RequireAdmin then
        return ply:IsAdmin()
    end
    
    return true
end

-- Log admin action
function HYPERDRIVE.AdminPanel.LogAction(admin, action, details)
    if not HYPERDRIVE.AdminPanel.Config.LogAdminActions then return end
    
    local logEntry = {
        admin = IsValid(admin) and admin:Nick() or "Console",
        adminSteamID = IsValid(admin) and admin:SteamID() or "N/A",
        action = action,
        details = details or {},
        timestamp = CurTime(),
        id = #HYPERDRIVE.AdminPanel.State.actionLog + 1
    }
    
    table.insert(HYPERDRIVE.AdminPanel.State.actionLog, logEntry)
    
    -- Limit log size
    local maxLogEntries = 1000
    while #HYPERDRIVE.AdminPanel.State.actionLog > maxLogEntries do
        table.remove(HYPERDRIVE.AdminPanel.State.actionLog, 1)
    end
    
    -- Console output
    print(string.format("[Hyperdrive Admin] %s performed action: %s", logEntry.admin, action))
    
    -- Add to error recovery system if available
    if HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.LogError then
        HYPERDRIVE.ErrorRecovery.LogError("Admin action: " .. action, 
            HYPERDRIVE.ErrorRecovery.Severity.LOW, {admin = logEntry.admin, details = details})
    end
end

-- Get system status for admin panel
function HYPERDRIVE.AdminPanel.GetSystemStatus()
    local status = {
        engines = {},
        integrations = {},
        performance = {},
        errors = {},
        network = {},
        monitoring = {},
        timestamp = CurTime()
    }
    
    -- Get all hyperdrive engines
    local engines = ents.FindByClass("hyperdrive_*")
    for _, engine in ipairs(engines) do
        if IsValid(engine) and string.find(engine:GetClass(), "engine") then
            local engineStatus = {
                entIndex = engine:EntIndex(),
                class = engine:GetClass(),
                position = engine:GetPos(),
                energy = engine.GetEnergy and engine:GetEnergy() or 0,
                charging = engine.GetCharging and engine:GetCharging() or false,
                cooldown = engine.GetCooldown and engine:GetCooldown() or 0,
                destination = engine.GetDestination and engine:GetDestination() or Vector(0,0,0),
                owner = engine.GetOwner and IsValid(engine:GetOwner()) and engine:GetOwner():Nick() or "Unknown"
            }
            
            table.insert(status.engines, engineStatus)
        end
    end
    
    -- Get integration status
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.CheckIntegrations then
        status.integrations = HYPERDRIVE.EnhancedConfig.CheckIntegrations()
    end
    
    -- Get performance metrics
    if HYPERDRIVE.Performance and HYPERDRIVE.Performance.GetStatistics then
        status.performance = HYPERDRIVE.Performance.GetStatistics()
    end
    
    -- Get error statistics
    if HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.GetStatistics then
        status.errors = HYPERDRIVE.ErrorRecovery.GetStatistics()
    end
    
    -- Get network statistics
    if HYPERDRIVE.Network and HYPERDRIVE.Network.GetStatistics then
        status.network = HYPERDRIVE.Network.GetStatistics()
    end
    
    -- Get monitoring status
    if HYPERDRIVE.Monitoring and HYPERDRIVE.Monitoring.State then
        status.monitoring = {
            systemHealth = HYPERDRIVE.Monitoring.State.systemHealth,
            monitoredEngines = table.Count(HYPERDRIVE.Monitoring.State.monitoredEngines),
            activeAlerts = table.Count(HYPERDRIVE.Monitoring.State.activeAlerts),
            alertHistory = #HYPERDRIVE.Monitoring.State.alertHistory
        }
    end
    
    return status
end

-- Execute admin command
function HYPERDRIVE.AdminPanel.ExecuteCommand(admin, command, parameters)
    if not HasAdminAccess(admin) then
        return false, "Access denied"
    end
    
    HYPERDRIVE.AdminPanel.LogAction(admin, command, parameters)
    
    if command == "emergency_stop_all" then
        -- Emergency stop all hyperdrive operations
        local engines = ents.FindByClass("hyperdrive_*")
        local stoppedCount = 0
        
        for _, engine in ipairs(engines) do
            if IsValid(engine) and engine.AbortJump then
                engine:AbortJump("Emergency stop by admin")
                stoppedCount = stoppedCount + 1
            end
        end
        
        return true, string.format("Emergency stopped %d engines", stoppedCount)
        
    elseif command == "force_cooldown_reset" then
        -- Reset cooldowns for specified engines
        local engineIds = parameters.engineIds or {}
        local resetCount = 0
        
        for _, entIndex in ipairs(engineIds) do
            local engine = Entity(entIndex)
            if IsValid(engine) and engine.SetCooldown then
                engine:SetCooldown(0)
                resetCount = resetCount + 1
            end
        end
        
        return true, string.format("Reset cooldown for %d engines", resetCount)
        
    elseif command == "teleport_engine" then
        -- Teleport engine to specified position
        local engineId = parameters.engineId
        local position = parameters.position
        
        if not engineId or not position then
            return false, "Missing parameters"
        end
        
        local engine = Entity(engineId)
        if not IsValid(engine) then
            return false, "Engine not found"
        end
        
        -- Use safe execution if available
        local success, result = true, "Teleported successfully"
        if HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.SafeExecute then
            success, result = HYPERDRIVE.ErrorRecovery.SafeExecute(
                function(context)
                    context.engine:SetPos(context.position)
                    return true
                end,
                {engine = engine, position = position},
                "AdminTeleport"
            )
        else
            engine:SetPos(position)
        end
        
        return success, result
        
    elseif command == "system_override" then
        -- Enable/disable system overrides
        local systemName = parameters.system
        local enabled = parameters.enabled
        
        if not systemName then
            return false, "System name required"
        end
        
        HYPERDRIVE.AdminPanel.State.systemOverrides[systemName] = enabled
        
        return true, string.format("System override %s: %s", systemName, enabled and "enabled" or "disabled")
        
    elseif command == "clear_error_log" then
        -- Clear error logs
        if HYPERDRIVE.ErrorRecovery then
            HYPERDRIVE.ErrorRecovery.State.errorLog = {}
            HYPERDRIVE.ErrorRecovery.State.totalErrors = 0
            HYPERDRIVE.ErrorRecovery.State.recoveredErrors = 0
            HYPERDRIVE.ErrorRecovery.State.criticalErrors = 0
        end
        
        return true, "Error log cleared"
        
    elseif command == "force_backup" then
        -- Force backup creation for all engines
        local engines = ents.FindByClass("hyperdrive_*")
        local backupCount = 0
        
        if HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.CreateBackup then
            for _, engine in ipairs(engines) do
                if IsValid(engine) and string.find(engine:GetClass(), "engine") then
                    local entities = {}
                    -- Get entities for backup (simplified)
                    if HYPERDRIVE.ShipDetection and HYPERDRIVE.ShipDetection.DetectAndClassifyShip then
                        local detection = HYPERDRIVE.ShipDetection.DetectAndClassifyShip(engine)
                        entities = detection.entities
                    end
                    
                    local backupId = HYPERDRIVE.ErrorRecovery.CreateBackup(engine, entities)
                    if backupId then
                        backupCount = backupCount + 1
                    end
                end
            end
        end
        
        return true, string.format("Created %d backups", backupCount)
        
    elseif command == "network_optimization_toggle" then
        -- Toggle network optimization
        if HYPERDRIVE.Network then
            local currentState = HYPERDRIVE.Network.Config.EnableOptimization
            HYPERDRIVE.Network.Config.EnableOptimization = not currentState
            return true, "Network optimization " .. (HYPERDRIVE.Network.Config.EnableOptimization and "enabled" or "disabled")
        end
        
        return false, "Network optimization system not available"
        
    else
        return false, "Unknown command: " .. command
    end
end

-- Handle admin command from client
net.Receive("hyperdrive_admin_command", function(len, ply)
    if not HasAdminAccess(ply) then
        net.Start("hyperdrive_admin_response")
        net.WriteTable({success = false, message = "Access denied"})
        net.Send(ply)
        return
    end
    
    local command = net.ReadString()
    local parameters = net.ReadTable()
    
    local success, message = HYPERDRIVE.AdminPanel.ExecuteCommand(ply, command, parameters)
    
    net.Start("hyperdrive_admin_response")
    net.WriteTable({success = success, message = message, command = command})
    net.Send(ply)
end)

-- Console commands for admin panel
concommand.Add("hyperdrive_admin_panel", function(ply, cmd, args)
    if not HasAdminAccess(ply) then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local status = HYPERDRIVE.AdminPanel.GetSystemStatus()
    
    if IsValid(ply) then
        -- Send admin panel data to client
        net.Start("hyperdrive_admin_panel_open")
        net.WriteTable(status)
        net.Send(ply)
        
        ply:ChatPrint("[Hyperdrive] Admin panel opened")
    else
        -- Console output for server
        print("[Hyperdrive Admin] System Status:")
        print("  • Engines: " .. #status.engines)
        print("  • System Health: " .. (status.monitoring.systemHealth or "unknown"))
        print("  • Active Alerts: " .. (status.monitoring.activeAlerts or 0))
        print("  • Total Errors: " .. (status.errors.totalErrors or 0))
    end
end)

concommand.Add("hyperdrive_admin_emergency_stop", function(ply, cmd, args)
    if not HasAdminAccess(ply) then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local success, message = HYPERDRIVE.AdminPanel.ExecuteCommand(ply, "emergency_stop_all", {})
    
    if IsValid(ply) then
        ply:ChatPrint("[Hyperdrive Admin] " .. message)
    else
        print("[Hyperdrive Admin] " .. message)
    end
end)

concommand.Add("hyperdrive_admin_status", function(ply, cmd, args)
    if not HasAdminAccess(ply) then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    local status = HYPERDRIVE.AdminPanel.GetSystemStatus()
    
    sendMessage("[Hyperdrive Admin] System Overview:")
    sendMessage("  • Engines: " .. #status.engines)
    sendMessage("  • Integrations: " .. table.Count(status.integrations))
    sendMessage("  • System Health: " .. (status.monitoring.systemHealth or "unknown"))
    sendMessage("  • Active Alerts: " .. (status.monitoring.activeAlerts or 0))
    sendMessage("  • Total Errors: " .. (status.errors.totalErrors or 0))
    sendMessage("  • Recovery Rate: " .. string.format("%.1f%%", (status.errors.recoveryRate or 0) * 100))
    sendMessage("  • Network Usage: " .. string.format("%.1f%%", (status.network.bandwidthUsage or 0) / 10000))
    sendMessage("  • Admin Sessions: " .. table.Count(HYPERDRIVE.AdminPanel.State.activeSessions))
end)

concommand.Add("hyperdrive_admin_log", function(ply, cmd, args)
    if not HasAdminAccess(ply) then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local count = tonumber(args[1]) or 10
    local actionLog = HYPERDRIVE.AdminPanel.State.actionLog
    
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    sendMessage("[Hyperdrive Admin] Recent Actions (last " .. count .. "):")
    
    local startIdx = math.max(1, #actionLog - count + 1)
    for i = startIdx, #actionLog do
        local entry = actionLog[i]
        local timeAgo = string.format("%.1fs ago", CurTime() - entry.timestamp)
        sendMessage(string.format("  • %s: %s (%s)", entry.admin, entry.action, timeAgo))
    end
end)

print("[Hyperdrive] Admin panel system loaded")
