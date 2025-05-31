-- Enhanced Hyperdrive System - Sound System
-- Comprehensive sound integration for immersive experience

-- Initialize sound system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Sounds = HYPERDRIVE.Sounds or {}

-- Sound configuration
HYPERDRIVE.Sounds.Config = {
    Enabled = true,
    MasterVolume = 1.0,
    HyperdriveVolume = 0.8,
    ShieldVolume = 0.7,
    UIVolume = 0.6,
    EnvironmentVolume = 0.5,
    FadeTime = 2.0,
    MaxDistance = 2000,
    MinDistance = 100
}

-- Sound file definitions
HYPERDRIVE.Sounds.Files = {
    -- Hyperdrive sounds
    Hyperdrive = {
        InHyperspace = "hyperdrive/ship_in_hyperspace.wav",
        JumpInitiate = "buttons/button15.wav", -- Fallback until custom sound added
        JumpComplete = "buttons/button17.wav", -- Fallback until custom sound added
        EngineHum = "ambient/machines/machine1_hit1.wav", -- Fallback
        Charging = "ambient/energy/zap1.wav" -- Fallback
    },

    -- Shield sounds
    Shield = {
        Engage = "shield_engage.mp3",
        Disengage = "shield_disengage.mp3",
        Hit = "shield_hit.mp3",
        Recharge = "ambient/energy/newspark04.wav" -- Fallback
    },

    -- UI sounds
    UI = {
        Open = "buttons/button15.wav",
        Close = "buttons/button10.wav",
        Click = "buttons/button9.wav",
        Hover = "buttons/button24.wav",
        Error = "buttons/button11.wav",
        Success = "buttons/button17.wav",
        Warning = "buttons/button8.wav",
        Notification = "buttons/button14.wav"
    },

    -- Ship core sounds
    Core = {
        Activate = "buttons/button15.wav",
        Deactivate = "buttons/button10.wav",
        Emergency = "ambient/alarms/klaxon1.wav",
        Critical = "ambient/alarms/warningbell1.wav",
        StatusChange = "buttons/button14.wav"
    }
}

-- Sound instances for looping sounds
HYPERDRIVE.Sounds.Instances = {}

-- Load configuration from ConVars
local function LoadSoundConfig()
    local function SafeGetConVar(name, default, getFunc)
        local convar = GetConVar(name)
        if convar then
            return convar[getFunc](convar)
        end
        return default
    end

    HYPERDRIVE.Sounds.Config.Enabled = SafeGetConVar("hyperdrive_ui_sounds", true, "GetBool")
    HYPERDRIVE.Sounds.Config.MasterVolume = SafeGetConVar("hyperdrive_sound_volume", 1.0, "GetFloat")
    HYPERDRIVE.Sounds.Config.HyperdriveVolume = SafeGetConVar("hyperdrive_hyperdrive_volume", 0.8, "GetFloat")
    HYPERDRIVE.Sounds.Config.ShieldVolume = SafeGetConVar("hyperdrive_shield_volume", 0.7, "GetFloat")
    HYPERDRIVE.Sounds.Config.UIVolume = SafeGetConVar("hyperdrive_ui_volume", 0.6, "GetFloat")
end

-- Initialize sound system
function HYPERDRIVE.Sounds.Initialize()
    LoadSoundConfig()

    -- Precache all sound files
    for category, sounds in pairs(HYPERDRIVE.Sounds.Files) do
        for soundName, soundFile in pairs(sounds) do
            if file.Exists("sound/" .. soundFile, "GAME") then
                util.PrecacheSound(soundFile)
                print("[Hyperdrive Sounds] Precached: " .. soundFile)
            else
                print("[Hyperdrive Sounds] Warning: Sound file not found: " .. soundFile)
            end
        end
    end

    print("[Hyperdrive Sounds] Sound system initialized with " .. table.Count(HYPERDRIVE.Sounds.Files) .. " categories")
end

-- Play a sound with volume and distance control
function HYPERDRIVE.Sounds.PlaySound(category, soundName, entity, volume, pitch)
    if not HYPERDRIVE.Sounds.Config.Enabled then return end

    local soundFile = HYPERDRIVE.Sounds.Files[category] and HYPERDRIVE.Sounds.Files[category][soundName]
    if not soundFile then
        print("[Hyperdrive Sounds] Warning: Sound not found: " .. category .. "." .. soundName)
        return
    end

    -- Calculate volume
    local finalVolume = (volume or 1.0) * HYPERDRIVE.Sounds.Config.MasterVolume

    -- Apply category-specific volume
    if category == "Hyperdrive" then
        finalVolume = finalVolume * HYPERDRIVE.Sounds.Config.HyperdriveVolume
    elseif category == "Shield" then
        finalVolume = finalVolume * HYPERDRIVE.Sounds.Config.ShieldVolume
    elseif category == "UI" then
        finalVolume = finalVolume * HYPERDRIVE.Sounds.Config.UIVolume
    end

    -- Play sound
    if IsValid(entity) then
        -- 3D positioned sound
        entity:EmitSound(soundFile, 75, pitch or 100, finalVolume)
    else
        -- 2D UI sound
        surface.PlaySound(soundFile)
    end
end

-- Play looping sound
function HYPERDRIVE.Sounds.PlayLoopingSound(category, soundName, entity, volume, pitch, identifier)
    if not HYPERDRIVE.Sounds.Config.Enabled then return end
    if not IsValid(entity) then return end

    local soundFile = HYPERDRIVE.Sounds.Files[category] and HYPERDRIVE.Sounds.Files[category][soundName]
    if not soundFile then return end

    identifier = identifier or (category .. "_" .. soundName .. "_" .. entity:EntIndex())

    -- Stop existing instance
    HYPERDRIVE.Sounds.StopLoopingSound(identifier)

    -- Create new sound instance
    local sound = CreateSound(entity, soundFile)
    if sound then
        local finalVolume = (volume or 1.0) * HYPERDRIVE.Sounds.Config.MasterVolume

        if category == "Hyperdrive" then
            finalVolume = finalVolume * HYPERDRIVE.Sounds.Config.HyperdriveVolume
        elseif category == "Shield" then
            finalVolume = finalVolume * HYPERDRIVE.Sounds.Config.ShieldVolume
        end

        sound:SetSoundLevel(75)
        sound:PlayEx(finalVolume, pitch or 100)

        HYPERDRIVE.Sounds.Instances[identifier] = sound

        return identifier
    end
end

-- Stop looping sound
function HYPERDRIVE.Sounds.StopLoopingSound(identifier)
    local sound = HYPERDRIVE.Sounds.Instances[identifier]
    if sound then
        sound:Stop()
        HYPERDRIVE.Sounds.Instances[identifier] = nil
    end
end

-- Stop all looping sounds
function HYPERDRIVE.Sounds.StopAllLoopingSounds()
    for identifier, sound in pairs(HYPERDRIVE.Sounds.Instances) do
        if sound then
            sound:Stop()
        end
    end
    HYPERDRIVE.Sounds.Instances = {}
end

-- Fade sound volume
function HYPERDRIVE.Sounds.FadeSound(identifier, targetVolume, fadeTime)
    local sound = HYPERDRIVE.Sounds.Instances[identifier]
    if not sound then return end

    fadeTime = fadeTime or HYPERDRIVE.Sounds.Config.FadeTime

    -- Simple fade implementation
    local startTime = CurTime()
    local startVolume = 1.0 -- Current volume (simplified)

    local function UpdateFade()
        if not HYPERDRIVE.Sounds.Instances[identifier] then return end

        local elapsed = CurTime() - startTime
        local progress = math.min(elapsed / fadeTime, 1.0)
        local currentVolume = Lerp(progress, startVolume, targetVolume)

        -- Note: GMod's CreateSound doesn't have direct volume control during playback
        -- This is a simplified implementation

        if progress < 1.0 then
            timer.Simple(0.1, UpdateFade)
        end
    end

    UpdateFade()
end

-- Convenience functions for specific sound categories
HYPERDRIVE.Sounds.Hyperdrive = {
    PlayInHyperspace = function(entity, volume)
        return HYPERDRIVE.Sounds.PlayLoopingSound("Hyperdrive", "InHyperspace", entity, volume)
    end,

    PlayJumpInitiate = function(entity, volume)
        HYPERDRIVE.Sounds.PlaySound("Hyperdrive", "JumpInitiate", entity, volume)
    end,

    PlayJumpComplete = function(entity, volume)
        HYPERDRIVE.Sounds.PlaySound("Hyperdrive", "JumpComplete", entity, volume)
    end,

    PlayEngineHum = function(entity, volume)
        return HYPERDRIVE.Sounds.PlayLoopingSound("Hyperdrive", "EngineHum", entity, volume)
    end,

    PlayCharging = function(entity, volume)
        return HYPERDRIVE.Sounds.PlayLoopingSound("Hyperdrive", "Charging", entity, volume)
    end
}

HYPERDRIVE.Sounds.Shield = {
    PlayEngage = function(entity, volume)
        HYPERDRIVE.Sounds.PlaySound("Shield", "Engage", entity, volume)
    end,

    PlayDisengage = function(entity, volume)
        HYPERDRIVE.Sounds.PlaySound("Shield", "Disengage", entity, volume)
    end,

    PlayHit = function(entity, volume)
        HYPERDRIVE.Sounds.PlaySound("Shield", "Hit", entity, volume)
    end,

    PlayRecharge = function(entity, volume)
        return HYPERDRIVE.Sounds.PlayLoopingSound("Shield", "Recharge", entity, volume)
    end
}

HYPERDRIVE.Sounds.UI = {
    PlayOpen = function() HYPERDRIVE.Sounds.PlaySound("UI", "Open") end,
    PlayClose = function() HYPERDRIVE.Sounds.PlaySound("UI", "Close") end,
    PlayClick = function() HYPERDRIVE.Sounds.PlaySound("UI", "Click") end,
    PlayHover = function() HYPERDRIVE.Sounds.PlaySound("UI", "Hover") end,
    PlayError = function() HYPERDRIVE.Sounds.PlaySound("UI", "Error") end,
    PlaySuccess = function() HYPERDRIVE.Sounds.PlaySound("UI", "Success") end,
    PlayWarning = function() HYPERDRIVE.Sounds.PlaySound("UI", "Warning") end,
    PlayNotification = function() HYPERDRIVE.Sounds.PlaySound("UI", "Notification") end
}

HYPERDRIVE.Sounds.Core = {
    PlayActivate = function(entity, volume)
        HYPERDRIVE.Sounds.PlaySound("Core", "Activate", entity, volume)
    end,

    PlayDeactivate = function(entity, volume)
        HYPERDRIVE.Sounds.PlaySound("Core", "Deactivate", entity, volume)
    end,

    PlayEmergency = function(entity, volume)
        return HYPERDRIVE.Sounds.PlayLoopingSound("Core", "Emergency", entity, volume)
    end,

    PlayCritical = function(entity, volume)
        return HYPERDRIVE.Sounds.PlayLoopingSound("Core", "Critical", entity, volume)
    end,

    PlayStatusChange = function(entity, volume)
        HYPERDRIVE.Sounds.PlaySound("Core", "StatusChange", entity, volume)
    end
}

-- ConVar change callbacks for sound settings
cvars.AddChangeCallback("hyperdrive_ui_sounds", function(name, old, new)
    HYPERDRIVE.Sounds.Config.Enabled = tobool(new)
    if not HYPERDRIVE.Sounds.Config.Enabled then
        HYPERDRIVE.Sounds.StopAllLoopingSounds()
    end
end)

-- Initialize when client loads
hook.Add("InitPostEntity", "HyperdriveSoundInit", function()
    timer.Simple(1, function()
        HYPERDRIVE.Sounds.Initialize()
    end)
end)

-- Network receiver for server-triggered sounds
net.Receive("hyperdrive_play_sound", function()
    local category = net.ReadString()
    local soundName = net.ReadString()
    local entity = net.ReadEntity()

    HYPERDRIVE.Sounds.PlaySound(category, soundName, entity)
end)

-- Cleanup on disconnect
hook.Add("ShutDown", "HyperdriveSoundCleanup", function()
    HYPERDRIVE.Sounds.StopAllLoopingSounds()
end)

print("[Hyperdrive] Sound system loaded successfully!")
