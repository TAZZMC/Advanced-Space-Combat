-- Advanced Space Combat - Asset Management System v3.0.0
-- Comprehensive asset loading, validation, and fallback system

print("[Advanced Space Combat] Asset Management System v3.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.Assets = ASC.Assets or {}

-- Asset configuration
ASC.Assets.Config = {
    EnableAssetValidation = true,
    EnableFallbackAssets = true,
    EnableAssetLogging = true,
    EnableAssetPrecaching = true,
    AssetLoadTimeout = 5.0,
    
    -- Asset quality settings
    MaterialQuality = "high", -- high, medium, low
    ModelQuality = "high",
    SoundQuality = "high",
    EffectQuality = "high"
}

-- Asset registry
ASC.Assets.Registry = {
    Materials = {},
    Models = {},
    Sounds = {},
    Effects = {},
    Fonts = {},
    
    -- Asset status tracking
    LoadedAssets = 0,
    TotalAssets = 0,
    FailedAssets = {},
    MissingAssets = {}
}

-- Required materials
ASC.Assets.Materials = {
    -- Entity materials
    "entities/ship_core",
    "entities/hyperdrive_engine",
    "entities/hyperdrive_master_engine",
    "entities/asc_shield_generator",
    "entities/asc_pulse_cannon",
    "entities/asc_railgun",
    "entities/asc_plasma_cannon",
    "entities/asc_beam_weapon",
    "entities/asc_torpedo_launcher",
    "entities/asc_flight_console",
    "entities/asc_docking_pad",
    "entities/asc_shuttle",
    
    -- Effect materials
    "effects/asc_hyperspace_portal",
    "effects/asc_shield_bubble",
    "effects/asc_pulse_beam",
    "effects/asc_railgun_trail",
    "effects/asc_plasma_burst",
    "effects/asc_beam_continuous",
    "effects/asc_torpedo_trail",
    "effects/asc_explosion_large",
    "effects/asc_explosion_small",
    "effects/asc_energy_discharge",
    
    -- UI materials
    "gui/asc_ship_core_icon",
    "gui/asc_engine_icon",
    "gui/asc_weapon_icon",
    "gui/asc_shield_icon",
    "gui/asc_background",
    "gui/asc_button_normal",
    "gui/asc_button_hover",
    "gui/asc_progress_bar"
}

-- Required models
ASC.Assets.Models = {
    -- Core entities
    "models/asc/ship_core.mdl",
    "models/asc/hyperdrive_engine.mdl",
    "models/asc/hyperdrive_master_engine.mdl",
    "models/asc/hyperdrive_computer.mdl",
    
    -- Weapons
    "models/asc/weapons/pulse_cannon.mdl",
    "models/asc/weapons/railgun.mdl",
    "models/asc/weapons/plasma_cannon.mdl",
    "models/asc/weapons/beam_weapon.mdl",
    "models/asc/weapons/torpedo_launcher.mdl",
    
    -- Systems
    "models/asc/systems/shield_generator.mdl",
    "models/asc/systems/flight_console.mdl",
    "models/asc/systems/docking_pad.mdl",
    "models/asc/systems/shuttle.mdl",
    
    -- Projectiles
    "models/asc/projectiles/torpedo.mdl",
    "models/asc/projectiles/railgun_slug.mdl",
    "models/asc/projectiles/plasma_bolt.mdl"
}

-- Required sounds
ASC.Assets.Sounds = {
    -- Hyperdrive sounds
    "asc/hyperdrive/engine_startup.wav",
    "asc/hyperdrive/engine_running.wav",
    "asc/hyperdrive/engine_shutdown.wav",
    "asc/hyperdrive/jump_charge.wav",
    "asc/hyperdrive/jump_activate.wav",
    "asc/hyperdrive/jump_travel.wav",
    "asc/hyperdrive/jump_exit.wav",
    
    -- Weapon sounds
    "asc/weapons/pulse_cannon_fire.wav",
    "asc/weapons/pulse_cannon_charge.wav",
    "asc/weapons/railgun_fire.wav",
    "asc/weapons/railgun_charge.wav",
    "asc/weapons/plasma_cannon_fire.wav",
    "asc/weapons/beam_weapon_fire.wav",
    "asc/weapons/torpedo_launch.wav",
    "asc/weapons/weapon_reload.wav",
    
    -- Shield sounds
    "asc/shields/shield_activate.wav",
    "asc/shields/shield_deactivate.wav",
    "asc/shields/shield_hit.wav",
    "asc/shields/shield_recharge.wav",
    "asc/shields/shield_overload.wav",
    
    -- System sounds
    "asc/systems/ship_core_startup.wav",
    "asc/systems/ship_core_running.wav",
    "asc/systems/computer_beep.wav",
    "asc/systems/alert_warning.wav",
    "asc/systems/alert_critical.wav",
    "asc/systems/docking_clamps.wav",
    "asc/systems/airlock_cycle.wav",
    
    -- AI sounds
    "asc/ai/aria_acknowledge.wav",
    "asc/ai/aria_negative.wav",
    "asc/ai/aria_warning.wav",
    "asc/ai/aria_critical.wav"
}

-- Required effects
ASC.Assets.Effects = {
    "asc_hyperspace_portal",
    "asc_shield_impact",
    "asc_pulse_blast",
    "asc_railgun_impact",
    "asc_plasma_explosion",
    "asc_beam_continuous",
    "asc_torpedo_explosion",
    "asc_engine_trail",
    "asc_jump_flash",
    "asc_system_sparks"
}

-- Asset loading functions
function ASC.Assets.LoadMaterial(materialPath)
    if ASC.Assets.Registry.Materials[materialPath] then
        return ASC.Assets.Registry.Materials[materialPath]
    end
    
    local success, material = pcall(Material, materialPath)
    
    if success and material and not material:IsError() then
        ASC.Assets.Registry.Materials[materialPath] = material
        ASC.Assets.Registry.LoadedAssets = ASC.Assets.Registry.LoadedAssets + 1
        
        if ASC.Assets.Config.EnableAssetLogging then
            print("[ASC Assets] Loaded material: " .. materialPath)
        end
        
        return material
    else
        -- Create fallback material
        if ASC.Assets.Config.EnableFallbackAssets then
            local fallback = ASC.Assets.CreateFallbackMaterial(materialPath)
            ASC.Assets.Registry.Materials[materialPath] = fallback
            return fallback
        end
        
        table.insert(ASC.Assets.Registry.FailedAssets, materialPath)
        if ASC.Assets.Config.EnableAssetLogging then
            print("[ASC Assets] Failed to load material: " .. materialPath)
        end
        
        return nil
    end
end

function ASC.Assets.CreateFallbackMaterial(materialPath)
    -- Create a simple fallback material based on type
    local fallbackPath = "error"
    
    if string.find(materialPath, "effect") then
        fallbackPath = "effects/energyball"
    elseif string.find(materialPath, "gui") then
        fallbackPath = "gui/silkicons/error"
    elseif string.find(materialPath, "entities") then
        fallbackPath = "models/debug/debugwhite"
    end
    
    local fallback = Material(fallbackPath)
    
    if ASC.Assets.Config.EnableAssetLogging then
        print("[ASC Assets] Created fallback material for: " .. materialPath .. " -> " .. fallbackPath)
    end
    
    return fallback
end

function ASC.Assets.ValidateModel(modelPath)
    if not file.Exists(modelPath, "GAME") then
        table.insert(ASC.Assets.Registry.MissingAssets, "Model: " .. modelPath)
        return false
    end
    
    ASC.Assets.Registry.LoadedAssets = ASC.Assets.Registry.LoadedAssets + 1
    return true
end

function ASC.Assets.ValidateSound(soundPath)
    local fullPath = "sound/" .. soundPath
    if not file.Exists(fullPath, "GAME") then
        table.insert(ASC.Assets.Registry.MissingAssets, "Sound: " .. soundPath)
        return false
    end
    
    ASC.Assets.Registry.LoadedAssets = ASC.Assets.Registry.LoadedAssets + 1
    return true
end

-- Precache all assets
function ASC.Assets.PrecacheAssets()
    if not ASC.Assets.Config.EnableAssetPrecaching then return end
    
    print("[ASC Assets] Starting asset precaching...")
    
    ASC.Assets.Registry.TotalAssets = #ASC.Assets.Materials + #ASC.Assets.Models + #ASC.Assets.Sounds
    ASC.Assets.Registry.LoadedAssets = 0
    
    -- Precache materials
    for _, materialPath in ipairs(ASC.Assets.Materials) do
        ASC.Assets.LoadMaterial(materialPath)
    end
    
    -- Validate models
    for _, modelPath in ipairs(ASC.Assets.Models) do
        ASC.Assets.ValidateModel(modelPath)
    end
    
    -- Validate sounds
    for _, soundPath in ipairs(ASC.Assets.Sounds) do
        ASC.Assets.ValidateSound(soundPath)
    end
    
    -- Report results
    local successRate = (ASC.Assets.Registry.LoadedAssets / ASC.Assets.Registry.TotalAssets) * 100
    print("[ASC Assets] Precaching complete: " .. ASC.Assets.Registry.LoadedAssets .. "/" .. ASC.Assets.Registry.TotalAssets .. " (" .. math.floor(successRate) .. "%)")
    
    if #ASC.Assets.Registry.MissingAssets > 0 then
        print("[ASC Assets] Missing assets: " .. #ASC.Assets.Registry.MissingAssets)
        for _, asset in ipairs(ASC.Assets.Registry.MissingAssets) do
            print("  - " .. asset)
        end
    end
end

-- Get asset with fallback
function ASC.Assets.GetMaterial(materialPath)
    return ASC.Assets.Registry.Materials[materialPath] or ASC.Assets.LoadMaterial(materialPath)
end

function ASC.Assets.GetModel(modelPath)
    if ASC.Assets.ValidateModel(modelPath) then
        return modelPath
    else
        -- Return fallback model
        return "models/error.mdl"
    end
end

function ASC.Assets.GetSound(soundPath)
    if ASC.Assets.ValidateSound(soundPath) then
        return soundPath
    else
        -- Return fallback sound
        return "buttons/button15.wav"
    end
end

-- Asset status functions
function ASC.Assets.GetStatus()
    return {
        total = ASC.Assets.Registry.TotalAssets,
        loaded = ASC.Assets.Registry.LoadedAssets,
        failed = #ASC.Assets.Registry.FailedAssets,
        missing = #ASC.Assets.Registry.MissingAssets,
        success_rate = (ASC.Assets.Registry.LoadedAssets / math.max(ASC.Assets.Registry.TotalAssets, 1)) * 100
    }
end

function ASC.Assets.PrintStatus()
    local status = ASC.Assets.GetStatus()
    print("[ASC Assets] Status Report:")
    print("  Total Assets: " .. status.total)
    print("  Loaded: " .. status.loaded)
    print("  Failed: " .. status.failed)
    print("  Missing: " .. status.missing)
    print("  Success Rate: " .. math.floor(status.success_rate) .. "%")
end

-- Initialize asset system
if CLIENT then
    hook.Add("Initialize", "ASC_InitializeAssets", function()
        timer.Simple(1, function()
            ASC.Assets.PrecacheAssets()
        end)
    end)
end

-- Console commands for asset management
if SERVER then
    concommand.Add("asc_assets_status", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        ASC.Assets.PrintStatus()
    end)

    concommand.Add("asc_assets_reload", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        print("[ASC Assets] Reloading assets...")
        ASC.Assets.PrecacheAssets()
    end)

    concommand.Add("asc_assets_validate", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        print("[ASC Assets] Validating all assets...")

        local missing = {}

        -- Check materials
        for _, mat in ipairs(ASC.Assets.Materials) do
            if not file.Exists("materials/" .. mat .. ".vmt", "GAME") then
                table.insert(missing, "Material: " .. mat .. ".vmt")
            end
        end

        -- Check models
        for _, model in ipairs(ASC.Assets.Models) do
            if not file.Exists(model, "GAME") then
                table.insert(missing, "Model: " .. model)
            end
        end

        -- Check sounds
        for _, sound in ipairs(ASC.Assets.Sounds) do
            if not file.Exists("sound/" .. sound, "GAME") then
                table.insert(missing, "Sound: " .. sound)
            end
        end

        if #missing > 0 then
            print("[ASC Assets] Missing " .. #missing .. " assets:")
            for _, asset in ipairs(missing) do
                print("  - " .. asset)
            end
        else
            print("[ASC Assets] All assets validated successfully!")
        end
    end)
end

print("[Advanced Space Combat] Asset Management System - Loaded successfully!")
