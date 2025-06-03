-- Advanced Space Combat - Sound System v5.1.0
-- Professional sound management with Stargate technology integration
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Advanced Space Combat] Sound System v5.1.0 - Ultimate Edition Loading...")

-- Initialize sound namespace
ASC = ASC or {}
ASC.Sound = ASC.Sound or {}

-- Sound configuration
ASC.Sound.Config = {
    EnableSounds = true,
    MasterVolume = 1.0,
    WeaponVolume = 0.8,
    EngineVolume = 0.7,
    UIVolume = 0.5,
    AIVolume = 0.6,
    EnableFallbackSounds = true,
    EnableSoundLogging = false
}

-- Sound registry
ASC.Sound.Registry = {
    Weapons = {},
    Engines = {},
    Shields = {},
    Ancient = {},
    Asgard = {},
    Goauld = {},
    Wraith = {},
    Ori = {},
    Tauri = {},
    UI = {},
    AI = {}
}

-- Sound definitions
ASC.Sound.Definitions = {
    -- Weapon sounds
    Weapons = {
        ["pulse_cannon_fire"] = "asc/weapons/pulse_cannon_fire.wav",
        ["beam_weapon_charge"] = "asc/weapons/beam_weapon_charge.wav",
        ["beam_weapon_fire"] = "asc/weapons/beam_weapon_fire.wav",
        ["torpedo_launch"] = "asc/weapons/torpedo_launch.wav",
        ["plasma_cannon_fire"] = "asc/weapons/plasma_cannon_fire.wav",
        ["railgun_fire"] = "asc/weapons/railgun_fire.wav"
    },
    
    -- Ancient technology sounds
    Ancient = {
        ["drone_fire"] = "asc/weapons/ancient_drone_fire.wav",
        ["drone_impact"] = "asc/weapons/ancient_drone_impact.wav",
        ["drone_explode"] = "asc/weapons/ancient_drone_explode.wav",
        ["explosion"] = "asc/weapons/ancient_explosion.wav",
        ["zpm_activate"] = "asc/ancient/zpm_activate.wav",
        ["zpm_hum"] = "asc/ancient/zpm_hum.wav",
        ["control_chair_activate"] = "asc/ancient/control_chair_activate.wav",
        ["shield_activate"] = "asc/shields/ancient_activate.wav",
        ["shield_hit"] = "asc/shields/ancient_hit.wav"
    },
    
    -- Asgard technology sounds
    Asgard = {
        ["ion_fire"] = "asc/weapons/asgard_ion_fire.wav",
        ["plasma_fire"] = "asc/weapons/asgard_plasma_fire.wav",
        ["beam"] = "asc/weapons/asgard_beam.wav",
        ["shield_activate"] = "asc/shields/asgard_activate.wav"
    },
    
    -- Goa'uld technology sounds
    Goauld = {
        ["staff_fire"] = "asc/weapons/goauld_staff_fire.wav",
        ["ribbon_fire"] = "asc/weapons/goauld_ribbon_fire.wav",
        ["hand_device"] = "asc/weapons/goauld_hand_device.wav",
        ["shield_activate"] = "asc/shields/goauld_activate.wav"
    },
    
    -- Wraith technology sounds
    Wraith = {
        ["dart_fire"] = "asc/weapons/wraith_dart_fire.wav",
        ["culling_beam"] = "asc/weapons/wraith_culling_beam.wav"
    },
    
    -- Ori technology sounds
    Ori = {
        ["pulse_fire"] = "asc/weapons/ori_pulse_fire.wav",
        ["beam_fire"] = "asc/weapons/ori_beam_fire.wav",
        ["satellite_fire"] = "asc/weapons/ori_satellite_fire.wav"
    },
    
    -- Tau'ri technology sounds
    Tauri = {
        ["railgun_fire"] = "asc/weapons/tauri_railgun_fire.wav",
        ["nuke_launch"] = "asc/weapons/tauri_nuke_launch.wav",
        ["nuke_explode"] = "asc/weapons/tauri_nuke_explode.wav"
    },
    
    -- Engine sounds
    Engines = {
        ["hyperdrive_charge"] = "asc/engines/hyperdrive_charge.wav",
        ["hyperdrive_jump"] = "asc/engines/hyperdrive_jump.wav",
        ["ancient_hyperdrive"] = "asc/engines/ancient_hyperdrive.wav",
        ["engine_idle"] = "asc/engines/engine_idle.wav",
        ["engine_thrust"] = "asc/engines/engine_thrust.wav"
    },
    
    -- UI sounds
    UI = {
        ["button_click"] = "asc/ui/button_click.wav",
        ["interface_open"] = "asc/ui/interface_open.wav",
        ["notification"] = "asc/ui/notification.wav",
        ["error"] = "asc/ui/error.wav",
        ["success"] = "asc/ui/success.wav"
    },
    
    -- ARIA-2 AI sounds
    AI = {
        ["response"] = "asc/ai/aria_response.wav",
        ["notification"] = "asc/ai/aria_notification.wav",
        ["startup"] = "asc/ai/aria_startup.wav",
        ["help"] = "asc/ai/aria_help.wav"
    }
}

-- Fallback sounds for missing files
ASC.Sound.Fallbacks = {
    weapon_fire = "weapons/pistol/pistol_fire2.wav",
    weapon_impact = "physics/metal/metal_box_impact_hard1.wav",
    explosion = "ambient/explosions/explode_4.wav",
    engine = "ambient/machines/machine1_hit1.wav",
    ui_click = "buttons/button15.wav",
    ui_notification = "buttons/button17.wav",
    shield_activate = "ambient/energy/zap1.wav",
    energy_charge = "ambient/energy/newspark04.wav"
}

-- Sound precaching function (integrates with Lua sound definitions)
function ASC.Sound.PrecacheSounds()
    if not ASC.Sound.Config.EnableSounds then return end

    print("[Advanced Space Combat] Precaching sounds with Lua definitions...")

    -- Use the new Lua-based sound definitions if available
    if ASC.SoundDefs and ASC.SoundDefs.RegisterSounds then
        ASC.SoundDefs.RegisterSounds()
        print("[Advanced Space Combat] Using Lua-based sound definitions")
        return
    end

    -- Fallback to legacy definitions if Lua definitions not available
    local totalSounds = 0
    local successCount = 0

    -- Precache all sound categories
    for category, sounds in pairs(ASC.Sound.Definitions) do
        for soundName, soundPath in pairs(sounds) do
            totalSounds = totalSounds + 1

            local success = ASC.Sound.PrecacheSound(soundPath, category, soundName)
            if success then
                successCount = successCount + 1
            end
        end
    end

    print("[Advanced Space Combat] Sound precaching complete: " .. successCount .. "/" .. totalSounds .. " sounds loaded")
end

-- Individual sound precaching
function ASC.Sound.PrecacheSound(soundPath, category, soundName)
    local success = pcall(function()
        util.PrecacheSound(soundPath)
        
        -- Register sound in appropriate category
        if not ASC.Sound.Registry[category] then
            ASC.Sound.Registry[category] = {}
        end
        ASC.Sound.Registry[category][soundName] = soundPath
    end)
    
    if not success then
        if ASC.Sound.Config.EnableFallbackSounds then
            ASC.Sound.CreateFallbackSound(soundPath, category, soundName)
        end
        
        if ASC.Sound.Config.EnableSoundLogging then
            print("[Advanced Space Combat] Missing sound: " .. soundPath)
        end
    end
    
    return success
end

-- Create fallback sound
function ASC.Sound.CreateFallbackSound(originalPath, category, soundName)
    local fallbackSound = nil
    
    -- Determine appropriate fallback based on sound type
    if string.find(originalPath, "weapon") and string.find(originalPath, "fire") then
        fallbackSound = ASC.Sound.Fallbacks.weapon_fire
    elseif string.find(originalPath, "weapon") and string.find(originalPath, "impact") then
        fallbackSound = ASC.Sound.Fallbacks.weapon_impact
    elseif string.find(originalPath, "explode") then
        fallbackSound = ASC.Sound.Fallbacks.explosion
    elseif string.find(originalPath, "engine") then
        fallbackSound = ASC.Sound.Fallbacks.engine
    elseif string.find(originalPath, "ui") and string.find(originalPath, "click") then
        fallbackSound = ASC.Sound.Fallbacks.ui_click
    elseif string.find(originalPath, "ui") then
        fallbackSound = ASC.Sound.Fallbacks.ui_notification
    elseif string.find(originalPath, "shield") then
        fallbackSound = ASC.Sound.Fallbacks.shield_activate
    elseif string.find(originalPath, "charge") then
        fallbackSound = ASC.Sound.Fallbacks.energy_charge
    else
        fallbackSound = ASC.Sound.Fallbacks.ui_notification
    end
    
    -- Register fallback sound
    if not ASC.Sound.Registry[category] then
        ASC.Sound.Registry[category] = {}
    end
    ASC.Sound.Registry[category][soundName] = fallbackSound
end

-- Play sound function (enhanced for Lua definitions)
function ASC.Sound.PlaySound(category, subcategory, soundName, entity, volume, pitch)
    if not ASC.Sound.Config.EnableSounds then return end

    -- Try new Lua-based sound definitions first
    if ASC.SoundDefs and ASC.SoundDefs.PlaySound then
        local success = ASC.SoundDefs.PlaySound(category, subcategory, soundName, entity, volume, pitch)
        if success then return end
    end

    -- Fallback to legacy system
    local soundPath = nil
    if soundName then
        -- Three-parameter call (category, subcategory, soundName)
        soundPath = ASC.Sound.GetSound(category, subcategory)
    else
        -- Two-parameter call (category, soundName) - legacy compatibility
        soundPath = ASC.Sound.GetSound(category, subcategory)
        soundName = subcategory
    end

    if not soundPath then return end

    -- Apply volume settings
    volume = volume or 1.0
    volume = volume * ASC.Sound.Config.MasterVolume

    -- Apply category-specific volume
    if category == "Weapons" or category == "Ancient" or category == "Asgard" or category == "Goauld" or category == "Wraith" or category == "Ori" or category == "Tauri" then
        volume = volume * ASC.Sound.Config.WeaponVolume
    elseif category == "Engines" then
        volume = volume * ASC.Sound.Config.EngineVolume
    elseif category == "UI" then
        volume = volume * ASC.Sound.Config.UIVolume
    elseif category == "AI" then
        volume = volume * ASC.Sound.Config.AIVolume
    end

    pitch = pitch or 100

    -- Play sound
    if IsValid(entity) then
        entity:EmitSound(soundPath, 75, pitch, volume)
    else
        sound.Play(soundPath, Vector(0, 0, 0), 75, pitch, volume)
    end
end

-- Get sound path
function ASC.Sound.GetSound(category, soundName)
    if ASC.Sound.Registry[category] and ASC.Sound.Registry[category][soundName] then
        return ASC.Sound.Registry[category][soundName]
    end
    
    -- Return fallback
    return ASC.Sound.Fallbacks.ui_notification
end

-- Sound configuration functions
function ASC.Sound.SetMasterVolume(volume)
    ASC.Sound.Config.MasterVolume = math.Clamp(volume, 0, 1)
end

function ASC.Sound.SetCategoryVolume(category, volume)
    volume = math.Clamp(volume, 0, 1)
    
    if category == "weapons" then
        ASC.Sound.Config.WeaponVolume = volume
    elseif category == "engines" then
        ASC.Sound.Config.EngineVolume = volume
    elseif category == "ui" then
        ASC.Sound.Config.UIVolume = volume
    elseif category == "ai" then
        ASC.Sound.Config.AIVolume = volume
    end
end

-- Console commands
concommand.Add("asc_sound_test", function(player, cmd, args)
    if not IsValid(player) then return end
    
    local category = args[1] or "UI"
    local soundName = args[2] or "button_click"
    
    ASC.Sound.PlaySound(category, soundName, player)
    player:ChatPrint("[Advanced Space Combat] Playing sound: " .. category .. "." .. soundName)
end)

concommand.Add("asc_sound_volume", function(player, cmd, args)
    if not IsValid(player) then return end
    
    local category = args[1]
    local volume = tonumber(args[2])
    
    if not category or not volume then
        player:ChatPrint("[Advanced Space Combat] Usage: asc_sound_volume <category> <volume>")
        player:ChatPrint("Categories: master, weapons, engines, ui, ai")
        return
    end
    
    if category == "master" then
        ASC.Sound.SetMasterVolume(volume)
    else
        ASC.Sound.SetCategoryVolume(category, volume)
    end
    
    player:ChatPrint("[Advanced Space Combat] " .. category .. " volume set to " .. volume)
end)

-- Initialize sound system
hook.Add("Initialize", "ASC_SoundSystem", function()
    ASC.Sound.PrecacheSounds()
    print("[Advanced Space Combat] Sound System initialized with fallback support")
end)

print("[Advanced Space Combat] Sound System loaded successfully!")
