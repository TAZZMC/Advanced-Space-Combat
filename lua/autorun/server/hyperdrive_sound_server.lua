-- Hyperdrive Server-Side Sound System
-- Handles triggering client-side sounds from server events

if CLIENT then return end

HYPERDRIVE.ServerSounds = HYPERDRIVE.ServerSounds or {}

-- Send sound to all players in range
function HYPERDRIVE.ServerSounds.PlaySound(soundName, position, volume, pitch, range)
    volume = volume or 75
    pitch = pitch or 100
    range = range or 1500
    
    local recipients = {}
    
    if isvector(position) then
        -- Find players in range
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetPos():Distance(position) <= range then
                table.insert(recipients, ply)
            end
        end
    else
        -- Send to all players
        recipients = player.GetAll()
    end
    
    if #recipients > 0 then
        net.Start("hyperdrive_play_sound")
        net.WriteString(soundName)
        net.WriteVector(position or Vector(0,0,0))
        net.WriteFloat(volume)
        net.WriteFloat(pitch)
        net.Send(recipients)
    end
end

-- Send sound sequence (jump, charge, etc.)
function HYPERDRIVE.ServerSounds.PlaySequence(sequenceType, originPos, destinationPos, jumpType, entity)
    jumpType = jumpType or "standard"
    
    local recipients = {}
    local range = 2000
    
    -- Find players in range of origin
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():Distance(originPos) <= range then
            table.insert(recipients, ply)
        end
    end
    
    -- Also include players near destination for jump sequences
    if sequenceType == "jump" and destinationPos then
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetPos():Distance(destinationPos) <= range then
                if not table.HasValue(recipients, ply) then
                    table.insert(recipients, ply)
                end
            end
        end
    end
    
    if #recipients > 0 then
        net.Start("hyperdrive_play_sequence")
        net.WriteString(sequenceType)
        net.WriteVector(originPos)
        net.WriteVector(destinationPos or Vector(0,0,0))
        net.WriteString(jumpType)
        if IsValid(entity) then
            net.WriteEntity(entity)
        else
            net.WriteEntity(NULL)
        end
        net.Send(recipients)
    end
end

-- Send Stargate sequence sound
function HYPERDRIVE.ServerSounds.PlayStargateSequence(originPos, destinationPos)
    local recipients = {}
    local range = 2500 -- Larger range for dramatic effect
    
    -- Find players in range
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local dist1 = ply:GetPos():Distance(originPos)
            local dist2 = destinationPos and ply:GetPos():Distance(destinationPos) or math.huge
            if dist1 <= range or dist2 <= range then
                table.insert(recipients, ply)
            end
        end
    end
    
    if #recipients > 0 then
        net.Start("hyperdrive_stargate_sound")
        net.WriteVector(originPos)
        net.WriteVector(destinationPos or Vector(0,0,0))
        net.Send(recipients)
    end
end

-- Send beacon sound
function HYPERDRIVE.ServerSounds.PlayBeaconSound(soundType, entity, range)
    if not IsValid(entity) then return end
    
    range = range or 1000
    local recipients = {}
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():Distance(entity:GetPos()) <= range then
            table.insert(recipients, ply)
        end
    end
    
    if #recipients > 0 then
        net.Start("hyperdrive_beacon_sound")
        net.WriteString(soundType)
        net.WriteEntity(entity)
        net.Send(recipients)
    end
end

-- Send fleet sound
function HYPERDRIVE.ServerSounds.PlayFleetSound(soundType, position, range)
    range = range or 2000
    local recipients = {}
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():Distance(position) <= range then
            table.insert(recipients, ply)
        end
    end
    
    if #recipients > 0 then
        net.Start("hyperdrive_fleet_sound")
        net.WriteString(soundType)
        net.WriteVector(position)
        net.Send(recipients)
    end
end

-- Send ambient sound
function HYPERDRIVE.ServerSounds.PlayAmbientSound(entity, soundName, duration, range)
    if not IsValid(entity) then return end
    
    range = range or 1500
    duration = duration or 0
    local recipients = {}
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():Distance(entity:GetPos()) <= range then
            table.insert(recipients, ply)
        end
    end
    
    if #recipients > 0 then
        net.Start("hyperdrive_ambient_sound")
        net.WriteEntity(entity)
        net.WriteString(soundName or "hyperspace_ambient")
        net.WriteFloat(duration)
        net.Send(recipients)
    end
end

-- Stop sounds
function HYPERDRIVE.ServerSounds.StopSounds(entity, stopAll, range)
    range = range or 1500
    local recipients = {}
    
    if stopAll then
        recipients = player.GetAll()
    elseif IsValid(entity) then
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetPos():Distance(entity:GetPos()) <= range then
                table.insert(recipients, ply)
            end
        end
    end
    
    if #recipients > 0 then
        net.Start("hyperdrive_stop_sound")
        net.WriteEntity(entity or NULL)
        net.WriteBool(stopAll or false)
        net.Send(recipients)
    end
end

-- Convenience functions for common operations

-- Engine startup sound
function HYPERDRIVE.ServerSounds.EngineStartup(engine)
    if not IsValid(engine) then return end
    HYPERDRIVE.ServerSounds.PlaySequence("startup", engine:GetPos(), nil, "standard", engine)
end

-- Engine charging sound
function HYPERDRIVE.ServerSounds.EngineCharging(engine)
    if not IsValid(engine) then return end
    HYPERDRIVE.ServerSounds.PlaySequence("charge", engine:GetPos(), nil, "standard", engine)
end

-- Jump sequence sound
function HYPERDRIVE.ServerSounds.JumpSequence(engine, destination, jumpType)
    if not IsValid(engine) then return end
    jumpType = jumpType or "standard"
    HYPERDRIVE.ServerSounds.PlaySequence("jump", engine:GetPos(), destination, jumpType, engine)
end

-- Stargate jump sound
function HYPERDRIVE.ServerSounds.StargateJump(engine, destination)
    if not IsValid(engine) then return end
    HYPERDRIVE.ServerSounds.PlayStargateSequence(engine:GetPos(), destination)
end

-- Hyperspace ambient sound
function HYPERDRIVE.ServerSounds.HyperspaceAmbient(entity, duration)
    if not IsValid(entity) then return end
    duration = duration or 5.0
    HYPERDRIVE.ServerSounds.PlayAmbientSound(entity, "hyperspace_ambient", duration)
end

-- Beacon pulse sound
function HYPERDRIVE.ServerSounds.BeaconPulse(beacon)
    if not IsValid(beacon) then return end
    HYPERDRIVE.ServerSounds.PlayBeaconSound("pulse", beacon)
end

-- Fleet coordination sounds
function HYPERDRIVE.ServerSounds.FleetSync(position)
    HYPERDRIVE.ServerSounds.PlayFleetSound("sync", position)
end

function HYPERDRIVE.ServerSounds.FleetReady(position)
    HYPERDRIVE.ServerSounds.PlayFleetSound("ready", position)
end

function HYPERDRIVE.ServerSounds.FleetJump(position)
    HYPERDRIVE.ServerSounds.PlayFleetSound("jump", position)
end

-- Computer sounds
function HYPERDRIVE.ServerSounds.ComputerBeep(computer)
    if not IsValid(computer) then return end
    HYPERDRIVE.ServerSounds.PlaySound("computer_beep", computer:GetPos(), 60, 100, 500)
end

function HYPERDRIVE.ServerSounds.ComputerError(computer)
    if not IsValid(computer) then return end
    HYPERDRIVE.ServerSounds.PlaySound("computer_error", computer:GetPos(), 70, 100, 500)
end

function HYPERDRIVE.ServerSounds.ComputerConfirm(computer)
    if not IsValid(computer) then return end
    HYPERDRIVE.ServerSounds.PlaySound("computer_confirm", computer:GetPos(), 65, 100, 500)
end

-- Alert sounds
function HYPERDRIVE.ServerSounds.AlertWarning(entity)
    if not IsValid(entity) then return end
    HYPERDRIVE.ServerSounds.PlaySound("alert_warning", entity:GetPos(), 80, 100, 1000)
end

function HYPERDRIVE.ServerSounds.AlertCritical(entity)
    if not IsValid(entity) then return end
    HYPERDRIVE.ServerSounds.PlaySound("alert_critical", entity:GetPos(), 90, 100, 1500)
end

function HYPERDRIVE.ServerSounds.AlertSuccess(entity)
    if not IsValid(entity) then return end
    HYPERDRIVE.ServerSounds.PlaySound("alert_success", entity:GetPos(), 75, 100, 800)
end

print("[Hyperdrive] Server-side sound system loaded")
