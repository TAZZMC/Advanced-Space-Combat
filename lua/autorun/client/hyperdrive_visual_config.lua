-- Hyperdrive Visual Effects Configuration
-- This file allows users to configure visual effects to prevent white screen issues

if SERVER then return end

-- Create configuration table
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.VisualConfig = HYPERDRIVE.VisualConfig or {}

-- Default configuration values
HYPERDRIVE.VisualConfig.Settings = {
    -- Screen effects intensity (0.0 to 1.0)
    ScreenEffectsIntensity = 0.5,
    
    -- Flash effects intensity (0.0 to 1.0)
    FlashIntensity = 0.3,
    
    -- Background opacity (0.0 to 1.0)
    BackgroundOpacity = 0.4,
    
    -- Motion blur intensity (0.0 to 1.0)
    MotionBlurIntensity = 0.3,
    
    -- Color modification intensity (0.0 to 1.0)
    ColorModIntensity = 0.4,
    
    -- Enable/disable specific effects
    EnableScreenEffects = true,
    EnableFlashEffects = true,
    EnableMotionBlur = true,
    EnableColorMod = true,
    EnableParticles = true,
    
    -- Performance settings
    MaxParticles = 500,
    EffectUpdateRate = 0.1,
    
    -- Debug settings
    ShowDebugInfo = false,
    LogEffects = false
}

-- Load configuration from file
function HYPERDRIVE.VisualConfig.Load()
    local fileName = "hyperdrive_visual_config.txt"
    if file.Exists(fileName, "DATA") then
        local data = file.Read(fileName, "DATA")
        if data then
            local config = util.JSONToTable(data)
            if config then
                table.Merge(HYPERDRIVE.VisualConfig.Settings, config)
                print("[Hyperdrive Visual] Configuration loaded")
                return true
            end
        end
    end
    
    -- Save default config if none exists
    HYPERDRIVE.VisualConfig.Save()
    print("[Hyperdrive Visual] Default configuration created")
    return false
end

-- Save configuration to file
function HYPERDRIVE.VisualConfig.Save()
    local data = util.TableToJSON(HYPERDRIVE.VisualConfig.Settings, true)
    if data then
        file.Write("hyperdrive_visual_config.txt", data)
        print("[Hyperdrive Visual] Configuration saved")
        return true
    end
    return false
end

-- Get setting value
function HYPERDRIVE.VisualConfig.Get(setting)
    return HYPERDRIVE.VisualConfig.Settings[setting]
end

-- Set setting value
function HYPERDRIVE.VisualConfig.Set(setting, value)
    if HYPERDRIVE.VisualConfig.Settings[setting] ~= nil then
        HYPERDRIVE.VisualConfig.Settings[setting] = value
        HYPERDRIVE.VisualConfig.Save()
        return true
    end
    return false
end

-- Console commands for configuration
concommand.Add("hyperdrive_visual_set", function(ply, cmd, args)
    if #args < 2 then
        print("Usage: hyperdrive_visual_set <setting> <value>")
        print("Available settings:")
        for setting, value in pairs(HYPERDRIVE.VisualConfig.Settings) do
            print("  " .. setting .. " = " .. tostring(value))
        end
        return
    end
    
    local setting = args[1]
    local value = args[2]
    
    -- Convert value to appropriate type
    if value == "true" then
        value = true
    elseif value == "false" then
        value = false
    elseif tonumber(value) then
        value = tonumber(value)
    end
    
    if HYPERDRIVE.VisualConfig.Set(setting, value) then
        print("[Hyperdrive Visual] Set " .. setting .. " = " .. tostring(value))
    else
        print("[Hyperdrive Visual] Unknown setting: " .. setting)
    end
end)

concommand.Add("hyperdrive_visual_get", function(ply, cmd, args)
    if #args < 1 then
        print("Current visual configuration:")
        for setting, value in pairs(HYPERDRIVE.VisualConfig.Settings) do
            print("  " .. setting .. " = " .. tostring(value))
        end
        return
    end
    
    local setting = args[1]
    local value = HYPERDRIVE.VisualConfig.Get(setting)
    if value ~= nil then
        print("[Hyperdrive Visual] " .. setting .. " = " .. tostring(value))
    else
        print("[Hyperdrive Visual] Unknown setting: " .. setting)
    end
end)

concommand.Add("hyperdrive_visual_reset", function(ply, cmd, args)
    -- Reset to safe defaults for white screen issues
    HYPERDRIVE.VisualConfig.Settings.ScreenEffectsIntensity = 0.3
    HYPERDRIVE.VisualConfig.Settings.FlashIntensity = 0.2
    HYPERDRIVE.VisualConfig.Settings.BackgroundOpacity = 0.3
    HYPERDRIVE.VisualConfig.Settings.MotionBlurIntensity = 0.2
    HYPERDRIVE.VisualConfig.Settings.ColorModIntensity = 0.3
    
    HYPERDRIVE.VisualConfig.Save()
    print("[Hyperdrive Visual] Reset to safe defaults")
end)

concommand.Add("hyperdrive_visual_disable_all", function(ply, cmd, args)
    -- Disable all effects to fix white screen
    HYPERDRIVE.VisualConfig.Settings.EnableScreenEffects = false
    HYPERDRIVE.VisualConfig.Settings.EnableFlashEffects = false
    HYPERDRIVE.VisualConfig.Settings.EnableMotionBlur = false
    HYPERDRIVE.VisualConfig.Settings.EnableColorMod = false
    
    HYPERDRIVE.VisualConfig.Save()
    print("[Hyperdrive Visual] All effects disabled")
end)

concommand.Add("hyperdrive_visual_enable_all", function(ply, cmd, args)
    -- Re-enable all effects with safe values
    HYPERDRIVE.VisualConfig.Settings.EnableScreenEffects = true
    HYPERDRIVE.VisualConfig.Settings.EnableFlashEffects = true
    HYPERDRIVE.VisualConfig.Settings.EnableMotionBlur = true
    HYPERDRIVE.VisualConfig.Settings.EnableColorMod = true
    
    HYPERDRIVE.VisualConfig.Settings.ScreenEffectsIntensity = 0.4
    HYPERDRIVE.VisualConfig.Settings.FlashIntensity = 0.3
    HYPERDRIVE.VisualConfig.Settings.MotionBlurIntensity = 0.3
    HYPERDRIVE.VisualConfig.Settings.ColorModIntensity = 0.4
    
    HYPERDRIVE.VisualConfig.Save()
    print("[Hyperdrive Visual] All effects enabled with safe values")
end)

-- Load configuration on startup
timer.Simple(1, function()
    HYPERDRIVE.VisualConfig.Load()
end)

print("[Hyperdrive Visual] Configuration system loaded")
print("Use 'hyperdrive_visual_disable_all' to fix white screen issues")
print("Use 'hyperdrive_visual_reset' to reset to safe defaults")
