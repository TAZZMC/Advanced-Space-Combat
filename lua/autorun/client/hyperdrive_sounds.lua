-- Hyperdrive Sound System
if SERVER then return end

HYPERDRIVE.Sounds = HYPERDRIVE.Sounds or {}

-- Sound definitions
HYPERDRIVE.Sounds.Library = {
    -- Custom Hyperdrive sounds
    hyperspace_travel = "hyperdrive/ship_in_hyperspace.wav",
    hyperspace_ambient = "hyperdrive/ship_in_hyperspace.wav",

    -- Engine sounds
    engine_idle = "ambient/energy/electric_loop.wav",
    engine_startup = "ambient/energy/whiteflash.wav",
    engine_shutdown = "ambient/energy/zap1.wav",
    engine_hum = "ambient/energy/electric_loop.wav",

    -- Charging sounds
    charge_start = "ambient/energy/spark1.wav",
    charge_loop = "ambient/energy/electric_loop.wav",
    charge_buildup = "ambient/energy/whiteflash.wav",
    charge_complete = "ambient/energy/zap9.wav",

    -- Jump sounds
    jump_initiate = "ambient/energy/zap7.wav",
    jump_portal_open = "ambient/explosions/explode_4.wav",
    jump_travel = "hyperdrive/ship_in_hyperspace.wav", -- Use custom sound
    jump_arrival = "ambient/energy/zap9.wav",
    jump_abort = "ambient/energy/zap1.wav",

    -- Stargate 4-stage sounds
    sg_initiation = "ambient/energy/spark6.wav",
    sg_window_open = "ambient/energy/whiteflash.wav",
    sg_hyperspace = "hyperdrive/ship_in_hyperspace.wav", -- Use custom sound
    sg_exit = "ambient/energy/zap9.wav",

    -- Computer sounds
    computer_beep = "buttons/button15.wav",
    computer_error = "buttons/button10.wav",
    computer_confirm = "buttons/button9.wav",
    computer_startup = "ambient/energy/spark6.wav",
    computer_shutdown = "ambient/energy/zap1.wav",

    -- Alert sounds
    alert_warning = "ambient/alarms/warningbell1.wav",
    alert_critical = "ambient/alarms/klaxon1.wav",
    alert_success = "ambient/water/drip3.wav",
    alert_low_energy = "ambient/alarms/warningbell1.wav",

    -- Beacon sounds
    beacon_pulse = "ambient/energy/spark1.wav",
    beacon_activate = "ambient/energy/spark6.wav",
    beacon_deactivate = "ambient/energy/zap1.wav",

    -- Fleet sounds
    fleet_sync = "buttons/button9.wav",
    fleet_ready = "ambient/energy/zap9.wav",
    fleet_jump = "ambient/energy/whiteflash.wav"
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

function HYPERDRIVE.Sounds.PlayJumpSequence(originPos, destinationPos, jumpType)
    jumpType = jumpType or "standard"

    if jumpType == "stargate" then
        HYPERDRIVE.Sounds.PlayStargateSequence(originPos, destinationPos)
        return
    end

    -- Jump initiation
    HYPERDRIVE.Sounds.Play("jump_initiate", originPos, 90, 80)

    -- Portal opening
    timer.Simple(0.2, function()
        HYPERDRIVE.Sounds.Play("jump_portal_open", originPos, 100, 60)
    end)

    -- Travel sound with custom hyperspace audio
    timer.Simple(0.4, function()
        HYPERDRIVE.Sounds.Play("jump_travel", originPos, 80, 100)
    end)

    -- Arrival
    timer.Simple(2.0, function() -- Longer travel time for immersion
        HYPERDRIVE.Sounds.Play("jump_arrival", destinationPos, 85, 120)
    end)
end

-- New function for Stargate 4-stage travel
function HYPERDRIVE.Sounds.PlayStargateSequence(originPos, destinationPos)
    -- Stage 1: Initiation (3 seconds)
    HYPERDRIVE.Sounds.Play("sg_initiation", originPos, 85, 90)

    -- Stage 2: Window Opening (2 seconds)
    timer.Simple(3.0, function()
        HYPERDRIVE.Sounds.Play("sg_window_open", originPos, 95, 80)
    end)

    -- Stage 3: Hyperspace Travel (5 seconds)
    timer.Simple(5.0, function()
        local sound = HYPERDRIVE.Sounds.Create("sg_hyperspace", game.GetWorld(), 75, 100)
        if sound then
            sound:Play()
            -- Stop after hyperspace duration
            timer.Simple(5.0, function()
                sound:Stop()
            end)
        end
    end)

    -- Stage 4: Exit Stabilization (2 seconds)
    timer.Simple(10.0, function()
        HYPERDRIVE.Sounds.Play("sg_exit", destinationPos, 90, 110)
    end)
end

-- New function for hyperspace ambient sound
function HYPERDRIVE.Sounds.PlayHyperspaceAmbient(entity, duration)
    if not IsValid(entity) then return end

    local sound = HYPERDRIVE.Sounds.Create("hyperspace_ambient", entity, 60, 95)
    if sound then
        sound:Play()

        -- Stop after duration
        if duration then
            timer.Simple(duration, function()
                sound:Stop()
            end)
        end

        return sound
    end
end

function HYPERDRIVE.Sounds.PlayComputerSound(soundName, entity)
    local pos = IsValid(entity) and entity:GetPos() or nil
    HYPERDRIVE.Sounds.Play("computer_" .. soundName, pos, 60, 100)
end

function HYPERDRIVE.Sounds.PlayAlert(alertType, entity)
    local pos = IsValid(entity) and entity:GetPos() or nil
    HYPERDRIVE.Sounds.Play("alert_" .. alertType, pos, 80, 100)
end

-- New function for beacon sounds
function HYPERDRIVE.Sounds.PlayBeaconSound(soundType, entity)
    local pos = IsValid(entity) and entity:GetPos() or nil
    HYPERDRIVE.Sounds.Play("beacon_" .. soundType, pos, 70, 100)
end

-- New function for fleet coordination sounds
function HYPERDRIVE.Sounds.PlayFleetSound(soundType, position)
    HYPERDRIVE.Sounds.Play("fleet_" .. soundType, position, 75, 100)
end

-- Enhanced charge sequence with completion sound
function HYPERDRIVE.Sounds.PlayEnhancedChargeSequence(entity)
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

    -- Charge complete sound
    timer.Simple(chargeTime, function()
        if IsValid(entity) then
            HYPERDRIVE.Sounds.Play("charge_complete", entity:GetPos(), 80, 110)
        end
    end)
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

-- Network receivers for server-triggered sounds
net.Receive("hyperdrive_play_sound", function()
    local soundName = net.ReadString()
    local pos = net.ReadVector()
    local volume = net.ReadFloat()
    local pitch = net.ReadFloat()

    HYPERDRIVE.Sounds.Play(soundName, pos, volume, pitch)
end)

net.Receive("hyperdrive_play_sequence", function()
    local sequenceType = net.ReadString()
    local originPos = net.ReadVector()
    local destinationPos = net.ReadVector()
    local jumpType = net.ReadString()

    if sequenceType == "jump" then
        HYPERDRIVE.Sounds.PlayJumpSequence(originPos, destinationPos, jumpType)
    elseif sequenceType == "charge" then
        local entity = net.ReadEntity()
        if IsValid(entity) then
            HYPERDRIVE.Sounds.PlayEnhancedChargeSequence(entity)
        end
    elseif sequenceType == "startup" then
        local entity = net.ReadEntity()
        if IsValid(entity) then
            HYPERDRIVE.Sounds.PlayEngineStartup(entity)
        end
    end
end)

net.Receive("hyperdrive_stargate_sound", function()
    local originPos = net.ReadVector()
    local destinationPos = net.ReadVector()

    HYPERDRIVE.Sounds.PlayStargateSequence(originPos, destinationPos)
end)

net.Receive("hyperdrive_beacon_sound", function()
    local soundType = net.ReadString()
    local entity = net.ReadEntity()

    HYPERDRIVE.Sounds.PlayBeaconSound(soundType, entity)
end)

net.Receive("hyperdrive_fleet_sound", function()
    local soundType = net.ReadString()
    local position = net.ReadVector()

    HYPERDRIVE.Sounds.PlayFleetSound(soundType, position)
end)

net.Receive("hyperdrive_ambient_sound", function()
    local entity = net.ReadEntity()
    local soundName = net.ReadString()
    local duration = net.ReadFloat()

    if IsValid(entity) then
        if duration > 0 then
            HYPERDRIVE.Sounds.PlayHyperspaceAmbient(entity, duration)
        else
            HYPERDRIVE.Sounds.StartAmbient(entity, soundName, 60, 100)
        end
    end
end)

net.Receive("hyperdrive_stop_sound", function()
    local entity = net.ReadEntity()
    local stopAll = net.ReadBool()

    if stopAll then
        HYPERDRIVE.Sounds.StopAll()
    elseif IsValid(entity) then
        HYPERDRIVE.Sounds.StopAmbient(entity)
    end
end)

print("[Hyperdrive] Sound system loaded with " .. table.Count(HYPERDRIVE.Sounds.Library) .. " sounds")
