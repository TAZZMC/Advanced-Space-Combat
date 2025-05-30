-- Enhanced Hyperdrive System v2.1.0 - Main Initialization
-- Comprehensive space travel system with advanced UI, CAP integration, and ship management

-- Shared initialization
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Version = "2.1.0"
HYPERDRIVE.Author = "Enhanced Hyperdrive Team"
HYPERDRIVE.BuildDate = os.date("%Y-%m-%d")
HYPERDRIVE.Features = {
    "Advanced Ship Core System",
    "Modern UI Framework",
    "CAP (Carter Addon Pack) Integration",
    "4-Stage Stargate Hyperdrive",
    "Ship Naming & Management",
    "Hull Damage & Repair System",
    "Advanced Shield Systems",
    "Spacebuild 3 Integration",
    "SB3 Resource Management",
    "Auto Resource Provision",
    "Weld Detection System",
    "Wiremod Integration",
    "Real-time HUD System",
    "Entity Selector Interface",
    "Q Menu Configuration",
    "Enhanced Visual Effects",
    "Performance Optimization",
    "Modern Theme System",
    "Animation Framework",
    "Notification System"
}

-- Core system namespaces
HYPERDRIVE.Core = HYPERDRIVE.Core or {}
HYPERDRIVE.ShipCore = HYPERDRIVE.ShipCore or {}
HYPERDRIVE.CAP = HYPERDRIVE.CAP or {}
HYPERDRIVE.Shields = HYPERDRIVE.Shields or {}
HYPERDRIVE.HullDamage = HYPERDRIVE.HullDamage or {}
HYPERDRIVE.SB3Resources = HYPERDRIVE.SB3Resources or {}
HYPERDRIVE.Wire = HYPERDRIVE.Wire or {}
HYPERDRIVE.Config = HYPERDRIVE.Config or {}
HYPERDRIVE.Effects = HYPERDRIVE.Effects or {}
HYPERDRIVE.UI = HYPERDRIVE.UI or {}
HYPERDRIVE.Stargate = HYPERDRIVE.Stargate or {}

-- System status tracking
HYPERDRIVE.SystemStatus = {
    Initialized = false,
    LoadedModules = {},
    IntegrationStatus = {},
    LastUpdate = 0
}

-- Initialize core modules
HYPERDRIVE.Core = HYPERDRIVE.Core or {}
HYPERDRIVE.Effects = HYPERDRIVE.Effects or {}
HYPERDRIVE.Network = HYPERDRIVE.Network or {}
HYPERDRIVE.UI = HYPERDRIVE.UI or {}
HYPERDRIVE.Destinations = HYPERDRIVE.Destinations or {}
HYPERDRIVE.Config = HYPERDRIVE.Config or {}

-- Integration modules
HYPERDRIVE.Wiremod = HYPERDRIVE.Wiremod or {}
HYPERDRIVE.Spacebuild = HYPERDRIVE.Spacebuild or {}
HYPERDRIVE.Stargate = HYPERDRIVE.Stargate or {}
HYPERDRIVE.CAP = HYPERDRIVE.CAP or {}

-- Ship Core System (MANDATORY)
HYPERDRIVE.ShipCore = HYPERDRIVE.ShipCore or {}
HYPERDRIVE.ShipCore.Ships = HYPERDRIVE.ShipCore.Ships or {}
HYPERDRIVE.ShipCore.EntityToShip = HYPERDRIVE.ShipCore.EntityToShip or {}

-- Shield System
HYPERDRIVE.Shields = HYPERDRIVE.Shields or {}

-- Hull Damage System
HYPERDRIVE.HullDamage = HYPERDRIVE.HullDamage or {}

-- Ship Naming System
HYPERDRIVE.ShipNames = HYPERDRIVE.ShipNames or {}
HYPERDRIVE.ShipNames.Registry = HYPERDRIVE.ShipNames.Registry or {}

-- Interface System
HYPERDRIVE.Interface = HYPERDRIVE.Interface or {}
HYPERDRIVE.Interface.ActiveSessions = HYPERDRIVE.Interface.ActiveSessions or {}

-- Global hyperdrive settings (shared between client and server)
HYPERDRIVE.Config = {
    MaxJumpDistance = 50000,        -- Maximum jump distance in units
    MinJumpDistance = 1000,         -- Minimum jump distance in units
    EnergyPerUnit = 0.1,           -- Energy cost per unit of distance
    MaxEnergy = 1000,              -- Maximum energy capacity
    RechargeRate = 5,              -- Energy recharge per second
    CooldownTime = 10,             -- Cooldown between jumps in seconds
    JumpChargeTime = 3,            -- Time to charge before jump
    SafetyRadius = 500,            -- Safety radius around destination
}

if SERVER then
    -- Server-side initialization
    print("[Hyperdrive] Server-side initialization...")

    -- Add enhanced client-side files to download
    AddCSLuaFile("autorun/client/hyperdrive_hud.lua")
    AddCSLuaFile("autorun/client/hyperdrive_effects_v2.lua")
    AddCSLuaFile("autorun/client/hyperdrive_sounds.lua")
    AddCSLuaFile("autorun/client/hyperdrive_materials.lua")
    AddCSLuaFile("autorun/client/hyperdrive_simple_interface.lua")
    AddCSLuaFile("autorun/client/hyperdrive_admin_panel.lua")
    AddCSLuaFile("autorun/client/hyperdrive_hyperspace_effects.lua")
    AddCSLuaFile("autorun/client/hyperdrive_hyperspace_window.lua")
    AddCSLuaFile("autorun/client/hyperdrive_stargate_client.lua")
    AddCSLuaFile("autorun/client/hyperdrive_visual_config.lua")
    AddCSLuaFile("autorun/client/hyperdrive_qmenu_config.lua")
    AddCSLuaFile("autorun/client/hyperdrive_ui_theme.lua")
    AddCSLuaFile("autorun/client/hyperdrive_entity_selector.lua")

    -- Add sound files to download
    resource.AddFile("sound/hyperdrive/ship_in_hyperspace.wav")

    -- Emergency network safety check
    local function IsNetworkSafe()
        -- Check if we should disable network optimization to prevent overflow
        local playerCount = #player.GetAll()
        if playerCount > 10 then
            print("[Hyperdrive] Warning: High player count (" .. playerCount .. "), disabling network optimization")
            return false
        end
        return true
    end

    -- Initialize ship naming system
    HYPERDRIVE.ShipNames.Registry = {}

    -- Ship naming utility functions
    function HYPERDRIVE.ShipNames.RegisterShip(coreEntity, shipName)
        if IsValid(coreEntity) and shipName then
            local entIndex = coreEntity:EntIndex()
            HYPERDRIVE.ShipNames.Registry[entIndex] = {
                name = shipName,
                core = coreEntity,
                timestamp = os.time()
            }
        end
    end

    function HYPERDRIVE.ShipNames.GetShipName(coreEntity)
        if IsValid(coreEntity) then
            local entIndex = coreEntity:EntIndex()
            local entry = HYPERDRIVE.ShipNames.Registry[entIndex]
            return entry and entry.name or "Unnamed Ship"
        end
        return "Unnamed Ship"
    end

    function HYPERDRIVE.ShipNames.UnregisterShip(coreEntity)
        if IsValid(coreEntity) then
            local entIndex = coreEntity:EntIndex()
            HYPERDRIVE.ShipNames.Registry[entIndex] = nil
        end
    end

    -- Load core systems first (order matters for dependencies)
    local coreFiles = {
        "autorun/hyperdrive_config_enhanced.lua",    -- Enhanced configuration system
        "autorun/hyperdrive_interface_system.lua",   -- Interface system (load early)
        "autorun/hyperdrive_save_restore.lua",       -- Load early to protect entities
        "autorun/hyperdrive_ship_core.lua",          -- Ship detection and core system
        "autorun/hyperdrive_sb3_resource_core.lua",  -- Spacebuild 3 resource integration
        "autorun/hyperdrive_hull_damage.lua",        -- Hull damage system
        "autorun/hyperdrive_shields.lua",            -- Shield system
        "autorun/hyperdrive_world_effects.lua",      -- World-based effects system
        "autorun/hyperdrive_core_v2.lua",            -- Core hyperdrive system
        "autorun/hyperdrive_network_strings.lua",    -- Network string definitions
        "autorun/hyperdrive_security.lua",           -- Security and validation
        "autorun/hyperdrive_ship_detection.lua",     -- Ship detection algorithms
        "autorun/hyperdrive_optimization_engine.lua", -- Performance optimization
        "autorun/hyperdrive_error_recovery.lua",     -- Error handling and recovery
        "autorun/hyperdrive_debug.lua"               -- Debug and logging system
    }

    for _, fileName in ipairs(coreFiles) do
        if file.Exists(fileName, "LUA") then
            include(fileName)
        else
            print("[Hyperdrive] Warning: " .. fileName .. " not found, skipping...")
        end
    end

    -- Load integration systems (with error handling)
    local integrationFiles = {
        "autorun/hyperdrive_wiremod.lua",
        "autorun/hyperdrive_spacebuild.lua",
        "autorun/hyperdrive_cap_integration.lua",
        "autorun/hyperdrive_stargate.lua",
        "autorun/hyperdrive_hyperspace.lua",
        "autorun/hyperdrive_quantum.lua",
        "autorun/hyperdrive_navigation_ai.lua",
        "autorun/hyperdrive_ui_enhanced.lua",
        "autorun/hyperdrive_dashboard.lua",
        "autorun/hyperdrive_admin_panel.lua",
        "autorun/hyperdrive_master.lua",
        "autorun/server/hyperdrive_hyperspace_dimension.lua",
        "autorun/server/hyperdrive_destinations.lua"
    }

    for _, fileName in ipairs(integrationFiles) do
        if file.Exists(fileName, "LUA") then
            include(fileName)
        else
            print("[Hyperdrive] Warning: " .. fileName .. " not found, skipping...")
        end
    end

    -- Load network system (simple or optimized based on safety)
    if IsNetworkSafe() then
        if file.Exists("autorun/hyperdrive_network_optimization.lua", "LUA") then
            include("autorun/hyperdrive_network_optimization.lua")
            print("[Hyperdrive] Network optimization loaded")
        end
    else
        print("[Hyperdrive] Network optimization disabled for safety")
    end

    -- Always load simple network as fallback/override
    if file.Exists("autorun/server/hyperdrive_simple_network.lua", "LUA") then
        include("autorun/server/hyperdrive_simple_network.lua")
    end

    -- Custom resources would be added here if they existed
    -- Using default GMod materials and sounds for compatibility

    -- Destination storage
    HYPERDRIVE.Destinations = {}
    HYPERDRIVE.ActiveJumps = {}

    -- Utility functions
    function HYPERDRIVE.IsValidDestination(pos)
        if not pos or not isvector(pos) then return false end

        -- Check if destination is within map bounds
        local trace = util.TraceLine({
            start = pos + Vector(0, 0, 100),
            endpos = pos - Vector(0, 0, 100),
            mask = MASK_SOLID_BRUSHONLY
        })

        return not trace.Hit or trace.Fraction > 0.1
    end

    function HYPERDRIVE.CalculateEnergyCost(distance)
        return math.max(1, distance * HYPERDRIVE.Config.EnergyPerUnit)
    end

    -- Network strings are now loaded from hyperdrive_network_strings.lua

    -- Add help commands
    concommand.Add("hyperdrive_help", function(ply, cmd, args)
        if IsValid(ply) then
            ply:ChatPrint("=== Enhanced Hyperdrive System v" .. (HYPERDRIVE.Version or "2.1") .. " - Help ===")
            ply:ChatPrint("• USE (E) key to open interfaces on all hyperdrive entities")
            ply:ChatPrint("• Ship Core: Main ship management interface with naming system")
            ply:ChatPrint("• Hyperdrive Engine: Engine status, ship info, and hull monitoring")
            ply:ChatPrint("• Hyperdrive Computer: Navigation, fleet control, and ship management")
            ply:ChatPrint("• Hyperdrive Beacon: Beacon configuration and network setup")
            ply:ChatPrint("• Shield Generator: Shield control and CAP integration")
            ply:ChatPrint("• SHIFT + USE: Open ship core management from engines")
            ply:ChatPrint("• Ship Naming: Use ship core interface to name and manage ships")
            ply:ChatPrint("• Hull Damage: Integrated hull monitoring and repair systems")
            ply:ChatPrint("• SB3 Resources: Automatic resource provision for welded entities")
            ply:ChatPrint("• Q Menu Config: Easy configuration through spawn menu")
            ply:ChatPrint("• Enhanced UI: Tabbed interface with real-time monitoring")
            ply:ChatPrint("• Features: " .. table.concat(HYPERDRIVE.Features or {}, ", "))
            ply:ChatPrint("• Commands: hyperdrive_help, hyperdrive_status, hyperdrive_sb3_resources")
            ply:ChatPrint("• Configuration: Q Menu → Utilities → Enhanced Hyperdrive")
        else
            print("=== Enhanced Hyperdrive System v" .. (HYPERDRIVE.Version or "2.1") .. " - Server Help ===")
            print("• All entities use USE (E) key for interfaces")
            print("• Ship naming system with persistence")
            print("• Hull damage system with auto-repair")
            print("• Shield system with CAP integration")
            print("• Interface system with session tracking")
            print("• SB3 resource system with automatic provision")
            print("• Wiremod support for all entities")
            print("• Configuration: hyperdrive_config_show")
            print("• Resource Status: hyperdrive_sb3_resources")
        end
    end)

    -- Add status command
    concommand.Add("hyperdrive_status", function(ply, cmd, args)
        if IsValid(ply) then
            ply:ChatPrint("=== Hyperdrive System Status ===")
            ply:ChatPrint("• Version: " .. (HYPERDRIVE.Version or "Unknown"))
            ply:ChatPrint("• Build Date: " .. (HYPERDRIVE.BuildDate or "Unknown"))
            ply:ChatPrint("• Ship Cores: " .. #ents.FindByClass("ship_core"))
            ply:ChatPrint("• Engines: " .. #ents.FindByClass("hyperdrive_engine"))
            ply:ChatPrint("• Master Engines: " .. #ents.FindByClass("hyperdrive_master_engine"))
            ply:ChatPrint("• Computers: " .. #ents.FindByClass("hyperdrive_computer"))
            ply:ChatPrint("• Beacons: " .. #ents.FindByClass("hyperdrive_beacon"))
            ply:ChatPrint("• Shield Generators: " .. #ents.FindByClass("hyperdrive_shield_generator"))

            -- Show active ships
            local shipCount = 0
            if HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.Ships then
                shipCount = table.Count(HYPERDRIVE.ShipCore.Ships)
            end
            ply:ChatPrint("• Active Ships: " .. shipCount)

            -- Show interface sessions
            local sessionCount = 0
            if HYPERDRIVE.Interface and HYPERDRIVE.Interface.ActiveSessions then
                for player, sessions in pairs(HYPERDRIVE.Interface.ActiveSessions) do
                    if IsValid(player) then
                        sessionCount = sessionCount + sessions
                    end
                end
            end
            ply:ChatPrint("• Active Interface Sessions: " .. sessionCount)

            -- Show integrations
            local integrations = {}
            if HYPERDRIVE.ShipCore then table.insert(integrations, "Ship Core") end
            if HYPERDRIVE.Shields then table.insert(integrations, "Shields") end
            if HYPERDRIVE.HullDamage then table.insert(integrations, "Hull Damage") end
            if HYPERDRIVE.Interface then table.insert(integrations, "Interface System") end
            if CAP or StarGate then table.insert(integrations, "CAP") end
            if WireLib then table.insert(integrations, "Wiremod") end
            ply:ChatPrint("• Active Integrations: " .. table.concat(integrations, ", "))
        end
    end)

    print("[Hyperdrive] Server initialization complete!")

elseif CLIENT then
    -- Client-side initialization
    print("[Hyperdrive] Client-side initialization...")

    HYPERDRIVE = HYPERDRIVE or {}
    HYPERDRIVE.HUD = {}
    HYPERDRIVE.Effects = {}

    -- Load enhanced client-side systems (with error handling and proper order)
    local clientFiles = {
        -- Core UI theme system (load first)
        "autorun/client/hyperdrive_ui_theme.lua",

        -- Enhanced HUD and effects
        "autorun/client/hyperdrive_hud.lua",
        "autorun/client/hyperdrive_effects_v2.lua",
        "autorun/client/hyperdrive_sounds.lua",
        "autorun/client/hyperdrive_materials.lua",

        -- Interface systems
        "autorun/client/hyperdrive_simple_interface.lua",
        "autorun/client/hyperdrive_entity_selector.lua",
        "autorun/client/hyperdrive_admin_panel.lua",

        -- Advanced features
        "autorun/client/hyperdrive_hyperspace_effects.lua",
        "autorun/client/hyperdrive_hyperspace_window.lua",
        "autorun/client/hyperdrive_stargate_client.lua",
        "autorun/client/hyperdrive_visual_config.lua",
        "autorun/client/hyperdrive_qmenu_config.lua"
    }

    for _, fileName in ipairs(clientFiles) do
        if file.Exists(fileName, "LUA") then
            include(fileName)
        else
            print("[Hyperdrive] Warning: " .. fileName .. " not found, skipping...")
        end
    end

    -- Add client-side help command
    concommand.Add("hyperdrive_help", function(ply, cmd, args)
        chat.AddText(Color(100, 200, 255), "=== Enhanced Hyperdrive System v" .. (HYPERDRIVE.Version or "2.1") .. " - Help ===")
        chat.AddText(Color(255, 255, 255), "• USE (E) key to open interfaces on all hyperdrive entities")
        chat.AddText(Color(255, 255, 255), "• Ship Core: Main ship management interface with naming system")
        chat.AddText(Color(255, 255, 255), "• Hyperdrive Engine: Engine status, ship info, and hull monitoring")
        chat.AddText(Color(255, 255, 255), "• Hyperdrive Computer: Navigation, fleet control, and ship management")
        chat.AddText(Color(255, 255, 255), "• Hyperdrive Beacon: Beacon configuration and network setup")
        chat.AddText(Color(255, 255, 255), "• Shield Generator: Shield control and CAP integration")
        chat.AddText(Color(255, 255, 255), "• SHIFT + USE: Open ship core management from engines")
        chat.AddText(Color(255, 255, 255), "• Ship Naming: Use ship core interface to name and manage ships")
        chat.AddText(Color(255, 255, 255), "• Hull Damage: Integrated hull monitoring and repair systems")
        chat.AddText(Color(255, 255, 255), "• Q Menu Config: Easy configuration through spawn menu")
        chat.AddText(Color(255, 255, 255), "• Enhanced UI: Tabbed interface with real-time monitoring")
        chat.AddText(Color(100, 255, 100), "• Features: " .. table.concat(HYPERDRIVE.Features or {}, ", "))
        chat.AddText(Color(255, 255, 255), "• Commands: hyperdrive_help, hyperdrive_status")
        chat.AddText(Color(100, 200, 255), "• Configuration: Q Menu → Utilities → Enhanced Hyperdrive")
    end)

    print("[Hyperdrive] Client initialization complete!")
end

-- Shared utility functions
function HYPERDRIVE.GetDistance(pos1, pos2)
    return pos1:Distance(pos2)
end

function HYPERDRIVE.FormatDistance(distance)
    if distance < 1000 then
        return string.format("%.0f units", distance)
    else
        return string.format("%.1f km", distance / 1000)
    end
end

function HYPERDRIVE.FormatEnergy(energy)
    return string.format("%.0f EU", energy)
end

-- Enhanced initialization function
function HYPERDRIVE.InitializeEnhanced()
    print("[Hyperdrive] Running enhanced system initialization...")

    -- Apply enhanced configuration if available
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Core then
        local coreConfig = HYPERDRIVE.EnhancedConfig.Core

        -- Update core system config
        if HYPERDRIVE.Core and HYPERDRIVE.Core.Config then
            HYPERDRIVE.Core.Config.EnableShipCore = coreConfig.EnableShipCore
            HYPERDRIVE.Core.Config.AutoDetectShips = coreConfig.AutoDetectShips
            HYPERDRIVE.Core.Config.RequireShipForJump = coreConfig.RequireShipForJump
            HYPERDRIVE.Core.Config.RequireShipCore = coreConfig.RequireShipCore
            HYPERDRIVE.Core.Config.EnforceOneCorePerShip = coreConfig.EnforceOneCorePerShip
            HYPERDRIVE.Core.Config.EnableShields = coreConfig.EnableShields
            HYPERDRIVE.Core.Config.AutoActivateShields = coreConfig.AutoActivateShields
            HYPERDRIVE.Core.Config.EnableCAPIntegration = coreConfig.EnableCAPIntegration
            HYPERDRIVE.Core.Config.EnableHullDamage = coreConfig.EnableHullDamage
            HYPERDRIVE.Core.Config.AutoCreateHullSystem = coreConfig.AutoCreateHullSystem
            HYPERDRIVE.Core.Config.HullDamageWireIntegration = coreConfig.HullDamageWireIntegration
            HYPERDRIVE.Core.Config.HullAutoRepair = coreConfig.HullAutoRepair
            HYPERDRIVE.Core.Config.MinimumShipSize = coreConfig.MinShipSize
            print("[Hyperdrive] Core system configuration updated with one-core-per-ship enforcement and hull damage system")
        end

        -- Update shield system config
        if HYPERDRIVE.Shields and HYPERDRIVE.Shields.Config then
            HYPERDRIVE.Shields.Config.AutoActivateOnCharge = coreConfig.AutoActivateShields
            HYPERDRIVE.Shields.Config.AutoDeactivateOnCooldown = coreConfig.ShieldAutoDeactivate
            HYPERDRIVE.Shields.Config.DamageReduction = coreConfig.ShieldProtectionLevel
            HYPERDRIVE.Shields.Config.MaintenanceCost = coreConfig.ShieldEnergyConsumption
            print("[Hyperdrive] Shield system configuration updated")
        end

        -- Update hull damage system config
        if HYPERDRIVE.HullDamage and HYPERDRIVE.HullDamage.Config then
            local hullConfig = HYPERDRIVE.EnhancedConfig.HullDamage or {}
            HYPERDRIVE.HullDamage.Config.EnableHullDamage = hullConfig.EnableHullDamage ~= false
            HYPERDRIVE.HullDamage.Config.MaxHullIntegrity = hullConfig.MaxHullIntegrity or 100
            HYPERDRIVE.HullDamage.Config.CriticalHullThreshold = hullConfig.CriticalHullThreshold or 25
            HYPERDRIVE.HullDamage.Config.EmergencyHullThreshold = hullConfig.EmergencyHullThreshold or 10
            HYPERDRIVE.HullDamage.Config.HullRepairRate = hullConfig.HullRepairRate or 0.5
            HYPERDRIVE.HullDamage.Config.AutoRepairEnabled = hullConfig.AutoRepairEnabled ~= false
            HYPERDRIVE.HullDamage.Config.AutoRepairDelay = hullConfig.AutoRepairDelay or 30
            HYPERDRIVE.HullDamage.Config.DamageToShieldsRatio = hullConfig.DamageToShieldsRatio or 0.3
            HYPERDRIVE.HullDamage.Config.HullBreachChance = hullConfig.HullBreachChance or 0.1
            HYPERDRIVE.HullDamage.Config.SystemFailureChance = hullConfig.SystemFailureChance or 0.05
            HYPERDRIVE.HullDamage.Config.DamageVisualsEnabled = hullConfig.DamageVisualsEnabled ~= false
            HYPERDRIVE.HullDamage.Config.DamageEffectsEnabled = hullConfig.DamageEffectsEnabled ~= false
            HYPERDRIVE.HullDamage.Config.HullDamageWireIntegration = hullConfig.HullDamageWireIntegration ~= false
            print("[Hyperdrive] Hull damage system configuration updated")
        end
    end

    -- Integration status report
    local integrations = {}
    if HYPERDRIVE.Core then table.insert(integrations, "Core V2") end
    if HYPERDRIVE.ShipCore then table.insert(integrations, "Ship Core") end
    if HYPERDRIVE.Shields then table.insert(integrations, "Shields") end
    if HYPERDRIVE.HullDamage then table.insert(integrations, "Hull Damage") end
    if HYPERDRIVE.UI then table.insert(integrations, "Ship Core UI") end
    if CAP or StarGate then table.insert(integrations, "CAP") end
    if SpaceCombat2 then table.insert(integrations, "SC2") end
    if Spacebuild then table.insert(integrations, "SB3") end
    if WireLib then table.insert(integrations, "Wiremod") end

    print("[Hyperdrive] Enhanced initialization complete with integrations: " .. table.concat(integrations, ", "))
end

-- Run enhanced initialization after all systems load
timer.Simple(2, function()
    HYPERDRIVE.InitializeEnhanced()
end)

-- Hook for cleanup
hook.Add("ShutDown", "HyperdriveCleanup", function()
    if SERVER and HYPERDRIVE.ActiveJumps then
        for k, v in pairs(HYPERDRIVE.ActiveJumps) do
            if IsValid(v.entity) then
                v.entity:Remove()
            end
        end
    end
end)
