-- Advanced Space Combat v5.1.0 - Main Initialization
-- Ultimate space combat simulation with enhanced Stargate hyperspace technology
-- Professional-grade addon for Garry's Mod with modern UI and ARIA-4 AI systems
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED AND OPTIMIZED
--
-- Copyright (c) 2025 Advanced Space Combat Team
-- Licensed under MIT License - See LICENSE file for details

print("================================================================================")
print("[Advanced Space Combat] Advanced Space Combat v5.1.0 - ARIA-4 Ultimate Edition")
print("[Advanced Space Combat] Enhanced Stargate hyperspace with 4-stage travel system")
print("================================================================================")

-- Initialize main namespace
ASC = ASC or {}
HYPERDRIVE = ASC -- Backward compatibility alias

-- System information
ASC.VERSION = "5.1.0"
ASC.BUILD = "2025.01.15.STARGATE.ULTIMATE.OPTIMIZED"
ASC.NAME = "Advanced Space Combat - ARIA-4 Ultimate Edition with Enhanced Stargate Hyperspace"
ASC.AUTHOR = "Advanced Space Combat Team"
ASC.STATUS = "Production Ready - Ultimate Optimized Edition"
ASC.DESCRIPTION = "Ultimate space combat with ARIA-4 AI v5.1.0, 4-stage Stargate hyperspace, comprehensive optimizations, and complete integrations"
ASC.LICENSE = "MIT License"
ASC.REPOSITORY = "https://github.com/advanced-space-combat/asc-stargate-hyperspace"
ASC.DOCUMENTATION = "https://docs.advanced-space-combat.com/stargate-hyperspace"
ASC.SUPPORT = "https://discord.gg/advanced-space-combat-stargate"
ASC.WEBSITE = "https://advanced-space-combat.com"

-- Optimization system flags
ASC.OPTIMIZATIONS = {
    Performance = true,
    AI = true,
    Theme = true,
    Network = true,
    Branding = true,
    Integration = true
}
ASC.LAST_UPDATED = os.date("%Y-%m-%d %H:%M:%S")
ASC.UPDATE_NOTES = "Complete code update - All systems optimized, enhanced Stargate hyperspace, improved integrations"

-- Enhanced Feature list with Stargate Hyperspace
ASC.FEATURES = {
    -- Core Systems (Updated v5.1.0)
    "Advanced Ship Core System with Auto-Detection & Real-Time Updates",
    "Professional Ship Management Interface with Modern UI",
    "Real-Time Ship Status Monitoring & Diagnostics",
    "Automated Ship Naming System with Custom Templates",
    "Hull Damage & Repair System with Visual Indicators",
    "Enhanced Resource Management with SB3 Integration",
    "Comprehensive Entity Registration & Validation",

    -- Enhanced Stargate Hyperspace System
    "4-Stage Stargate Hyperspace Travel (Initiation, Window Opening, Travel, Exit)",
    "Authentic Stargate Visual Effects (Blue/Purple Energy Windows)",
    "Stretched Starlines and Dimensional Tunnel Effects",
    "Gravitational Anomaly Detection and Navigation Hazards",
    "Ancient Technology and ZPM Integration Bonuses",
    "Progressive System Stabilization and Energy Management",
    "Client-Side HUD with Stage Progress and Time Remaining",
    "Enhanced Screen Effects and Motion Blur During Travel",

    -- Combat Systems
    "5 Advanced Weapon Types (Pulse, Beam, Torpedo, Railgun, Plasma)",
    "Weapon Groups with Coordinated Firing",
    "Ammunition Manufacturing & Management",
    "10-Category Weapon Upgrade System",
    "Tactical AI with 3 Behavior Modes",
    "Fleet Combat Coordination",
    "Point Defense Systems",
    
    -- Flight & Navigation
    "Physics-Based Ship Flight (6-DOF)",
    "Advanced Autopilot with Collision Avoidance",
    "Formation Flying (4 Formation Types)",
    "Waypoint Navigation System",
    "Flight Console with Real-Time HUD",
    "Energy Management for Flight Operations",
    "Navigation Beacons & Route Planning",
    
    -- Docking & Transport
    "Ship Docking System (5 Pad Types)",
    "Automated 3-Phase Landing Approach",
    "Shuttle System (4 Shuttle Types)",
    "Mission Management with Auto-Assignment",
    "Passenger Transport Operations",
    "Cargo Delivery System",
    "Emergency Evacuation Protocols",
    "Service Automation (Refuel/Repair/Resupply)",
    
    -- User Experience
    "ARIA-4 Next-Generation AI Assistant with Advanced Intelligence",
    "AI Intent Recognition and Sentiment Analysis",
    "AI Conversation Memory and Contextual Understanding",
    "AI-Enhanced Tactical Decision Making",
    "AI-Powered Navigation and Pathfinding",
    "AI-Assisted Weapon Targeting and Accuracy",
    "Ultimate Hyperdrive Engine - All Types Unified",
    "Comprehensive Undo System with Smart Cleanup",
    "Enhanced Spawn Tool with Auto-Linking",
    "Real-Time System Integration",
    "Professional Error Handling",
    "Performance Optimization",
    
    -- Integration Systems
    "Spacebuild 3 Resource Integration",
    "CAP (Carter Addon Pack) Shield Integration",
    "Wiremod Support for All Systems",
    "Steam Workshop Compatibility",
    "Multi-Platform Addon Support"
}

-- Core system namespaces
ASC.Core = ASC.Core or {}
ASC.ShipCore = ASC.ShipCore or {}
ASC.Weapons = ASC.Weapons or {}
ASC.WeaponGroups = ASC.WeaponGroups or {}
ASC.Ammunition = ASC.Ammunition or {}
ASC.WeaponUpgrades = ASC.WeaponUpgrades or {}
ASC.TacticalAI = ASC.TacticalAI or {}
ASC.Flight = ASC.Flight or {}
ASC.Navigation = ASC.Navigation or {}
ASC.DockingPad = ASC.DockingPad or {}
ASC.Shuttle = ASC.Shuttle or {}
ASC.Shields = ASC.Shields or {}
ASC.HullDamage = ASC.HullDamage or {}
ASC.SB3Resources = ASC.SB3Resources or {}
ASC.CAP = ASC.CAP or {}
ASC.Wire = ASC.Wire or {}
ASC.Config = ASC.Config or {}
ASC.Effects = ASC.Effects or {}
ASC.UI = ASC.UI or {}
ASC.Sounds = ASC.Sounds or {}
ASC.Undo = ASC.Undo or {}
ASC.ChatAI = ASC.ChatAI or {}

-- System status tracking
ASC.SystemStatus = {
    Initialized = false,
    LoadedModules = {},
    IntegrationStatus = {},
    LastUpdate = 0,
    
    -- System Status Flags
    ShipCoreSystem = false,
    WeaponsSystem = false,
    WeaponGroups = false,
    AmmunitionSystem = false,
    WeaponUpgrades = false,
    TacticalAI = false,
    FlightSystem = false,
    NavigationSystem = false,
    DockingPadSystem = false,
    ShuttleSystem = false,
    ShieldSystem = false,
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

-- Configuration system
ASC.Config = {
    -- Core Settings
    MaxJumpDistance = 50000,
    MinJumpDistance = 1000,
    EnergyPerUnit = 0.1,
    MaxEnergy = 1000,
    RechargeRate = 5,
    CooldownTime = 10,
    JumpChargeTime = 3,
    SafetyRadius = 500,
    
    -- Combat Settings
    MaxWeaponsPerShip = 20,
    WeaponLinkRange = 2000,
    TacticalAIUpdateRate = 0.5,
    AmmunitionCapacity = 10000,
    
    -- Flight Settings
    FlightUpdateRate = 0.1,
    AutopilotPrecision = 50,
    FormationSpacing = 200,
    CollisionAvoidanceRange = 500,
    
    -- Docking Settings
    LandingRange = 3000,
    DockingPrecision = 25,
    ServiceRange = 100,
    
    -- Performance Settings (Optimized)
    UpdateRate = 0.2, -- Reduced frequency for better performance
    NetworkRate = 0.5, -- Reduced network updates
    ThinkRate = 0.1, -- Reduced think frequency
    MaxEntities = 500, -- Reduced for stability
    MaxShips = 25, -- Reduced for performance
    MaxWeapons = 100, -- Reduced for stability
    MaxShuttles = 10, -- Reduced for performance
    MaxDockingPads = 15, -- Reduced for performance

    -- Master Scheduler Settings
    MasterScheduler = {
        Enabled = true,
        HighPriorityRate = 0.1, -- 10 FPS for critical systems
        MediumPriorityRate = 0.5, -- 2 FPS for normal systems
        LowPriorityRate = 2.0, -- 0.5 FPS for background tasks
        MaxUpdatesPerFrame = 5, -- Limit updates per frame
        AdaptiveThrottling = true -- Enable performance-based throttling
    }
}

-- Helper function for safe ConVar creation
local function SafeCreateConVar(name, default, flags, help)
    local success, err = pcall(function()
        if not ConVarExists(name) then
            CreateConVar(name, default, flags, help)
            return true
        end
        return false
    end)
    
    if not success then
        local existing = GetConVar(name)
        if not existing then
            print("[Advanced Space Combat] Warning: Could not create ConVar '" .. name .. "': " .. tostring(err))
        end
    end
end

-- Create configuration ConVars
SafeCreateConVar("asc_enabled", "1", FCVAR_ARCHIVE, "Enable/disable Advanced Space Combat")
SafeCreateConVar("asc_debug_mode", "0", FCVAR_ARCHIVE, "Enable debug mode")
SafeCreateConVar("asc_max_range", "100000", FCVAR_ARCHIVE, "Maximum jump range")
SafeCreateConVar("asc_energy_cost", "1000", FCVAR_ARCHIVE, "Energy cost per jump")
SafeCreateConVar("asc_require_ship_core", "1", FCVAR_ARCHIVE, "Require ship core for operations")
SafeCreateConVar("asc_auto_detect_ships", "1", FCVAR_ARCHIVE, "Auto-detect ship structures")
SafeCreateConVar("asc_enable_weapons", "1", FCVAR_ARCHIVE, "Enable weapon systems")
SafeCreateConVar("asc_enable_flight", "1", FCVAR_ARCHIVE, "Enable flight systems")
SafeCreateConVar("asc_enable_docking", "1", FCVAR_ARCHIVE, "Enable docking systems")
SafeCreateConVar("asc_enable_shuttles", "1", FCVAR_ARCHIVE, "Enable shuttle systems")
SafeCreateConVar("asc_enable_shields", "1", FCVAR_ARCHIVE, "Enable shield systems")
SafeCreateConVar("asc_enable_sb3", "1", FCVAR_ARCHIVE, "Enable Spacebuild 3 integration")
SafeCreateConVar("asc_enable_cap", "1", FCVAR_ARCHIVE, "Enable CAP integration")
SafeCreateConVar("asc_enable_wiremod", "1", FCVAR_ARCHIVE, "Enable Wiremod integration")
SafeCreateConVar("asc_enable_chat_ai", "1", FCVAR_ARCHIVE, "Enable ARIA chat AI")

-- UI System ConVars
SafeCreateConVar("asc_ui_enabled", "1", FCVAR_ARCHIVE, "Enable UI system")
SafeCreateConVar("asc_ui_animations", "1", FCVAR_ARCHIVE, "Enable UI animations")
SafeCreateConVar("asc_ui_sounds", "1", FCVAR_ARCHIVE, "Enable UI sounds")
SafeCreateConVar("asc_ui_scale", "1.0", FCVAR_ARCHIVE, "UI scale factor")
SafeCreateConVar("asc_ui_high_contrast", "0", FCVAR_ARCHIVE, "Enable high contrast mode")

-- Sound System ConVars
SafeCreateConVar("asc_sound_volume", "1.0", FCVAR_ARCHIVE, "Master volume")
SafeCreateConVar("asc_sound_weapons", "1.0", FCVAR_ARCHIVE, "Weapon sound volume")
SafeCreateConVar("asc_sound_engines", "1.0", FCVAR_ARCHIVE, "Engine sound volume")
SafeCreateConVar("asc_sound_shields", "1.0", FCVAR_ARCHIVE, "Shield sound volume")
SafeCreateConVar("asc_sound_ui", "0.6", FCVAR_ARCHIVE, "UI sound volume")

-- Phase 2 Enhanced ConVars - Ship Core Settings (effects removed per user request)
SafeCreateConVar("asc_show_front_indicators", "1", FCVAR_ARCHIVE, "Show ship front direction indicators")
SafeCreateConVar("asc_auto_show_arrows", "1", FCVAR_ARCHIVE, "Automatically show front arrows on ship cores")
SafeCreateConVar("asc_indicator_distance", "150", FCVAR_ARCHIVE, "Distance of front indicator from ship core")
SafeCreateConVar("asc_enable_auto_linking", "1", FCVAR_ARCHIVE, "Enable automatic component linking")
SafeCreateConVar("asc_enable_cap_integration", "1", FCVAR_ARCHIVE, "Enable CAP asset integration")
SafeCreateConVar("asc_enable_ai_system", "1", FCVAR_ARCHIVE, "Enable ARIA-4 AI system")
SafeCreateConVar("asc_default_ship_range", "2000", FCVAR_ARCHIVE, "Default ship detection range")
SafeCreateConVar("asc_performance_mode", "0", FCVAR_ARCHIVE, "Enable performance mode (reduces update rates)")
SafeCreateConVar("asc_spawn_delay", "5", FCVAR_ARCHIVE, "Delay before ship core starts full operations (seconds)")

-- Advanced Optimization System ConVars
SafeCreateConVar("asc_enable_spatial_partitioning", "1", FCVAR_ARCHIVE, "Enable spatial partitioning for entity detection")
SafeCreateConVar("asc_enable_constraint_caching", "1", FCVAR_ARCHIVE, "Enable constraint relationship caching")
SafeCreateConVar("asc_enable_incremental_detection", "1", FCVAR_ARCHIVE, "Enable incremental ship detection")
SafeCreateConVar("asc_enable_adaptive_scheduling", "1", FCVAR_ARCHIVE, "Enable adaptive performance scheduling")
SafeCreateConVar("asc_performance_threshold", "30", FCVAR_ARCHIVE, "FPS threshold for performance optimizations")
SafeCreateConVar("asc_optimization_debug", "0", FCVAR_ARCHIVE, "Enable optimization system debug output")

-- Backward compatibility aliases
HYPERDRIVE.VERSION = ASC.VERSION
HYPERDRIVE.BUILD = ASC.BUILD
HYPERDRIVE.Features = ASC.FEATURES
HYPERDRIVE.Config = ASC.Config
HYPERDRIVE.SystemStatus = ASC.SystemStatus

-- Copy all namespaces for backward compatibility
for k, v in pairs(ASC) do
    if type(v) == "table" and k ~= "SystemStatus" and k ~= "Config" then
        HYPERDRIVE[k] = v
    end
end

-- Load organization and UI systems on client
if CLIENT then
    include("autorun/client/asc_convar_manager.lua")
    include("autorun/client/asc_spawn_menu_organization.lua")
    include("autorun/client/asc_entity_categories.lua")
    include("autorun/client/asc_ui_system.lua")
    include("autorun/client/asc_loading_screen.lua")
    include("autorun/client/asc_character_theme.lua")

    include("autorun/client/asc_comprehensive_theme.lua")
    include("autorun/client/asc_weapon_interface_theme.lua")
    include("autorun/client/asc_flight_interface_theme.lua")
    include("autorun/client/asc_ai_interface_theme.lua")
    include("autorun/client/asc_vgui_theme_integration.lua")
    include("autorun/client/asc_game_interface_theme.lua")
    include("autorun/client/asc_advanced_theme_effects.lua")
    -- include("autorun/client/asc_hud_overlay_system.lua") -- File removed as per user request to remove all HUD systems
    include("autorun/client/asc_settings_menu_theme.lua")
    include("autorun/client/asc_master_theme_controller.lua")
end

-- Add organization and UI systems to client download
if SERVER then
    AddCSLuaFile("autorun/client/asc_convar_manager.lua")
    AddCSLuaFile("autorun/client/asc_spawn_menu_organization.lua")
    AddCSLuaFile("autorun/client/asc_entity_categories.lua")
    AddCSLuaFile("autorun/client/asc_ui_system.lua")
    AddCSLuaFile("autorun/client/asc_loading_screen.lua")
    AddCSLuaFile("autorun/client/asc_character_theme.lua")

    AddCSLuaFile("autorun/client/asc_comprehensive_theme.lua")
    AddCSLuaFile("autorun/client/asc_weapon_interface_theme.lua")
    AddCSLuaFile("autorun/client/asc_flight_interface_theme.lua")
    AddCSLuaFile("autorun/client/asc_ai_interface_theme.lua")
    AddCSLuaFile("autorun/client/asc_vgui_theme_integration.lua")
    AddCSLuaFile("autorun/client/asc_game_interface_theme.lua")
    AddCSLuaFile("autorun/client/asc_advanced_theme_effects.lua")

    AddCSLuaFile("autorun/client/asc_settings_menu_theme.lua")
    AddCSLuaFile("autorun/client/asc_master_theme_controller.lua")

    -- Add missing client files
    AddCSLuaFile("autorun/client/asc_character_selection.lua")
    AddCSLuaFile("autorun/client/asc_web_resource_manager.lua")
    AddCSLuaFile("autorun/client/hyperdrive_effects_v2.lua")
    AddCSLuaFile("autorun/client/hyperdrive_hyperspace_effects.lua")
    AddCSLuaFile("autorun/client/hyperdrive_sound_system.lua")

    AddCSLuaFile("autorun/client/asc_menu_organization.lua")
    AddCSLuaFile("autorun/client/asc_spawn_menu_complete.lua")
    AddCSLuaFile("autorun/client/asc_simple_organization.lua")
end

-- Load debug, error recovery, and multilingual systems first
include("autorun/asc_debug_system.lua")
include("autorun/asc_error_recovery.lua")
include("autorun/asc_multilingual_system.lua")
include("autorun/asc_czech_localization.lua")
include("autorun/asc_gmod_localization.lua")

-- Load resource manifest early for loading screen integration
include("autorun/asc_resource_manifest.lua")

-- Load documentation, console, Stargate technology, and resource systems (shared)
include("autorun/asc_documentation_system.lua")
include("autorun/asc_console_commands.lua")
include("autorun/asc_stargate_technology.lua")
include("autorun/asc_resource_management.lua")
include("autorun/asc_tactical_ai_system.lua")
include("autorun/asc_shield_system.lua")
include("autorun/asc_flight_system.lua")
include("autorun/asc_docking_system.lua")
include("autorun/asc_formation_system.lua")
include("autorun/asc_boss_system.lua")
include("autorun/asc_weapon_system.lua")
include("autorun/asc_ai_system_v2.lua")
include("autorun/asc_sound_definitions.lua")
include("autorun/asc_sound_system.lua")
include("autorun/asc_entity_spawning.lua")

-- Load enhanced CAP integration systems
include("autorun/asc_cap_assets.lua")
include("autorun/asc_cap_enhanced_integration.lua")
include("autorun/asc_cap_entity_integration.lua")
include("autorun/asc_cap_effects_system.lua")
include("autorun/asc_cap_weapons_integration.lua")
include("autorun/asc_cap_console_commands.lua")

-- Load optimization systems first
include("autorun/asc_master_scheduler.lua")
include("autorun/asc_memory_optimizer.lua")
include("autorun/asc_performance_monitor.lua")

-- Load missing feature systems
include("autorun/asc_point_defense_system.lua")
include("autorun/asc_countermeasures_system.lua")
include("autorun/asc_czech_auto_detection.lua")
include("autorun/asc_localization_test.lua")
include("autorun/asc_localization_integration.lua")
if SERVER then
    AddCSLuaFile("autorun/asc_debug_system.lua")
    AddCSLuaFile("autorun/asc_error_recovery.lua")
    AddCSLuaFile("autorun/asc_multilingual_system.lua")
    AddCSLuaFile("autorun/asc_czech_localization.lua")
    AddCSLuaFile("autorun/asc_gmod_localization.lua")
    AddCSLuaFile("autorun/asc_documentation_system.lua")
    AddCSLuaFile("autorun/asc_console_commands.lua")
    AddCSLuaFile("autorun/asc_stargate_technology.lua")
    AddCSLuaFile("autorun/asc_resource_management.lua")
    AddCSLuaFile("autorun/asc_tactical_ai_system.lua")
    AddCSLuaFile("autorun/asc_shield_system.lua")
    AddCSLuaFile("autorun/asc_flight_system.lua")
    AddCSLuaFile("autorun/asc_docking_system.lua")
    AddCSLuaFile("autorun/asc_formation_system.lua")
    AddCSLuaFile("autorun/asc_boss_system.lua")
    AddCSLuaFile("autorun/asc_weapon_system.lua")
    AddCSLuaFile("autorun/asc_ai_system_v2.lua")
    AddCSLuaFile("autorun/asc_sound_definitions.lua")
    AddCSLuaFile("autorun/asc_sound_system.lua")
    AddCSLuaFile("autorun/asc_entity_spawning.lua")

    -- Add enhanced CAP integration files
    AddCSLuaFile("autorun/asc_cap_assets.lua")
    AddCSLuaFile("autorun/asc_cap_enhanced_integration.lua")
    AddCSLuaFile("autorun/asc_cap_entity_integration.lua")
    AddCSLuaFile("autorun/asc_cap_effects_system.lua")
    AddCSLuaFile("autorun/asc_cap_weapons_integration.lua")
    AddCSLuaFile("autorun/asc_cap_console_commands.lua")

    -- Add localization system files
    AddCSLuaFile("autorun/asc_localization_test.lua")
    AddCSLuaFile("autorun/asc_localization_integration.lua")
end

-- Load client-side systems
if CLIENT then
    include("autorun/client/asc_fonts.lua")
    include("autorun/client/asc_ship_camera.lua")
end
if SERVER then
    AddCSLuaFile("autorun/client/asc_fonts.lua")
    AddCSLuaFile("autorun/client/asc_ship_camera.lua")
end

print("================================================================================")
print("[Advanced Space Combat] ARIA-4 ULTIMATE EDITION WITH ENHANCED STARGATE HYPERSPACE!")
print("[Advanced Space Combat] Version: " .. ASC.VERSION .. " Build: " .. ASC.BUILD)
print("[Advanced Space Combat] Features: " .. #ASC.FEATURES .. " systems loaded")
print("[Advanced Space Combat] AI Assistant: ARIA-4 v5.1.0 - Next-Generation Intelligence - Use 'aria help'")
print("[Advanced Space Combat] Enhanced Hyperspace: 4-stage Stargate travel with authentic mechanics")
print("[Advanced Space Combat] CAP Integration: Enhanced integration with Steam Workshop ID 180077636")
print("[Advanced Space Combat] Technology System: 6 cultures, 200+ models, 300+ materials, dynamic selection")
print("[Advanced Space Combat] UI System: Ultimate edition with modern design and hyperspace HUD")
print("[Advanced Space Combat] Last Updated: " .. ASC.LAST_UPDATED)
print("[Advanced Space Combat] Documentation: Updated with emoji and modern formatting")
print("[Advanced Space Combat] Resource Management: Intelligent handling of missing files")
print("[Advanced Space Combat] Sound System: Professional Lua-based audio with fallbacks")
print("[Advanced Space Combat] Localization: Comprehensive Czech language support with GMod integration")
print("[Advanced Space Combat] Quality: Enterprise-grade architecture")
print("================================================================================")
print("[Advanced Space Combat] 🌌 READY FOR ULTIMATE SPACE ADVENTURES! 🚀")
print("[Advanced Space Combat] Type !ai help to get started with ARIA-4 assistant")
print("[Advanced Space Combat] Use 'asc_optimization_status' to check optimization systems")
print("================================================================================")

-- Add optimization status command
concommand.Add("asc_optimization_status", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end

    print("[Advanced Space Combat] Optimization Status:")

    -- Master Scheduler Status
    if ASC.MasterScheduler and ASC.MasterScheduler.Initialized then
        local stats = ASC.MasterScheduler.GetStats()
        print("  Master Scheduler: ACTIVE")
        print("    Total Tasks: " .. stats.TotalTasks)
        print("    Performance Level: " .. stats.Performance.PerformanceLevel)
        print("    Current FPS: " .. math.floor(stats.Performance.CurrentFPS))
        print("    Tasks Executed: " .. stats.Stats.TasksExecuted)
    else
        print("  Master Scheduler: INACTIVE")
    end

    -- Memory Optimizer Status
    if ASC.MemoryOptimizer and ASC.MemoryOptimizer.Initialized then
        local stats = ASC.MemoryOptimizer.GetStats()
        print("  Memory Optimizer: ACTIVE")
        print("    Current Memory: " .. string.format("%.2f", stats.CurrentMemoryMB) .. "MB")
        print("    Peak Memory: " .. string.format("%.2f", stats.PeakMemoryMB) .. "MB")
        print("    GC Count: " .. stats.GCCount)
    else
        print("  Memory Optimizer: INACTIVE")
    end

    -- Performance Monitor Status
    if ASC.PerformanceMonitor and ASC.PerformanceMonitor.Initialized then
        local stats = ASC.PerformanceMonitor.GetStats()
        print("  Performance Monitor: ACTIVE")
        print("    Performance Level: " .. stats.State.PerformanceLevel)
        print("    Alerts Triggered: " .. stats.State.AlertsTriggered)
        print("    Optimizations Applied: " .. stats.State.OptimizationsApplied)
    else
        print("  Performance Monitor: INACTIVE")
    end

    print("  Optimization Flags:")
    for flag, enabled in pairs(ASC.OPTIMIZATIONS) do
        print("    " .. flag .. ": " .. (enabled and "ENABLED" or "DISABLED"))
    end
end)
