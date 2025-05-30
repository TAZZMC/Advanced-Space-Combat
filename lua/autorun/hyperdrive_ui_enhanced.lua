-- Hyperdrive Enhanced User Interface System
-- Advanced UI for ship management, monitoring, and control

if CLIENT then return end

-- Initialize UI system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.UI = HYPERDRIVE.UI or {}

print("[Hyperdrive] Enhanced UI system loading...")

-- UI configuration
HYPERDRIVE.UI.Config = {
    EnableAdvancedUI = true,        -- Enable advanced UI features
    ShowPerformanceMetrics = true,  -- Show performance metrics in UI
    ShowShipClassification = true,  -- Show ship classification in UI
    AutoRefreshInterval = 2,        -- UI auto-refresh interval (seconds)
    MaxLogEntries = 50,             -- Maximum log entries to keep
    EnableSoundEffects = true,      -- Enable UI sound effects
}

-- UI state storage
HYPERDRIVE.UI.State = {
    activeWindows = {},
    logEntries = {},
    lastUpdate = 0,
}

-- Network strings for UI
util.AddNetworkString("hyperdrive_ui_open")
util.AddNetworkString("hyperdrive_ui_update")
util.AddNetworkString("hyperdrive_ui_command")
util.AddNetworkString("hyperdrive_ui_log")

-- Function to get UI configuration
local function GetUIConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("UI", key, HYPERDRIVE.UI.Config[key] or default)
    end
    return HYPERDRIVE.UI.Config[key] or default
end

-- Generate comprehensive ship status
function HYPERDRIVE.UI.GetShipStatus(engine)
    if not IsValid(engine) then return nil end

    local status = {
        engine = {
            class = engine:GetClass(),
            energy = (engine.GetEnergy and engine:GetEnergy()) or 0,
            maxEnergy = 1000, -- Default, should be configurable
            charging = (engine.GetCharging and engine:GetCharging()) or false,
            cooldown = (engine.GetCooldown and engine:GetCooldown()) or 0,
            destination = (engine.GetDestination and engine:GetDestination()) or Vector(0,0,0),
            position = engine:GetPos(),
        },
        ship = {},
        integrations = {},
        performance = {},
        timestamp = CurTime()
    }

    -- Get ship classification if available
    if HYPERDRIVE.ShipDetection and HYPERDRIVE.ShipDetection.DetectAndClassifyShip then
        local detection = HYPERDRIVE.ShipDetection.DetectAndClassifyShip(engine)
        status.ship = {
            type = detection.shipType.name,
            entityCount = detection.composition.totalEntities,
            mass = detection.composition.totalMass,
            dimensions = detection.composition.dimensions,
            movementStrategy = detection.movementStrategy,
            energyMultiplier = detection.shipType.energyMultiplier,
            composition = detection.composition
        }
    end

    -- Get integration status
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.CheckIntegrations then
        status.integrations = HYPERDRIVE.EnhancedConfig.CheckIntegrations()
    end

    -- Get performance metrics if available
    if HYPERDRIVE.Performance and HYPERDRIVE.Performance.Metrics then
        status.performance = table.Copy(HYPERDRIVE.Performance.Metrics)
    end

    -- Get SC2 specific status
    if HYPERDRIVE.SpaceCombat2 then
        status.sc2 = {
            gyropod = (HYPERDRIVE.SpaceCombat2.FindGyropod and IsValid(HYPERDRIVE.SpaceCombat2.FindGyropod(engine))) or false,
            shipCore = (HYPERDRIVE.SpaceCombat2.FindShipCore and IsValid(HYPERDRIVE.SpaceCombat2.FindShipCore(engine))) or false,
        }

        if HYPERDRIVE.SpaceCombat2.ValidateShipConfiguration then
            local isValid, issues = HYPERDRIVE.SpaceCombat2.ValidateShipConfiguration(engine)
            status.sc2.valid = isValid
            status.sc2.issues = issues
        end
    end

    -- Get SB3 specific status
    if HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced then
        status.sb3 = {
            shipCore = (HYPERDRIVE.Spacebuild.Enhanced.FindShipCore and IsValid(HYPERDRIVE.Spacebuild.Enhanced.FindShipCore(engine))) or false,
        }

        if HYPERDRIVE.Spacebuild.GetLifeSupportStatus then
            status.sb3.lifeSupport = HYPERDRIVE.Spacebuild.GetLifeSupportStatus(engine)
        end

        if HYPERDRIVE.Spacebuild.Enhanced.ValidateShipConfiguration then
            local isValid, issues = HYPERDRIVE.Spacebuild.Enhanced.ValidateShipConfiguration(engine)
            status.sb3.valid = isValid
            status.sb3.issues = issues
        end
    end

    return status
end

-- Add log entry
function HYPERDRIVE.UI.AddLogEntry(message, level, engineId)
    local entry = {
        message = message,
        level = level or "info", -- info, warning, error, success
        timestamp = CurTime(),
        engineId = engineId
    }

    table.insert(HYPERDRIVE.UI.State.logEntries, entry)

    -- Limit log entries
    local maxEntries = GetUIConfig("MaxLogEntries", 50)
    while #HYPERDRIVE.UI.State.logEntries > maxEntries do
        table.remove(HYPERDRIVE.UI.State.logEntries, 1)
    end

    -- Send to clients if they have UI open
    net.Start("hyperdrive_ui_log")
    net.WriteTable(entry)
    net.Broadcast()
end

-- Open enhanced UI for player
function HYPERDRIVE.UI.OpenUI(ply, engine)
    if not IsValid(ply) or not IsValid(engine) then return end
    if not GetUIConfig("EnableAdvancedUI", true) then return end

    local status = HYPERDRIVE.UI.GetShipStatus(engine)
    if not status then return end

    -- Store active window
    HYPERDRIVE.UI.State.activeWindows[ply] = {
        engine = engine,
        openTime = CurTime()
    }

    -- Send UI data to client
    net.Start("hyperdrive_ui_open")
    net.WriteEntity(engine)
    net.WriteTable(status)
    net.WriteTable(HYPERDRIVE.UI.State.logEntries)
    net.Send(ply)

    HYPERDRIVE.UI.AddLogEntry("UI opened for " .. ply:Nick(), "info", engine:EntIndex())
end

-- Update UI for all active windows
function HYPERDRIVE.UI.UpdateActiveUIs()
    if not GetUIConfig("EnableAdvancedUI", true) then return end

    for ply, windowData in pairs(HYPERDRIVE.UI.State.activeWindows) do
        if IsValid(ply) and IsValid(windowData.engine) then
            local status = HYPERDRIVE.UI.GetShipStatus(windowData.engine)
            if status then
                net.Start("hyperdrive_ui_update")
                net.WriteTable(status)
                net.Send(ply)
            end
        else
            -- Clean up invalid windows
            HYPERDRIVE.UI.State.activeWindows[ply] = nil
        end
    end
end

-- Handle UI commands from clients
net.Receive("hyperdrive_ui_command", function(len, ply)
    if not IsValid(ply) then return end

    local command = net.ReadString()
    local engineId = net.ReadInt(16)
    local data = net.ReadTable()

    local engine = Entity(engineId)
    if not IsValid(engine) then return end

    -- Validate player can control this engine
    if engine:GetPos():Distance(ply:GetPos()) > 500 then
        HYPERDRIVE.UI.AddLogEntry("Player too far from engine", "error", engineId)
        return
    end

    -- Process command
    if command == "set_destination" then
        local pos = data.position
        if isvector(pos) then
            local success, message = engine:SetDestinationPos(pos)
            HYPERDRIVE.UI.AddLogEntry(message, success and "success" or "error", engineId)
        end

    elseif command == "start_jump" then
        local success, message = engine:StartJump()
        HYPERDRIVE.UI.AddLogEntry(message, success and "success" or "error", engineId)

    elseif command == "abort_jump" then
        if engine.AbortJump then
            engine:AbortJump("User abort")
            HYPERDRIVE.UI.AddLogEntry("Jump aborted by " .. ply:Nick(), "warning", engineId)
        end

    elseif command == "run_diagnostics" then
        -- Run ship diagnostics
        local diagnostics = {}

        if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.ValidateShipConfiguration then
            local isValid, issues = HYPERDRIVE.SpaceCombat2.ValidateShipConfiguration(engine)
            diagnostics.sc2 = {valid = isValid, issues = issues}
        end

        if HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced and HYPERDRIVE.Spacebuild.Enhanced.ValidateShipConfiguration then
            local isValid, issues = HYPERDRIVE.Spacebuild.Enhanced.ValidateShipConfiguration(engine)
            diagnostics.sb3 = {valid = isValid, issues = issues}
        end

        HYPERDRIVE.UI.AddLogEntry("Diagnostics completed by " .. ply:Nick(), "info", engineId)

        -- Send diagnostics back to client
        net.Start("hyperdrive_ui_update")
        net.WriteTable({diagnostics = diagnostics})
        net.Send(ply)

    elseif command == "close_ui" then
        HYPERDRIVE.UI.State.activeWindows[ply] = nil
        HYPERDRIVE.UI.AddLogEntry("UI closed by " .. ply:Nick(), "info", engineId)
    end
end)

-- Auto-update timer
timer.Create("HyperdriveUIUpdate", GetUIConfig("AutoRefreshInterval", 2), 0, function()
    HYPERDRIVE.UI.UpdateActiveUIs()
end)

-- Hook into engine use to open UI
hook.Add("PlayerUse", "HyperdriveUIOpen", function(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    if not string.find(ent:GetClass(), "hyperdrive") then return end
    if not string.find(ent:GetClass(), "engine") then return end

    -- Check if player is holding a key for advanced UI
    if ply:KeyDown(IN_WALK) then -- Shift key
        HYPERDRIVE.UI.OpenUI(ply, ent)
        return false -- Prevent normal use
    end
end)

-- Clean up on player disconnect
hook.Add("PlayerDisconnected", "HyperdriveUICleanup", function(ply)
    HYPERDRIVE.UI.State.activeWindows[ply] = nil
end)

-- Console commands for UI management
concommand.Add("hyperdrive_ui_open", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or not string.find(trace.Entity:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive UI] Look at a hyperdrive engine")
        return
    end

    HYPERDRIVE.UI.OpenUI(ply, trace.Entity)
end)

concommand.Add("hyperdrive_ui_close", function(ply, cmd, args)
    if not IsValid(ply) then return end

    HYPERDRIVE.UI.State.activeWindows[ply] = nil
    ply:ChatPrint("[Hyperdrive UI] UI closed")
end)

concommand.Add("hyperdrive_ui_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local activeCount = table.Count(HYPERDRIVE.UI.State.activeWindows)
    local logCount = #HYPERDRIVE.UI.State.logEntries

    ply:ChatPrint("[Hyperdrive UI] Status:")
    ply:ChatPrint("  • Active Windows: " .. activeCount)
    ply:ChatPrint("  • Log Entries: " .. logCount)
    ply:ChatPrint("  • Advanced UI: " .. (GetUIConfig("EnableAdvancedUI", true) and "Enabled" or "Disabled"))
end)

print("[Hyperdrive] Enhanced UI system loaded")
