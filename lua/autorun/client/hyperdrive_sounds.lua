-- Hyperdrive Sound System
if SERVER then return end

HYPERDRIVE.Sounds = HYPERDRIVE.Sounds or {}

-- Sound definitions
HYPERDRIVE.Sounds.Library = {
    -- Engine sounds
    engine_idle = "ambient/energy/electric_loop.wav",
    engine_startup = "ambient/energy/whiteflash.wav",
    engine_shutdown = "ambient/energy/zap1.wav",

    -- Charging sounds
    charge_start = "ambient/energy/spark1.wav",
    charge_loop = "ambient/energy/electric_loop.wav",
    charge_buildup = "ambient/energy/whiteflash.wav",

    -- Jump sounds
    jump_initiate = "ambient/energy/zap7.wav",
    jump_portal_open = "ambient/explosions/explode_4.wav",
    jump_travel = "ambient/wind/wind_rooftop1.wav",
    jump_arrival = "ambient/energy/zap9.wav",

    -- Computer sounds
    computer_beep = "buttons/button15.wav",
    computer_error = "buttons/button10.wav",
    computer_confirm = "buttons/button9.wav",
    computer_startup = "ambient/energy/spark6.wav",

    -- Alert sounds
    alert_warning = "ambient/alarms/warningbell1.wav",
    alert_critical = "ambient/alarms/klaxon1.wav",
    alert_success = "ambient/water/drip3.wav"
}

-- Sound instances
HYPERDRIVE.Sounds.Active = {}

-- Create a sound instance
function HYPERDRIVE.Sounds.Create(soundName, entity, volume, pitch)
    local soundPath = HYPERDRIVE.Sounds.Library[soundName]
    if not soundPath then
        print("[Hyperdrive Sounds] Unknown sound: " .. tostring(soundName))
        return nil
    end

    local sound
    if IsValid(entity) then
        sound = CreateSound(entity, soundPath)
    else
        sound = CreateSound(game.GetWorld(), soundPath)
    end

    if sound then
        sound:SetSoundLevel(volume or 75)
        sound:ChangePitch(pitch or 100)

        -- Store reference
        local id = #HYPERDRIVE.Sounds.Active + 1
        HYPERDRIVE.Sounds.Active[id] = {
            sound = sound,
            name = soundName,
            entity = entity
        }

        return sound, id
    end

    return nil
end

-- Play a one-shot sound
function HYPERDRIVE.Sounds.Play(soundName, position, volume, pitch)
    local soundPath = HYPERDRIVE.Sounds.Library[soundName]
    if not soundPath then
        print("[Hyperdrive Sounds] Unknown sound: " .. tostring(soundName))
        return
    end

    if position and isvector(position) then
        sound.Play(soundPath, position, volume or 75, pitch or 100)
    else
        surface.PlaySound(soundPath)
    end
end

-- Stop a sound by ID
function HYPERDRIVE.Sounds.Stop(soundId)
    local soundData = HYPERDRIVE.Sounds.Active[soundId]
    if soundData and soundData.sound then
        soundData.sound:Stop()
        HYPERDRIVE.Sounds.Active[soundId] = nil
    end
end

-- Stop all sounds
function HYPERDRIVE.Sounds.StopAll()
    for id, soundData in pairs(HYPERDRIVE.Sounds.Active) do
        if soundData.sound then
            soundData.sound:Stop()
        end
    end
    HYPERDRIVE.Sounds.Active = {}
end

-- Clean up invalid sounds
function HYPERDRIVE.Sounds.Cleanup()
    for id, soundData in pairs(HYPERDRIVE.Sounds.Active) do
        if not IsValid(soundData.entity) then
            if soundData.sound then
                soundData.sound:Stop()
            end
            HYPERDRIVE.Sounds.Active[id] = nil
        end
    end
end

-- Enhanced sound effects for hyperdrive operations
function HYPERDRIVE.Sounds.PlayEngineStartup(entity)
    HYPERDRIVE.Sounds.Play("engine_startup", entity:GetPos(), 80, 90)

    timer.Simple(0.5, function()
        if IsValid(entity) then
            local sound = HYPERDRIVE.Sounds.Create("engine_idle", entity, 60, 95)
            if sound then
                sound:Play()
            end
        end
    end)
end

function HYPERDRIVE.Sounds.PlayChargeSequence(entity)
    -- Initial charge sound
    HYPERDRIVE.Sounds.Play("charge_start", entity:GetPos(), 70, 100)

    -- Buildup loop
    timer.Simple(0.3, function()
        if IsValid(entity) then
            local sound = HYPERDRIVE.Sounds.Create("charge_loop", entity, 65, 110)
            if sound then
                sound:Play()

                -- Stop after charge time
                local chargeTime = (HYPERDRIVE.Config and HYPERDRIVE.Config.JumpChargeTime) or 3
                timer.Simple(chargeTime - 0.5, function()
                    sound:Stop()
                end)
            end
        end
    end)

    -- Final buildup
    local chargeTime = (HYPERDRIVE.Config and HYPERDRIVE.Config.JumpChargeTime) or 3
    timer.Simple(chargeTime - 0.2, function()
        if IsValid(entity) then
            HYPERDRIVE.Sounds.Play("charge_buildup", entity:GetPos(), 85, 120)
        end
    end)
end

function HYPERDRIVE.Sounds.PlayJumpSequence(originPos, destinationPos)
    -- Jump initiation
    HYPERDRIVE.Sounds.Play("jump_initiate", originPos, 90, 80)

    -- Portal opening
    timer.Simple(0.2, function()
        HYPERDRIVE.Sounds.Play("jump_portal_open", originPos, 100, 60)
    end)

    -- Travel sound (brief)
    timer.Simple(0.4, function()
        HYPERDRIVE.Sounds.Play("jump_travel", originPos, 70, 150)
    end)

    -- Arrival
    timer.Simple(0.6, function()
        HYPERDRIVE.Sounds.Play("jump_arrival", destinationPos, 85, 120)
    end)
end

function HYPERDRIVE.Sounds.PlayComputerSound(soundName, entity)
    local pos = IsValid(entity) and entity:GetPos() or nil
    HYPERDRIVE.Sounds.Play("computer_" .. soundName, pos, 60, 100)
end

function HYPERDRIVE.Sounds.PlayAlert(alertType, entity)
    local pos = IsValid(entity) and entity:GetPos() or nil
    HYPERDRIVE.Sounds.Play("alert_" .. alertType, pos, 80, 100)
end

-- Ambient sound management
local ambientSounds = {}

function HYPERDRIVE.Sounds.StartAmbient(entity, soundName, volume, pitch)
    if not IsValid(entity) then return end

    local entIndex = entity:EntIndex()

    -- Stop existing ambient sound
    if ambientSounds[entIndex] then
        ambientSounds[entIndex]:Stop()
    end

    -- Create new ambient sound
    local sound = HYPERDRIVE.Sounds.Create(soundName, entity, volume, pitch)
    if sound then
        sound:Play()
        ambientSounds[entIndex] = sound
    end
end

function HYPERDRIVE.Sounds.StopAmbient(entity)
    if not IsValid(entity) then return end

    local entIndex = entity:EntIndex()
    if ambientSounds[entIndex] then
        ambientSounds[entIndex]:Stop()
        ambientSounds[entIndex] = nil
    end
end

-- Hook for entity removal
hook.Add("EntityRemoved", "HyperdriveSoundsCleanup", function(ent)
    if ent:GetClass() == "hyperdrive_engine" or ent:GetClass() == "hyperdrive_computer" then
        HYPERDRIVE.Sounds.StopAmbient(ent)
    end
end)

-- Periodic cleanup
timer.Create("HyperdriveSoundsCleanup", 30, 0, function()
    HYPERDRIVE.Sounds.Cleanup()
end)

-- Console commands for sound testing
concommand.Add("hyperdrive_test_sound", function(ply, cmd, args)
    if #args < 1 then
        ply:ChatPrint("[Hyperdrive] Usage: hyperdrive_test_sound <sound_name>")
        return
    end

    local soundName = args[1]
    HYPERDRIVE.Sounds.Play(soundName, ply:GetPos())
    ply:ChatPrint("[Hyperdrive] Playing sound: " .. soundName)
end)

concommand.Add("hyperdrive_list_sounds", function(ply, cmd, args)
    ply:ChatPrint("[Hyperdrive] Available sounds:")
    for name, path in pairs(HYPERDRIVE.Sounds.Library) do
        ply:ChatPrint("  • " .. name .. " (" .. path .. ")")
    end
end)

print("[Hyperdrive] Sound system loaded with " .. table.Count(HYPERDRIVE.Sounds.Library) .. " sounds")
