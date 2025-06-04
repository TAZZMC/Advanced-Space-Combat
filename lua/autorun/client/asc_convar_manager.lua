-- Advanced Space Combat - ConVar Manager v1.0.0
-- Centralized ConVar creation and management to prevent conflicts

print("[Advanced Space Combat] ConVar Manager v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.ConVarManager = ASC.ConVarManager or {}

-- ConVar registry to track created ConVars
ASC.ConVarManager.Registry = {}

-- ConVar definitions
ASC.ConVarManager.ConVarDefinitions = {
    -- VGUI Theme Integration
    ["asc_vgui_theme_enabled"] = {default = "1", description = "Enable VGUI auto-theming"},
    ["asc_vgui_theme_all"] = {default = "1", description = "Theme all VGUI elements (not just ASC)"},
    ["asc_vgui_performance_mode"] = {default = "1", description = "Enable performance optimizations"},
    ["asc_vgui_safe_mode"] = {default = "1", description = "Enable safe mode with error protection"},
    
    -- Game Interface Theme
    ["asc_theme_spawn_menu"] = {default = "1", description = "Enable spawn menu theming"},
    ["asc_theme_context_menu"] = {default = "1", description = "Enable context menu theming"},
    ["asc_theme_chat"] = {default = "1", description = "Enable chat theming"},
    ["asc_theme_console"] = {default = "1", description = "Enable console theming"},
    ["asc_theme_notifications"] = {default = "1", description = "Enable notification theming"},
    ["asc_theme_scoreboard"] = {default = "1", description = "Enable scoreboard theming"},
    ["asc_game_theme_enabled"] = {default = "1", description = "Enable game interface theming"},
    ["asc_game_theme_glassmorphism"] = {default = "1", description = "Enable glassmorphism effects"},
    ["asc_game_theme_animations"] = {default = "1", description = "Enable game theme animations"},
    ["asc_game_theme_glow"] = {default = "1", description = "Enable glow effects"},
    
    -- Advanced Effects
    ["asc_effects_enabled"] = {default = "1", description = "Enable advanced visual effects"},
    ["asc_effects_particles"] = {default = "1", description = "Enable particle effects"},
    ["asc_effects_holograms"] = {default = "1", description = "Enable holographic effects"},
    ["asc_effects_scanlines"] = {default = "1", description = "Enable scanline effects"},
    ["asc_effects_energy"] = {default = "1", description = "Enable energy effects"},
    ["asc_effects_quality"] = {default = "high", description = "Effect quality (low/medium/high/ultra)"},
    ["asc_effects_performance"] = {default = "1", description = "Enable performance optimizations"},
    
    -- HUD Overlay
    ["asc_hud_targeting"] = {default = "1", description = "Enable targeting system"},
    ["asc_hud_radar"] = {default = "1", description = "Enable radar overlay"},
    ["asc_hud_threats"] = {default = "1", description = "Enable threat indicators"},
    ["asc_hud_navigation"] = {default = "1", description = "Enable navigation overlay"},
    ["asc_hud_crosshair"] = {default = "1", description = "Enable enhanced crosshair"},
    ["asc_hud_damage"] = {default = "1", description = "Enable damage indicators"},
    ["asc_hud_shields"] = {default = "1", description = "Enable shield visualizer"},
    ["asc_hud_overlay_alpha"] = {default = "0.8", description = "HUD overlay transparency"},
    
    -- Settings Menu Theme
    ["asc_settings_theme_enabled"] = {default = "1", description = "Enable settings menu theming"},
    ["asc_settings_animations"] = {default = "1", description = "Enable settings menu animations"},
    ["asc_settings_glow"] = {default = "1", description = "Enable settings menu glow effects"},
    ["asc_settings_gradients"] = {default = "1", description = "Enable settings menu gradients"},
    
    -- Master Theme Controller
    ["asc_master_theme_enabled"] = {default = "1", description = "Enable master theme system"},
    ["asc_theme_preset"] = {default = "Standard", description = "Theme preset (Minimal/Standard/Full/Performance)"},
    ["asc_theme_intensity"] = {default = "1.0", description = "Global theme intensity (0.0-1.0)"},
    ["asc_theme_performance_mode"] = {default = "0", description = "Enable performance mode"},
    ["asc_theme_auto_performance"] = {default = "1", description = "Automatically adjust for performance"},
    
    -- Player HUD Theme
    ["asc_hud_enabled"] = {default = "1", description = "Enable custom HUD"},
    ["asc_hud_health_bar"] = {default = "1", description = "Enable health bar"},
    ["asc_hud_armor_bar"] = {default = "1", description = "Enable armor bar"},
    ["asc_hud_ammo_display"] = {default = "1", description = "Enable ammo display"},
    ["asc_hud_crosshair_enabled"] = {default = "1", description = "Enable custom crosshair"},
    
    -- Comprehensive Theme
    ["asc_theme_entity_interfaces"] = {default = "1", description = "Enable entity interface theming"},
    ["asc_theme_tool_panels"] = {default = "1", description = "Enable tool panel theming"},
    ["asc_theme_sounds"] = {default = "1", description = "Enable theme sounds"},
    
    -- Character Theme
    ["asc_character_theme_enabled"] = {default = "1", description = "Enable character theming"},
    ["asc_character_models"] = {default = "1", description = "Enable custom character models"},
    ["asc_character_sounds"] = {default = "1", description = "Enable character sounds"}
}

-- Safe ConVar creation function
function ASC.ConVarManager.CreateConVar(name, defaultValue, description)
    -- Check if ConVar already exists
    if ASC.ConVarManager.Registry[name] then
        return ASC.ConVarManager.Registry[name]
    end
    
    -- Check if ConVar exists in engine
    local existing = GetConVar(name)
    if existing then
        ASC.ConVarManager.Registry[name] = existing
        return existing
    end
    
    -- Create new ConVar
    local success, convar = pcall(function()
        return CreateClientConVar(name, defaultValue, true, false, description)
    end)
    
    if success and convar then
        ASC.ConVarManager.Registry[name] = convar
        print("[Advanced Space Combat] Created ConVar: " .. name .. " = " .. defaultValue)
        return convar
    else
        print("[Advanced Space Combat] Failed to create ConVar: " .. name)
        return nil
    end
end

-- Initialize all ConVars
function ASC.ConVarManager.InitializeAllConVars()
    print("[Advanced Space Combat] Initializing all ConVars...")
    
    local created = 0
    local skipped = 0
    
    for name, def in pairs(ASC.ConVarManager.ConVarDefinitions) do
        local convar = ASC.ConVarManager.CreateConVar(name, def.default, def.description)
        if convar then
            created = created + 1
        else
            skipped = skipped + 1
        end
    end
    
    print("[Advanced Space Combat] ConVar initialization complete:")
    print("  Created: " .. created)
    print("  Skipped: " .. skipped)
    print("  Total: " .. (created + skipped))
end

-- Get ConVar safely
function ASC.ConVarManager.GetConVar(name)
    -- Check registry first
    if ASC.ConVarManager.Registry[name] then
        return ASC.ConVarManager.Registry[name]
    end
    
    -- Try to get from engine
    local convar = GetConVar(name)
    if convar then
        ASC.ConVarManager.Registry[name] = convar
        return convar
    end
    
    -- ConVar doesn't exist
    return nil
end

-- Get ConVar value safely
function ASC.ConVarManager.GetConVarValue(name, defaultValue)
    local convar = ASC.ConVarManager.GetConVar(name)
    if convar then
        if defaultValue and type(defaultValue) == "number" then
            return convar:GetFloat()
        elseif defaultValue and type(defaultValue) == "boolean" then
            return convar:GetBool()
        else
            return convar:GetString()
        end
    end
    
    return defaultValue
end

-- Check if ConVar exists
function ASC.ConVarManager.ConVarExists(name)
    return ASC.ConVarManager.GetConVar(name) ~= nil
end

-- Reset all ConVars to defaults
function ASC.ConVarManager.ResetAllConVars()
    print("[Advanced Space Combat] Resetting all ConVars to defaults...")
    
    for name, def in pairs(ASC.ConVarManager.ConVarDefinitions) do
        RunConsoleCommand(name, def.default)
    end
    
    print("[Advanced Space Combat] All ConVars reset to defaults")
end

-- List all ConVars
function ASC.ConVarManager.ListAllConVars()
    print("=== Advanced Space Combat ConVars ===")
    
    for name, def in pairs(ASC.ConVarManager.ConVarDefinitions) do
        local convar = ASC.ConVarManager.GetConVar(name)
        local value = convar and convar:GetString() or "NOT FOUND"
        print(string.format("%-30s = %-10s (default: %s)", name, value, def.default))
    end
    
    print("=====================================")
end

-- Console commands
concommand.Add("asc_convars_init", function()
    ASC.ConVarManager.InitializeAllConVars()
end)

concommand.Add("asc_convars_reset", function()
    ASC.ConVarManager.ResetAllConVars()
end)

concommand.Add("asc_convars_list", function()
    ASC.ConVarManager.ListAllConVars()
end)

-- Initialize ConVars immediately
ASC.ConVarManager.InitializeAllConVars()

-- Override global ConVarExists function for ASC ConVars
local originalConVarExists = ConVarExists
function ConVarExists(name)
    -- Check ASC ConVar manager first
    if string.find(name, "asc_") then
        return ASC.ConVarManager.ConVarExists(name)
    end
    
    -- Use original function for non-ASC ConVars
    return originalConVarExists(name)
end

print("[Advanced Space Combat] ConVar Manager loaded successfully!")
