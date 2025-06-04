-- Enhanced Hyperdrive System - Advanced Admin Panel
-- Comprehensive server administration tools for hyperdrive system

if CLIENT then return end

HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Admin = HYPERDRIVE.Admin or {}

-- Admin panel configuration
HYPERDRIVE.Admin.Config = {
    RequiredRank = "admin", -- Minimum rank required
    LogActions = true,
    NotifyAdmins = true,
    EnableRemoteControl = true,
    EnableMassOperations = true,
    EnableSystemDiagnostics = true,
    EnablePerformanceMonitoring = true,
    
    -- Permission levels
    Permissions = {
        view_status = "user",
        control_engines = "moderator", 
        mass_operations = "admin",
        system_config = "superadmin",
        emergency_controls = "superadmin"
    }
}

-- Admin command registry
HYPERDRIVE.Admin.Commands = {}

-- Utility functions
local function IsAuthorized(ply, permission)
    if not IsValid(ply) then return false end
    
    local requiredRank = HYPERDRIVE.Admin.Config.Permissions[permission] or "admin"
    
    -- Check if player has required rank
    if ply:IsSuperAdmin() then return true end
    if requiredRank == "admin" and ply:IsAdmin() then return true end
    if requiredRank == "moderator" and (ply:IsAdmin() or ply:GetUserGroup() == "moderator") then return true end
    if requiredRank == "user" then return true end
    
    return false
end

local function LogAdminAction(ply, action, details)
    if not HYPERDRIVE.Admin.Config.LogActions then return end
    
    local logMessage = string.format("[Hyperdrive Admin] %s (%s) performed: %s", 
        IsValid(ply) and ply:Nick() or "Console", 
        IsValid(ply) and ply:SteamID() or "CONSOLE", 
        action)
    
    if details then
        logMessage = logMessage .. " - " .. details
    end
    
    print(logMessage)
    
    -- Log to file if available
    if file then
        local logFile = "hyperdrive_admin_log.txt"
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        local logEntry = string.format("[%s] %s\n", timestamp, logMessage)
        file.Append(logFile, logEntry)
    end
end

local function NotifyAdmins(message, level)
    if not HYPERDRIVE.Admin.Config.NotifyAdmins then return end
    
    level = level or "info"
    local color = Color(100, 150, 255)
    
    if level == "warning" then color = Color(255, 200, 100)
    elseif level == "error" then color = Color(255, 100, 100)
    elseif level == "success" then color = Color(100, 255, 100)
    end
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:IsAdmin() then
            ply:ChatPrint("[Advanced Space Combat] " .. message)
        end
    end
end

-- System status functions
function HYPERDRIVE.Admin.GetSystemStatus()
    local status = {
        engines = {},
        shipCores = {},
        shields = {},
        performance = {},
        errors = {}
    }
    
    -- Get all hyperdrive engines
    local engines = {}
    table.Add(engines, ents.FindByClass("hyperdrive_engine"))
    table.Add(engines, ents.FindByClass("hyperdrive_master_engine"))
    
    for _, engine in ipairs(engines) do
        if IsValid(engine) then
            table.insert(status.engines, {
                entity = engine,
                class = engine:GetClass(),
                pos = engine:GetPos(),
                energy = engine:GetNWFloat("Energy", 0),
                maxEnergy = engine:GetNWFloat("MaxEnergy", 1000),
                charging = engine:GetNWBool("Charging", false),
                cooldown = engine:GetNWFloat("Cooldown", 0),
                owner = engine:GetNWString("Owner", "Unknown")
            })
        end
    end
    
    -- Get all ship cores
    for _, core in ipairs(ents.FindByClass("ship_core")) do
        if IsValid(core) then
            table.insert(status.shipCores, {
                entity = core,
                pos = core:GetPos(),
                shipName = core:GetNWString("ShipName", "Unnamed"),
                state = core:GetNWInt("State", 0),
                hullIntegrity = core:GetNWFloat("HullIntegrity", 100),
                energyLevel = core:GetNWFloat("EnergyLevel", 100),
                owner = core:GetNWString("Owner", "Unknown")
            })
        end
    end
    
    -- Get all shield generators
    for _, shield in ipairs(ents.FindByClass("hyperdrive_shield_generator")) do
        if IsValid(shield) then
            table.insert(status.shields, {
                entity = shield,
                pos = shield:GetPos(),
                active = shield:GetNWBool("ShieldActive", false),
                strength = shield:GetNWFloat("ShieldStrength", 0),
                maxStrength = shield:GetNWFloat("MaxShieldStrength", 100),
                owner = shield:GetNWString("Owner", "Unknown")
            })
        end
    end
    
    -- Performance metrics
    status.performance = {
        serverFPS = math.floor(1 / engine.TickInterval()),
        entityCount = #ents.GetAll(),
        hyperdriveEntityCount = #engines + #status.shipCores + #status.shields,
        memoryUsage = collectgarbage("count"),
        uptime = CurTime()
    }
    
    return status
end

-- Admin commands
function HYPERDRIVE.Admin.Commands.status(ply, args)
    if not IsAuthorized(ply, "view_status") then
        ply:ChatPrint("[Hyperdrive Admin] Access denied.")
        return
    end
    
    local status = HYPERDRIVE.Admin.GetSystemStatus()
    
    ply:ChatPrint("=== HYPERDRIVE SYSTEM STATUS ===")
    ply:ChatPrint(string.format("Engines: %d | Ship Cores: %d | Shields: %d", 
        #status.engines, #status.shipCores, #status.shields))
    ply:ChatPrint(string.format("Server FPS: %d | Entities: %d | Memory: %.1f MB", 
        status.performance.serverFPS, status.performance.entityCount, status.performance.memoryUsage / 1024))
    
    LogAdminAction(ply, "Viewed system status")
end

function HYPERDRIVE.Admin.Commands.emergency_stop(ply, args)
    if not IsAuthorized(ply, "emergency_controls") then
        ply:ChatPrint("[Hyperdrive Admin] Access denied.")
        return
    end
    
    local stopped = 0
    
    -- Stop all charging engines
    local engines = {}
    table.Add(engines, ents.FindByClass("hyperdrive_engine"))
    table.Add(engines, ents.FindByClass("hyperdrive_master_engine"))
    
    for _, engine in ipairs(engines) do
        if IsValid(engine) and engine:GetNWBool("Charging", false) then
            if engine.StopCharging then
                engine:StopCharging()
                stopped = stopped + 1
            end
        end
    end
    
    ply:ChatPrint(string.format("[Hyperdrive Admin] Emergency stop executed. %d engines stopped.", stopped))
    NotifyAdmins(string.format("%s executed emergency stop (%d engines affected)", ply:Nick(), stopped), "warning")
    LogAdminAction(ply, "Emergency stop", string.format("%d engines stopped", stopped))
end

function HYPERDRIVE.Admin.Commands.recharge_all(ply, args)
    if not IsAuthorized(ply, "mass_operations") then
        ply:ChatPrint("[Hyperdrive Admin] Access denied.")
        return
    end
    
    local recharged = 0
    
    -- Recharge all engines
    local engines = {}
    table.Add(engines, ents.FindByClass("hyperdrive_engine"))
    table.Add(engines, ents.FindByClass("hyperdrive_master_engine"))
    
    for _, engine in ipairs(engines) do
        if IsValid(engine) then
            engine:SetNWFloat("Energy", engine:GetNWFloat("MaxEnergy", 1000))
            engine:SetNWFloat("Cooldown", 0)
            recharged = recharged + 1
        end
    end
    
    ply:ChatPrint(string.format("[Hyperdrive Admin] %d engines recharged.", recharged))
    NotifyAdmins(string.format("%s recharged all engines (%d affected)", ply:Nick(), recharged), "success")
    LogAdminAction(ply, "Mass recharge", string.format("%d engines recharged", recharged))
end

function HYPERDRIVE.Admin.Commands.repair_all(ply, args)
    if not IsAuthorized(ply, "mass_operations") then
        ply:ChatPrint("[Hyperdrive Admin] Access denied.")
        return
    end
    
    local repaired = 0
    
    -- Repair all ship cores
    for _, core in ipairs(ents.FindByClass("ship_core")) do
        if IsValid(core) then
            core:SetNWFloat("HullIntegrity", 100)
            core:SetNWFloat("EnergyLevel", 100)
            core:SetNWInt("State", 1) -- ACTIVE
            repaired = repaired + 1
        end
    end
    
    -- Repair all shields
    for _, shield in ipairs(ents.FindByClass("hyperdrive_shield_generator")) do
        if IsValid(shield) then
            shield:SetNWFloat("ShieldStrength", shield:GetNWFloat("MaxShieldStrength", 100))
            repaired = repaired + 1
        end
    end
    
    ply:ChatPrint(string.format("[Hyperdrive Admin] %d entities repaired.", repaired))
    NotifyAdmins(string.format("%s repaired all systems (%d affected)", ply:Nick(), repaired), "success")
    LogAdminAction(ply, "Mass repair", string.format("%d entities repaired", repaired))
end

function HYPERDRIVE.Admin.Commands.diagnostics(ply, args)
    if not IsAuthorized(ply, "system_config") then
        ply:ChatPrint("[Hyperdrive Admin] Access denied.")
        return
    end
    
    ply:ChatPrint("=== HYPERDRIVE DIAGNOSTICS ===")
    
    -- Check for common issues
    local issues = {}
    
    -- Check for engines without ship cores
    local engines = {}
    table.Add(engines, ents.FindByClass("hyperdrive_engine"))
    table.Add(engines, ents.FindByClass("hyperdrive_master_engine"))
    
    for _, engine in ipairs(engines) do
        if IsValid(engine) then
            local nearbyCore = false
            for _, core in ipairs(ents.FindByClass("ship_core")) do
                if IsValid(core) and engine:GetPos():Distance(core:GetPos()) < 500 then
                    nearbyCore = true
                    break
                end
            end
            if not nearbyCore then
                table.insert(issues, string.format("Engine at %s has no nearby ship core", tostring(engine:GetPos())))
            end
        end
    end
    
    -- Check for low energy systems
    for _, core in ipairs(ents.FindByClass("ship_core")) do
        if IsValid(core) then
            local energy = core:GetNWFloat("EnergyLevel", 100)
            if energy < 25 then
                table.insert(issues, string.format("Ship core '%s' has low energy (%d%%)", 
                    core:GetNWString("ShipName", "Unnamed"), math.floor(energy)))
            end
        end
    end
    
    if #issues == 0 then
        ply:ChatPrint("No issues detected.")
    else
        ply:ChatPrint(string.format("Found %d issues:", #issues))
        for i, issue in ipairs(issues) do
            ply:ChatPrint(string.format("%d. %s", i, issue))
        end
    end
    
    LogAdminAction(ply, "Ran diagnostics", string.format("%d issues found", #issues))
end

-- Console command registration
concommand.Add("hyperdrive_admin", function(ply, cmd, args)
    if not IsValid(ply) and not game.SinglePlayer() then
        -- Console command
        ply = nil
    end
    
    if #args == 0 then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Admin] Available commands: status, emergency_stop, recharge_all, repair_all, diagnostics")
        else
            print("[Hyperdrive Admin] Available commands: status, emergency_stop, recharge_all, repair_all, diagnostics")
        end
        return
    end
    
    local command = args[1]
    local commandArgs = {}
    for i = 2, #args do
        table.insert(commandArgs, args[i])
    end
    
    if HYPERDRIVE.Admin.Commands[command] then
        HYPERDRIVE.Admin.Commands[command](ply, commandArgs)
    else
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Admin] Unknown command: " .. command)
        else
            print("[Hyperdrive Admin] Unknown command: " .. command)
        end
    end
end)

-- Auto-diagnostics timer
timer.Create("HyperdriveAdminDiagnostics", 300, 0, function() -- Every 5 minutes
    if not HYPERDRIVE.Admin.Config.EnableSystemDiagnostics then return end
    
    local status = HYPERDRIVE.Admin.GetSystemStatus()
    
    -- Check for critical issues
    local criticalIssues = 0
    
    -- Check server performance
    if status.performance.serverFPS < 20 then
        NotifyAdmins("Server FPS is critically low: " .. status.performance.serverFPS, "error")
        criticalIssues = criticalIssues + 1
    end
    
    -- Check for emergency states
    for _, core in ipairs(status.shipCores) do
        if core.state == 4 then -- EMERGENCY
            NotifyAdmins(string.format("Ship core '%s' is in emergency state", core.shipName), "error")
            criticalIssues = criticalIssues + 1
        end
    end
    
    if criticalIssues > 0 then
        print(string.format("[Hyperdrive Admin] Auto-diagnostics found %d critical issues", criticalIssues))
    end
end)

print("[Hyperdrive] Advanced Admin Panel loaded")
