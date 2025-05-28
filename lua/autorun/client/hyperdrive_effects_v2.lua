-- Hyperdrive Enhanced Visual Effects V2
-- This file provides advanced visual effects for the hyperdrive system

if SERVER then return end

-- Ensure HYPERDRIVE table exists first
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Effects = HYPERDRIVE.Effects or {}
HYPERDRIVE.Effects.Version = "2.0.0"

-- Enhanced effect configuration
HYPERDRIVE.Effects.Config = {
    -- Quality settings
    ParticleCount = 1.0, -- Multiplier for particle count
    EffectRange = 2000, -- Maximum effect visibility range
    LODSystem = true, -- Level of detail based on distance

    -- Advanced effects
    QuantumFluctuations = true,
    SpaceTimeDistortion = true,
    EnergyResonance = true,
    GravitationalWaves = true,

    -- Performance optimization
    MaxActiveEffects = 20,
    EffectCulling = true,
    DynamicQuality = true,

    -- Visual enhancements
    HDRLighting = true,
    VolumetricEffects = true,
    MotionBlur = true,
    ChromaticAberration = true
}

-- Advanced particle system
function HYPERDRIVE.Effects.CreateAdvancedParticles(pos, effectType, intensity, data)
    local emitter = ParticleEmitter(pos)
    if not emitter then return end

    intensity = intensity or 1.0
    data = data or {}

    -- Calculate LOD based on distance
    local ply = LocalPlayer()
    local distance = IsValid(ply) and ply:GetPos():Distance(pos) or 1000
    local lod = HYPERDRIVE.Effects.Config.LODSystem and math.max(0.1, 1 - (distance / HYPERDRIVE.Effects.Config.EffectRange)) or 1.0

    local particleCount = math.floor(intensity * lod * HYPERDRIVE.Effects.Config.ParticleCount)

    if effectType == "quantum_jump" then
        HYPERDRIVE.Effects.CreateQuantumJumpEffect(emitter, pos, particleCount, data)
    elseif effectType == "spacetime_distortion" then
        HYPERDRIVE.Effects.CreateSpaceTimeDistortion(emitter, pos, particleCount, data)
    elseif effectType == "energy_resonance" then
        HYPERDRIVE.Effects.CreateEnergyResonance(emitter, pos, particleCount, data)
    elseif effectType == "gravitational_waves" then
        HYPERDRIVE.Effects.CreateGravitationalWaves(emitter, pos, particleCount, data)
    end

    emitter:Finish()
end

-- Quantum jump effect with uncertainty principle
function HYPERDRIVE.Effects.CreateQuantumJumpEffect(emitter, pos, count, data)
    local efficiency = data.efficiency or 1.0
    local techLevel = data.techLevel or "tau_ri"

    -- Base quantum particles
    for i = 1, count * 2 do
        local particle = emitter:Add("effects/energyball", pos + VectorRand() * 100)
        if particle then
            -- Quantum uncertainty - particles appear and disappear randomly
            local uncertainty = math.random() * 0.5

            particle:SetVelocity(VectorRand() * (300 + uncertainty * 200))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 3) * efficiency)
            particle:SetStartAlpha(255 * (1 - uncertainty))
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(5, 15) * efficiency)
            particle:SetEndSize(math.Rand(20, 40) * efficiency)

            -- Technology-specific colors
            if techLevel == "ancient" then
                particle:SetColor(255, 215, 0) -- Gold
            elseif techLevel == "ori" then
                particle:SetColor(255, 100, 0) -- Orange
            elseif techLevel == "asgard" then
                particle:SetColor(100, 150, 255) -- Blue
            else
                particle:SetColor(150, 200, 255) -- Default blue-white
            end

            particle:SetGravity(Vector(0, 0, -50 * uncertainty))
            particle:SetAirResistance(20)

            -- Quantum tunneling effect
            if math.random() < 0.1 then
                particle:SetCollide(false)
                particle:SetBounce(0)
            end
        end
    end

    -- Quantum field fluctuations
    if HYPERDRIVE.Effects.Config.QuantumFluctuations then
        for i = 1, count do
            local particle = emitter:Add("effects/spark", pos + VectorRand() * 200)
            if particle then
                particle:SetVelocity(VectorRand() * 500)
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(0.5, 2))
                particle:SetStartAlpha(200)
                particle:SetEndAlpha(0)
                particle:SetStartSize(2)
                particle:SetEndSize(8)
                particle:SetColor(255, 255, 255)
                particle:SetGravity(Vector(0, 0, 0))
            end
        end
    end
end

-- Space-time distortion effect
function HYPERDRIVE.Effects.CreateSpaceTimeDistortion(emitter, pos, count, data)
    if not HYPERDRIVE.Effects.Config.SpaceTimeDistortion then return end

    local mass = data.mass or 1000
    local distortionStrength = math.log(mass / 1000 + 1) -- Logarithmic scaling

    -- Gravitational lensing particles
    for i = 1, count do
        local angle = (i / count) * 360 * 3 -- Multiple rings
        local radius = math.Rand(50, 150) * distortionStrength
        local height = math.sin(angle * math.pi / 180) * 30

        local particlePos = pos + Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            height
        )

        local particle = emitter:Add("effects/energyball", particlePos)
        if particle then
            -- Curved trajectory due to space-time curvature
            local curvature = Vector(
                -math.sin(math.rad(angle)) * 100,
                math.cos(math.rad(angle)) * 100,
                math.sin(CurTime() * 2 + i) * 50
            )

            particle:SetVelocity(curvature)
            particle:SetLifeTime(0)
            particle:SetDieTime(3 * distortionStrength)
            particle:SetStartAlpha(150)
            particle:SetEndAlpha(0)
            particle:SetStartSize(8)
            particle:SetEndSize(20)
            particle:SetColor(200, 150, 255) -- Purple for space-time
            particle:SetGravity(Vector(0, 0, -30))
            particle:SetAirResistance(40)
        end
    end
end

-- Energy resonance effect
function HYPERDRIVE.Effects.CreateEnergyResonance(emitter, pos, count, data)
    if not HYPERDRIVE.Effects.Config.EnergyResonance then return end

    local frequency = data.frequency or 1.0
    local amplitude = data.amplitude or 1.0

    -- Resonance waves
    for i = 1, count do
        local time = CurTime()
        local phase = (i / count) * 2 * math.pi
        local resonanceOffset = Vector(
            math.sin(time * frequency + phase) * amplitude * 50,
            math.cos(time * frequency + phase) * amplitude * 50,
            math.sin(time * frequency * 2 + phase) * amplitude * 25
        )

        local particle = emitter:Add("effects/energyball", pos + resonanceOffset)
        if particle then
            particle:SetVelocity(resonanceOffset * 2)
            particle:SetLifeTime(0)
            particle:SetDieTime(2)
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(6)
            particle:SetEndSize(18)
            particle:SetColor(255, 255, 100) -- Yellow for energy
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetAirResistance(30)
        end
    end
end

-- Gravitational wave effect
function HYPERDRIVE.Effects.CreateGravitationalWaves(emitter, pos, count, data)
    if not HYPERDRIVE.Effects.Config.GravitationalWaves then return end

    local waveSpeed = data.waveSpeed or 1000
    local waveAmplitude = data.waveAmplitude or 1.0

    -- Expanding gravitational waves
    for i = 1, count do
        local waveRadius = (CurTime() * waveSpeed) % 500
        local angle = (i / count) * 360

        local wavePos = pos + Vector(
            math.cos(math.rad(angle)) * waveRadius,
            math.sin(math.rad(angle)) * waveRadius,
            math.sin(waveRadius / 50) * waveAmplitude * 20
        )

        local particle = emitter:Add("effects/spark", wavePos)
        if particle then
            particle:SetVelocity(Vector(0, 0, 0))
            particle:SetLifeTime(0)
            particle:SetDieTime(0.5)
            particle:SetStartAlpha(100)
            particle:SetEndAlpha(0)
            particle:SetStartSize(3)
            particle:SetEndSize(1)
            particle:SetColor(150, 255, 150) -- Green for gravitational waves
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
end

-- Enhanced screen effects
function HYPERDRIVE.Effects.CreateScreenEffects(pos, effectType, intensity)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local distance = ply:GetPos():Distance(pos)
    local maxDistance = 2000
    local effectStrength = math.max(0, 1 - (distance / maxDistance)) * intensity

    if effectStrength <= 0 then return end

    -- Screen distortion
    if HYPERDRIVE.Effects.Config.SpaceTimeDistortion then
        local distortionData = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = effectStrength * 0.1,
            ["$pp_colour_brightness"] = effectStrength * 0.2,
            ["$pp_colour_contrast"] = 1 + effectStrength * 0.3,
            ["$pp_colour_colour"] = 1 - effectStrength * 0.2,
            ["$pp_colour_mulr"] = 1,
            ["$pp_colour_mulg"] = 1 - effectStrength * 0.1,
            ["$pp_colour_mulb"] = 1 + effectStrength * 0.2
        }

        DrawColorModify(distortionData)
    end

    -- Motion blur
    if HYPERDRIVE.Effects.Config.MotionBlur then
        DrawMotionBlur(effectStrength * 0.5, effectStrength * 0.8, 0.01)
    end

    -- Chromatic aberration
    if HYPERDRIVE.Effects.Config.ChromaticAberration then
        -- This would require a custom shader, simplified version:
        local aberrationStrength = effectStrength * 5
        util.ScreenShake(pos, aberrationStrength, 10, 0.5, maxDistance)
    end
end

-- Dynamic lighting system
function HYPERDRIVE.Effects.CreateDynamicLight(pos, effectType, intensity, duration)
    local dlight = DynamicLight(util.CRC(tostring(pos) .. effectType))
    if not dlight then return end

    dlight.pos = pos
    dlight.brightness = 10 * intensity
    dlight.size = 800 * intensity
    dlight.decay = 1000
    dlight.dietime = CurTime() + (duration or 2)

    -- Effect-specific lighting
    if effectType == "quantum_jump" then
        dlight.r = 150
        dlight.g = 200
        dlight.b = 255
    elseif effectType == "spacetime_distortion" then
        dlight.r = 200
        dlight.g = 150
        dlight.b = 255
    elseif effectType == "energy_resonance" then
        dlight.r = 255
        dlight.g = 255
        dlight.b = 100
    elseif effectType == "gravitational_waves" then
        dlight.r = 150
        dlight.g = 255
        dlight.b = 150
    end

    -- HDR lighting enhancement
    if HYPERDRIVE.Effects.Config.HDRLighting then
        dlight.brightness = dlight.brightness * 1.5
        dlight.size = dlight.size * 1.2
    end
end

-- Effect management system
HYPERDRIVE.Effects.ActiveEffects = {}

function HYPERDRIVE.Effects.RegisterEffect(id, pos, effectType, duration)
    HYPERDRIVE.Effects.ActiveEffects[id] = {
        pos = pos,
        effectType = effectType,
        startTime = CurTime(),
        duration = duration or 5,
        intensity = 1.0
    }

    -- Limit active effects for performance
    if #HYPERDRIVE.Effects.ActiveEffects > HYPERDRIVE.Effects.Config.MaxActiveEffects then
        -- Remove oldest effect
        local oldestId = nil
        local oldestTime = math.huge

        for effectId, effect in pairs(HYPERDRIVE.Effects.ActiveEffects) do
            if effect.startTime < oldestTime then
                oldestTime = effect.startTime
                oldestId = effectId
            end
        end

        if oldestId then
            HYPERDRIVE.Effects.ActiveEffects[oldestId] = nil
        end
    end
end

function HYPERDRIVE.Effects.UpdateEffects()
    local currentTime = CurTime()

    for id, effect in pairs(HYPERDRIVE.Effects.ActiveEffects) do
        local elapsed = currentTime - effect.startTime

        if elapsed >= effect.duration then
            HYPERDRIVE.Effects.ActiveEffects[id] = nil
        else
            -- Update effect intensity based on time
            local progress = elapsed / effect.duration
            effect.intensity = 1 - progress

            -- Create ongoing effects
            if effect.effectType == "energy_resonance" then
                HYPERDRIVE.Effects.CreateAdvancedParticles(effect.pos, effect.effectType, effect.intensity * 0.1)
            end
        end
    end
end

-- Hook for continuous effect updates
hook.Add("Think", "HyperdriveEffectsUpdate", function()
    HYPERDRIVE.Effects.UpdateEffects()
end)

-- Network message handlers for effects
net.Receive("hyperdrive_effect", function()
    local pos = net.ReadVector()
    local effectType = net.ReadString()
    local intensity = net.ReadFloat()
    local data = net.ReadTable()

    HYPERDRIVE.Effects.CreateAdvancedParticles(pos, effectType, intensity, data)
    HYPERDRIVE.Effects.CreateDynamicLight(pos, effectType, intensity)
    HYPERDRIVE.Effects.CreateScreenEffects(pos, effectType, intensity)

    -- Register for ongoing effects
    local effectId = util.CRC(tostring(pos) .. effectType .. CurTime())
    HYPERDRIVE.Effects.RegisterEffect(effectId, pos, effectType, 3)
end)

print("[Hyperdrive] Enhanced Effects V2 loaded")
