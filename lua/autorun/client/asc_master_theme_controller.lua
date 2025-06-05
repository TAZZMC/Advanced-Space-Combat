-- Advanced Space Combat - Master Theme Controller v1.0.0
-- Central control system for all ASC theme components

print("[Advanced Space Combat] Master Theme Controller v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.MasterTheme = ASC.MasterTheme or {}

-- Master theme configuration
ASC.MasterTheme.Config = {
    -- Global theme settings
    GlobalThemeEnabled = true,
    ThemeIntensity = 1.0, -- 0.0 to 1.0
    AnimationSpeed = 1.0,
    EffectQuality = "high", -- low, medium, high, ultra
    
    -- Component enable/disable
    Components = {
        VGUITheme = true,
        GameInterface = true,
        AdvancedEffects = true,
        HUDOverlay = true,
        SettingsMenu = true,
        ComprehensiveTheme = true,
        WeaponInterface = true,
        FlightInterface = true,
        AIInterface = true,
        CharacterTheme = true,
        PlayerHUD = true
    },
    
    -- Performance settings
    Performance = {
        MaxFPS = 60,
        ReduceEffectsOnLowFPS = true,
        LowFPSThreshold = 30,
        DisableEffectsOnLowFPS = 15,
        UpdateInterval = 0.1
    },
    
    -- Theme presets
    Presets = {
        ["Minimal"] = {
            VGUITheme = true,
            GameInterface = false,
            AdvancedEffects = false,
            HUDOverlay = false,
            SettingsMenu = true,
            ThemeIntensity = 0.5
        },
        ["Standard"] = {
            VGUITheme = true,
            GameInterface = true,
            AdvancedEffects = false,
            HUDOverlay = true,
            SettingsMenu = true,
            ThemeIntensity = 0.8
        },
        ["Full"] = {
            VGUITheme = true,
            GameInterface = true,
            AdvancedEffects = true,
            HUDOverlay = true,
            SettingsMenu = true,
            ThemeIntensity = 1.0
        },
        ["Performance"] = {
            VGUITheme = true,
            GameInterface = false,
            AdvancedEffects = false,
            HUDOverlay = false,
            SettingsMenu = false,
            ThemeIntensity = 0.3
        }
    }
}

-- Master theme state
ASC.MasterTheme.State = {
    CurrentPreset = "Standard",
    LastFPSCheck = 0,
    CurrentFPS = 60,
    PerformanceMode = false,
    ComponentStates = {},
    LastUpdate = 0,
    InitializationComplete = false
}

-- Initialize master theme controller
function ASC.MasterTheme.Initialize()
    print("[Advanced Space Combat] Master theme controller initialized")

    -- ConVars are now managed centrally by ASC.ConVarManager
    
    -- Initialize hooks
    ASC.MasterTheme.InitializeHooks()
    
    -- Load current preset
    ASC.MasterTheme.LoadPreset(GetConVar("asc_theme_preset"):GetString())
    
    -- Initialize all theme components
    timer.Simple(1, function()
        ASC.MasterTheme.InitializeAllComponents()
    end)
end

-- Initialize hooks
function ASC.MasterTheme.InitializeHooks()
    -- Performance monitoring with error protection
    hook.Add("Think", "ASC_MasterTheme_Performance", function()
        local success, err = pcall(ASC.MasterTheme.MonitorPerformance)
        if not success then
            print("[ASC Master Theme] Performance monitoring error: " .. tostring(err))
            -- Disable performance monitoring if it keeps failing
            hook.Remove("Think", "ASC_MasterTheme_Performance")
        end
    end)
    
    -- ConVar change monitoring
    cvars.AddChangeCallback("asc_theme_preset", function(convar, oldValue, newValue)
        ASC.MasterTheme.LoadPreset(newValue)
    end)
    
    cvars.AddChangeCallback("asc_theme_intensity", function(convar, oldValue, newValue)
        ASC.MasterTheme.UpdateThemeIntensity(tonumber(newValue) or 1.0)
    end)
    
    cvars.AddChangeCallback("asc_theme_performance_mode", function(convar, oldValue, newValue)
        ASC.MasterTheme.SetPerformanceMode(newValue == "1")
    end)
    
    -- Map change hook
    hook.Add("Initialize", "ASC_MasterTheme_MapInit", function()
        timer.Simple(2, function()
            ASC.MasterTheme.RefreshAllThemes()
        end)
    end)
end

-- Initialize all theme components
function ASC.MasterTheme.InitializeAllComponents()
    print("[Advanced Space Combat] Initializing all theme components...")
    
    local config = ASC.MasterTheme.Config
    local components = config.Components
    
    -- Initialize each component if enabled
    if components.VGUITheme and ASC.VGUITheme then
        ASC.VGUITheme.Initialize()
        print("✓ VGUI Theme initialized")
    end
    
    if components.GameInterface and ASC.GameTheme then
        ASC.GameTheme.Initialize()
        print("✓ Game Interface Theme initialized")
    end
    
    if components.AdvancedEffects and ASC.AdvancedEffects then
        ASC.AdvancedEffects.Initialize()
        print("✓ Advanced Effects initialized")
    end
    
    if components.HUDOverlay and ASC.HUDOverlay then
        ASC.HUDOverlay.Initialize()
        print("✓ HUD Overlay initialized")
    end
    
    if components.SettingsMenu and ASC.SettingsTheme then
        ASC.SettingsTheme.Initialize()
        print("✓ Settings Menu Theme initialized")
    end
    
    if components.ComprehensiveTheme and ASC.ComprehensiveTheme then
        ASC.ComprehensiveTheme.Initialize()
        print("✓ Comprehensive Theme initialized")
    end
    
    ASC.MasterTheme.State.InitializationComplete = true
    print("[Advanced Space Combat] All theme components initialized successfully!")
    
    -- Apply current settings
    ASC.MasterTheme.ApplyCurrentSettings()
end

-- Load theme preset
function ASC.MasterTheme.LoadPreset(presetName)
    local presets = ASC.MasterTheme.Config.Presets
    local preset = presets[presetName]
    
    if not preset then
        print("[Advanced Space Combat] Unknown preset: " .. presetName .. ", using Standard")
        preset = presets["Standard"]
        presetName = "Standard"
    end
    
    print("[Advanced Space Combat] Loading theme preset: " .. presetName)
    
    -- Update component states
    for component, enabled in pairs(preset) do
        if component ~= "ThemeIntensity" then
            ASC.MasterTheme.Config.Components[component] = enabled
        end
    end
    
    -- Update theme intensity
    if preset.ThemeIntensity then
        ASC.MasterTheme.Config.ThemeIntensity = preset.ThemeIntensity
        RunConsoleCommand("asc_theme_intensity", tostring(preset.ThemeIntensity))
    end
    
    ASC.MasterTheme.State.CurrentPreset = presetName
    
    -- Apply the preset
    ASC.MasterTheme.ApplyPreset(preset)
end

-- Apply theme preset
function ASC.MasterTheme.ApplyPreset(preset)
    -- Enable/disable components based on preset
    for component, enabled in pairs(preset) do
        if component ~= "ThemeIntensity" then
            ASC.MasterTheme.SetComponentEnabled(component, enabled)
        end
    end
    
    -- Refresh all themes
    timer.Simple(0.5, function()
        ASC.MasterTheme.RefreshAllThemes()
    end)
end

-- Set component enabled state
function ASC.MasterTheme.SetComponentEnabled(component, enabled)
    ASC.MasterTheme.Config.Components[component] = enabled
    ASC.MasterTheme.State.ComponentStates[component] = enabled
    
    -- Update corresponding ConVars
    local convarMap = {
        VGUITheme = "asc_vgui_theme_enabled",
        GameInterface = "asc_game_theme_enabled",
        AdvancedEffects = "asc_effects_enabled",
        HUDOverlay = "asc_hud_targeting",
        SettingsMenu = "asc_settings_theme_enabled"
    }
    
    local convar = convarMap[component]
    if convar then
        RunConsoleCommand(convar, enabled and "1" or "0")
    end
end

-- Update theme intensity
function ASC.MasterTheme.UpdateThemeIntensity(intensity)
    intensity = math.Clamp(intensity, 0.0, 1.0)
    ASC.MasterTheme.Config.ThemeIntensity = intensity
    
    print("[Advanced Space Combat] Theme intensity set to: " .. intensity)
    
    -- Apply intensity to all theme systems
    if ASC.ComprehensiveTheme and ASC.ComprehensiveTheme.Config then
        -- Adjust alpha values based on intensity
        for colorName, color in pairs(ASC.ComprehensiveTheme.Config.Colors) do
            if color.a then
                color.a = math.floor(color.a * intensity)
            end
        end
    end
end

-- Set performance mode
function ASC.MasterTheme.SetPerformanceMode(enabled)
    ASC.MasterTheme.State.PerformanceMode = enabled
    
    if enabled then
        print("[Advanced Space Combat] Performance mode enabled")
        ASC.MasterTheme.LoadPreset("Performance")
    else
        print("[Advanced Space Combat] Performance mode disabled")
        ASC.MasterTheme.LoadPreset(ASC.MasterTheme.State.CurrentPreset)
    end
end

-- Monitor performance
function ASC.MasterTheme.MonitorPerformance()
    local currentTime = CurTime()
    local state = ASC.MasterTheme.State
    local config = ASC.MasterTheme.Config
    
    if currentTime - state.LastFPSCheck < 1.0 then return end
    
    -- Calculate FPS
    state.CurrentFPS = 1.0 / FrameTime()
    
    -- Auto-adjust for performance if enabled
    if GetConVar("asc_theme_auto_performance"):GetBool() then
        if state.CurrentFPS < config.Performance.DisableEffectsOnLowFPS and not state.PerformanceMode then
            print("[Advanced Space Combat] Low FPS detected, enabling performance mode")
            ASC.MasterTheme.SetPerformanceMode(true)
        elseif state.CurrentFPS > config.Performance.LowFPSThreshold + 10 and state.PerformanceMode then
            print("[Advanced Space Combat] FPS improved, disabling performance mode")
            ASC.MasterTheme.SetPerformanceMode(false)
        end
    end
    
    state.LastFPSCheck = currentTime
end

-- Refresh all themes
function ASC.MasterTheme.RefreshAllThemes()
    print("[Advanced Space Combat] Refreshing all theme systems...")
    
    -- Refresh each component
    if ASC.VGUITheme and ASC.VGUITheme.Initialize then
        ASC.VGUITheme.Initialize()
    end
    
    if ASC.GameTheme and ASC.GameTheme.Initialize then
        ASC.GameTheme.Initialize()
    end
    
    if ASC.AdvancedEffects and ASC.AdvancedEffects.Initialize then
        ASC.AdvancedEffects.Initialize()
    end
    
    if ASC.HUDOverlay and ASC.HUDOverlay.Initialize then
        ASC.HUDOverlay.Initialize()
    end
    
    if ASC.SettingsTheme and ASC.SettingsTheme.Initialize then
        ASC.SettingsTheme.Initialize()
    end
    
    if ASC.ComprehensiveTheme and ASC.ComprehensiveTheme.Initialize then
        ASC.ComprehensiveTheme.Initialize()
    end
    
    print("[Advanced Space Combat] All theme systems refreshed!")
end

-- Apply current settings
function ASC.MasterTheme.ApplyCurrentSettings()
    local intensity = GetConVar("asc_theme_intensity"):GetFloat()
    ASC.MasterTheme.UpdateThemeIntensity(intensity)
    
    local performanceMode = GetConVar("asc_theme_performance_mode"):GetBool()
    if performanceMode then
        ASC.MasterTheme.SetPerformanceMode(true)
    end
end

-- Get theme status
function ASC.MasterTheme.GetStatus()
    local state = ASC.MasterTheme.State
    local config = ASC.MasterTheme.Config
    
    return {
        preset = state.CurrentPreset,
        intensity = config.ThemeIntensity,
        performanceMode = state.PerformanceMode,
        fps = state.CurrentFPS,
        components = config.Components,
        initialized = state.InitializationComplete
    }
end

-- Console commands
concommand.Add("asc_theme_status", function()
    local status = ASC.MasterTheme.GetStatus()
    
    print("=== Advanced Space Combat Theme Status ===")
    print("Preset: " .. status.preset)
    print("Intensity: " .. status.intensity)
    print("Performance Mode: " .. (status.performanceMode and "Enabled" or "Disabled"))
    print("Current FPS: " .. math.floor(status.fps))
    print("Initialized: " .. (status.initialized and "Yes" or "No"))
    print("")
    print("Components:")
    for component, enabled in pairs(status.components) do
        print("  " .. component .. ": " .. (enabled and "Enabled" or "Disabled"))
    end
    print("==========================================")
end)

concommand.Add("asc_theme_preset", function(ply, cmd, args)
    if args[1] then
        ASC.MasterTheme.LoadPreset(args[1])
        RunConsoleCommand("asc_theme_preset", args[1])
    else
        print("Available presets: Minimal, Standard, Full, Performance")
        print("Current preset: " .. ASC.MasterTheme.State.CurrentPreset)
    end
end)

concommand.Add("asc_theme_refresh", function()
    ASC.MasterTheme.RefreshAllThemes()
end)

concommand.Add("asc_theme_reset", function()
    print("[Advanced Space Combat] Resetting theme system...")
    ASC.MasterTheme.LoadPreset("Standard")
    RunConsoleCommand("asc_theme_intensity", "1.0")
    RunConsoleCommand("asc_theme_performance_mode", "0")
    ASC.MasterTheme.RefreshAllThemes()
    print("[Advanced Space Combat] Theme system reset to defaults")
end)

-- Initialize on client
hook.Add("Initialize", "ASC_MasterTheme_Init", function()
    timer.Simple(0.5, function()
        ASC.MasterTheme.Initialize()
    end)
end)

print("[Advanced Space Combat] Master Theme Controller loaded successfully!")
