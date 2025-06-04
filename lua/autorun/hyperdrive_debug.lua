-- Hyperdrive Debug System
-- This file provides debugging tools and diagnostics for the hyperdrive system

HYPERDRIVE.Debug = HYPERDRIVE.Debug or {}

-- Debug configuration
HYPERDRIVE.Debug.Config = {
    EnableLogging = true,
    LogLevel = 1, -- 0=None, 1=Errors, 2=Warnings, 3=Info, 4=Debug
    MaxLogEntries = 100,
    ShowNetworkMessages = false,
    ShowEntityCreation = true,
    ShowJumpEvents = true
}

-- Debug log storage
HYPERDRIVE.Debug.Log = {}

-- Log function
function HYPERDRIVE.Debug.Log(level, message, category)
    if not HYPERDRIVE.Debug.Config.EnableLogging then return end

    -- Convert string level to number if needed
    local numLevel = level
    if type(level) == "string" then
        local levelMap = {ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4}
        numLevel = levelMap[level] or 3
    end

    if numLevel > HYPERDRIVE.Debug.Config.LogLevel then return end

    local levelNames = {"ERROR", "WARN", "INFO", "DEBUG"}
    local levelName = levelNames[numLevel] or (type(level) == "string" and level or "UNKNOWN")
    local timestamp = os.date("%H:%M:%S")

    local logEntry = {
        time = timestamp,
        level = levelName,
        category = category or "GENERAL",
        message = message
    }

    table.insert(HYPERDRIVE.Debug.Log, logEntry)

    -- Limit log size
    if #HYPERDRIVE.Debug.Log > HYPERDRIVE.Debug.Config.MaxLogEntries then
        table.remove(HYPERDRIVE.Debug.Log, 1)
    end

    -- Print to console
    local prefix = "[Hyperdrive " .. levelName .. "]"
    if category then
        prefix = prefix .. " [" .. category .. "]"
    end

    print(prefix .. " " .. message)
end

-- Error logging
function HYPERDRIVE.Debug.Error(message, category)
    HYPERDRIVE.Debug.Log(1, message, category)
end

-- Warning logging
function HYPERDRIVE.Debug.Warn(message, category)
    HYPERDRIVE.Debug.Log(2, message, category)
end

-- Info logging
function HYPERDRIVE.Debug.Info(message, category)
    HYPERDRIVE.Debug.Log(3, message, category)
end

-- Debug logging
function HYPERDRIVE.Debug.Debug(message, category)
    HYPERDRIVE.Debug.Log(4, message, category)
end

-- System diagnostics
function HYPERDRIVE.Debug.RunDiagnostics()
    local diagnostics = {
        core = {},
        entities = {},
        integrations = {},
        network = {},
        performance = {}
    }

    -- Core system checks
    diagnostics.core.initialized = HYPERDRIVE ~= nil
    diagnostics.core.config_loaded = HYPERDRIVE.Config ~= nil
    diagnostics.core.functions_loaded = HYPERDRIVE.CalculateEnergyCost ~= nil

    -- Entity checks
    local entityCounts = {}
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) then
            local class = ent:GetClass()
            if string.find(class, "hyperdrive") then
                entityCounts[class] = (entityCounts[class] or 0) + 1
            end
        end
    end
    diagnostics.entities.counts = entityCounts

    -- Integration checks
    diagnostics.integrations.wiremod = WireLib ~= nil
    diagnostics.integrations.spacebuild = CAF ~= nil
    diagnostics.integrations.stargate = StarGate ~= nil

    -- Network checks
    if SERVER then
        diagnostics.network.server_side = true
        diagnostics.network.network_strings = {
            "hyperdrive_jump",
            "hyperdrive_status",
            "hyperdrive_destination",
            "hyperdrive_open_interface",
            "hyperdrive_set_destination",
            "hyperdrive_start_jump"
        }
    else
        diagnostics.network.client_side = true
    end

    -- Performance checks
    diagnostics.performance.entity_count = #ents.GetAll()
    diagnostics.performance.hyperdrive_entities = table.Count(entityCounts)

    return diagnostics
end

-- Entity analysis
function HYPERDRIVE.Debug.AnalyzeEntity(ent)
    if not IsValid(ent) then
        return {error = "Invalid entity"}
    end

    local analysis = {
        basic = {},
        hyperdrive = {},
        integrations = {},
        status = {}
    }

    -- Basic entity info
    analysis.basic.class = ent:GetClass()
    analysis.basic.model = ent:GetModel()
    analysis.basic.position = ent:GetPos()
    analysis.basic.angles = ent:GetAngles()
    analysis.basic.health = ent:Health()

    -- Check if it's a hyperdrive entity
    local class = ent:GetClass()
    if string.find(class, "hyperdrive") then
        analysis.hyperdrive.is_hyperdrive = true

        -- Common hyperdrive properties
        if ent.GetEnergy then
            analysis.hyperdrive.energy = ent:GetEnergy()
            if ent.GetEnergyPercent then
                analysis.hyperdrive.energy_percent = ent:GetEnergyPercent()
            else
                analysis.hyperdrive.energy_percent = 0
            end
        end

        if ent.GetCharging then
            analysis.hyperdrive.charging = ent:GetCharging()
        end

        if ent.GetDestination then
            analysis.hyperdrive.destination = ent:GetDestination()
        end

        if ent.GetCooldown then
            analysis.hyperdrive.cooldown = ent:GetCooldown()
            if ent.GetCooldownRemaining then
                analysis.hyperdrive.cooldown_remaining = ent:GetCooldownRemaining()
            else
                analysis.hyperdrive.cooldown_remaining = 0
            end
        end

        -- Integration-specific properties
        if class == "hyperdrive_sb_engine" then
            analysis.integrations.spacebuild = {}
            analysis.integrations.spacebuild.power_level = ent.GetPowerLevel and ent:GetPowerLevel() or 0
            analysis.integrations.spacebuild.oxygen_level = ent.GetOxygenLevel and ent:GetOxygenLevel() or 0
            analysis.integrations.spacebuild.coolant_level = ent.GetCoolantLevel and ent:GetCoolantLevel() or 0
            analysis.integrations.spacebuild.temperature = ent.GetTemperature and ent:GetTemperature() or 0
        end

        if class == "hyperdrive_sg_engine" then
            analysis.integrations.stargate = {}
            analysis.integrations.stargate.tech_level = ent.GetTechLevel and ent:GetTechLevel() or "tau_ri"
            analysis.integrations.stargate.naquadah_level = ent.GetNaquadahLevel and ent:GetNaquadahLevel() or 0
            analysis.integrations.stargate.zpm_power = ent.GetZPMPower and ent:GetZPMPower() or 0
            analysis.integrations.stargate.gate_address = ent.GetGateAddress and ent:GetGateAddress() or ""
        end

        if class == "hyperdrive_master_engine" then
            analysis.integrations.master = {}
            analysis.integrations.master.system_integration = ent.GetSystemIntegration and ent:GetSystemIntegration() or 0
            analysis.integrations.master.efficiency_rating = ent.GetEfficiencyRating and ent:GetEfficiencyRating() or 1.0
            analysis.integrations.master.operational_mode = ent.GetOperationalMode and ent:GetOperationalMode() or 1
        end

        -- Status checks
        if ent.CanJump then
            analysis.status.can_jump = ent:CanJump()
        end

        if ent.IsOnCooldown then
            analysis.status.on_cooldown = ent:IsOnCooldown()
        end
    else
        analysis.hyperdrive.is_hyperdrive = false
    end

    return analysis
end

-- Console commands
concommand.Add("hyperdrive_debug", function(ply, cmd, args)
    if not IsValid(ply) and #args == 0 then
        print("Hyperdrive Debug Commands:")
        print("  hyperdrive_debug diagnostics - Run system diagnostics")
        print("  hyperdrive_debug log - Show debug log")
        print("  hyperdrive_debug analyze - Analyze entity you're looking at")
        print("  hyperdrive_debug clear - Clear debug log")
        print("  hyperdrive_debug level <0-4> - Set debug level")
        return
    end

    local command = args[1] or "help"

    if command == "diagnostics" then
        local diag = HYPERDRIVE.Debug.RunDiagnostics()

        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Debug] Diagnostics complete - check console")
        end

        print("=== HYPERDRIVE DIAGNOSTICS ===")
        print("Core System:")
        print("  Initialized: " .. tostring(diag.core.initialized))
        print("  Config Loaded: " .. tostring(diag.core.config_loaded))
        print("  Functions Loaded: " .. tostring(diag.core.functions_loaded))

        print("Entities:")
        for class, count in pairs(diag.entities.counts) do
            print("  " .. class .. ": " .. count)
        end

        print("Integrations:")
        print("  Wiremod: " .. tostring(diag.integrations.wiremod))
        print("  Spacebuild: " .. tostring(diag.integrations.spacebuild))
        print("  Stargate: " .. tostring(diag.integrations.stargate))

        print("Performance:")
        print("  Total Entities: " .. diag.performance.entity_count)
        print("  Hyperdrive Entities: " .. diag.performance.hyperdrive_entities)

    elseif command == "log" then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Debug] Log entries - check console")
        end

        print("=== HYPERDRIVE DEBUG LOG ===")
        for _, entry in ipairs(HYPERDRIVE.Debug.Log) do
            print(string.format("[%s] [%s] [%s] %s", entry.time, entry.level, entry.category, entry.message))
        end

    elseif command == "analyze" then
        if not IsValid(ply) then
            print("Must be used by a player")
            return
        end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("[Hyperdrive Debug] Look at an entity to analyze")
            return
        end

        local analysis = HYPERDRIVE.Debug.AnalyzeEntity(trace.Entity)

        ply:ChatPrint("[Hyperdrive Debug] Analysis complete - check console")
        print("=== ENTITY ANALYSIS ===")
        PrintTable(analysis)

    elseif command == "clear" then
        HYPERDRIVE.Debug.Log = {}
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Debug] Log cleared")
        else
            print("Debug log cleared")
        end

    elseif command == "level" then
        local level = tonumber(args[2])
        if level and level >= 0 and level <= 4 then
            HYPERDRIVE.Debug.Config.LogLevel = level
            local message = "Debug level set to " .. level
            if IsValid(ply) then
                ply:ChatPrint("[Hyperdrive Debug] " .. message)
            else
                print(message)
            end
        else
            local message = "Invalid level. Use 0-4 (0=None, 1=Errors, 2=Warnings, 3=Info, 4=Debug)"
            if IsValid(ply) then
                ply:ChatPrint("[Hyperdrive Debug] " .. message)
            else
                print(message)
            end
        end

    else
        local message = "Unknown debug command. Use 'hyperdrive_debug' for help"
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Debug] " .. message)
        else
            print(message)
        end
    end
end)

-- Hook into entity creation for debugging
hook.Add("OnEntityCreated", "HyperdriveDebugEntityCreation", function(ent)
    if not HYPERDRIVE.Debug.Config.ShowEntityCreation then return end

    timer.Simple(0.1, function()
        if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive") then
            HYPERDRIVE.Debug.Info("Entity created: " .. ent:GetClass() .. " at " .. tostring(ent:GetPos()), "ENTITY")
        end
    end)
end)

-- Hook into entity removal for debugging
hook.Add("EntityRemoved", "HyperdriveDebugEntityRemoval", function(ent)
    if not HYPERDRIVE.Debug.Config.ShowEntityCreation then return end

    if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive") then
        HYPERDRIVE.Debug.Info("Entity removed: " .. ent:GetClass(), "ENTITY")
    end
end)

HYPERDRIVE.Debug.Info("Debug system loaded", "SYSTEM")
