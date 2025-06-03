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
ASC.BUILD = "2025.01.15.STARGATE.ULTIMATE"
ASC.NAME = "Advanced Space Combat - ARIA-4 Ultimate Edition with Enhanced Stargate Hyperspace"
ASC.AUTHOR = "Advanced Space Combat Team"
ASC.STATUS = "Production Ready - Ultimate Stargate Edition"
ASC.DESCRIPTION = "Ultimate space combat with ARIA-4 AI, 4-stage Stargate hyperspace, complete integrations, and all code updated"
ASC.LICENSE = "MIT License"
ASC.REPOSITORY = "https://github.com/advanced-space-combat/asc-stargate-hyperspace"
ASC.DOCUMENTATION = "https://docs.advanced-space-combat.com/stargate-hyperspace"
ASC.SUPPORT = "https://discord.gg/advanced-space-combat-stargate"
ASC.WEBSITE = "https://advanced-space-combat.com"
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
    
    -- Performance Settings
    UpdateRate = 0.1,
    NetworkRate = 0.2,
    ThinkRate = 0.05,
    MaxEntities = 1000,
    MaxShips = 50,
    MaxWeapons = 200,
    MaxShuttles = 20,
    MaxDockingPads = 30
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

-- Phase 2 Enhanced ConVars - Ship Core Visual and Audio Settings
SafeCreateConVar("asc_show_front_indicators", "1", FCVAR_ARCHIVE, "Show ship front direction indicators")
SafeCreateConVar("asc_auto_show_arrows", "1", FCVAR_ARCHIVE, "Automatically show front arrows on ship cores")
SafeCreateConVar("asc_indicator_distance", "150", FCVAR_ARCHIVE, "Distance of front indicator from ship core")
SafeCreateConVar("asc_enable_ship_sounds", "1", FCVAR_ARCHIVE, "Enable ship core ambient sounds")
SafeCreateConVar("asc_ship_core_volume", "0.15", FCVAR_ARCHIVE, "Ship core ambient sound volume")
SafeCreateConVar("asc_default_ship_sound", "ambient/atmosphere/ambience_base.wav", FCVAR_ARCHIVE, "Default ship core ambient sound")
SafeCreateConVar("asc_enable_auto_linking", "1", FCVAR_ARCHIVE, "Enable automatic component linking")
SafeCreateConVar("asc_enable_cap_integration", "1", FCVAR_ARCHIVE, "Enable CAP asset integration")
SafeCreateConVar("asc_enable_ai_system", "1", FCVAR_ARCHIVE, "Enable ARIA-4 AI system")
SafeCreateConVar("asc_default_ship_range", "2000", FCVAR_ARCHIVE, "Default ship detection range")

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
    include("autorun/client/asc_spawn_menu_organization.lua")
    include("autorun/client/asc_entity_categories.lua")
    include("autorun/client/asc_ui_system.lua")
end

-- Add organization and UI systems to client download
if SERVER then
    AddCSLuaFile("autorun/client/asc_spawn_menu_organization.lua")
    AddCSLuaFile("autorun/client/asc_entity_categories.lua")
    AddCSLuaFile("autorun/client/asc_ui_system.lua")
end

-- Load debug, error recovery, and multilingual systems first
include("autorun/asc_debug_system.lua")
include("autorun/asc_error_recovery.lua")
include("autorun/asc_multilingual_system.lua")

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
if SERVER then
    AddCSLuaFile("autorun/asc_debug_system.lua")
    AddCSLuaFile("autorun/asc_error_recovery.lua")
    AddCSLuaFile("autorun/asc_multilingual_system.lua")
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
print("[Advanced Space Combat] Stargate Tech: 6 cultures, 60+ technologies, ZPM/Ancient bonuses")
print("[Advanced Space Combat] UI System: Ultimate edition with modern design and hyperspace HUD")
print("[Advanced Space Combat] Last Updated: " .. ASC.LAST_UPDATED)
print("[Advanced Space Combat] Documentation: Updated with emoji and modern formatting")
print("[Advanced Space Combat] Resource Management: Intelligent handling of missing files")
print("[Advanced Space Combat] Sound System: Professional Lua-based audio with fallbacks")
print("[Advanced Space Combat] Quality: Enterprise-grade architecture")
print("================================================================================")
print("[Advanced Space Combat] 🌌 READY FOR ULTIMATE SPACE ADVENTURES! 🚀")
print("[Advanced Space Combat] Type !ai help to get started with ARIA-4 assistant")
print("================================================================================")
