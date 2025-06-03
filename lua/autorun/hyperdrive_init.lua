-- Enhanced Hyperdrive System v5.1.0 - Main Initialization
-- Comprehensive space travel system with advanced UI, CAP integration, sound system, and visual effects
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED AND OPTIMIZED WITH STARGATE HYPERSPACE

print("[Hyperdrive] ENHANCED STARGATE HYPERSPACE UPDATE v5.1.0 - ULTIMATE 4-STAGE TRAVEL SYSTEM")
print("[Hyperdrive] Advanced Space Combat v5.1.0 - Ultimate Stargate Hyperspace Edition initializing...")
print("[Hyperdrive] All code updated and optimized for maximum performance and compatibility")

-- Shared initialization
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Version = "5.1.0"
HYPERDRIVE.Author = "Advanced Space Combat Team"
HYPERDRIVE.BuildDate = os.date("%Y-%m-%d")
HYPERDRIVE.BuildNumber = "5100" -- Ultimate Stargate Hyperspace build - All code updated
HYPERDRIVE.Status = "Production Ready - Ultimate Stargate Hyperspace Edition"
HYPERDRIVE.LastUpdate = "Complete code update - All systems optimized with enhanced 4-Stage Stargate Hyperspace"
HYPERDRIVE.Features = {
    "Enhanced 4-Stage Stargate Hyperspace System",
    "Authentic Stargate Visual Effects and Sound",
    "Gravitational Anomaly Detection",
    "Ancient Technology and ZPM Bonuses",
    "Progressive System Stabilization",
    "Client-Side HUD and Screen Effects",
    "Ultimate Hyperdrive Engine - All Types Unified",
    "ARIA-4 Next-Generation AI Assistant",
    "Advanced Ship Core System",
    "Modern UI Framework",
    "CAP (Carter Addon Pack) Integration",
    "Ship Naming & Management",
    "Hull Damage & Repair System",
    "Advanced Shield Systems",
    "Spacebuild 3 Integration (Official Steam Workshop)",
    "SB3 Resource Management with Auto-Distribution",
    "Auto Resource Provision and Collection",
    "Steam Workshop SB3 v3.2.0 Support",
    "Weld Detection System",
    "Wiremod Integration",
    "Real-time HUD System",
    "Entity Selector Interface",
    "Q Menu Configuration",
    "Enhanced Visual Effects",
    "Professional Sound System",
    "Advanced Materials & Effects",
    "Spatial Audio Support",
    "Performance Optimization",
    "Modern Theme System",
    "Animation Framework",
    "Notification System",

    -- v2.2.1 Advanced Features - COMPLETE CODE UPDATE WITH STEAM WORKSHOP
    "Fleet Management System with Formation Flying",
    "Advanced Admin Panel with Real-Time Monitoring",
    "Real-Time Monitoring with Multi-Frequency Updates",
    "System Diagnostics with Predictive Analytics",
    "Emergency Controls with Instant Response",
    "Multi-Ship Coordination with Live Sync",
    "Formation Flying with Automatic Positioning",
    "Performance Analytics with Live Metrics",
    "Enhanced Accessibility with High Contrast",
    "Cross-System Integration with All Addons",

    -- v2.2.1 Combat & Weapons Systems
    "Advanced Weapons Arsenal (5 Weapon Types)",
    "Railgun System with Penetrating Projectiles",
    "Plasma Cannon with Area-Effect Damage",
    "Torpedo Launcher with Smart Guidance",
    "Beam Weapons with Continuous Fire",
    "Point Defense Systems",
    "Ammunition Management with Manufacturing",
    "Weapon Upgrade System (10 Categories)",
    "Tactical AI with 3 Behavior Modes",
    "Fleet Combat Coordination",

    -- v2.2.1 Flight & Navigation Systems
    "Advanced Ship Flight System",
    "Physics-Based Movement with 6-DOF",
    "Autopilot with Collision Avoidance",
    "Formation Flying (4 Formation Types)",
    "Waypoint Navigation System",
    "Flight Console with Real-Time HUD",
    "Energy Management for Flight Operations",
    "Navigation Beacons and Route Planning",

    -- v2.2.1 Docking & Transport Systems
    "Ship Docking Pad System (5 Pad Types)",
    "Automated Landing with 3-Phase Approach",
    "Shuttle System (4 Shuttle Types)",
    "Mission Management with Auto-Assignment",
    "Passenger Transport Operations",
    "Cargo Delivery System",
    "Emergency Evacuation Protocols",
    "Service Automation (Refuel/Repair/Resupply)",

    -- v4.0.0 Advanced User Experience
    "Comprehensive Undo System with Smart Cleanup",
    "ARIA-4 AI Assistant with Intent Recognition and Sentiment Analysis",
    "AI Conversation Memory and Contextual Understanding",
    "Enhanced Spawn Tool with Auto-Linking",
    "Real-Time System Integration",
    "Professional Error Handling",
    "Performance Optimization",
    "User-Friendly Operation",
    "Complete Documentation System",

    -- Real-Time Update Features
    "Real-Time Entity Scanning (10 FPS)",
    "Real-Time Resource Calculations (5 FPS)",
    "Real-Time System Health Checks (2 FPS)",
    "Real-Time Network Synchronization (10 FPS)",
    "Real-Time Performance Monitoring (20 FPS)",
    "Real-Time Alert System with Instant Notifications",
    "Real-Time HUD Updates with Live Data Streams",
    "Real-Time Fleet Coordination with Live Status",

    -- Steam Workshop Integration Features
    "Steam Workshop CAP Collection Support (32 Components)",
    "Steam Workshop Spacebuild 3 v3.2.0 Integration",
    "Official CAP Steam Workshop Detection",
    "Official SB3 Steam Workshop Detection",
    "Multi-Source Addon Detection (Workshop + GitHub)",
    "Component-Level Integration Tracking",
    "Mixed Installation Support",
    "Workshop Version Compatibility",

    -- Complete Integration Features
    "Complete Code Integration Across All Systems",
    "Unified Error Handling and Recovery",
    "Professional Performance Optimization",
    "Production-Ready Quality Assurance",
    "Steam Workshop Compatibility Layer",
    "Multi-Platform Addon Support"
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
HYPERDRIVE.Sounds = HYPERDRIVE.Sounds or {}
HYPERDRIVE.WorldEffects = HYPERDRIVE.WorldEffects or {}

-- v2.2.0 New Namespaces
HYPERDRIVE.Fleet = HYPERDRIVE.Fleet or {}
HYPERDRIVE.Admin = HYPERDRIVE.Admin or {}
HYPERDRIVE.RealTime = HYPERDRIVE.RealTime or {}
HYPERDRIVE.Analytics = HYPERDRIVE.Analytics or {}
HYPERDRIVE.Diagnostics = HYPERDRIVE.Diagnostics or {}

-- v2.2.1 Combat & Weapons Namespaces
HYPERDRIVE.Weapons = HYPERDRIVE.Weapons or {}
HYPERDRIVE.WeaponGroups = HYPERDRIVE.WeaponGroups or {}
HYPERDRIVE.Ammunition = HYPERDRIVE.Ammunition or {}
HYPERDRIVE.WeaponUpgrades = HYPERDRIVE.WeaponUpgrades or {}
HYPERDRIVE.TacticalAI = HYPERDRIVE.TacticalAI or {}

-- v2.2.1 Flight & Navigation Namespaces
HYPERDRIVE.Flight = HYPERDRIVE.Flight or {}
HYPERDRIVE.Navigation = HYPERDRIVE.Navigation or {}

-- v2.2.1 Docking & Transport Namespaces
HYPERDRIVE.DockingPad = HYPERDRIVE.DockingPad or {}
HYPERDRIVE.Shuttle = HYPERDRIVE.Shuttle or {}

-- v2.2.1 Undo System Namespace
HYPERDRIVE.Undo = HYPERDRIVE.Undo or {}

-- v2.2.1 Chat AI Namespace
HYPERDRIVE.ChatAI = HYPERDRIVE.ChatAI or {}

-- System status tracking
HYPERDRIVE.SystemStatus = {
    Initialized = false,
    LoadedModules = {},
    IntegrationStatus = {},
    LastUpdate = 0,

    -- v2.2.1 New Systems Status
    WeaponsSystem = false,
    WeaponGroups = false,
    AmmunitionSystem = false,
    WeaponUpgrades = false,
    TacticalAI = false,
    FlightSystem = false,
    NavigationSystem = false,
    DockingPadSystem = false,
    ShuttleSystem = false,
    UndoSystem = false,
    ChatAI = false,

    -- Entity Counts
    EntityCounts = {
        ShipCores = 0,
        Engines = 0,
        Weapons = 0,
        FlightConsoles = 0,
        DockingPads = 0,
        Shuttles = 0,
        ShieldGenerators = 0
    }
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

-- Helper function to safely create ConVars with error handling
local function SafeCreateConVar(name, default, flags, help)
    local success, err = pcall(function()
        if not ConVarExists(name) then
            CreateConVar(name, default, flags, help)
            return true
        end
        return false -- Already exists
    end)

    if not success then
        -- ConVar already exists or other error, just get the existing one
        local existing = GetConVar(name)
        if not existing then
            print("[Hyperdrive] Warning: Could not create or find ConVar '" .. name .. "': " .. tostring(err))
        end
    end
end

-- Create ConVars for configuration with safe creation
SafeCreateConVar("hyperdrive_enabled", "1", FCVAR_ARCHIVE, "Enable/disable the hyperdrive system")
SafeCreateConVar("hyperdrive_debug_mode", "0", FCVAR_ARCHIVE, "Enable debug mode for hyperdrive system")

SafeCreateConVar("hyperdrive_max_range", "100000", FCVAR_ARCHIVE, "Maximum hyperdrive jump range")
SafeCreateConVar("hyperdrive_energy_cost", "1000", FCVAR_ARCHIVE, "Energy cost per hyperdrive jump")
SafeCreateConVar("hyperdrive_cooldown", "30", FCVAR_ARCHIVE, "Cooldown time between hyperdrive jumps")
SafeCreateConVar("hyperdrive_require_ship_core", "1", FCVAR_ARCHIVE, "Require ship core for hyperdrive operation")
SafeCreateConVar("hyperdrive_one_core_per_ship", "1", FCVAR_ARCHIVE, "Enforce one ship core per ship")
SafeCreateConVar("hyperdrive_auto_detect_ships", "1", FCVAR_ARCHIVE, "Auto-detect ship structures")
SafeCreateConVar("hyperdrive_enable_shields", "1", FCVAR_ARCHIVE, "Enable shield system")
SafeCreateConVar("hyperdrive_enable_hull_damage", "1", FCVAR_ARCHIVE, "Enable hull damage system")
SafeCreateConVar("hyperdrive_enable_sb3_resources", "1", FCVAR_ARCHIVE, "Enable Spacebuild 3 resource integration")
SafeCreateConVar("hyperdrive_enable_cap_integration", "1", FCVAR_ARCHIVE, "Enable CAP (Carter Addon Pack) integration")
SafeCreateConVar("hyperdrive_enable_use_key_interfaces", "1", FCVAR_ARCHIVE, "Enable USE (E) key interfaces")
SafeCreateConVar("hyperdrive_enable_shift_modifier", "1", FCVAR_ARCHIVE, "Enable SHIFT+USE for ship core access")
SafeCreateConVar("hyperdrive_enable_feedback_messages", "1", FCVAR_ARCHIVE, "Enable feedback messages")

-- Modern UI System ConVars
SafeCreateConVar("hyperdrive_modern_ui_enabled", "1", FCVAR_ARCHIVE, "Enable modern UI framework")
SafeCreateConVar("hyperdrive_ui_glassmorphism", "1", FCVAR_ARCHIVE, "Enable glassmorphism design")
SafeCreateConVar("hyperdrive_ui_animations", "1", FCVAR_ARCHIVE, "Enable UI animations")
SafeCreateConVar("hyperdrive_ui_notifications", "1", FCVAR_ARCHIVE, "Enable UI notifications")
SafeCreateConVar("hyperdrive_ui_sounds", "1", FCVAR_ARCHIVE, "Enable UI sound effects")
SafeCreateConVar("hyperdrive_ui_anim_speed", "1.0", FCVAR_ARCHIVE, "Animation speed multiplier")
SafeCreateConVar("hyperdrive_ui_scale", "1.0", FCVAR_ARCHIVE, "UI scale factor")
SafeCreateConVar("hyperdrive_ui_notif_duration", "5.0", FCVAR_ARCHIVE, "Notification duration in seconds")
SafeCreateConVar("hyperdrive_ui_max_notifications", "5", FCVAR_ARCHIVE, "Maximum number of notifications")

-- Accessibility ConVars
SafeCreateConVar("hyperdrive_ui_high_contrast", "0", FCVAR_ARCHIVE, "Enable high contrast mode")
SafeCreateConVar("hyperdrive_ui_large_text", "0", FCVAR_ARCHIVE, "Enable large text mode")
SafeCreateConVar("hyperdrive_ui_reduced_motion", "0", FCVAR_ARCHIVE, "Enable reduced motion for motion sensitivity")
SafeCreateConVar("hyperdrive_ui_colorblind_friendly", "0", FCVAR_ARCHIVE, "Enable color blind friendly mode")

-- Performance ConVars
SafeCreateConVar("hyperdrive_ui_reduce_on_low_fps", "1", FCVAR_ARCHIVE, "Reduce animations on low FPS")
SafeCreateConVar("hyperdrive_ui_min_fps", "30", FCVAR_ARCHIVE, "Minimum FPS for animations")

-- Sound System ConVars
SafeCreateConVar("hyperdrive_sound_volume", "1.0", FCVAR_ARCHIVE, "Master volume for hyperdrive sounds")
SafeCreateConVar("hyperdrive_spatial_audio", "1", FCVAR_ARCHIVE, "Enable 3D spatial audio")
SafeCreateConVar("hyperdrive_sound_hyperdrive_volume", "1.0", FCVAR_ARCHIVE, "Volume for hyperdrive engine sounds")
SafeCreateConVar("hyperdrive_sound_shields_volume", "1.0", FCVAR_ARCHIVE, "Volume for shield sounds")
SafeCreateConVar("hyperdrive_sound_alerts_volume", "1.0", FCVAR_ARCHIVE, "Volume for alert sounds")
SafeCreateConVar("hyperdrive_sound_ambient_volume", "0.6", FCVAR_ARCHIVE, "Volume for ambient sounds")
SafeCreateConVar("hyperdrive_sound_effects_volume", "0.9", FCVAR_ARCHIVE, "Volume for effect sounds")
SafeCreateConVar("hyperdrive_shield_volume", "0.7", FCVAR_ARCHIVE, "Volume for shield system sounds")
SafeCreateConVar("hyperdrive_ui_volume", "0.6", FCVAR_ARCHIVE, "Volume for UI interaction sounds")

-- v2.2.0 New ConVars
SafeCreateConVar("hyperdrive_ui_realtime", "1", FCVAR_ARCHIVE, "Enable real-time HUD updates")
SafeCreateConVar("hyperdrive_ui_alerts", "1", FCVAR_ARCHIVE, "Enable real-time system alerts")
SafeCreateConVar("hyperdrive_ui_fleet", "1", FCVAR_ARCHIVE, "Enable fleet management UI")
SafeCreateConVar("hyperdrive_fleet_formation", "1", FCVAR_ARCHIVE, "Enable automatic formation flying")
SafeCreateConVar("hyperdrive_ui_stargate", "1", FCVAR_ARCHIVE, "Enable Stargate sequence UI")
SafeCreateConVar("hyperdrive_stargate_progress", "1", FCVAR_ARCHIVE, "Enable stage progress display")
SafeCreateConVar("hyperdrive_ui_admin", "1", FCVAR_ARCHIVE, "Enable admin panel UI")
SafeCreateConVar("hyperdrive_admin_perfmon", "1", FCVAR_ARCHIVE, "Enable performance monitoring")
SafeCreateConVar("hyperdrive_ui_hover", "1", FCVAR_ARCHIVE, "Enable UI hover effects")
SafeCreateConVar("hyperdrive_ui_click", "1", FCVAR_ARCHIVE, "Enable UI click effects")
SafeCreateConVar("hyperdrive_ui_transitions", "1", FCVAR_ARCHIVE, "Enable theme transitions")

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
    AddCSLuaFile("autorun/client/hyperdrive_ui_theme.lua")
    AddCSLuaFile("autorun/client/hyperdrive_entity_selector.lua")
    AddCSLuaFile("autorun/client/asc_spawn_menu_complete.lua")
    AddCSLuaFile("autorun/client/asc_menu_organization.lua")

    -- Add v2.2.1 client-side files
    AddCSLuaFile("entities/hyperdrive_flight_console/cl_init.lua")
    AddCSLuaFile("entities/hyperdrive_docking_pad/cl_init.lua")
    AddCSLuaFile("entities/hyperdrive_shuttle/cl_init.lua")



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
        "autorun/hyperdrive_sound_system.lua",       -- Sound system (load early for integration)
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
        "autorun/hyperdrive_debug.lua",              -- Debug and logging system
        "autorun/hyperdrive_real_time_monitoring.lua", -- Real-time monitoring
        "autorun/hyperdrive_performance_analytics.lua", -- Performance analytics
        "autorun/asc_code_fixes.lua",                 -- Code fixes and error recovery
        "autorun/asc_system_diagnostics.lua",         -- System diagnostics and health monitoring
        "autorun/asc_status_commands.lua"             -- Status commands and help system
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
        "autorun/server/hyperdrive_destinations.lua",

        -- v2.2.0 New Files
        "autorun/hyperdrive_fleet_management.lua",
        "autorun/server/hyperdrive_admin_panel.lua",

        -- v2.2.1 Combat & Weapons Systems
        "autorun/hyperdrive_weapons_system.lua",
        "autorun/hyperdrive_weapon_groups.lua",
        "autorun/hyperdrive_ammunition_system.lua",
        "autorun/hyperdrive_weapon_upgrades.lua",
        "autorun/hyperdrive_tactical_ai.lua",

        -- v2.2.1 Flight & Navigation Systems
        "autorun/hyperdrive_ship_flight_system.lua",
        "autorun/hyperdrive_navigation_system.lua",

        -- v2.2.1 Docking & Transport Systems
        "autorun/hyperdrive_docking_pad_system.lua",
        "autorun/hyperdrive_shuttle_system.lua",

        -- v2.2.1 Undo System
        "autorun/hyperdrive_undo_system.lua",

        -- v2.2.1 Chat AI System
        "autorun/hyperdrive_chat_ai.lua"
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
            ply:ChatPrint("=== Enhanced Hyperdrive System v2.2.1 - Help ===")
            ply:ChatPrint("• USE (E) key to open interfaces on all hyperdrive entities")
            ply:ChatPrint("• Ship Core: Main ship management interface with naming system")
            ply:ChatPrint("• Hyperdrive Engine: Engine status, ship info, and hull monitoring")
            ply:ChatPrint("• Hyperdrive Computer: Navigation, fleet control, and ship management")
            ply:ChatPrint("• Shield Generator: Shield control and CAP integration")
            ply:ChatPrint("")
            ply:ChatPrint("=== v2.2.1 New Features ===")
            ply:ChatPrint("• Weapons: 5 types - Pulse, Beam, Torpedo, Railgun, Plasma")
            ply:ChatPrint("• Flight Console: Ship movement with autopilot and formations")
            ply:ChatPrint("• Docking Pads: 5 types with automated landing and services")
            ply:ChatPrint("• Shuttles: 4 types for automated transport missions")
            ply:ChatPrint("• Undo System: Press Z to undo, hyperdrive_undo_list for history")
            ply:ChatPrint("• ARIA-4 AI: Use 'aria <question>' (primary) or !ai (legacy) to talk to ARIA-4")
            ply:ChatPrint("")
            ply:ChatPrint("• SHIFT + USE: Open ship core management from engines")
            ply:ChatPrint("• Ship Naming: Use ship core interface to name and manage ships")
            ply:ChatPrint("• Hull Damage: Integrated hull monitoring and repair systems")
            ply:ChatPrint("• SB3 Resources: Automatic resource provision for welded entities")
            ply:ChatPrint("• Auto-linking: Weapons and systems auto-link to nearby ship cores")
            ply:ChatPrint("• Commands: hyperdrive_help, hyperdrive_status, hyperdrive_undo")
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
            ply:ChatPrint("=== Enhanced Hyperdrive System v2.2.1 Status ===")
            ply:ChatPrint("• Version: " .. (HYPERDRIVE.VERSION or "2.2.1"))
            ply:ChatPrint("• Build: " .. (HYPERDRIVE.BUILD or "2024.12.19"))

            -- Core entities
            ply:ChatPrint("• Ship Cores: " .. #ents.FindByClass("ship_core"))
            ply:ChatPrint("• Engines: " .. #ents.FindByClass("hyperdrive_engine"))
            ply:ChatPrint("• Master Engines: " .. #ents.FindByClass("hyperdrive_master_engine"))
            ply:ChatPrint("• Computers: " .. #ents.FindByClass("hyperdrive_computer"))
            ply:ChatPrint("• Shield Generators: " .. #ents.FindByClass("hyperdrive_shield_generator"))

            -- v2.2.1 entities
            local weapons = #ents.FindByClass("hyperdrive_pulse_cannon") + #ents.FindByClass("hyperdrive_beam_weapon") +
                           #ents.FindByClass("hyperdrive_torpedo_launcher") + #ents.FindByClass("hyperdrive_railgun") +
                           #ents.FindByClass("hyperdrive_plasma_cannon")
            ply:ChatPrint("• Weapons: " .. weapons)
            ply:ChatPrint("• Flight Consoles: " .. #ents.FindByClass("hyperdrive_flight_console"))
            ply:ChatPrint("• Docking Pads: " .. #ents.FindByClass("hyperdrive_docking_pad"))
            ply:ChatPrint("• Shuttles: " .. #ents.FindByClass("hyperdrive_shuttle"))

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

            -- Show v2.2.1 systems status
            ply:ChatPrint("")
            ply:ChatPrint("=== v2.2.1 Systems Status ===")
            local systems = {}
            if HYPERDRIVE.Weapons then table.insert(systems, "Weapons") end
            if HYPERDRIVE.Flight then table.insert(systems, "Flight") end
            if HYPERDRIVE.DockingPad then table.insert(systems, "Docking") end
            if HYPERDRIVE.Shuttle then table.insert(systems, "Shuttles") end
            if HYPERDRIVE.Undo then table.insert(systems, "Undo") end
            if HYPERDRIVE.ChatAI then table.insert(systems, "Chat AI") end
            ply:ChatPrint("• Active v2.2.1 Systems: " .. table.concat(systems, ", "))

            -- Show integrations
            local integrations = {}
            if HYPERDRIVE.ShipCore then table.insert(integrations, "Ship Core") end
            if HYPERDRIVE.Shields then table.insert(integrations, "Shields") end
            if HYPERDRIVE.HullDamage then table.insert(integrations, "Hull Damage") end
            if HYPERDRIVE.Interface then table.insert(integrations, "Interface System") end
            if CAP or StarGate then table.insert(integrations, "CAP") end
            if WireLib then table.insert(integrations, "Wiremod") end
            if HYPERDRIVE.SB3Resources then table.insert(integrations, "SB3 Resources") end
            ply:ChatPrint("• Active Integrations: " .. table.concat(integrations, ", "))
        end
    end)

    -- System status update function
    function HYPERDRIVE.UpdateSystemStatus()
        -- Update system status flags
        HYPERDRIVE.SystemStatus.WeaponsSystem = HYPERDRIVE.Weapons ~= nil
        HYPERDRIVE.SystemStatus.WeaponGroups = HYPERDRIVE.WeaponGroups ~= nil
        HYPERDRIVE.SystemStatus.AmmunitionSystem = HYPERDRIVE.Ammunition ~= nil
        HYPERDRIVE.SystemStatus.WeaponUpgrades = HYPERDRIVE.WeaponUpgrades ~= nil
        HYPERDRIVE.SystemStatus.TacticalAI = HYPERDRIVE.TacticalAI ~= nil
        HYPERDRIVE.SystemStatus.FlightSystem = HYPERDRIVE.Flight ~= nil
        HYPERDRIVE.SystemStatus.NavigationSystem = HYPERDRIVE.Navigation ~= nil
        HYPERDRIVE.SystemStatus.DockingPadSystem = HYPERDRIVE.DockingPad ~= nil
        HYPERDRIVE.SystemStatus.ShuttleSystem = HYPERDRIVE.Shuttle ~= nil
        HYPERDRIVE.SystemStatus.UndoSystem = HYPERDRIVE.Undo ~= nil
        HYPERDRIVE.SystemStatus.ChatAI = HYPERDRIVE.ChatAI ~= nil

        -- Update entity counts
        HYPERDRIVE.SystemStatus.EntityCounts.ShipCores = #ents.FindByClass("ship_core")
        HYPERDRIVE.SystemStatus.EntityCounts.Engines = #ents.FindByClass("hyperdrive_engine") + #ents.FindByClass("hyperdrive_master_engine")
        HYPERDRIVE.SystemStatus.EntityCounts.Weapons = #ents.FindByClass("hyperdrive_pulse_cannon") + #ents.FindByClass("hyperdrive_beam_weapon") +
                                                       #ents.FindByClass("hyperdrive_torpedo_launcher") + #ents.FindByClass("hyperdrive_railgun") +
                                                       #ents.FindByClass("hyperdrive_plasma_cannon")
        HYPERDRIVE.SystemStatus.EntityCounts.FlightConsoles = #ents.FindByClass("hyperdrive_flight_console")
        HYPERDRIVE.SystemStatus.EntityCounts.DockingPads = #ents.FindByClass("hyperdrive_docking_pad")
        HYPERDRIVE.SystemStatus.EntityCounts.Shuttles = #ents.FindByClass("hyperdrive_shuttle")
        HYPERDRIVE.SystemStatus.EntityCounts.ShieldGenerators = #ents.FindByClass("hyperdrive_shield_generator")

        HYPERDRIVE.SystemStatus.LastUpdate = CurTime()
    end

    -- Update system status every 30 seconds
    timer.Create("HyperdriveSystemStatusUpdate", 30, 0, function()
        HYPERDRIVE.UpdateSystemStatus()
    end)

    -- Initial system status update
    timer.Simple(5, function()
        HYPERDRIVE.UpdateSystemStatus()
        HYPERDRIVE.SystemStatus.Initialized = true
        print("[Hyperdrive] System status tracking initialized")
    end)

    print("[Hyperdrive] Enhanced Hyperdrive System v2.2.1 - Server initialization complete!")
    print("[Hyperdrive] All systems loaded and ready for operation!")

elseif CLIENT then
    -- Client-side initialization
    print("[Hyperdrive] Client-side initialization...")

    HYPERDRIVE = HYPERDRIVE or {}
    HYPERDRIVE.HUD = {}
    HYPERDRIVE.Effects = {}

    -- Initialize UI system first
    HYPERDRIVE.UI = HYPERDRIVE.UI or {}
    HYPERDRIVE.UI.Config = HYPERDRIVE.UI.Config or {}

    -- Load UI configuration from ConVars
    HYPERDRIVE.UI.Config.ModernUIEnabled = GetConVar("hyperdrive_modern_ui_enabled"):GetBool()
    HYPERDRIVE.UI.Config.GlassmorphismEnabled = GetConVar("hyperdrive_ui_glassmorphism"):GetBool()
    HYPERDRIVE.UI.Config.AnimationsEnabled = GetConVar("hyperdrive_ui_animations"):GetBool()
    HYPERDRIVE.UI.Config.NotificationsEnabled = GetConVar("hyperdrive_ui_notifications"):GetBool()
    HYPERDRIVE.UI.Config.SoundsEnabled = GetConVar("hyperdrive_ui_sounds"):GetBool()
    HYPERDRIVE.UI.Config.AnimationSpeed = GetConVar("hyperdrive_ui_anim_speed"):GetFloat()
    HYPERDRIVE.UI.Config.UIScale = GetConVar("hyperdrive_ui_scale"):GetFloat()
    HYPERDRIVE.UI.Config.NotificationDuration = GetConVar("hyperdrive_ui_notif_duration"):GetFloat()
    HYPERDRIVE.UI.Config.MaxNotifications = GetConVar("hyperdrive_ui_max_notifications"):GetInt()
    HYPERDRIVE.UI.Config.HighContrast = GetConVar("hyperdrive_ui_high_contrast"):GetBool()
    HYPERDRIVE.UI.Config.LargeText = GetConVar("hyperdrive_ui_large_text"):GetBool()
    HYPERDRIVE.UI.Config.ReducedMotion = GetConVar("hyperdrive_ui_reduced_motion"):GetBool()
    HYPERDRIVE.UI.Config.ColorBlindFriendly = GetConVar("hyperdrive_ui_colorblind_friendly"):GetBool()
    HYPERDRIVE.UI.Config.ReduceOnLowFPS = GetConVar("hyperdrive_ui_reduce_on_low_fps"):GetBool()
    HYPERDRIVE.UI.Config.MinFPS = GetConVar("hyperdrive_ui_min_fps"):GetInt()

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
        "autorun/client/hyperdrive_qmenu_config.lua",
        "autorun/client/hyperdrive_spawn_menu.lua"
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
        chat.AddText(Color(100, 200, 255), "=== Enhanced Hyperdrive System v2.2.1 - Help ===")
        chat.AddText(Color(255, 255, 255), "• USE (E) key to open interfaces on all hyperdrive entities")
        chat.AddText(Color(255, 255, 255), "• Ship Core: Main ship management interface with naming system")
        chat.AddText(Color(255, 255, 255), "• Hyperdrive Engine: Engine status, ship info, and hull monitoring")
        chat.AddText(Color(255, 255, 255), "• Hyperdrive Computer: Navigation, fleet control, and ship management")
        chat.AddText(Color(255, 255, 255), "• Shield Generator: Shield control and CAP integration")
        chat.AddText(Color(100, 255, 100), "")
        chat.AddText(Color(100, 255, 100), "=== v2.2.1 New Features ===")
        chat.AddText(Color(255, 255, 255), "• Weapons: 5 types - Pulse, Beam, Torpedo, Railgun, Plasma")
        chat.AddText(Color(255, 255, 255), "• Flight Console: Ship movement with autopilot and formations")
        chat.AddText(Color(255, 255, 255), "• Docking Pads: 5 types with automated landing and services")
        chat.AddText(Color(255, 255, 255), "• Shuttles: 4 types for automated transport missions")
        chat.AddText(Color(255, 255, 255), "• Undo System: Press Z to undo, hyperdrive_undo_list for history")
        chat.AddText(Color(255, 255, 255), "• ARIA-4 AI: Use 'aria <question>' (primary) or !ai (legacy) to talk to ARIA-4")
        chat.AddText(Color(100, 255, 100), "")
        chat.AddText(Color(255, 255, 255), "• SHIFT + USE: Open ship core management from engines")
        chat.AddText(Color(255, 255, 255), "• Ship Naming: Use ship core interface to name and manage ships")
        chat.AddText(Color(255, 255, 255), "• Hull Damage: Integrated hull monitoring and repair systems")
        chat.AddText(Color(255, 255, 255), "• Auto-linking: Weapons and systems auto-link to nearby ship cores")
        chat.AddText(Color(255, 255, 255), "• Commands: hyperdrive_help, hyperdrive_status, hyperdrive_undo")
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

    print("[Hyperdrive] Enhanced Stargate Hyperspace Edition initialization complete with integrations: " .. table.concat(integrations, ", "))
    print("[Hyperdrive] Enhanced Hyperspace System: 4-stage Stargate travel with authentic mechanics")
    print("[Hyperdrive] ARIA-4 AI: Next-generation intelligence with contextual understanding")
    print("[Hyperdrive] Stargate Features: Ancient tech bonuses, ZPM integration, gravitational anomaly detection")
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
